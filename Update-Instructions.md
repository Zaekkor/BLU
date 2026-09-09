# Updating to this version of BLU.lua

If you already have an older BLU.lua with your gear filled in, don't just overwrite it —
you'd lose all your gear. Follow these steps instead.

**Before you start:** make a backup copy of your current BLU.lua somewhere safe.

---

## Understanding the file

Roughly two-thirds of the way down there's a divider that looks like this:

```lua
--[[
--------------------------------
Everything below can be ignored.
--------------------------------
]]
```

- **Above the line** — your settings, spell lists, and gear sets. This is the part you
  normally edit.
- **Below the line** — the logic that decides which gear to equip when. You don't edit this.

Both halves need attention when updating, but in different ways.

---

## The short version

1. Open the new BLU.lua and your old BLU.lua side by side.
2. Copy your **gear sets** and your **settings values** from the old file into the new one.
3. Save the new file over your old one.
4. Don't copy anything else — the new file's spell lists and logic are the updated parts.

If you'd rather not hand-copy, see "Doing it the other way round" at the end.

---

## Step by step

### Step 1 — Copy your settings values

Near the very top of the new file you'll find these. Copy the numbers from your old file:

```lua
local fastCastValue = 0.10
local ninSJMaxMP = nil
local whmSJMaxMP = nil
local blmSJMaxMP = nil
local rdmSJMaxMP = nil
local drkSJMaxMP = nil
local extraThreshold = nil
```

`nil` means "not set." If yours has numbers, copy them across.

> **Note on `extraThreshold`:** if you set this to a number, the `/extra` command becomes
> active. If you leave it as `nil`, `/extra` does nothing (safely — it won't error).

### Step 2 — Copy your gear sets

Everything from `local sets = {` down to the divider line is gear. Copy each set's
contents from your old file into the matching set in the new file.

Copy **the items inside the braces**, not the set names — the new file has the correct
names already, and some have changed.

### Step 3 — Check these specific set names

Some sets **must not** have `_Priority` on the end. The shared framework files read these
directly by name, and adding `_Priority` makes the game error with
`bad argument #1 to 'pairs' (table expected, got nil)`:

```
DT          DTNight     MDT         Override    Evasion     Town        Haste
SIRD        SIRD_NIN    FireRes     IceRes      EarthRes    WindRes     WaterRes
LightningRes   LightningRes_NoBarthunder   LightningRes_WithBarthunderCarol
Cheat_C3HPDown   Cheat_C4HPDown   Cheat_HPUp
```

If your old file has any of these with `_Priority` on the end, keep the gear but use the
plain name. Every *other* set in the file should keep its `_Priority` suffix.

### Step 4 — New sets to fill in

These are new or newly-used. They'll be empty in the new file — add gear if you want them:

| Set | What it's for |
|---|---|
| `RefBody_Priority` | Body slot forced by `/refbody` (comes pre-filled with Mirage Jubbah) |
| `AFHands_Priority` | Hands slot forced by `/afhands` (comes pre-filled with Magus Bazubands) |
| `Enmity_Priority` | Overlaid on hate spells when `/hate` is on |
| `TP_Tank_LowAcc_Priority` | Tanking TP set, via `/tp` |
| `TP_Tank_HighAcc_Priority` | Tanking TP set with accuracy, via `/tp` |
| `RedLotusBlade_Default_Priority` | Red Lotus Blade weaponskill |
| `SeraphBlade_Default_Priority` | Seraph Blade weaponskill |
| `BluMagical_INT_Extra_Priority` | Used by `/extra` on INT-based nukes |
| `BluMagical_MND_Extra_Priority` | Used by `/extra` on MND-based nukes |
| `BluMagical_CHR_Extra_Priority` | Used by `/extra` on CHR-based nukes |
| `IdleMaxMP_Priority` | Idle gear once MP is topped off |

Leaving any of them empty is fine — they simply do nothing.

### Step 5 — Sets that were removed

If your old file has these, don't copy them. They aren't used anymore:

- `Ws_Hybrid_Priority`, `Vorpal_Hybrid_Priority`, `Savage_Hybrid_Priority`,
  `Expiacion_Hybrid_Priority` — never actually wired up to anything.
- `BluDark_Priority` — replaced by the stat-based sets.

---

## What about below the line?

**Normally, nothing to do.** Take the new version as-is — that's where the updates are.

The one exception: if you edited the spell lists yourself (the `local BluMag...` and
`local BluPhys...` lines near the top), your edits won't carry over. Those lists changed
in this version, so check them against your old file and re-add any personal changes.

For example, if you'd added `'Head Butt'` to `BluPhysDEX` so your stun spell picked up
DEX gear, you'd need to add that back.

---

## Doing it the other way round

If you have a lot of gear and only a few sets changed, it can be easier to start from
*your* file and bring the new changes into it. In that case, replace everything from the
divider line down with the new version, then work through Steps 3–5 above on your own
sets. Step 4's new sets will need adding by hand.

---

## Checking it worked

Load the profile in game. If it loads with no errors, you're good. Then try:

- `/afhands` and `/refbody` — should print a message and swap the slot.
- `/hate` — should print a message; cast Wild Carrot or Blank Gaze and check your enmity gear.
- `/tp` — should cycle through five states now, not three.

**If nothing happens at all and there's no error**, check that the very last line of your
file is `return profile`. If it's missing, the file loads silently but does nothing.

**If you get `bad argument #1 to 'pairs' (table expected, got nil)`**, a set is missing or
misnamed — go back to Step 3.
