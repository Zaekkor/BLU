This BLU.lua is ready to go for level 75 ToAU era FFXI, specifically developed for use on Horizon XI server. The goal was to structure it in a way that it works with Rag's existing architecture found here https://github.com/yzyii/luashitacast. 

All of the BLU specific logic is self-contained in the BLU.lua file so this should work with your current files.

This LUA has been tested, but there is absolutely a possibility I missed certain testing cases/scenarios.

**Now some disclaimers:**
- Claude did a lot of the work in creating the BLU.lua so there is absolutely a possibility of redundant code, weird workarounds for problems, etc. 
- This file is based off of the 3.0.5 version of Rag's files. You need to be on at least 3.0.0 I believe. He continues to make updates, though, but from what I can tell, unless Rag makes some big logic changes (unlikely), later versions are likely to work as well.
- Please understand that things absolutely could break or not function properly. But for now, at least in testing, everything appears to be working. If you find something that isn't working, feel free to share it with me and/or share the fix if you fix it.
- This is all based on era knowledge of BLU. Era+ changes will likely require some changes to the file so keep this link saved for updates.
- Rag will eventually make his own BLU.lua that will likely be different. I recommend swapping to his once he releases it, but it sounds like it could be a while for that to come out.
- I kept the gear sets filled for what I was testing. They are definitely not perfect, and are using stuff like Morrigan's set which we won't have as of time of release of this file on Horizon XI. Obviously you'll need to make your own changes there. **Please pay special notice to any comments added to gearsets, though!**

This is set up to work with the level sync priority feature LuAshitacast utilizes, so you can add gear in like this: `Main = {'Perdu Hanger', 'Centurion\'s Sword', 'Fire Sword'},` and it will try to equip each sequentially until it lands on one you can equip.
