# BLU.lua Changelog

## Latest

**New**
- Warlock's Mantle support, matching WHM.lua and BLM.lua. While subbing /RDM it's equipped
  during precast and its 2% Fast Cast is added on top of `fastCastValue` for the cast-delay
  calculation. The 2% can't be folded into `fastCastValue` directly because it only applies
  on that one subjob. Comment out the `Back` line in the `warlocks_mantle` table near the
  top of the file to disable it if you don't own the mantle.

**Fixes**
- The cure cheat now actually works. `Cheat_HPUp` was applied during precast, but the Cure
  and Enmity sets land afterwards and overwrote its slots - and since the HP the cure heals
  is (max HP at resolution - current HP), only the gear worn when the spell resolves counts.
  The HP-up half was therefore doing nothing. `Cheat_HPUp` is now re-applied at the very end
  of midcast, after Cure and Enmity, via `ApplyCheatHPUp()`. This mirrors how PLD.lua does
  the same trick.
  - Trade-off, which PLD accepts too: `Cheat_HPUp`'s slots now override your Enmity gear in
    those slots. That swaps a little enmity-from-gear for a bigger cure, which is usually
    the better deal since cure enmity scales with HP actually healed.

**Notes**
- Added guidance in the sets table recommending the `{ Name = 'Item', Priority = 60 }`
  syntax for the three `Cheat_*` sets. Priority controls equip *order* within a single swap
  (higher goes on first), so putting +HP gear on before -HP gear comes off stops max HP
  dipping mid-swap and clamping away HP you didn't intend to lose. These three sets are
  bare-named and never pass through `gFunc.EvaluateLevels`, so unlike the `_Priority`-suffixed
  sets they can use that syntax.

**Spell table additions**
- New `BluMagDEX` table and matching `BluMagical_DEX_Priority` /
  `BluMagical_DEX_Extra_Priority` sets, wired into both the magical stat dispatch and
  `/extra` mode. Charged Whisker is its first member.
- `BluMagSkill` += Blood Drain, Digest, Blood Saber, Osmosis.
- `BluMagDebuff` += MP Drainkiss.
- `BluMagMND` += Everyone's Grudge.
- `BluMagINT` += Blastbomb, Leafstorm, Thermal Pulse, Water Bomb, Dark Orb.

**Fixes**
- Corrected `'CMain Wave'` in `BluMagDebuff` to `'Cold Wave'`. The original looked like a
  find-and-replace accident (`old` -> `Main` inside "Cold Wave"), which meant Cold Wave was
  never actually matching and the bogus name could never match anything.

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
