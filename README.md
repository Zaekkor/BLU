This BLU.lua is ready to go for level 75 ToAU era FFXI, specifically developed for use on Horizon XI server. The goal was to structure it in a way that it works with Rag's existing architecture found here https://github.com/yzyii/luashitacast. 

All of the BLU specific logic is self-contained in the BLU.lua file so this should work with your current files.

Now that this LUA has been live on HXI's ToAU launch it's gone through a few version updates to resolve bugs and add in various feature requests. While working pretty well at this point, there is absolutely still a possibility I missed certain things.

Please join my discord here: https://discord.gg/ktAwae97Px and use the #bug-reports forum if you find anything broken specifically with the LUA. As a note, this should only be used for bugs with my LUA and not bugs with Luashitacast or Rag's files.

I will also be pinging the discord server with updates to the LUA so I encourage you to join for that as well!

**Now some disclaimers:**
- Claude did a lot of the work in creating the BLU.lua so there is absolutely a possibility of redundant code, weird workarounds for problems, etc. I've made efforts to clean it up, but AI gonna AI.
- This file is based off of the 3.0.5 version of Rag's files. Version 1.5.1 and above of this BLU.lua will require version 3.1.3 of Rag's files. You need to be on at least 3.1.3 to not encounter any issues/errors. Rag continues to make updates to his files and over time updating his files will be required for this LUA to properly function without issues.
- This lua was originally developed with in-era knowledge, and has been being changed as we learn new era+ things from HXI such as the new Metallic Body formula. You'll want to keep notifications on for updates, or at least check the #version-updates page weekly to make sure you don't miss out on import updates or hotfixes.
- The gear sets are left empty except for a select few that were pre-defined due to their usecase (such as the AFHands set). **Please pay special notice to any comments added to gearsets, though!**
- This lua is set up to work with the level sync priority feature LuAshitacast utilizes, so you can add gear in like this: `Main = {'Perdu Hanger', 'Centurion\'s Sword', 'Fire Sword'},` and it will try to equip each sequentially until it lands on one you can equip. Any sets that do not have the `_Priority` suffix, though, you will want to keep gear out of brackets (`Main = 'Perdu Hanger` instead of `Main = {'Perdu Hanger'}`).

- Reference the Commands.md file to understand all relevant commands for this lua.
- Reference the Update-Instructions.md file for instructions on how to properly update from older versions.


For the time being, I am one of the main sources of a BLU lua compatible with Rag's files. Rag has stated that he is not currently playing FFXI or Horizon at all and that any DMs asking him if he's going to implement ToAU jobs will just cause him to block you. Please do not message him about any upcoming BLU lua work and absolutely do not message him regarding tech support for my lua specifically.
