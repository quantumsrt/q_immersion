Config = {}

-- Feature Toggles
Config.EnablePersistentFlashlight = true
Config.PreventPropLoss = true
Config.DisableCombatRoll = true
Config.EnableLegInjuries = true
Config.DisableReticle = true
Config.EnableVehicleRestrictions = true

-- Injury Settings
Config.InjuryDuration = 60000 -- Duration in ms
Config.FallChance = 0.1      -- 10% chance to fall when injured

-- Vehicle Settings
Config.RollThreshold = 20.0  -- Angle at which vehicle controls are disabled

-- Vehicle Class Exclusions
Config.ExcludedVehicleClasses = {
    [8] = true,   -- Motorcycles
    [13] = true,  -- Cycles
    [14] = true,  -- Boats
    [15] = true,  -- Helicopters
    [16] = true,  -- Planes
    [21] = true   -- Trains
}

-- Specific Vehicle Model Exclusions (add any specific vehicles you want to exclude)
Config.ExcludedVehicleModels = {
    -- ["adder"] = true,
    -- ["zentorno"] = true,
}

-- Weapons that should retain their reticle
Config.ReticleEnabledWeapons = {
    "WEAPON_SNIPERRIFLE",
    "WEAPON_HEAVYSNIPER",
    "WEAPON_HEAVYSNIPER_MK2",
    "WEAPON_MARKSMANRIFLE",
    "WEAPON_MARKSMANRIFLE_MK2"
}

-- Injured Bone IDs
Config.InjuredBones = {
    [58271] = 'left',  -- Left Upper Leg
    [63931] = 'left',  -- Left Lower Leg
    [51826] = 'right', -- Right Upper Leg
    [36864] = 'right', -- Right Lower Leg
    [14201] = 'left',  -- Left Foot
    [52301] = 'right'  -- Right Foot
}