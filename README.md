This BLU.lua is ready to go for level 75 ToAU era FFXI, specifically developed for use on Horizon XI server. The goal was to structure it in a way that it works with Rag's existing architecture found here https://github.com/yzyii/luashitacast. 

All of the BLU specific logic is self-contained in the BLU.lua file so this should work with your current files.

Now that this LUA has been live on HXI's ToAU launch it's gone through a few version updates to resolve bugs and add in various feature requests. While working pretty well at this point, there is absolutely still a possibility I missed certain things.

Please join my discord here: https://discord.gg/ktAwae97Px and use the #bug-reports forum if you find anything broken specifically with the LUA. As a note, this should only be used for bugs with my LUA and not bugs with Luashitacast or Rag's files.

I will also be pinging the discord server with update to the LUA so I encourage you to join for that as well!

**Now some disclaimers:**
- Claude did a lot of the work in creating the BLU.lua so there is absolutely a possibility of redundant code, weird workarounds for problems, etc. I've made efforts to clean it up, but AI gonna AI.
- This file is based off of the 3.0.5 version of Rag's files. You need to be on at least 3.0.0 I believe. He continues to make updates, though, but from what I can tell, unless Rag makes some big logic changes (unlikely), later versions are likely to work as well.
- This lua was originally developed with in-era knowledge, and has been being changed as we learn new era+ things from HXI such as the new Metallic Body formula. You'll want to keep notifications on for updates, or at least check the #version-updates page weekly to make sure you don't miss out on import updates or hotfixes.
- The gear sets used in this LUA are placeholders from testing. They are definitely not perfect, and are using stuff like Morrigan's set which we won't have as of time of release of this file on Horizon XI. Obviously you'll need to make your own changes there. **Please pay special notice to any comments added to gearsets, though!**
- This lua is set up to work with the level sync priority feature LuAshitacast utilizes, so you can add gear in like this: `Main = {'Perdu Hanger', 'Centurion\'s Sword', 'Fire Sword'},` and it will try to equip each sequentially until it lands on one you can equip.

For the time being, I am one of the main sources of a BLU lua compatible with Rag's files. Rag has stated that he is not currently playing FFXI or Horizon at all and that any DMs asking him if he's going to implement ToAU jobs will just cause him to block you. Please do not message him about any upcoming BLU lua work and absolutely do not message him regarding tech support for my lua specifically.
