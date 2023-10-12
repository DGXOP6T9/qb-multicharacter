local QBCore = exports['qb-core']:GetCoreObject()
local cam = nil
local charPed = nil
local vehicle = nil
local vehicleBack = nil
local prop = nil
local NewPeds = {}

-- Main Thread

CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
			TriggerEvent('qb-multicharacter:client:chooseChar')
			return
		end
	end
end)

-- Functions
local function skyCam(bool)
    TriggerEvent('qb-weathersync:client:DisableSync')
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        FreezeEntityPosition(PlayerPedId(), false)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.CamCoords.x, Config.CamCoords.y, Config.CamCoords.z, -16.0 ,0.0, Config.CamCoords.w, 50.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)

        -- Enable weather synchronization
        TriggerEvent('qb-weathersync:client:EnableSync')
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)

        -- Disable weather synchronization
        TriggerEvent('qb-weathersync:client:DisableSync')
    end
end


local function RemoveTrain()
	if vehicle ~= nil then
		DeleteEntity(vehicle)
		DeleteEntity(vehicleBack)
        vehicle = nil
        vehicleBack = nil
	end
end



AddEventHandler('onClientResourceStart', function (resourceName)
	if(GetCurrentResourceName() ~= resourceName) then
	  return
	end
    RemoveTrain()
  end)

AddEventHandler('onClientResourceStop', function (resourceName)
	if(GetCurrentResourceName() ~= resourceName) then
	  return
	end
    RemoveTrain()
  end)

local function Lerp(a, b, t)
	return a + (b - a) * t
end

local function VecLerp(x1, y1, z1, x2, y2, z2, l, clamp)
    if clamp then
        if l < 0.0 then l = 0.0 end
        if l > 1.0 then l = 1.0 end
    end
    local x = Lerp(x1, x2, l)
    local y = Lerp(y1, y2, l)
    local z = Lerp(z1, z2, l)
    return vector3(x, y, z)
end

local function StartTrain()
    RemoveTrain()
	local tempmodel = GetHashKey(Config.Plane)
	RequestModel(tempmodel)
	while not HasModelLoaded(tempmodel) do
		RequestModel(tempmodel)
		Wait(0)
	end
    local coords = vector3(Config.TrainCoord.Start[1], Config.TrainCoord.Start[2], Config.TrainCoord.Start[3])
    vehicle = CreateVehicle(tempmodel, coords, Config.TrainCoord.Heading, false, false)
    FreezeEntityPosition(vehicle, true)

    CreateThread(function()
        local coords2 = vector3(Config.TrainCoord.Stop[1], Config.TrainCoord.Stop[2], Config.TrainCoord.Stop[3])
	    for i=1,100 do
	    	local setpos = VecLerp(coords[1],coords[2],coords[3], coords2[1],coords2[2],coords2[3], i/100, true)
	    	SetEntityCoords(vehicle,setpos)
	  		Wait(15)
	    end
	end)
end

local function openCharMenu(bool)
    QBCore.Functions.TriggerCallback("qb-multicharacter:server:GetNumberOfCharacters", function(result)
        SetNuiFocus(bool, bool)
        SendNUIMessage({
            action = "ui",
            toggle = bool,
            nChar = result,
        })
        skyCam(bool)
    end)
end

-- Events

RegisterNetEvent('qb-multicharacter:client:closeNUIdefault', function() -- This event is only for no starting apartments
    DeleteEntity(charPed)
    NewPeds[k].prop = prop -- Store the prop reference in the table
    for k, v in pairs(NewPeds) do
        SetEntityAsMissionEntity(v[1], true, true)
        DeleteEntity(v[1])

        if v.prop and DoesEntityExist(v.prop) then
            DeleteEntity(v.prop)
        end

        NewPeds[k] = nil -- Remove the ped entry from the table
    end
    NewPeds = {}
    SetNuiFocus(false, false)
    DoScreenFadeOut(500)
    Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    Wait(500)
    openCharMenu()
    SetEntityVisible(PlayerPedId(), true)
    Wait(500)
    DoScreenFadeIn(250)
    TriggerEvent('qb-weathersync:client:EnableSync')
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end)

RegisterNetEvent('qb-multicharacter:client:closeNUI', function()
    DeleteEntity(charPed)
    NewPeds[k].prop = prop -- Store the prop reference in the table
    for k, v in pairs(NewPeds) do
        SetEntityAsMissionEntity(v[1], true, true)
        DeleteEntity(v[1])

        if v.prop and DoesEntityExist(v.prop) then
            DeleteEntity(v.prop)
        end

        NewPeds[k] = nil -- Remove the ped entry from the table
    end
    NewPeds = {}
    SetNuiFocus(false, false)
end)

RegisterNetEvent('qb-multicharacter:client:chooseChar', function()
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    Wait(1000)
    local interior = GetInteriorAtCoords(Config.Interior.x, Config.Interior.y, Config.Interior.z - 18.9)
    LoadInterior(interior)
    while not IsInteriorReady(interior) do
        Wait(1000)
    end
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
    Wait(1500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    TriggerEvent("loading:disableLoading")
    openCharMenu(true)
end)

-- NUI Callbacks

RegisterNUICallback('closeUI', function()
    openCharMenu(false)
end)

RegisterNUICallback('disconnectButton', function()
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    for k, v in pairs(NewPeds) do
        SetEntityAsMissionEntity(v[1], true, true)
        DeleteEntity(v[1])

        if v.prop and DoesEntityExist(v.prop) then
            DeleteEntity(v.prop)
        end

        NewPeds[k] = nil -- Remove the ped entry from the table
    end
    NewPeds = {}
    TriggerServerEvent('qb-multicharacter:server:disconnect')
end)

RegisterNUICallback('selectCharacter', function(data)
    local cData = data.cData
    RemoveTrain()
    DoScreenFadeOut(10)
    TriggerServerEvent('qb-multicharacter:server:loadUserData', cData)
    openCharMenu(false)
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    for k, v in pairs(NewPeds) do
        SetEntityAsMissionEntity(v[1], true, true)
        DeleteEntity(v[1])

        if v.prop and DoesEntityExist(v.prop) then
            DeleteEntity(v.prop)
        end

        NewPeds[k] = nil -- Remove the ped entry from the table
    end
    NewPeds = {}
end)


RegisterNUICallback('setupCharacters', function()
    RemoveTrain()
    StartTrain()
    Wait(3000) -- Delay of 5 seconds
    for k, v in pairs(NewPeds) do
        SetEntityAsMissionEntity(v[1], true, true)
        DeleteEntity(v[1])

        if v.prop and DoesEntityExist(v.prop) then
            DeleteEntity(v.prop)
        end

        NewPeds[k] = nil -- Remove the ped entry from the table
    end
    NewPeds = {}
    QBCore.Functions.TriggerCallback("qb-multicharacter:server:SetupNewCharacter", function(result)
        for k, v in pairs(result) do 
            local model = tonumber(v[1])
            if model ~= nil then
                CreateThread(function()
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(0)
                    end
                    if Config.PedCords[k] ~= nil and Config.PedCords[k][1] ~= nil and Config.PedCords[k][2] ~= nil and Config.PedCords[k][3] ~= nil then
                        local onScreen, xxx, yyy = GetHudScreenPositionFromWorldPosition(Config.PedCords[k][1], Config.PedCords[k][2], Config.PedCords[k][3])
                        SendNUIMessage({
                            action = "SetupCharacterNUI",
                            left = xxx*100,
                            top = yyy*70,
                            cid = v[3],
                            charinfo = v[4],
                            Data = v[5],
                        })
                        charPed = CreatePed(2, model, Config.PedCords[k][1], Config.PedCords[k][2], Config.PedCords[k][3], Config.PedCords[k][4], false, true)
                        SetPedComponentVariation(charPed, 0, 0, 0, 2)
                        FreezeEntityPosition(charPed, false)
                        SetEntityInvincible(charPed, true)
                        PlaceObjectOnGroundProperly(charPed)
                        SetBlockingOfNonTemporaryEvents(charPed, true)
                        TaskLookAtCoord(charPed, -1358.10, -3203.86, 16.43, -1)
                        local data = json.decode(v[2])
                        TriggerEvent('qb-clothing:client:loadPlayerClothing', data, charPed)
                        NewPeds[k] = {charPed} -- Store the new ped in the table
                        local emoteName = "airportbag" -- The name of the emote you want to set
                        if Config.Emotes[emoteName] then
                            local emoteData = Config.Emotes[emoteName]
                            RequestModel(GetHashKey(emoteData.AnimationOptions.Prop))
                            while not HasModelLoaded(GetHashKey(emoteData.AnimationOptions.Prop)) do
                                Wait(0)
                            end
                            local prop = CreateObject(GetHashKey(emoteData.AnimationOptions.Prop), 0.0, 0.0, 0.0, true, true, true)
                            AttachEntityToEntity(prop, charPed, GetPedBoneIndex(charPed, emoteData.AnimationOptions.PropBone), 
                                emoteData.AnimationOptions.PropPlacement[1], emoteData.AnimationOptions.PropPlacement[2], 
                                emoteData.AnimationOptions.PropPlacement[3], emoteData.AnimationOptions.PropPlacement[4], 
                                emoteData.AnimationOptions.PropPlacement[5], emoteData.AnimationOptions.PropPlacement[6], false, false, false, false, 2, true)
                            RequestAnimDict(emoteData[1])
                            while not HasAnimDictLoaded(emoteData[1]) do
                                Wait(0)
                            end
                            TaskPlayAnim(charPed, emoteData[1], emoteData[2], 8.0, -8.0, -1, emoteData.AnimationOptions.EmoteLoop, 
                                emoteData.AnimationOptions.EmoteMoving, false, false, false)
                            SetPedMovementClipset(charPed, "MOVE_M@BAIL_BOND_NOT_TAZERED", 1)
                            SetPedConfigFlag(charPed, 185, true)
                            NewPeds[k].prop = prop -- Store the prop reference in the table
                        else
                            print("Emote not found:", emoteName)
                        end
                    else
                        print("Missing or invalid PedCords for key:", k)
                    end
                end)
            end
            Wait(20)
        end
    end)
end)


RegisterNUICallback('removeBlur', function()
    SetTimecycleModifier('default')
end)

RegisterNUICallback('createNewCharacter', function(data)
    local cData = data
    DoScreenFadeOut(150)
    if cData.gender == "Male" then
        cData.gender = 0
    elseif cData.gender == "Female" then
        cData.gender = 1
    end
    TriggerServerEvent('qb-multicharacter:server:createCharacter', cData)
    Wait(500)
end)

RegisterNUICallback('removeCharacter', function(data)
    TriggerServerEvent('qb-multicharacter:server:deleteCharacter', data.citizenid)
    TriggerEvent('qb-multicharacter:client:chooseChar')
end)