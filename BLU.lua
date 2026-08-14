local profile = {}

-- Approximate Fast Cast % from gear listed in the Precast set below. Adjust if you change that set.
local fastCastValue = 0.10

-- These mirror gcmage.DoDefault's subjob MaxMP convenience params (see RDM.lua). BLU commonly subs
-- NIN, which has no MP-conservation idle gear convention like WHM/BLM/RDM/DRK subs do, so these are
-- left nil (disabled) by default. Fill in a value here if you want IdleMaxMP gear at a specific
-- subjob MP threshold.
local ninSJMaxMP = 748
local whmSJMaxMP = 816
local blmSJMaxMP = nil
local rdmSJMaxMP = nil
local drkSJMaxMP = nil

-- Self-contained "Extra mode" equivalent to the /extra command other mage jobs get via companion
-- "_advanced" files (rdm_advanced.lua/whm_advanced.lua) we don't have access to. While the /extra
-- toggle is on and current (or post-cast) MP is still at or above this threshold, BLU stays in
-- IdleMaxMP-conservation gear - while idle and not engaged, and layered onto magical casts - rather
-- than falling back to normal gear, letting you squeeze a few more casts out before MP gets tight.
-- Tune this to whatever MP value makes sense for your own IdleMaxMP set/playstyle.
local extraThreshold = 817

-- Blue Magic classification tables. These decide which gear set HandleMidcast reaches for based on the spell being cast.

local BluMagPhys = T{'Foot Kick', 'Sprout Smack', 'Wild Oats', 'Power Attack', 'Queasyshroom', 'Battle Dance', 'Feather Storm', 'Helldive', 'Bludgeon', 'Claw Cyclone', 'Screwdriver', 'Grand Slam', 'Smite of Rage', 'Pinecone Bomb', 'Jet Stream', 'Uppercut', 'Terror Touch', 'Mandibular Bite', 'Sickle Slash', 'Dimensional Death', 'Spiral Spin', 'Death Scissors', 'Seedspray', 'Body Slam', 'Hydro Shot', 'Frenetic Rip', 'Spinal Cleave', 'Hysteric Barrage', 'Asuran Claws', 'Cannonball', 'Disseverment', 'Ram Charge', 'Vertical Cleave', 'Final Sting', 'Goblin Rush', 'Vanity Dive', 'Whirl of Rage', 'Benthic Typhoon', 'Quad. Continuum', 'Empty Thrash', 'Delta Thrust', 'Heavy Strike', 'Quadrastrike', 'Tourbillion', 'Amorphic Spikes', 'Barbed Crescent', 'Bilgestorm', 'Bloodrake', 'Glutinous Dart', 'Paralyzing Triad', 'Thrashing Assault', 'Sinker Drill', 'Sweeping Gouge', 'Saurian Slide'}
local BluMagDebuff = T{'Filamented Hold', 'Cimicine Discharge', 'Demoralizing Roar', 'Venom Shell', 'Light of Penance', 'Sandspray', 'Auroral Drape', 'Frightful Roar', 'Enervation', 'Infrasonics', 'Lowing', 'CMain Wave', 'Awful Eye', 'Voracious Trunk', 'Sheep Song', 'Soporific', 'Yawn', 'Dream Flower', 'Chaotic Eye', 'Sound Blast', 'Blank Gaze', 'Stinking Gas', 'Geist Wall', 'Feather Tickle', 'Reaving Wind', 'Mortal Ray', 'Absolute Terror', 'Blistering Roar', 'Cruel Joke'}
local BluMagBuff = T{'Zephyr Mantle', 'Cocoon', 'Refueling', 'Feather Barrier', 'Memento Mori', 'Warm-Up', 'Amplification', 'Triumphant Roar', 'Saline Coat', 'Reactor Cool', 'Plasma Charge', 'Regeneration', 'Animating Wail', 'Battery Charge', 'Winds of Promy.', 'Barrier Tusk', 'Orcish Counterstance', 'Pyric Bulwark', 'Nat. Meditation', 'Restoral', 'Erratic Flutter', 'Carcharian Verve', 'Harden Shell', 'Mighty Guard'}
local BluMagSkill = T{'Metallic Body', 'Diamondhide', 'Magic Barrier', 'Occultation', 'Atra. Libations'}
local BluMagCure = T{'Pollen', 'Healing Breeze', 'Wild Carrot', 'Magic Fruit', 'Plenilune Embrace'}
local BluMagEnmity = T{'Actinic Burst', 'Exuviation', 'Fantod', 'Jettatura', 'Temporal Shift'}

-- Physical Blue Magic stat-mod sub-classification, sourced from the bg-wiki "Calculating Blue Magic
-- Damage" Stat Mod column (cross-referenced against multiple independent, community-maintained
-- GearSwap data files for consistency). Where a spell's secondary stat isn't STR/DEX/VIT/AGI/CHR
-- (e.g. the INT-mod Mandibular Bite/Queasyshroom, or the MND-mod Ram Charge/Screwdriver/Tourbillion),
-- it falls back to STR per user direction, since there's no dedicated INT/MND physical subset.
local BluPhysStun = T{'Head Butt', 'Frypan', 'Tail Slap', 'Sub-zero Smash', 'Sudden Lunge'}
local BluPhysSTR = T{'Battle Dance', 'Death Scissors', 'Dimensional Death', 'Empty Thrash', 'Quadrastrike', 'Sinker Drill', 'Spinal Cleave', 'Uppercut', 'Vertical Cleave', 'Saurian Slide', 'Bloodrake', 'Mandibular Bite', 'Queasyshroom', 'Ram Charge', 'Screwdriver', 'Tourbillion', 'Bilgestorm', 'Whirl of Rage', 'Sweeping Gouge', 'Final Sting'}
local BluPhysDEX = T{'Amorphic Spikes', 'Asuran Claws', 'Barbed Crescent', 'Claw Cyclone', 'Disseverment', 'Foot Kick', 'Frenetic Rip', 'Goblin Rush', 'Hysteric Barrage', 'Paralyzing Triad', 'Seedspray', 'Sickle Slash', 'Smite of Rage', 'Terror Touch', 'Thrashing Assault', 'Vanity Dive', 'Heavy Strike'}
local BluPhysVIT = T{'Body Slam', 'Cannonball', 'Delta Thrust', 'Glutinous Dart', 'Grand Slam', 'Power Attack', 'Quad. Continuum', 'Sprout Smack'}
local BluPhysAGI = T{'Benthic Typhoon', 'Feather Storm', 'Helldive', 'Hydro Shot', 'Jet Stream', 'Pinecone Bomb', 'Spiral Spin', 'Wild Oats'}
local BluPhysCHR = T{'Bludgeon'}
local BluPhysMulti = T{'Bludgeon', 'Jet Stream', 'Quad. Continuum', 'Frenetic Rip', 'Hysteric Barrage', 'Disseverment'}

-- Magical Blue Magic stat-mod sub-classification, same source. Everything not listed here defaults
-- to INT (the standard magic damage stat) - only the spells with a documented MND or CHR mod get
-- their own list. Only applies to the generic magic-damage fallback in HandleMidcast (Cure/Enmity/
-- Stun/White Wind/Dark spells already have their own dedicated, more specific sets).
local BluMagMND = T{'Acrid Stream', 'Magic Hammer', 'Mind Blast'}
local BluMagCHR = T{'Eyes On Me', 'Mysterious Light'}
local BluMagINT = T{'Sandspin', 'Cursed Sphere', 'Bomb Toss', 'Death Ray', 'Blitzstrahl', 'Ice Break', 'Maelstrom', 'Corrosive Ooze', 'Firespit', 'Regurgitation'}

-- Breath spells use a distinct HP-based damage formula rather than scaling off STR/DEX/INT/etc, so
-- they get their own dedicated max-HP set rather than fitting the physical/magical split above.
local BluMagBreath = T{'Bad Breath', 'Flying Hip Press', 'Frost Breath', 'Heat Breath', 'Hecatomb Wave', 'Magnetite Cloud', 'Poison Breath', 'Radiant Breath', 'Self-Destruct', 'Thunder Breath', 'Vapor Spray', 'Wind Breath'}



local Settings = {
    CurrentLevel = 0,
}

-- Set true by /weapon or /wl (see HandleCommand), false by /weaponauto. Controls whether
-- GetAutoWeaponLoadout uses the SubJob-based auto-selection or the manually-toggled cycle value.
local weaponLoadoutManualOverride = false

-- Sticky flag for the MaxMP Resting logic below: once MP tops off while resting, stays true until you
-- stop resting, so a small MP dip right at the threshold (e.g. a party member's spell) doesn't cause
-- gear to flicker back and forth between Resting and IdleMaxMP.
local restingMaxMP = false


local sets = {
    Idle_Priority = {
        Ammo = {'Tiphia Sting'},
        Head = {'Crimson Mask'},
        Neck = {'Peacock Charm'},
        Ear1 = {'Ethereal Earring'},
        Ear2 = {'Merman\'s Earring'},
        Body = {'Morrigan\'s Robe'},
        Hands = {'Denali Wristbands'},
        Ring1 = {'Merman\'s Ring'},
        Ring2 = {'Merman\'s Ring'},
        Back = {'Umbra Cape'},
        Waist = {'Speed Belt'},
        Legs = {'Homam Cosciales'},
        Feet = {'Crimson Greaves'},
    },
    IdleALT_Priority = {},
    IdleMaxMP_Priority = {
        Ammo = {'Hedgehog Bomb'},
        Head = {'Walahra Turban'},
        Neck = {'Beak Necklace'},
        Ear1 = {'Antivenom Earring'},
        Ear2 = {'Phtm. Earring +1'},
        Body = {'Crm. Scale Mail'},
        Hands = {'Morrigan\'s Cuffs'},
        Ring1 = {'Astral Ring'},
        Ring2 = {'Astral Ring'},
        Back = {'Errant Cape'},
        Waist = {'Hierarch Belt'},
        Legs = {'Homam Cosciales'},
        Feet = {'Homam Gambieras'},
    },
    Resting_Priority = {
        Main = {'Pluto\'s Staff'},
        Sub = 'displaced',
        Head = {'Yigit Turban'},
        Neck = {'Beak Necklace'},
        Ear1 = {'Antivenom Earring'},
        Ear2 = {'Relaxing Earring'},
        Body = {'Yigit Gomlek'},
        Hands = {'Genie Gages'},
        Ring1 = {'Merman\'s Ring'},
        Ring2 = {'Merman\'s Ring'},
        Back = {'Umbra Cape'},
        Waist = {'Hierarch Belt'},
        Legs = {'Yigit Seraweels'},
        Feet = {'Arborist Nails'},
    },
    Town = {},
    Movement_Priority = {
        Legs = {'Crimson Cuisses'},
    },
    Movement_TP_Priority = {
        Legs = {'Crimson Cuisses'},
    },
    Override = {},

    DT_Priority = {Head = 'Darksteel Cap +1'},
    DTNight = {},
    MDT = {},
    FireRes = {},
    IceRes = {},
    LightningRes = {},
    LightningRes_NoBarthunder = {},
    LightningRes_WithBarthunderCarol = {},
    EarthRes = {},
    WindRes = {},
    WaterRes = {},
    Evasion = {},

    -- gcmage.DoMidcast's SetupInterimEquipSet accesses these by direct table field access (sets.SIRD,
    -- sets.SIRD_NIN), not through the bare-name/_Priority alias mechanism, so they need to exist as
    -- real keys here regardless - otherwise gFunc.Combine(nil, ...) crashes for anyone subbing NIN.
    -- Fill in real SIRD gear if you want it; empty is a safe no-op.
    SIRD = {},
    SIRD_NIN = {},

    -- Everything below is stubbed empty so nothing gcmage.DoMidcast/DoDefault/DoDefaultOverride/
    -- EquipWeaponLoadout/DoAbility might reference for non-Blue-Magic spells (now reachable via the
    -- gcmage.DoMidcast fallback in HandleMidcast) or job abilities can ever resolve to nil and crash,
    -- regardless of whether the surrounding gcmage.lua code is actually job-gated away from BLU today.
    -- Fill in real gear for any of these if you want it to matter; empty is always a safe no-op.

    -- Enhancing Magic / Stoneskin (Utsusemi, Stoneskin, Phalanx, etc. from a subjob spell)
    Enhancing_Priority = {},
    Stoneskin_Priority = {
        Ammo = {'Hedgehog Bomb'},
        Head = {'Yigit Turban'},
        Neck = {'Justice Badge'},
        Ear1 = {'Loquac. Earring'},
        Ear2 = {'Cmn. Earring'},
        Body = {'Errant Hpl.'},
        Hands = {'Yigit Gages'},
        Ring1 = {'Aqua Ring'},
        Ring2 = {'Tamas Ring'},
        Back = {'Prism Cape'},
        Waist = {'Penitent\'s Rope'},
        Legs = {'Morrigan\'s Slops'},
        Feet = {'Morrigan\'s Pgch.'},
    },
    StoneskinExtra_Priority = {
        Ammo = {'Hedgehog Bomb'},
        Head = {'Yigit Turban'},
        Neck = {'Justice Badge'},
        Ear1 = {'Loquac. Earring'},
        Ear2 = {'Antivenom Earring'},
        Body = {'Crm. Scale Mail'},
        Hands = {'Yigit Gages'},
        Ring1 = {'Astral Ring'},
        Ring2 = {'Tamas Ring'},
        Back = {'Prism Cape'},
        Waist = {'Penitent\'s Rope'},
        Legs = {'Morrigan\'s Slops'},
        Feet = {'Morrigan\'s Pgch.'},
    },
    PhalanxExtra_Priority = {},

    -- Dark Magic / Ninjutsu Stun
    Dark_Priority = {},
    Stun_Priority = {},

    -- Everything else gcmage.DoMidcast might reference for a subjob spell (Enfeebling, Nuke, MB,
    -- Banish, Cure5, Cursna, StunACC, Hate, TP, etc.) is uncommon enough for BLU that it's not worth
    -- its own dedicated set - see the aliasing block right after the sets table below instead, which
    -- points the bare names gcmage.lua looks for at the closest already-meaningful BLU set, so a rare
    -- subjob spell still gets reasonable gear instead of a "Set not found" warning and nothing at all.

    -- TP sets, dispatched by BLU's own self-contained TP logic in HandleDefault (not gcmage.DoDefault's
    -- native RDM/WHM/BRD/SMN-only dispatch, which BLU deliberately isn't part of) while
    -- engaged with the shared /tp cycle (Off / LowAcc / HighAcc) at anything other than Off.
    -- TP_LowAcc_Priority is the base set (also the default while the toggle sits on LowAcc);
    -- TP_HighAcc_Priority layers on top when the toggle is HighAcc; TP_NIN_Priority layers on top
    -- when subbing NIN. TP_HighAcc always applies after TP_NIN, so it wins any overlapping slot
    -- regardless of subjob.
    TP_LowAcc_Priority = {
        Range = 'displaced',
        Ammo = {'Tiphia Sting'},
        Head = {'Walahra Turban'},
        Neck = {'Fortitude Torque'},
        Ear1 = {'Brutal Earring'},
        Ear2 = {'Spike Earring'}, -- Below, we define a TP_Ear2 priority, however, if you do not have something better than Diabolos' Earring, still set something here for instances when you're in dark weather.
        Body = {'Morrigan\'s Robe'},
        Hands = {'Homam Manopolas'},
        Ring1 = {'Rajas Ring'},
        Ring2 = {'Sniper\'s Ring'},
        Back = {'Amemet Mantle +1'},
        Waist = {'Speed Belt'},
        Legs = {'Homam Cosciales'},
        Feet = {'Homam Gambieras'},
    },

    -- If you have an item you'd prefer to use instead of Diabolos' Earring, replace 'Better_Earring_Goes_Here' with the earring name.
    -- It will equip Diabolos' Earring only when not Dark weather and if no other item is listed ahead of it.
    -- If conditions are met, Fenrir's Earring will supercede both of these unless subjob is set to /NIN.
TP_Ear2_Priority = {
    Ear2 = {'Better_Earring_Goes_Here', 'Diabolos\'s Earring'}, 

},

    -- NOTE: TP_HighAcc_Priority and TP_NIN_Priority below are LAYERED ON TOP of TP_LowAcc_Priority in this
    -- architecture (only the slots that should actually change need to be listed) 
    TP_HighAcc_Priority = {
    Waist = {'Life Belt'},
    },
    TP_NIN_Priority = {
    Ear2 = {'Suppanomimi'},
    },
    TP_Mjollnir_Haste_Priority = {},

    -- Weapon Loadouts are meant to set custom weapon sets for engaging and fighting mobs.
    -- Weapon_Loadout_1 will auto-equip when SubJob is set to /NIN, and you are engaged.
    -- Weapon_Loadout_2 will auto-equip when SubJob is set to anything that is NOT /NIN, and you are engaged.
    -- Weapon_Loadout_3 will not auto-equip.
    -- You can still manually cycle these sets by typing /wl # in game. (Replace # with the loadout number)
    Weapon_Loadout_1_Priority = {
        Main = {'Perdu Hanger'},
        Sub = {'Ifrit\'s Blade'},
    },
    Weapon_Loadout_2_Priority = {
        Main = {'Perdu Hanger'},
        Sub = {'Genbu\'s Shield'},
    },
    Weapon_Loadout_3_Priority = {
        Main = { 'Tizona' },
        Sub = { 'Ifrit\'s Blade' },
    },


    Haste = {}, -- used e.g. for NIN subjob Utsusemi recast

    Preshot_Priority = {},
    Midshot_Priority = {},
    Ranged_Priority = {},

    Precast_Priority = {
        Ear1 = {'Loquac. Earring'},
    },
    Blu_Precast_Priority = {
        Ear1 = {'Loquac. Earring'},
    },
    Stoneskin_Precast_Priority = {},

    Cure_Priority = {
        Main = {'Apollo\'s Staff'},
        Sub = 'displaced',
        Ammo = {'Hedgehog Bomb'},
        Head = {'Yigit Turban'},
        Neck = {'Justice Badge'},
        Ear1 = {'Loquac. Earring'},
        Ear2 = {'Cmn. Earring'},
        Body = {'Errant Hpl.'},
        Hands = {'Yigit Gages'},
        Ring1 = {'Aqua Ring'},
        Ring2 = {'Tamas Ring'},
        Back = {'Prism Cape'},
        Waist = {'Penitent\'s Rope'},
        Legs = {'Morrigan\'s Slops'},
        Feet = {'Morrigan\'s Pgch.'},
    },
    WhiteWind_Priority = {},
    BluBreath_Priority = {},
    BluSkill_Priority = {
        Head = {'Mirage Keffiyeh'},
        Body = {'Magus Jubbah'},
    },

    -- This set is your default magical spell set. 
    BluMagical_Priority = {
        Ammo = {'Phtm. Tathlum'},
        Head = {'Morrigan\'s Coron.'},
        Neck = {'Philomath Stole'},
        Ear1 = {'Moldavite Earring'},
        Ear2 = {'Phtm. Earring +1'},
        Body = {'Morrigan\'s Robe'},
        Hands = {'Morrigan\'s Cuffs'},
        Ring1 = {'Snow Ring'},
        Ring2 = {'Tamas Ring'},
        Back = {'Prism Cape'},
        Waist = {'Penitent\'s Rope'},
        Legs = {'Morrigan\'s Slops'},
        Feet = {'Morrigan\'s Pgch.'},
    },

    -- The below sets are layered on top of BluMagical_Priority for magic-damage fallback based on each
    -- spell's dominant stat mod (see BluMagMND/CHR/INT classification above; BluMagical_Priority is still the
    -- fallback default for any spell not explicitly classified in one of those three tables).
    BluMagical_INT_Priority = {
        Ammo = {'Phtm. Tathlum'},
        Head = {'Morrigan\'s Coron.'},
        Neck = {'Philomath Stole'},
        Ear1 = {'Moldavite Earring'},
        Ear2 = {'Phtm. Earring +1'},
        Body = {'Morrigan\'s Robe'},
        Hands = {'Morrigan\'s Cuffs'},
        Ring1 = {'Snow Ring'},
        Ring2 = {'Tamas Ring'},
        Back = {'Prism Cape'},
        Waist = {'Penitent\'s Rope'},
        Legs = {'Morrigan\'s Slops'},
        Feet = {'Morrigan\'s Pgch.'},
    },
    BluMagical_MND_Priority = {
        Head = {'Yigit Turban'},
        Neck = {'Promise Badge'},
        Ear1 = {'Cmn. Earring'},
        Ear2 = {'Cmn. Earring'},
        Body = {'Errant Hpl.'},
        Hands = {'Yigit Gages'},
        Ring1 = {'Aqua Ring'},
        Ring2 = {'Tamas Ring'},
        Back = {'Prism Cape'},
        Waist = {'Penitent\'s Rope'},
        Legs = {'Morrigan\'s Slops'},
        Feet = {'Morrigan\'s Pgch.'},
    },
    BluMagical_CHR_Priority = {
        Ring1 = {'Heavens Ring'},
        Ring2 = {'Heavens Ring'},
    },

    -- Layered on top of the base BluMagical_INT/MND/CHR set (instead of it) when /extra mode is on
    -- and you'll still have plenty of MP left after the cast (see extraThreshold) - the BLU-specific
    -- equivalent of what gcmage.lua's NukeExtra/StoneskinExtra/PhalanxExtra would do for other mage
    -- jobs, but self-contained since that mechanism can't reach BLU.
    BluMagical_INT_Extra_Priority = {
        Ammo = {'Phtm. Tathlum'},
        Head = {'Morrigan\'s Coron.'},
        Neck = {'Philomath Stole'},
        Ear1 = {'Moldavite Earring'},
        Ear2 = {'Phtm. Earring +1'},
        Body = {'Crm. Scale Mail'},
        Hands = {'Morrigan\'s Cuffs'},
        Ring1 = {'Astral Ring'},
        Ring2 = {'Tamas Ring'},
        Back = {'Prism Cape'},
        Waist = {'Hierarch Belt'},
        Legs = {'Morrigan\'s Slops'},
        Feet = {'Morrigan\'s Pgch.'},
    },
    BluMagical_MND_Extra_Priority = {},
    BluMagical_CHR_Extra_Priority = {},

    BluMagicAccuracy_Priority = {
        Ammo = {'Phtm. Tathlum'},
        Head = {'Morrigan\'s Coron.'},
        Body = {'Nashira Manteel'},
        Hands = {'Morrigan\'s Cuffs'},
        Ring1 = {'Snow Ring'},
        Ring2 = {'Tamas Ring'},
        Back = {'Prism Cape'},
        Waist = {'Penitent\'s Rope'},
        Legs = {'Nashira Seraweels'},
        Feet = {'Denali Gamashes'},
    },
    BluStun_Priority = {},
    BluPhysical_Priority = {
        Head = {'Morrigan\'s Coron.'},
        Neck = {'Kubira Beads'},
        Ear1 = {'Triumph Earring'},
        Ear2 = {'Triumph Earring'},
        Body = {'Morrigan\'s Robe'},
        Hands = {'Alkyoneus\'s Brc.'},
        Ring1 = {'Rajas Ring'},
        Ring2 = {'Flame Ring'},
        Back = {'Forager\'s Mantle'},
        Waist = {'Warwolf Belt'},
        Legs = {'Morrigan\'s Slops'},
        Feet = {'Denali Gamashes'},
    },
    -- Layered on top of BluPhysical_Priority based on each spell's dominant secondary stat mod (see
    -- BluPhysSTR/DEX/VIT/AGI/CHR classification above).
    BluPhysical_STR_Priority = {},
    BluPhysical_DEX_Priority = {},
    BluPhysical_CHR_Priority = {
        Ring1 = {'Heavens Ring'},
        Ring2 = {'Heavens Ring'},
    },
    BluPhysical_AGI_Priority = {},
    BluPhysical_VIT_Priority = {},
    ConserveMP_Priority = {},
    Enmity_Priority = {},

    Ws_Default_Priority = {},
    Ws_Hybrid_Priority = {},
    Ws_HighAcc_Priority = {},

    Vorpal_Default_Priority = {},
    Vorpal_Hybrid_Priority = {},
    Vorpal_HighAcc_Priority = {},

    Savage_Default_Priority = {
        Head = 'Morrigan\'s Coron.',
        Neck = 'Kubira Beads',
        Ear1 = 'Triumph Earring',
        Ear2 = 'Triumph Earring',
        Body = 'Morrigan\'s Robe',
        Hands = 'Alkyoneus\'s Brc.',
        Ring1 = 'Rajas Ring',
        Ring2 = 'Flame Ring',
        Back = 'Forager\'s Mantle',
        Waist = 'Warwolf Belt',
        Legs = 'Morrigan\'s Slops',
        Feet = 'Denali Gamashes',
    },
    Savage_Hybrid_Priority = {},
    Savage_HighAcc_Priority = {},

    Expiacion_Default_Priority = {
        Head = 'Morrigan\'s Coron.',
        Neck = 'Kubira Beads',
        Ear1 = 'Triumph Earring',
        Ear2 = 'Triumph Earring',
        Body = 'Morrigan\'s Robe',
        Hands = 'Alkyoneus\'s Brc.',
        Ring1 = 'Rajas Ring',
        Ring2 = 'Flame Ring',
        Back = 'Forager\'s Mantle',
        Waist = 'Warwolf Belt',
        Legs = 'Morrigan\'s Slops',
        Feet = 'Denali Gamashes',
    },
    Expiacion_Hybrid_Priority = {},
    Expiacion_HighAcc_Priority = {},

    Ca_Priority = {},
    Ba_Priority = {},
    Diffusion_Priority = {},

    Salvage_Priority = {},

}

--[[
--------------------------------
Everything below can be ignored.
--------------------------------
]]

gcinclude = gFunc.LoadFile('common\\gcinclude-rag.lua')
gcmage = gFunc.LoadFile('common\\gcmage.lua')
gcmelee = gFunc.LoadFile('common\\gcmelee.lua') -- loaded for utility calls only (EquipBluPhysical, DoFenrirsEarring); gcmelee.Load() is intentionally never called since gcmage.Load() already owns the shared TP/Weapon Loadout/Mode cycles, and loading both would double-register conflicting alias commands.

-- Chained so both gcmage's (elemental staves/obis, conquest rings, etc.) and gcmelee's
-- (fenrirs_earring, muscle_belt, etc.) utility item sets are registered - we call gcmelee.DoFenrirsEarring
-- without loading the full gcmelee subsystem, so its AppendSets never runs unless we call it explicitly
-- like this.
-- Aliases the bare set names gcmage.lua's DoMidcast looks for (for spells cast via a subjob, which
-- outside a few niche cases shouldn't come up often) to whichever existing BLU set is the closest
-- functional match, since Lua tables are references - this makes e.g. gFunc.EquipSet('Enfeebling')
-- equip whatever's actually in BluMagicAccuracy_Priority, no gcmage.lua changes needed. If a set ends
-- up unmapped here (Nuke/MB family, Banish, Cure5, Cursna, StunACC, Hate, TP, etc.) and you hit a
-- "Set not found" for it, it's not aliased - either add a line here or just fill in that set directly.
sets.Enfeebling = sets.BluMagicAccuracy_Priority
sets.EnfeeblingACC = sets.BluMagicAccuracy_Priority
sets.EnfeeblingINT = sets.BluMagical_INT_Priority
sets.EnfeeblingMND = sets.BluMagical_MND_Priority
sets.Nuke = sets.BluMagical_INT_Priority
sets.NukeACC = sets.BluMagicAccuracy_Priority
sets.NukeDOT = sets.BluMagical_INT_Priority
sets.NukeHNM = sets.BluMagical_INT_Priority
sets.MB = sets.BluMagical_INT_Priority
sets.MBHNM = sets.BluMagical_INT_Priority
sets.Banish = sets.BluMagical_INT_Priority
sets.Cure5 = sets.Cure_Priority
sets.Cursna = sets.Cure_Priority
sets.StunACC = sets.BluStun_Priority
sets.Hate = sets.Enmity_Priority
sets.Hate_Flash = sets.Enmity_Priority
sets.Support_Flash = sets.Enmity_Priority
sets.TP = sets.TP_LowAcc_Priority

profile.Sets = gcmelee.AppendSets(gcmage.AppendSets(sets))

-- Casting a spell mid-fight normally swaps Main/Sub/Range/Ammo to whatever the cast's gear set
-- specifies, which resets TP if it changes weapons. Whenever we have TP banked, this locks those
-- four slots back to the appropriate TP set's weapons - built directly from our own set definitions
-- rather than reading back live equipment state, since equip commands are async and reading gear
-- back in the same tick they were issued can catch stale (pre-swap) data and cause flicker.
-- The _Priority convention wraps single items as { 'Item Name' }. That wrapping is only understood
-- by the engine when resolving a set by string name (gFunc.EquipSet('SomeName')) - a literal ad-hoc
-- table built by hand, like the lock set below, needs plain values instead. This unwraps a { 'Item' }
-- down to 'Item', and passes through plain strings or { Name = ..., Augment = ... } tables unchanged.
local function UnwrapItem(item)
    if (type(item) == 'table' and item.Name == nil and item[1] ~= nil) then
        return item[1]
    end
    return item
end

-- Auto-selects the Weapon Loadout by SubJob (Weapon_Loadout_1 for NIN sub, Weapon_Loadout_2 otherwise)
-- unless weaponLoadoutManualOverride is set, in which case the manually-toggled /weapon /wl cycle value
-- is used instead. See HandleCommand for how the override gets set/cleared.
local function GetAutoWeaponLoadout()
    if (weaponLoadoutManualOverride) then
        return gcdisplay.GetCycle('Weapon Loadout')
    end

    local player = gData.GetPlayer()
    if (player.SubJob == 'NIN') then
        return '1'
    end
    return '2'
end

local function LockTPWeapon()
    local player = gData.GetPlayer()
    -- Mimics the WHM/RDM pattern of gating the weapon/range/ammo lock behind the /tp toggle - unlike
    -- those jobs, BLU still always equips its TP accessory gear (rings, body, etc.) while engaged
    -- regardless of the toggle (see the Engaged block in HandleDefault), but the lock itself only
    -- applies when the toggle isn't 'Off', so /tp off lets you freely swap Main/Sub/Range/Ammo (e.g.
    -- for a spell that needs a staff) even while TP is banked.
    if (player.TP <= 0 or gcdisplay.GetCycle('TP') == 'Off') then return end

    local lockSet = gFunc.Combine({}, sets.TP_LowAcc_Priority)
    if (player.SubJob == 'NIN') then
        lockSet = gFunc.Combine(lockSet, sets.TP_NIN_Priority)
    end
    if (gcdisplay.GetCycle('TP') == 'HighAcc') then
        lockSet = gFunc.Combine(lockSet, sets.TP_HighAcc_Priority)
    end

    -- Main/Sub now live in the active Weapon Loadout set rather than the TP sets themselves, so layer
    -- that on top to pick up the actual weapon in use.
    local weaponSet = sets['Weapon_Loadout_' .. GetAutoWeaponLoadout() .. '_Priority']
    if (weaponSet ~= nil) then
        lockSet = gFunc.Combine(lockSet, weaponSet)
    end

    gFunc.EquipSet({
        Main = UnwrapItem(lockSet.Main),
        Sub = UnwrapItem(lockSet.Sub),
        Range = UnwrapItem(lockSet.Range),
        Ammo = UnwrapItem(lockSet.Ammo),
    })
end

profile.SetMacroBook = function()
    AshitaCore:GetChatManager():QueueCommand(1, '/macro book 5')
    AshitaCore:GetChatManager():QueueCommand(1, '/macro set 1')
end

profile.OnLoad = function()
    gcmage.Load(gcmage.GetVer())

    gcdisplay.CreateToggle('BLUExtra', false)

    -- weapon/wl are already aliased automatically by gcmage.Load() above (part of its own AliasList),
    -- but weaponauto/extra are entirely our own custom commands and need their own explicit alias
    -- registration, or Ashita has no idea to route /weaponauto and /extra to HandleCommand at all.
    gcinclude.SetAlias(T{'weaponauto', 'extra'})

    profile.SetMacroBook()
end

profile.OnUnload = function()
    gcmage.Unload()
    gcinclude.ClearAlias(T{'weaponauto', 'extra'})
end

profile.HandleCommand = function(args)
    if (args[1] == 'weapon' or args[1] == 'wl') then
        weaponLoadoutManualOverride = true
    elseif (args[1] == 'weaponauto') then
        weaponLoadoutManualOverride = false
        gcinclude.Message('Weapon Loadout', 'Auto (' .. GetAutoWeaponLoadout() .. ')')
        return
    elseif (args[1] == 'extra') then
        gcdisplay.AdvanceToggle('BLUExtra')
        gcinclude.Message('BLUExtra', gcdisplay.GetToggle('BLUExtra'))
        return
    end

    gcmage.DoCommands(args, sets)

    if (args[1] == 'horizonmode') then
        profile.HandleDefault()
    end
end

profile.HandleAbility = function()
    gcmage.DoAbility()

    local ability = gData.GetAction()
    if (string.match(ability.Name, 'Provoke')) then gFunc.EquipSet('Enmity') end
end

profile.HandleItem = function()
    gcinclude.DoItem()
end

profile.HandlePreshot = function()
    gFunc.EquipSet('Preshot')
    gFunc.EquipSet('Ranged')
end

profile.HandleMidshot = function()
    gFunc.EquipSet('Midshot')
end

profile.HandleWeaponskill = function()
    local ws = gData.GetAction()

    gFunc.EquipSet('Ws_Default')
    gcmelee.DoFenrirsEarring()

    if (ws.Name == 'Vorpal Blade') then
        gFunc.EquipSet('Vorpal_Default')
    elseif (ws.Name == 'Savage Blade') then
        gFunc.EquipSet('Savage_Default')
    elseif (ws.Name == 'Expiacion') then
        gFunc.EquipSet('Expiacion_Default')
    end

    if (gcdisplay.GetCycle('TP') == 'HighAcc') then
        gFunc.EquipSet('Ws_HighAcc')
    end
end

profile.HandleDefault = function()
    local myLevel = AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel();
    if (myLevel ~= Settings.CurrentLevel) then
        gFunc.EvaluateLevels(profile.Sets, myLevel);
        Settings.CurrentLevel = myLevel;
    end

    local player = gData.GetPlayer()
    local zone = gData.GetEnvironment()

    gcmage.DoDefault(sets, ninSJMaxMP, whmSJMaxMP, blmSJMaxMP, rdmSJMaxMP, drkSJMaxMP)

    -- Calls gcinclude.DoDefaultOverride directly rather than going through gcmage.DoDefaultOverride's
    -- wrapper. That wrapper adds a "MaxMP Resting" feature (WHM/BLM/RDM/SMN-oriented) that, once MP
    -- hits 95%, bypasses the correct 16-second-timer Resting gear entirely and re-equips Idle gear +
    -- dark_staff (Pluto's Staff) every tick instead - which is exactly why Pluto's Staff was jumping in
    -- immediately on Resting and the real Resting set never stuck. gcinclude.DoDefaultOverride(false)
    -- is the actual underlying function with the correct timer-gated Resting logic, with none of that.
    -- The wrapper's other addition, gcmage.EquipWeaponLoadout(), is redundant for us anyway since we
    -- apply our own auto-selected Weapon Loadout unconditionally below.
    gcinclude.DoDefaultOverride(false)

    -- Corrected, self-contained version of gcmage.lua's "MaxMP Resting" feature: once MP tops off
    -- while resting, there's no more benefit to Resting-tick gear, so switch to an MP-conservation
    -- idle set instead. Applied AFTER the correct timer-gated Resting call above, so it only ever WINS
    -- (overrides) rather than racing/blocking it like the original bug - Resting gear still gets its
    -- correct chance to show for the full window between the 16s timer expiring and MP actually
    -- reaching 95%. Fill in real gear for IdleMaxMP_Priority if you want this to do anything.
    if (player.Status == 'Resting') then
        if (player.MPP >= 95 or restingMaxMP) then
            restingMaxMP = true
            gFunc.EquipSet('IdleMaxMP')
            if (conquest:GetOutsideControl()) then
                gFunc.EquipSet('republic_gold_medal')
            end
        end
    else
        restingMaxMP = false
    end

    -- Self-contained "Extra mode": while idle (not resting, not engaged - those have their own gear
    -- priorities already) with /extra toggled on and current MP still at or above extraThreshold, stay
    -- in IdleMaxMP-conservation gear instead of normal Idle gear.
    if (player.Status ~= 'Resting' and player.Status ~= 'Engaged' and gcdisplay.GetToggle('BLUExtra') and player.MP >= extraThreshold) then
        gFunc.EquipSet('IdleMaxMP')
    end

    -- Always equip a TP set while engaged, regardless of the shared /tp toggle's Off/LowAcc/HighAcc
    -- state (gcmage.DoDefault's built-in TP dispatch only fires when that toggle isn't 'Off', which
    -- doesn't fit how BLU should play). TP_LowAcc is the base; NIN subjob gear layers on top of that
    -- if applicable; the /tp toggle's HighAcc layers on top of that again, so HighAcc always wins any
    -- slot it shares with TP_NIN, regardless of subjob.
    if (player.Status == 'Engaged') then
        gFunc.EquipSet('TP_LowAcc')

        if (zone.WeatherElement ~= 'Dark') then gFunc.EquipSet('TP_Ear2') end
        if (zone.Time >= 6 and zone.Time < 18 and player.SubJob ~= 'NIN') then gFunc.EquipSet('tp_fenrirs_earring') end
        if (gData.GetBuffCount(580) > 0) then gFunc.EquipSet('TP_Mjollnir_Haste') end -- Horizon Mjollnir Haste Buff

        if (player.SubJob == 'NIN') then
            gFunc.EquipSet('TP_NIN')
        end
        if (gcdisplay.GetCycle('TP') == 'HighAcc') then
            gFunc.EquipSet('TP_HighAcc')
        end

        -- gcmage.EquipWeaponLoadout() only fires when the /tp toggle isn't 'Off', which doesn't fit
        -- the "always equip while engaged" behavior we want, so apply the active loadout directly.
        -- Loadout is auto-selected by SubJob (see GetAutoWeaponLoadout above) rather than the manual
        -- /weapon toggle: Weapon_Loadout_1 for NIN sub, Weapon_Loadout_2 otherwise.
        gFunc.EquipSet('Weapon_Loadout_' .. GetAutoWeaponLoadout())
    end

    -- lazy equip weapons for salvage runs
    if (zone.Area ~= nil and zone.Area:contains('Remnants')) then
        gFunc.EquipSet('Salvage')
    end

    LockTPWeapon()

    gFunc.EquipSet(gcinclude.BuildLockableSet(gData.GetEquipment()))
end

profile.HandlePrecast = function()
    local action = gData.GetAction()

    gFunc.EquipSet('Precast')
    if (string.contains(action.Skill, 'Blue Magic')) then
        gFunc.EquipSet('Blu_Precast')
    elseif (string.contains(action.Name, 'Stoneskin')) then
        gFunc.EquipSet('Stoneskin_Precast')
    end

    local castDelay = ((action.CastTime * (1 - fastCastValue)) / 1000) - 0.4
    if (castDelay >= 0.25) then
        gFunc.SetMidDelay(castDelay)
        gcinclude.DoCancel(action, castDelay - 0.4)
    end

    LockTPWeapon()
end

profile.HandleMidcast = function()
    local action = gData.GetAction()
    gFunc.EquipSet('Haste') -- e.g. NIN subjob Utsusemi recast

    if (BluMagBreath:contains(action.Name)) then
        gFunc.EquipSet('BluBreath')
        gcmage.EquipObi(action)
        gcmage.EquipStaff()
    elseif (BluMagPhys:contains(action.Name) or BluPhysStun:contains(action.Name)) then
        -- Inlined from what used to be a custom gcmelee.EquipBluPhysical() addition, so BLU.lua no
        -- longer depends on any non-upstream change to gcmelee.lua.
        local physCa = gData.GetBuffCount('Chain Affinity')
        local physBa = gData.GetBuffCount('Burst Affinity')
        local physDiff = gData.GetBuffCount('Diffusion')

        gFunc.EquipSet('BluPhysical')

        if (physCa >= 1) then gFunc.EquipSet('Ca') end
        if (physBa >= 1) then gFunc.EquipSet('Ba') end
        if (physDiff >= 1) then gFunc.EquipSet('Diffusion') end

        if (BluPhysSTR:contains(action.Name)) then gFunc.EquipSet('BluPhysical_STR')
        elseif (BluPhysDEX:contains(action.Name)) then gFunc.EquipSet('BluPhysical_DEX')
        elseif (BluPhysVIT:contains(action.Name)) then gFunc.EquipSet('BluPhysical_VIT')
        elseif (BluPhysAGI:contains(action.Name)) then gFunc.EquipSet('BluPhysical_AGI')
        elseif (BluPhysCHR:contains(action.Name)) then gFunc.EquipSet('BluPhysical_CHR')
        end
        if (gcdisplay.GetCycle('TP') == 'HighAcc') and (BluePhysMulti:contains(action.Name)) then gFunc.EquipSet('TP_HighAcc')
end

        -- Stun-type spells (Head Butt, Frypan, etc.) are physical, not magical - they now get
        -- BluPhysical as their base like every other physical Blue Magic spell, with BluStun layered
        -- on top as the stun-specific overlay, instead of layering over BluMagical like before.
        if (BluPhysStun:contains(action.Name)) then gFunc.EquipSet('BluStun') end
    elseif (action.Skill == 'Blue Magic') then
        if (BluMagBuff:contains(action.Name)) then
            gFunc.EquipSet('ConserveMP') -- non-skill-scaling buffs (Refueling, Plasma Charge, etc.)
        elseif (BluMagSkill:contains(action.Name)) then
            gFunc.EquipSet('BluSkill') -- skill-scaling buffs/defenses (e.g. Zephyr Mantle)
        elseif (BluMagDebuff:contains(action.Name)) then
            gFunc.EquipSet('BluMagicAccuracy')
        else
            gFunc.EquipSet('BluMagical')
            if (BluMagCure:contains(action.Name)) then gFunc.EquipSet('Cure')
            elseif (BluMagEnmity:contains(action.Name)) then gFunc.EquipSet('Enmity')
            elseif (action.Name == 'White Wind') then gFunc.EquipSet('WhiteWind')
            else
                -- Generic magic-damage nuke (including Everyone's Grudge/Tenebral Crush, which used to
                -- get a dedicated BluDark set - now just fall through to their stat-mod classification
                -- like everything else): layer the stat-specific subset on top of BluMagical. INT is
                -- the default for anything not explicitly MND/CHR/INT-classified above.
                if (BluMagMND:contains(action.Name)) then gFunc.EquipSet('BluMagical_MND')
                elseif (BluMagCHR:contains(action.Name)) then gFunc.EquipSet('BluMagical_CHR')
                elseif (BluMagINT:contains(action.Name)) then gFunc.EquipSet('BluMagical_INT')
                else gFunc.EquipSet('BluMagical') -- unclassified spells still default to INT
                end

                -- Mirrors gcmage.lua's EquipHealing/EquipDivine trigger for Uggalepih Pendant (MP
                -- recovered on HP recovery magic cast) - self-contained here since BLU's dispatch never
                -- goes through those gcmage functions. Only applies to the INT/MND/CHR nuke spells
                -- above, not Cure (that trigger is WHM-specific). Reuses the shared uggalepih_pendant
                -- item set from gcmage.AppendSets rather than duplicating it.
                if (action.MppAftercast < 51) then
                    gFunc.EquipSet('uggalepih_pendant')
                end

                -- Self-contained "Extra mode": if /extra is on and you'll still have plenty of MP left
                -- after this cast, layer the stat-appropriate _Extra variant on top instead of the
                -- regular BluMagical_INT/MND/CHR set just applied above - the BLU-specific equivalent
                -- of NukeExtra/etc, checked against post-cast MP since the point is "can I afford
                -- another one right after this."
                if (gcdisplay.GetToggle('BLUExtra') and action.MpAftercast >= extraThreshold) then
                    if (BluMagMND:contains(action.Name)) then gFunc.EquipSet('BluMagical_MND_Extra')
                    elseif (BluMagCHR:contains(action.Name)) then gFunc.EquipSet('BluMagical_CHR_Extra')
                    else gFunc.EquipSet('BluMagical_INT_Extra') -- covers BluMagINT and the unclassified default
                    end
                end
            end

            local ca = gData.GetBuffCount('Chain Affinity')
            local ba = gData.GetBuffCount('Burst Affinity')
            local diff = gData.GetBuffCount('Diffusion')

            if (ca >= 1) then gFunc.EquipSet('Ca') end
            if (ba >= 1) then gFunc.EquipSet('Ba') end
            if (diff >= 1) then gFunc.EquipSet('Diffusion') end
        end

        -- Swap to the elemental staff/obi matching this spell's element (action.Element), the same way
        -- gcmage.DoMidcast does for WHM/BLM/RDM/SMN/BRD - EquipObi checks environment.WeatherElement/
        -- DayElement against action.Element and only equips an obi if you own one and it's active;
        -- EquipStaff checks environment.DayElement/WeatherElement and lastSummoningElement internally
        -- via the shared ElementalStaffTable. Both silently no-op for non-elemental Blue Magic spells.
        gcmage.EquipObi(action)
        gcmage.EquipStaff()
    else
        -- Anything that isn't a Blue Magic spell (e.g. actual White Magic Cure from a WHM subjob,
        -- Utsusemi/Stoneskin from NIN, Dia/Bio from RDM, etc.) gets handled by the same shared
        -- gcmage.DoMidcast dispatch RDM/WHM/BLM/SMN/BRD use, rather than us hand-rolling a branch for
        -- every possible subjob spell here. Requires SIRD/SIRD_NIN to exist in the sets table above
        -- (direct field access, not the bare-name alias mechanism) or this crashes for NIN subs.
        gcmage.DoMidcast(sets, ninSJMaxMP, whmSJMaxMP, blmSJMaxMP, rdmSJMaxMP, drkSJMaxMP)

        -- Self-contained Extra mode extension for Stoneskin/Phalanx (Enhancing Magic spells reachable
        -- via a subjob through the DoMidcast fallback above). gcmage.lua's own StoneskinExtra/
        -- PhalanxExtra dispatch inside EquipEnhancing is hard-gated to MainJob == 'BLM', so it can
        -- never fire for BLU - same story as NukeExtra, handled here instead.
        if (gcdisplay.GetToggle('BLUExtra') and action.MpAftercast >= extraThreshold) then
            if (action.Name == 'Stoneskin') then
                gFunc.EquipSet('StoneskinExtra')
            elseif (action.Name == 'Phalanx') then
                gFunc.EquipSet('PhalanxExtra')
            end
        end
    end

    LockTPWeapon()
end

return profile
