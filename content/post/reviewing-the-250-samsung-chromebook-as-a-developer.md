+++
Categories = []
Tags = ["chromebook", "hardware", "review"]
Description = ""
date = "2013-03-04T14:24:26-05:00"
title = "Reviewing the $250 Samsung Chromebook as a Developer"
aliases = ["/reviewing-the-250-samsung-chromebook-as-a-developer"]

+++

![Imgur](https://i.imgur.com/mhJryL0.png)

The [Samsung ARM Chromebook](https://www.samsung.com/us/computer/chrome-os-devices/XE303C12-A01US) (hereafter just "Chromebook") is an excellent little machine for casual web usage. The mouse and keyboard will be very familiar to Mac users, and the monitor is pretty sharp when viewed head-on. There are some rough edges in the OS itself, such as lack of power management options, but browser performance is much better than I expected from a $250 device. However, putting on my developer hat and running Ubuntu on top of Chrome OS revealed additional problems, some of them major (external monitor support is technically in beta but performs more like an alpha).

I really like this machine and think it has huge potential if Google and Samsung can iron out the hardware problems. Buy now if you only want Chrome OS, but wait for additional updates fixing hardware bugs before buying as a development machine.

## Full Review

I recently bought a Chromebook after reading <a href="https://news.ycombinator.com/item?id=5294251">this post on Hacker News</a> about running Ubuntu on one using chroot. Here's what I've found after a few days of using one.

A comprehensive review must examine the Chromebook in the two ways in which it can be used: first, with the stock Chrome OS as Google intends it to be used by the average user, and second as a full-blown Linux machine. I'll also discuss the hardware itself.

## The Hardware

<img class="alignnone" alt="" src="https://www.google.com/intl/en/chrome/assets/common/images/devices/samsung-chromebook/ss-cb-promolanding-carousel-1.jpg" width="433" height="298" />

The Chromebook looks like a Macbook Air on a budget. The keyboard isn't backlit, the bezel on the screen is larger than the Air's, and the hinge is ugly compared to the Air's seamless presentation. The screen only comes in a matte version. There is a bit of give underneath the trackpad, and forceful clicks will bend the front of the machine if it's not properly supported. The increase volume button is perilously close to the power button, as on the Air, but the power button won't shut anything down unless you hold it for a few seconds.

Having harped on the negative for a bit, the Chromebook is actually quite pleasant to use. The feel of the keyboard is very similar to the Mac equivalent, and I am easily able to attain 100+ words per minute on it after only having used it for a few days. The touchpad supports basic multitouch for scrolling and also has an option to reverse the scrolling direction if you're one of those natural scrolling people (like me!). The keyboard has dedicated volume and brightness keys but lacks media player buttons. The monitor is bright enough to use in very well-lit environments, and I generally don't have to keep it at full brightness in my apartment. Battery life seems to be quite good and possibly even better than the quoted 6.5 hours under light web usage. The whole thing of course runs silently (no fans) and stays pretty cool so it's comfortable to use on your lap.

Most of the other hardware components are functional but are more lacking in quality. The camera and microphone are there but pick up poor sound quality and low frame rates (around 5 or so frames per second, I'd estimate). I was actually able to bottom out the speakers while listening to a speech-only video, so forget listening to music of any quality on them. The Chromebook also has two USB ports, an SD card slot, and Bluetooth, but I didn't really have an opportunity to use any of them. I've heard Bluetooth support may be non-existent or buggy at this point, though, so research that further if that is important to you.

There are two major problems I've encountered so far with getting the hardware to work properly. First, the Wi-Fi seems very picky with certain routers. Of the three I've tested it on so far, two of them initially reject the connection with a DHCP error and only connect after a few minutes of coaxing and reconnecting. I suppose it's possible that the issue is with the routers themselves, but they've had no issues with my PC, multiple Macbooks, multiple iPads, and a Raspberry Pi running a tiny $14 Wi-Fi card. This seems to be hit or miss, but it'd be very irritating if your only router had this problem. The whole "starts up in seconds" benefit of this model would be pretty much lost to you.

<img src="https://imgur.com/lAUTyIz.jpg" width="434" height="270" />

The other major hardware problem involves connecting external monitors via HDMI. Under the current stable release of Chrome OS, the Chromebook actually does not support extending your display across monitors. You can either have your display on the internal or on the external, but not both. Furthermore, this support itself is pretty buggy, and I was not able to reliably get my external to connect. This is a pretty serious problem if you need more screen real estate. The beta release of Chrome OS does include support for extending your display across monitors, but the buggy connection problem persists and seems to have actually gotten worse, as I have managed to crash the entire machine by plugging a monitor into the HDMI port. It seems like the team at Google is working on the problem, but for now, the Chromebook might as well not have an HDMI port. I'd wait to buy one if this is a must-have for you.

All told, I think the hardware is great for the price point. Hopefully, the remaining bugs will get sorted out and Google and Samsung will have a computer to be proud of.

## Chrome OS

<a href="https://blog.travisthieman.s3.amazonaws.com/2013/03/Screenshot-2013-03-03-at-7.22.26-PM.png"><img class="alignnone size-medium wp-image-33" alt="Screenshot 2013-03-03 at 7.22.26 PM" src="https://blog.travisthieman.s3.amazonaws.com/2013/03/Screenshot-2013-03-03-at-7.22.26-PM.png" width="600" height="336" /></a>

When you first turn on the Chromebook, you're greeted with a very simple setup sequence that takes maybe 2 minutes to complete. This introduction, like the rest of the experience in Chrome OS, is very visually pleasing. The Google flat design philosophy is all over this product. The Chrome OS UI is spartan to a fault; it's very easy to get to what you want because there just aren't that many things you can do. Any apps you install are wisely condensed into a single apps button in the task bar, but once you open an app, it goes into a new tab in your current Chrome window. I question whether tabs were the best way to handle opening apps in a web-only OS, since you lose most of the functionality of the task bar. Unfortunately, there seems to be no option to change the way apps are opened. This problem extends to other functions of the OS; for example, there is no way to change the power management options. If you don't like your screen turning off every 5 minutes when idle, well, you're out of luck.

<a href="https://blog.travisthieman.s3.amazonaws.com/2013/03/Screenshot-2013-03-03-at-7.21.25-PM.png"><img class="alignnone size-medium wp-image-32" alt="Screenshot 2013-03-03 at 7.21.25 PM" src="https://blog.travisthieman.s3.amazonaws.com/2013/03/Screenshot-2013-03-03-at-7.21.25-PM.png" width="600" height="336" /></a>

The browsing experience is very similar to what you'd get on Chrome on a Macbook. Two-finger swipe scrolling is there, but not as smooth as on the Mac, and scrolling long distances is tedious since scrolling doesn't take acceleration into account. Pinch-to-zoom is missing. You will see slightly longer load times than what'd you get with a more powerful machine, but after spending a second or two on the initial load, most pages handle pretty well. I've been able to get a fair amount of load in the browser without seeing any real performance decrease (Spotify's new web player, Gmail, Google Docs, Twitter, Facebook, and GitHub all open at once presented no problems).

The Chromebook handles sleep exceptionally well and is typically ready to go by the time I've fully opened the screen. Boot times are indeed under 10 seconds, though you'll need to manually bypass the Scary Boot Screen(TM) if you turn on developer mode to still see that quick boot time. I've found that the Chromebook is very pleasant to use as a tablet replacement for browsing the Internet while enjoying the comforts of your couch. The faster nature of keyboard input, plus the easier multitasking with browser tabs, lead me to prefer the Chromebook to my iPad for this kind of usage.

Chrome OS, despite Google's marketing, is basically just a browser. But, hey, browsers are great. You also get functional camera, mic, and sound output, so you can do quite a few things with it. Performance is better than you'd expect for $250, so I think it'd be a pretty good machine even if you couldn't run Linux on it.

## Running Ubuntu using Crouton

And now, the fun part. Using [Crouton](https://github.com/dnschneid/crouton), I was able to get Ubuntu running with xfce in a chroot on the Chromebook. In theory, this method allows you to instantly switch between Chrome OS and Ubuntu with a single command. The low-level device stuff all still gets handled by Chrome OS, but Ubuntu is able to piggyback on top of Chrome and function normally. However, I found that there were some serious differences between theory and practice.

<a href="https://blog.travisthieman.s3.amazonaws.com/2013/03/Screenshot-030313-200555.png"><img class="alignnone size-medium wp-image-42" alt="Screenshot - 030313 - 20:05:55" src="https://blog.travisthieman.s3.amazonaws.com/2013/03/Screenshot-030313-200555.png" width="600" height="336" /></a>

Installation was very easy using Crouton and only took about 5 commands in total. I installed xfce, but other targets including Unity are available (though I was not able to get Unity to run particularly well). Crouton is still under active development, which is great because there are some bugs affecting switching between Chrome OS and your chroot. In one example, a race condition sometimes causes a graphical glitch where you have to "paint" the screen back into existence in Ubuntu before you can see what's going on. In another, tap-to-click with the touchpad will only work in Ubuntu once you've cycled back and forth between Chrome OS and Ubuntu at least once. Crouton is a very neat little hack, and I applaud its author for its creation, but it needs some more work from the community before it offers a friendly user experience.

Within Ubuntu itself, I am also having some difficulties. There seems to be some sort of bug with the omnibar in the current build of Chromium which frequently causes Chromium to crash when I type anything in the bar. It seems like the Chromebook may be at a disadvantage for Chromium updates due to its ARM processor, though I'm not sure if this bug has been fixed in a more recent x86 version. The ARM processor will cost you some flexibility in terms of third party software, particularly if you wanted to install any games on your Chromebook (the new Steam for Linux, for example, is not supported).

Any hardware issue in Chrome OS seems to get amplified when in Ubuntu. I was sometimes able to get external monitors working correctly in Chrome OS for short amounts of time, but upon switching to Ubuntu I would generally crash the entire machine. Ubuntu defers to Chrome OS's power management, which it generally handles just fine, but a few times Ubuntu has not been able to successfully come out of sleep and froze the entire machine. Hopefully, these issues will receive some attention since some Google engineers have been using Linux with their Chromebooks.

The conclusion here is similar to that of Chrome OS: very promising, but needs work. Here there is an additional dependency on Crouton, though if you're adventurous you could go for a straight dual-boot and see if you get better results. I'm still fixated on the external monitor issue, which is even worse in Ubuntu: without this, I don't see myself being able to get a whole lot done with this computer.

## Final Thoughts

I want to love this machine. I really do. However, the lack of external monitor support has prevented it from filling the purpose for which I bought it: to be a replacement dev machine I could keep at home so I didn't have to lug my Macbook Pro around everywhere. I'm still having a great time with it for general web usage, though, and it's great to have around when I'm watching a movie or otherwise engaging my primary monitor. I hope that Google is able to get some additional polish on the OS and hardware so that higher-end models like the<a href="https://www.google.com/intl/en/chrome/devices/chromebook-pixel/"> Chromebook Pixel</a> become viable alternatives to Mac hardware in the future. In the meantime, I'll be keeping an eye on the Chrome OS development channel.

<a href="https://news.ycombinator.com/item?id=5316003">Discuss This Post on Hacker News</a>

<em>Correction: </em>A previous version of this article stated that Apple's notebooks come with matte or glossy displays. This hasn't been true since 2012.
