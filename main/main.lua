-- Variables
local isInjured = false
local injuredLeg = 'none'
local lastInjuryTime = 0

-- Utility Functions
local function ShowNotification(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
end

local function LoadAnimSet(animSet)
    RequestAnimSet(animSet)
    while not HasAnimSetLoaded(animSet) do
        Citizen.Wait(10)
    end
end

local function ShouldCheckVehicle(vehicle)
    if vehicle == 0 then return false end
    
    -- Check vehicle class
    local class = GetVehicleClass(vehicle)
    if Config.ExcludedVehicleClasses[class] then return false end
    
    -- Check specific model
    local model = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(model):lower()
    if Config.ExcludedVehicleModels[modelName] then return false end
    
    return true
end

-- Persistent Flashlight System
Citizen.CreateThread(function()
    while true do
        if Config.EnablePersistentFlashlight then
            local ped = PlayerPedId()
            if IsPedArmed(ped, 4) or GetCurrentPedWeapon(ped, GetHashKey("WEAPON_FLASHLIGHT")) then
                SetFlashLightKeepOnWhileMoving(true)
            end
        end
        Citizen.Wait(0)
    end
end)

-- Prop Loss Prevention
Citizen.CreateThread(function()
    while true do
        if Config.PreventPropLoss then
            local ped = PlayerPedId()
            SetPedCanLosePropsOnDamage(ped, false, 0)
        end
        Citizen.Wait(1000)
    end
end)

-- Combat Roll Prevention
Citizen.CreateThread(function()
    while true do
        if Config.DisableCombatRoll then
            local ped = PlayerPedId()
            
            -- Check if player is armed or shooting
            if IsPedArmed(ped, 1 | 2 | 4) or IsPedShooting(ped) then
                DisableControlAction(0, 22, true)
                DisableControlAction(0, 37, true)
            end
            
            -- Additional checks for shooting states
            if IsPedShooting(ped) or IsPedInCover(ped) or IsPedAimingFromCover(ped) then
                DisableControlAction(0, 22, true)
                DisableControlAction(0, 37, true)
            end
        end
        Citizen.Wait(0)
    end
end)

-- Leg Injury System
local function ApplyInjuredMovement()
    local ped = PlayerPedId()
    LoadAnimSet("move_m@injured")
    SetPedMovementClipset(ped, "move_m@injured", 1.0)
end

local function HandleLegInjury(boneId)
    if not Config.EnableLegInjuries or isInjured then return end
    
    if Config.InjuredBones[boneId] then
        isInjured = true
        injuredLeg = Config.InjuredBones[boneId]
        lastInjuryTime = GetGameTimer()
        ApplyInjuredMovement()
        ShowNotification("~r~You've been shot in the " .. injuredLeg .. " leg!")
    end
end

-- Injury Effect Management
Citizen.CreateThread(function()
    while true do
        if isInjured then
            local ped = PlayerPedId()
            local currentTime = GetGameTimer()
            
            if math.random() < Config.FallChance then
                SetPedToRagdoll(ped, 1000, 1000, 0, true, true, false)
            end
            
            if currentTime - lastInjuryTime > Config.InjuryDuration then
                isInjured = false
                injuredLeg = 'none'
                ResetPedMovementClipset(ped, 0.0)
                ShowNotification("~g~Your leg has recovered.")
            end
        end
        Citizen.Wait(1000)
    end
end)

-- Damage Event Handler
RegisterNetEvent('gameEventTriggered')
AddEventHandler('gameEventTriggered', function(name, args)
    if name == "CEventNetworkEntityDamage" then
        local victim = args[1]
        local attacker = args[2]
        local boneId = args[8]
        
        if victim == PlayerPedId() then
            HandleLegInjury(boneId)
        end
    end
end)

-- Reticle Configuration
local reticleEnabledWeaponHashes = {}
Citizen.CreateThread(function()
    -- Convert weapon names to hashes once at startup
    for _, weaponName in ipairs(Config.ReticleEnabledWeapons) do
        reticleEnabledWeaponHashes[GetHashKey(weaponName)] = true
    end
    
    while true do
        if Config.DisableReticle then
            local ped = PlayerPedId()
            local _, weapon = GetCurrentPedWeapon(ped, true)
            
            if not reticleEnabledWeaponHashes[weapon] then
                HideHudComponentThisFrame(14)
            end
        end
        Citizen.Wait(0)
    end
end)

-- Vehicle Control System
Citizen.CreateThread(function()
    while true do
        if Config.EnableVehicleRestrictions then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            -- Only apply restrictions to valid vehicles (cars, trucks, etc.)
            if ShouldCheckVehicle(vehicle) then
                local roll = math.abs(GetEntityRoll(vehicle))
                local isInAir = IsEntityInAir(vehicle)
                
                -- Only apply restrictions to valid vehicles (cars, trucks, etc.)
                if roll > Config.RollThreshold or isInAir then
                    -- Disable all vehicle controls
                    DisableControlAction(0, 71, true)    -- Forward/Accelerate
                    DisableControlAction(0, 72, true)    -- Brake/Reverse
                    DisableControlAction(0, 59, true)    -- Left/Right
                    DisableControlAction(0, 60, true)    -- Up/Down
                    DisableControlAction(0, 73, true)    -- Handbrake
                    
                    -- Kill engine only when flipped (not when in air)
                    if roll > Config.RollThreshold then
                        SetVehicleEngineOn(vehicle, false, true, true)
                    end
                    
                    -- Apply some downward force when in air to prevent floating
                    if isInAir then
                        local velocity = GetEntityVelocity(vehicle)
                        SetEntityVelocity(vehicle, velocity.x * 0.99, velocity.y * 0.99, velocity.z)
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

-- Commands
--[[ RegisterCommand('toggleflashlight', function()
    Config.EnablePersistentFlashlight = not Config.EnablePersistentFlashlight
    ShowNotification("Persistent flashlight " .. (Config.EnablePersistentFlashlight and "~g~enabled" or "~r~disabled"))
end)

RegisterCommand('toggleproploss', function()
    Config.PreventPropLoss = not Config.PreventPropLoss
    ShowNotification("Prop loss prevention " .. (Config.PreventPropLoss and "~g~enabled" or "~r~disabled"))
end)

RegisterCommand('toggleroll', function()
    Config.DisableCombatRoll = not Config.DisableCombatRoll
    ShowNotification("Combat roll " .. (Config.DisableCombatRoll and "~r~disabled" or "~g~enabled"))
end)

RegisterCommand('togglereticle', function()
    Config.DisableReticle = not Config.DisableReticle
    ShowNotification("Reticle " .. (Config.DisableReticle and "~r~disabled" or "~g~enabled"))
end)

RegisterCommand('togglevehicle', function()
    Config.EnableVehicleRestrictions = not Config.EnableVehicleRestrictions
    ShowNotification("Vehicle restrictions " .. (Config.EnableVehicleRestrictions and "~g~enabled" or "~r~disabled"))
end) ]]

-- Initial setup
--[[ AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    ShowNotification("~b~Immersion System~w~ loaded successfully!")
end) ]]