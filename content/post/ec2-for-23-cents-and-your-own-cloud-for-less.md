+++
title = "EC2 for 23 Cents and Your Own Cloud for Less"
Tags = ["aws"]
Description = ""
Categories = []
date = "2013-09-15T16:05:53-05:00"
aliases = ["/ec2-for-23-cents-and-your-own-cloud-for-less"]

+++

<img src="http://i.imgur.com/4Jy6ikM.png" width="600"></img>

Last week, I reorganized my various desks, computers, keyboards, binary clocks, and comfy blankets in a home improvement frenzy. During this effort, I was forced to confront the two external hard drives collecting dust on my desk, the remnants of an abortive attempt to get a reasonable backup solution in place for my critical data about a year ago. The combination of sweat, technology, and <a href="http://www.youtube.com/watch?v=CjY_uSSncQw">Pat Benatar blasting in the background</a> was sufficient to kickstart a few weekend infrastructure projects.

## Cheap cloud storage with BitTorrent Sync and ownCloud

Two days after the initial cleaning frenzy, a new Raspberry Pi showed up at my door ready to be turned into an always-on Internet-facing file server. After installing <a href="http://www.raspbian.org">Raspbian</a> and following <a href="http://blog.bittorrent.com/2013/05/23/how-i-created-my-own-personal-cloud-using-bittorrent-sync-owncloud-and-raspberry-pi/">the instructions in this great blog post</a>, I had BTSync and ownCloud up and running. The linked post covers how to set it up yourself, so I'm going to talk about the problems I had along the way, as well as how pleased I am with the final result.

<img class="alignnone" alt="" src="http://i.imgur.com/mXqBXXo.png" width="614" height="237" />

I fell in love with <a href="http://labs.bittorrent.com/experiments/sync.html">BTSync</a> almost immediately. It is extremely simple to set up: you install a single binary, make it run on startup, and then do about 60 seconds worth of config in a barebones web app. I now have instances running on my Pi, my MacBook, my Ubuntu desktop, and an EC2 server for extra durability on my smaller but more critical documents. Installation of BTSync itself was easy on all of these platforms. Sync speed seems to max out my connection between all nodes except for the Pi, whose processor can only handle about 1 MBps of data transfer. The iOS app also has an option to back up all of your photos and videos to a specified folder. BTSync is a pretty new product, but it's already pretty useful and I can't wait to see what sort of improvements they make going forward.

<img class="alignnone" alt="" src="http://i.imgur.com/2HfwO5F.png" width="416" height="253" />

If you only want to do wholesale syncs of your folders, you'd probably be happy with just BTSync. Adding <a href="http://owncloud.org">ownCloud</a> makes it much easier to download and upload individual files within large folders. This is very helpful for use cases like dealing with a few hundred gigabytes of video files. ownCloud takes significantly more effort to set up, and once you're finished with the install you'll be running a MySQL-backed PHP app on top of Apache or nginx. All of this makes the Pi's 700MHz processor quite sad, and performance is not great. Some questionable decisions by the ownCloud maintainers (not only serving static files through PHP, but minifying them at runtime!) contribute to the speed issues. You can expect about 3-5 seconds per page load, but downloads and uploads seem to work reasonably well once you find files you want. I also ran into a bug that was preventing ownCloud from seeing symbolically linked folders, but was able to solve this by manually navigating to where the folder *should* have been in the file system.

I'm happy with my storage setup now, though I somewhat regret choosing a Pi for the task. It definitely works, but there are some rough edges and initial sync takes a very long time. I might try using a Chromebox or ~$200 PC if I do this again and have the budget for it.

## Let EC2 (almost) pay for itself with gitolite

<img class="alignnone" alt="" src="http://i.imgur.com/XZorzvQ.png" width="722" height="76" />

I love GitHub. Can we get that out of the way? <a href="http://octodex.github.com/">GitHub is awesome</a>. I currently pay GitHub $7 a month to host up to 5 private repositories so I can work on private side projects without exposing the code to the world. If you're like me, you can start using <a href="https://github.com/sitaramc/gitolite">gitolite</a> for 23 cents more than you're paying GitHub each month and have a dedicated t1.micro to play around with to boot. My micro's currently running this blog and some scrapers in addition to gitolite.

I was able to install gitolite on my existing server and migrate my private repositories off of GitHub in a total of about 15 minutes. Getting the basics going with gitolite was easy, and the user management seems sophisticated enough to easily allow collaborators should you want to add people to your projects without having to go back to paying GitHub.

Note that for this to make economic sense, you'll need to pay Amazon a fair bit upfront for a heavy utilization reserved instance. Using a t1.micro, a 3 year reservation is $100, with an hourly rate of $0.005 after that. You also need to tack on $0.80 a month for an 8 GB EBS volume. Total monthly cost amortized over three years is $7.23 for your t1.micro and $7.00 for the GitHub plan. To recap, you get unlimited private Git hosting and a dedicated t1.micro for an additional 23 cents per month. What's not to love here? Go forth and Git!
