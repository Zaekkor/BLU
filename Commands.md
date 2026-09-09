# BLU.lua Commands

Only commands that actually do something on this BLU profile are listed. Anything from the
main `Commands.md` that isn't here either doesn't apply to BLU or is gated to other jobs.

Commands marked **(BLU-specific)** don't exist in the stock profiles.
Commands marked **(modified)** exist elsewhere but behave differently here.

---

## Regular Toggles

```
/lock             - locks or unlocks all equipment.

/kite             - toggles Kite set on/off.
                    always takes precedence over other set overrides.

/weapon /wl       - (modified) manually cycle Weapon_Loadout sets.
                    On BLU, loadouts are normally chosen automatically by subjob:
                      Weapon_Loadout_1 -> /NIN
                      Weapon_Loadout_2 -> any other subjob
                    Using /weapon or /wl switches to manual mode and stops the
                    automatic selection. An argument jumps straight to a loadout,
                    e.g. /wl 3 goes directly to Weapon_Loadout_3
                    (Weapon_Loadout_3 is only reachable this way.)

/weaponauto       - (BLU-specific) returns weapon loadout selection to automatic
                    subjob-based mode after using /weapon or /wl.
```

## Idle Sets

```
/idle             - toggles between Idle and IdleALT.
/dt /pdt          - toggles DT set on/off.
/mdt              - toggles MDT set on/off.

/iceres /ires /bres       - toggles Ice Resistance set on/off.
/fireres /fres            - toggles Fire Resistance set on/off.
/earthres /eres /sres     - toggles Earth Resistance set on/off.
/windres /ares /wires     - toggles Wind Resistance set on/off.
/waterres /wres /wares    - toggles Water Resistance set on/off.
/lightningres /lres /tres - toggles Lightning Resistance set on/off.

/evasion /eva     - toggles Evasion set on/off.
/override /or     - toggles Override set on/off.
```

## TP Sets

```
/tp               - (modified) cycles which TP set is used while engaged.
                    On BLU this has five states instead of the usual three:

                      Off          - no HighAcc overlay; weapon lock disabled
                      LowAcc       - base TP set
                      HighAcc      - TP_HighAcc overlaid on the base set
                      Tank_LowAcc  - TP_Tank_LowAcc used as the base instead
                      Tank_HighAcc - TP_Tank_HighAcc overlaid on the tank base

                    Unlike other jobs, BLU always equips TP gear while engaged
                    even when this is set to Off. What Off actually disables is
                    the weapon/range/ammo lock, letting you freely swap those
                    slots (e.g. to a staff) while holding TP.
```

## Mage Commands

```
/setmp [number]   - sets the MP at which idle sets transition to IdleMaxMP.
/addmp [number]   - adds MP to the IdleMaxMP threshold (food, +MP effects).
/resetmp          - resets addmp and setmp to 0.

/hate             - (modified) overlays the Enmity set on spells that benefit from
                    boosted enmity. Stock profiles gate this to RDM/WHM; BLU has its
                    own implementation covering both Blue Magic and subjob White Magic:

                      Cures/heals - Healing Breeze, Wild Carrot, Magic Fruit,
                                    Plenilune Embrace, Restoral, Cure III
                      Debuffs     - Blank Gaze, Geist Wall, Sheep Song, Soporific,
                                    Yawn, Light of Penance, Actinic Burst, Jettatura,
                                    Temporal Shift, Dispel, Sleep, Blind
                      Other       - Terror Touch, Exuviation, Fantod

                    The Enmity set is applied last, so it overwrites any slot it
                    shares with the spell's normal gear.

                    /hate also enables the "cure cheat" when you cure YOURSELF:
                    your HP is briefly dropped during the cast so the cure heals
                    for more and generates more enmity, then restored just before
                    it lands. Uses these sets:

                      Cheat_C3HPDown - Cure III, Wild Carrot
                      Cheat_C4HPDown - Cure IV, Magic Fruit
                      Cheat_HPUp     - applied on top of either, just before the
                                       cast completes

                    So casting Wild Carrot on yourself with /hate on runs:
                    HP-down during the cast -> Cure set at midcast -> Enmity
                    overlaid on top. Leave the Cheat sets empty to skip the
                    HP-down step and just get the Enmity overlay.

/extra            - (BLU-specific) keeps MP-conservation gear on longer to squeeze out
                    extra casts. While on, and while MP is at or above the extraThreshold
                    value set near the top of BLU.lua:
                      - idle (not resting, not engaged) uses IdleMaxMP
                      - magical Blue Magic casts layer the matching _Extra variant
                        (BluMagical_INT_Extra / _MND_Extra / _CHR_Extra)
                      - Stoneskin and Phalanx use StoneskinExtra / PhalanxExtra
                    Does nothing if extraThreshold is left as nil.
```

## Forced Slot Toggles (BLU-specific)

```
/afhands          - forces Magus Bazubands into the Hands slot while idle or engaged,
                    overriding whatever gear would normally go there. Ignored while
                    resting, so your Resting set's hands always win.

/refbody          - forces Mirage Jubbah into the Body slot while engaged. Intended as
                    a TP body that also grants Refresh when MP is low. Only applies
                    while engaged; no other conditions.
```

## Special Commands

```
/lockset [number] - equips the given lockset and locks equipment.
                    use /lock to unlock again.

/lag              - removes midcast delays for when a zone is lagging.

/horizonmode      - manually triggers a HandleDefault gear equip, for
                    100% HorizonXI-approved play.

/gcdisplay        - toggles visibility of the UI component.
```

---

## Not applicable to BLU

These appear in the main `Commands.md` but are gated to other main jobs and do
nothing here: `/yellow`, `/mode`, `/mb`, `/csstun`, `/vert`.
