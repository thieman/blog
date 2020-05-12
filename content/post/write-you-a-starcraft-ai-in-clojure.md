+++
Tags = ["clojure", "starcraft"]
Description = ""
date = "2014-01-15T16:09:43-05:00"
title = "Write You a StarCraft AI in Clojure"
Categories = []
aliases = ["/write-you-a-starcraft-ai-in-clojure"]

+++

![Imgur](https://i.imgur.com/30gTwDW.png)

<a href="https://github.com/thieman/korhal">Korhal</a> is a StarCraft: Brood War Terran AI written entirely in Clojure. Current capabilities include unit-level micro routines like marine kiting and worker mineral walking, rote build order execution (9 depot, 11 barracks, etc), and a strategy engine to keep track of what the AI knows about its opponent. It probably won't beat anyone in a game right now, but it knows some neat tricks.

<iframe width="420" height="315" src="//www.youtube.com/embed/opuMbeqU0TI" frameborder="0" allowfullscreen></iframe>

&nbsp;

Korhal bundles a Clojure API to Brood War that can be used to write AIs for any race. To get started, check out the wiki's <a href="https://github.com/thieman/korhal/wiki/VM-Setup">setup page</a>. A <a href="https://github.com/thieman/korhal-starter">slightly-out-of-date starter project</a> is also provided which executes <a href="https://github.com/thieman/korhal-starter/blob/master/src/korhal/core.clj#L47">a very simple 6 pool zergling rush</a>.

## Let's See Some Code

The Clojure API provides a high-level interface to a nearly-complete set of BWAPI instructions. Here are a few simple examples. Every function here, with the exception of <code>can-afford?</code>, is provided out of the box:

```
;; mine with idle SCVs
(doseq [scv (filter idle? (my-scvs))]
  (let [dist-to-scv (fn [mineral] (dist scv mineral))
        closest-mineral (apply min-key dist-to-scv (minerals))]
    (right-click scv closest-mineral)))

;; build a spawning pool next to your hatchery
(when (and (can-afford? :spawning-pool)
            (zero? (count (my-spawning-pools))))
   (let [drone (first (filter completed? (my-drones)))
         hatchery (first (my-hatcheries))
         tx (+ 5 (tile-x hatchery))
         ty (tile-y hatchery)]
     (build drone tx ty :spawning-pool)))

;; move out of psi storm
(when (and (under-storm? unit) (not (moving? unit)))
  (move unit (- (pixel-x unit) 100) (- (pixel-y unit) 100)))))
```

In addition to direct commands to Brood War, Korhal provides some tooling to assist with more complex AI operations. One such tool is <a href="https://github.com/thieman/korhal/blob/master/src/korhal/tools/contract.clj">the contracts system</a>, which provides a way to keep track of what the AI has committed to spend during each run of the AI engines (hence why <code>can-afford?</code> is custom). Contracts also help with retrying buildings; if your worker gets blown up en route to build a supply depot, contracts still knows about the failed build command so you can execute it with a new worker. Some game logic (like contracted expenditures) must be brought into the AI this way so that you are not fully dependent on the <code>gameUpdate</code> loop for critical information like the amount of resources you have available.

## The Clojure API

Korhal bundles a port of <a href="https://code.google.com/p/jnibwapi/">JNIBWAPI</a>, a Java interface to <a href="https://code.google.com/p/bwapi/">BWAPI</a>. All of the interop code can be found <a href="https://github.com/thieman/korhal/tree/master/src/korhal/interop">in these two files</a>. There are also more extensive <a href="https://github.com/thieman/korhal/wiki/The-Clojure-API">notes on the API in the wiki</a>. The Clojure API allows the end user to bypass writing Java interop code entirely. While it is very useful that Clojure can easily call Java (this project would not be possible otherwise), I find that doing so does not feel very Clojurific. The API also allows the AI logic to worry less about the exact types it's operating on, which is useful if the library you're porting made some, er, questionable naming decisions:

```
;; use tile-x and let the API figure out the Java nonsense
(defn tile-x [obj]
  (if (instance? BaseLocation obj)
    (.getTx obj)
    (.getTileX obj)))
```

The API is created mostly by running <a href="https://github.com/thieman/korhal/blob/master/src/korhal/interop/interop.clj#L46">a series of function-generating macros</a> on <a href="https://github.com/thieman/korhal/blob/master/src/korhal/interop/interop_types.clj">giant lists of Clojure names and Java types</a>. More complex functions are defined in <code>interop.clj</code> and then imported through the rest of the project. This approach minimizes the amount of boilerplate code you have to write but is quite hacky. The result is two giant files that contain all of the Clojure API functions. I would gladly entertain alternative approaches to porting a large Java API without imposing types on the Clojure end-user, since this is very much a quick-and-dirty approach.

## Concurrent AI Design
Clojure makes <a href="https://clojure.org/concurrent_programming">concurrent programming</a> very simple using its included reference types. Korhal maintains an instance of JNIBWAPI in one thread that is responsible for all communication between Brood War and the AI. All of the actual AI logic is encapsulated in various engines (macro, micro, and strategy) that run in their own threads. These engines communicate information between themselves and the main thread in a thread-safe way using reference types.

When an engine wants to execute a command in the game, it inserts a <a href="https://en.wikipedia.org/wiki/Thunk_(functional_programming)">thunk</a> into an execution queue maintained in an atom, a Clojure reference type that manages shared, synchronous state. This is done by wrapping your command using the <code>with-api</code> macro. On each <code>gameUpdate</code> iteration, the main thread executes whatever thunks are in that queue.

Here's some code that the micro engine uses to stim marines. On each iteration of the engine, it runs combat functions on every unit currently fighting. It can call <code>micro-combat-stim</code> on a marine, and if the marine should stim now, it queues a closure to stim the marine during the next <code>gameUpdate</code> loop.

```
;; the with-api block is invoked during the next gameUpdate loop
(defn micro-combat-stim [unit]
  (when (and (or (is-marine? unit) (is-firebat? unit))
             (>= (health-perc unit) 0.5)
             (researched? :stim-packs)
             (not (stimmed? unit)))
    (with-api
      (when-not (stimmed? unit)
        (use-tech unit (tech-type-kws :stim-packs))))))

;; the macro itself is quite simple
(defmacro with-api [& body]
  `(do (swap! api-command conj (fn [] (do ~@body)))))
```

You can see the various queue options used by Korhal in <a href="https://github.com/thieman/korhal/blob/master/src/korhal/tools/queue.clj">the korhal.tools.queue module</a>. Additional macros provide for actions that are repeated every N frames or only execute if an expression evaluates to True at runtime.

## Fork It!

Those are the basics. If you'd like to write your own AI or contribute to making Korhal better, <a href="https://github.com/thieman/korhal">head over to GitHub and fork it</a>. This is by far the most fun project I've worked on and I'd love to see what other work comes out of it, so <a href="https://twitter.com/thieman">get at me on Twitter</a> if you've got any questions or want to share cool new stuff.

This project would not be possible without <a href="https://code.google.com/p/bwapi/">BWAPI</a> and <a href="https://code.google.com/p/jnibwapi/">JNIBWAPI</a>. Special thanks to everyone at <a href="https://www.hackerschool.com/">Hacker School</a>, particularly <a href="https://github.com/zachallaun">Zach Allaun</a>, <a href="https://webyrd.net/">Will Byrd</a>, and <a href="https://github.com/Apophenia">Lyndsey M</a>.

<iframe width="420" height="315" src="//www.youtube.com/embed/dLX-cETVdyM" frameborder="0" allowfullscreen></iframe>

<iframe width="420" height="315" src="//www.youtube.com/embed/qYkhnUEt310" frameborder="0" allowfullscreen></iframe>

<iframe width="420" height="315" src="//www.youtube.com/embed/LnIq5zx1jqw" frameborder="0" allowfullscreen></iframe>
