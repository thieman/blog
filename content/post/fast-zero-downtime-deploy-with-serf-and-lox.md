+++
date = "2014-07-20T16:24:15-05:00"
title = "Fast, Zero-Downtime Deploy with Serf and Lox"
Categories = ["aws", "serf", "deploy"]
Tags = []
Description = ""
aliases = ["/fast-zero-downtime-deploy-with-serf-and-lox"]

+++

![](http://i.imgur.com/0UgPwSv.png)

I recently had the opportunity to revamp our deploy pipeline at [GameChanger](http://gc.com), my wonderful employer. The result is a system that is robust, doesn't drop a single request during a deploy, and takes the same amount of time whether we're running ten instances or a thousand.

We achieved this using [Serf](http://serfdom.io), which provides a decentralized way to monitor cluster membership and trigger deploy events, and [Lox](http://gamechanger.github.io/lox), a simple Redis-backed service that helps us manage distributed locks across our cluster.

## Serf: Non-awful deploy triggering

The tests are passing and it's time to deploy a new version of your application. You've got a git tag all dressed up and ready to go, but now you need to somehow tell your production boxes to go get the new code. How do you do it? We've got a few obvious options that we as developers use every day to send messages to remote machines:

1. SSH to all the servers <img src="http://i.imgur.com/EJMcYTL.png" alt="" title="" style="display: inline-block;">
1. Send HTTP requests to services running on all the servers! <img src="http://i.imgur.com/EJMcYTL.png" alt="" title="" style="display: inline-block;"><img src="http://i.imgur.com/EJMcYTL.png" alt="" title="" style="display: inline-block;">
1. Do anything else that requires you to connect to **ALL THE SERVERS!** <img src="http://i.imgur.com/EJMcYTL.png" alt="" title="" style="display: inline-block;"><img src="http://i.imgur.com/EJMcYTL.png" alt="" title="" style="display: inline-block;"><img src="http://i.imgur.com/EJMcYTL.png" alt="" title="" style="display: inline-block;">

These are not great solutions. SSH is slow so it doesn't scale very well. The second idea requires you to roll your own specialized deploy service. All three of these can easily be interrupted halfway through your deploy or fail on a subset of your servers due to network partitions, Time Warner internet, or a kaiju attack in northern Virginia.

Enter [Serf](http://serfdom.io). We run Serf as a service on all our instances and use it to quickly, securely, and robustly propagate deploy messages through our entire cluster. You should read the documentation to get a full idea of what Serf can do for you, but for our purposes we get the following functionality:

* [Fast](http://www.serfdom.io/docs/internals/simulator.html) and partition-tolerant propagation of messages through our cluster via a [gossip protocol](http://www.serfdom.io/docs/internals/gossip.html)
* [Event handlers](http://www.serfdom.io/docs/agent/event-handlers.html) that run scripts in response to certain [events](http://www.serfdom.io/docs/commands/event.html) (in our case, we run a deploy script when we receive a deploy message)
* Insights into [cluster membership](http://www.serfdom.io/docs/commands/members.html). Every box knows about all the other boxes in the cluster and their roles

Here's a somewhat simplified look at how Serf's message propogation works and how we can send a message from one server and have that message eventually reach other servers that our originator doesn't know about.

![](http://i.imgur.com/SkKJvJp.png)

With Serf in the picture, it's now fast and easy for us to send a message to all of our servers. We simply SSH into a single box running in the cluster and send a Serf message from that box. [Within seconds](http://www.serfdom.io/docs/internals/simulator.html), every instance running in the cluster will start their deploy. We'll use the cluster membership functionality too in just a bit.

## Coordinated Deploys with Lox

You may have caught a slight problem in that last paragraph: all the servers will start their deploy at the same time. This will probably take down your website. What we would really like is for our servers to take turns so that we never have a full service interruption. We also want the deploy to remain fast. If we only have 2 instances online, only 1 should deploy at a time. If we have 1000 instances, we can have 500 deploy at a time and deploy just as quickly as when we were only running 2 instances, giving us a consistent deploy time.

<img src="http://gamechanger.github.io/lox/images/logo.png" alt="" style="width: 150px;">

We built [Lox](http://gamechanger.github.io/lox) to help us do this. Lox gives us a way to manage a distributed deploy lock across multiple servers. Lox gives our servers a way to take turns during a deploy, and it also uses client-driven concurrent lock constraints to allow each group of servers to determine the speed at which they deploy. These constraints can also change in the middle of a deploy, so deploy stays fast even if you scale up in the middle of one.

Let's run through a simple example where we have two "web" boxes running in our production environment. These both receive a deploy message from Serf at the same time and start their deploy process. This begins with a `POST` request to Lox that looks like this:

```
POST /lock
  - key: deploy.web.production
  - maximumLocks: 1
  - ttlSeconds: 60
```

Let's break this down. For more detailed information, you can refer to Lox's [documentation](https://gamechanger.github.io/lox/docs/api.html).

* `POST /lock` is the endpoint for acquiring a lock
* `key` is a shared identifier common to all instances of a given type. We want all the production web boxes to use the same distributed lock.
* `maximumLocks` lets Lox know that it should refuse to grant us a lock if doing so would cause more than this number of locks to be acquired in total
* `ttlSeconds` lets Lox know to release our lock after 60 seconds have passed. This is important to prevent deadlocks if an instance dies while it has a lock.

If our two web servers simultaneously send these requests, one will be granted a lock for 60 seconds or until explicitly released. This server gets this response:

```
201 CREATED
{lockId: "some-automatically-generated-uuid"}
```

The other web server will not be granted a lock since now there is already 1 lock granted and this server passed `maximumLocks=1` in its request. This server gets this response:

```
204 NO CONTENT
```

Notice how the client has to specify `maximumLocks` with each lock acquisition request it makes. This allows the speed of the deploy to change dynamically with the size of our cluster. Lox compares the number of currently held locks on `key` with the `maximumLocks` that's passed with the request. In our example, we passed `maximumLocks=1`, so Lox will refuse to grant a lock to this request if 1 or more locks are already held on the `deploy.web.production` key. How do we come up with the right `maximumLocks` number so that our deploy is fast but we never deploy all our servers at the same time?

Each server recalculates `maximumLocks` every time it tries to acquire a deploy lock. This is where Serf's cluster membership info is useful. When a server gets a message to deploy, we also pass it a concurrency variable letting it know what percentage of its sibling servers should be allowed to deploy at a time. In our example, our web servers each know using Serf that there are 2 total web servers. If we pass a concurrency variable of 0.5, they'll both pass `maximumLocks=1` in their lock requests. If more web servers join the cluster, their presence will be recorded in Serf and each web server will adjust its `maximumLocks` accordingly the next time it tries to acquire the lock.

Using Lox and the cluster membership information provided from Serf, our servers can all take turns deploying with other servers of their same type. This works even though we triggered the deploy on all our boxes simultaneously through a Serf event.

## Go Forth and Deploy Code

That's it! You can layer [Serf](http://serfdom.io) and [Lox](http://gamechanger.github.io/lox) on top of your existing deploy infrastructure to facilitate a consistently fast deploy that doesn't sacrifice availability. To recap:

* Serf provides a decentralized way to trigger deploy events and know which servers you have live in your cluster at any given time
* Lox lets your servers take turns deploying in a consistently fast way that scales with your cluster size, even if it changes in the middle of a deploy

If you have questions, you can reach me on [Twitter](https://twitter.com/thieman) or in the [Lox bug tracker](https://github.com/gamechanger/lox/issues) if you have a question specific to Lox. Pull requests welcome!
