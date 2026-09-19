# BLU.lua Changelog

## Latest

**Spell table additions**
- New `BluMagDEX` table and matching `BluMagical_DEX_Priority` /
  `BluMagical_DEX_Extra_Priority` sets, wired into both the magical stat dispatch and
  `/extra` mode. Charged Whisker is its first member.
- `BluMagSkill` += Blood Drain, Digest, Blood Saber, Osmosis.
- `BluMagDebuff` += MP Drainkiss.
- `BluMagMND` += Everyone's Grudge.
- `BluMagINT` += Blastbomb, Leafstorm, Thermal Pulse, Water Bomb, Dark Orb.

**Fixes**
- Corrected `'CMain Wave'` in `BluMagDebuff` to `'Cold Wave'`. 

**New**
- `thfSJMaxMP` - a dedicated IdleMaxMP threshold for a THF subjob. gcmage only gives WHM,
  BLM, RDM and DRK their own parameter; every other subjob shares a single catch-all that
  `ninSJMaxMP` feeds, so a THF sub previously just inherited whatever `ninSJMaxMP` was set
  to. Set `thfSJMaxMP` to override that while subbing THF, or leave it `nil` to keep the
  old shared behaviour. Implemented self-contained via `GetCatchAllSJMaxMP()`, with no
  changes to gcmage.

**Housekeeping**
- Most gear has been stripped out of the gear sets, leaving them empty for you to fill in.
  All 86 sets are still present and all logic is unchanged - only the contents were cleared.
  Four sets keep their contents, where the specific item is the point of the set:
  `AFHands_Priority`, `RefBody_Priority`, `TP_Ear2_Priority` and `BluSkill_Priority`.
- Added "do not touch" notes on the two auto-managed variables (`Settings.CurrentLevel`
  and `weaponLoadoutManualOverride`).
- `fastCastValue` reset to `0`.

---

## LuAshitacast v3.1.3 compatibility

**Requires the `common/` framework files at v3.1.3 or newer.** Nothing here changes how
BLU plays; it's all keeping pace with upstream changes to the shared files.

**New**
- `WeaponBash` set, plus a `gcmage.DoWeaponBash()` call in `HandleAbility`. v3.1.3 added a
  Weapon Bash set to every job. It only fires when you're subbing /DRK, using Weapon Bash,
  and holding a one-handed or hand-to-hand weapon. Ships empty, so it does nothing until
  you put a weapon in it.

**Fixes**
- `GetAutoWeaponLoadout()` now guards against the literal string `'Unknown'`, which
  `gcdisplay.GetCycle()` returns before the cycles are populated (e.g. on initial game
  load). Without the guard, having `/weapon` manual mode active during that window built
  the set name `Weapon_Loadout_Unknown` and logged a "Set not found" warning. It now falls
  back to the subjob default until the cycle is live. Upstream added the equivalent guard
  to `gcmage`/`gcmelee` in v3.1.1; this is the same fix for BLU's own loadout selection.

**Inherited from the framework — no BLU changes needed**
- Conquest items (including `republic_gold_medal` in the resting logic) now require
  Signet, Sanction or Sigil to be active before they'll equip.
- Storm Crackows auto-equip in assault zones, via `gcinclude`.
- Diabolos Ring now also triggers on Bio, not just Drain, under 85% MP.

---

## Previous

**New commands**
- `/refbody` - forces Mirage Jubbah into the Body slot while engaged (TP body with
  Refresh when MP is low). New `RefBody_Priority` set.
- `/hate` - overlays the Enmity set on spells that benefit from boosted enmity.
  The stock version of this command is gated to RDM/WHM, so BLU now has its own.

**Spell classification changes**
- Removed the `BluMagEnmity` table. Enmity gear is now applied via `/hate` instead of
  automatically, so it's opt-in rather than always-on. The spells it held were moved
  into the tables they actually belong to:
  - Actinic Burst, Jettatura, Temporal Shift -> `BluMagDebuff`
  - Exuviation, Fantod -> `BluMagBuff`
- Rail Cannon added to `BluMagMND`.
- Goblin Rush added to `BluPhysMulti` (stays in `BluMagPhys` as well).

**Fixes**
- Metallic Body now uses `BluMagical_MND` as its base with `BluSkill` overlaid on top,
  matching Horizon's custom formula which scales off MND in addition to Blue Magic Skill.
- The `Cheat_C3HPDown` / `Cheat_C4HPDown` / `Cheat_HPUp` sets now actually work. They were
  added previously only to stop a crash, but nothing ever equipped them - the stock
  implementation lives in a gcmage function BLU's own precast never calls. Reimplemented
  self-contained, and extended so Wild Carrot uses the C3 set and Magic Fruit the C4 set,
  alongside Cure III and Cure IV.

---

## Earlier

**New commands**
- `/afhands` - forces Magus Bazubands into the Hands slot while idle or engaged.
- `/extra` - keeps MP-conservation gear on longer to squeeze out extra casts.
- `/weaponauto` - returns weapon loadout selection to automatic subjob-based mode.

**Changes**
- `/tp` extended from three states to five, adding `Tank_LowAcc` and `Tank_HighAcc`.
- Weapon loadouts now auto-select by subjob (1 for /NIN, 2 for everything else).
  `/weapon` and `/wl` switch to manual mode; `/weaponauto` switches back.
- Added weaponskill sets for Red Lotus Blade and Seraph Blade.
- Removed four unused `_Hybrid` weaponskill sets that were never wired up.
- Per-weaponskill HighAcc sets (Vorpal, Savage, Expiacion) are now actually applied;
  previously only the generic `Ws_HighAcc` was.
- Elemental staff/obi swaps no longer fire on `BluMagBuff` / `BluMagSkill` spells,
  since staves don't affect them.
- Movement and Movement_TP gear now re-applied at the end of HandleDefault so TP and
  IdleMaxMP gear can't overwrite it.
- Resting no longer holds the TP weapon in place while leftover TP drains.
- Added a corrected MaxMP-Resting behaviour: once MP tops off while resting, switches
  to IdleMaxMP instead of staying in Resting gear.

**Fixes**
- Guarded `extraThreshold` against nil, which would otherwise crash `/extra` on use.
- Added `SIRD_NIN`, `Cheat_C3HPDown`, `Cheat_C4HPDown`, `Cheat_HPUp` and other sets that
  gcmage reads directly, which crashed with "bad argument #1 to 'pairs'" when missing.
