-- Made by Rapozillha


local IsAttached = false
local BrancardObject = nil
local IsLayingOnBed = false

function SetClosestBrancard()
    local Ped = PlayerPedId()
    local c = GetEntityCoords(Ped)
    local Object = GetClosestObjectOfType(c.x, c.y, c.z, 10.0, GetHashKey("prop_ld_binbag_01"), false, false, false)

    if Object ~= 0 then
        BrancardObject = Object
    end
end

Citizen.CreateThread(function()
    while true do
        SetClosestBrancard()
        Citizen.Wait(1000)
    end
end)


Citizen.CreateThread(function()
    while true do
        local PlayerPed = PlayerPedId()
        local PlayerPos = GetEntityCoords(PlayerPed)
        
        if BrancardObject ~= nil then
            local ObjectCoords = GetEntityCoords(BrancardObject)
            local OffsetCoords = GetOffsetFromEntityInWorldCoords(BrancardObject, 0, 0.85, 0)
            local Distance = #(PlayerPos - OffsetCoords)

            if Distance <= 1.0 then
                if not IsAttached then
                    DrawText3Ds(OffsetCoords.x, OffsetCoords.y, OffsetCoords.z, '~g~E~w~ - Empurrar')
                    if IsControlJustPressed(0, 51) then
                        AttachToBrancard()
                        IsAttached = true
                    end
                    if IsControlJustPressed(0, 74) then
                        FreezeEntityPosition(BrancardObject, true)
                    end
                else
                    DrawText3Ds(OffsetCoords.x, OffsetCoords.y, OffsetCoords.z, '~g~E~w~ - Largar')
                    if IsControlJustPressed(0, 51) then
                        DetachBrancard()
                        IsAttached = false
                    end
                end

                if not IsLayingOnBed then
                    if not IsAttached then
                        DrawText3Ds(OffsetCoords.x, OffsetCoords.y, OffsetCoords.z + 0.2, '~g~G~w~ - Deitar')
                        if IsControlJustPressed(0, 47) or IsDisabledControlJustPressed(0, 47) then
                            LayOnBrancard()
                        end
                    end
                end
            elseif Distance <= 2 then
                if not IsLayingOnBed then
                    DrawText3Ds(OffsetCoords.x, OffsetCoords.y, OffsetCoords.z, 'Maca')
                else
                    if not IsAttached then
                        DrawText3Ds(OffsetCoords.x, OffsetCoords.y, OffsetCoords.z + 0.2, '~g~G~w~ - Levantar')
                        if IsControlJustPressed(0, 47) or IsDisabledControlJustPressed(0, 47) then
                            GetOffBrancard()
                        end
                    end
                end
            end
        else
            Citizen.Wait(1000)
        end

        Citizen.Wait(3)
    end
end)

RegisterNetEvent('rapozillha:client:RemoveBrancardFromArea')
AddEventHandler('rapozillha:client:RemoveBrancardFromArea', function(PlayerPos, BObject)
    local Ped = PlayerPedId()
    local Pos = GetEntityCoords(Ped)

    if Pos ~= PlayerPos then
        local Distance = #(Pos - PlayerPos)

        if BrancardObject ~= nil or BrancardObject ~= 0 then
            if BrancardObject == BObject then
                if Distance < 10 then
                    if IsEntityPlayingAnim(Ped, 'anim@heists@box_carry@', 'idle', false) then
                        DetachBrancard()
                    end

                    if IsEntityPlayingAnim(Ped, "anim@gangops@morgue@table@", "ko_front", false) then
                        local Coords = GetOffsetFromEntityInWorldCoords(Ped, 0.85, 0.0, 0)
                        ClearPedTasks(Ped)
                        DetachEntity(Ped, false, true)
                        SetEntityCoords(Ped, Coords.x, Coords.y, Coords.z)
                        IsLayingOnBed = false
                    end
                end
            end
        end
    end
end)

function LayOnBrancard()
    local inBedDicts = "anim@gangops@morgue@table@"
    local inBedAnims = "ko_front"
    local PlayerPed = PlayerPedId()
    local PlayerPos = GetEntityCoords(PlayerPed)
    local Object = GetClosestObjectOfType(PlayerPos.x, PlayerPos.y, PlayerPos.z, 3.0, GetHashKey("prop_ld_binbag_01"), false, false, false)
    -- local player, distance = GetClosestPlayer()
    local player, distance = ESX.Game.GetClosestPlayer()

    if player == -1 then
        LoadAnim(inBedDicts)
        if Object ~= nil or Object ~= 0 then
            TaskPlayAnim(PlayerPedId(), inBedDicts, inBedAnims, 8.0, 8.0, -1, 69, 1, false, false, false)
            AttachEntityToEntity(PlayerPed, Object, 0, 0, 0.0, 1.1, 0.0, 0.0, 360.0, 0.0, false, false, false, false, 2, true)
            IsLayingOnBed = true
        end
    else
        if distance < 2.0 then
            TriggerServerEvent('rapozillha:Brancard:BusyCheck', GetPlayerServerId(player), "lay")
        else
            LoadAnim(inBedDicts)
            if Object ~= nil or Object ~= 0 then
                TaskPlayAnim(PlayerPedId(), inBedDicts, inBedAnims, 8.0, 8.0, -1, 69, 1, false, false, false)
                AttachEntityToEntity(PlayerPed, Object, 0, 0, 0.0, 1.1, 0.0, 0.0, 360.0, 0.0, false, false, false, false, 2, true)
                IsLayingOnBed = true
            end
        end
    end
end

RegisterNetEvent('rapozillha:Brancard:client:BusyCheck')
AddEventHandler('rapozillha:Brancard:client:BusyCheck', function(OtherId, type)
    local ped = PlayerPedId()
    if type == "lay" then
        LoadAnim("anim@gangops@morgue@table@")
        if IsEntityPlayingAnim(ped, "anim@gangops@morgue@table@", "ko_front", 3) then
            TriggerServerEvent('rapozillha:server:BusyResult', true, OtherId, type)
        else
            TriggerServerEvent('rapozillha:server:BusyResult', false, OtherId, type)
        end
    else
        LoadAnim('anim@heists@box_carry@')
        if IsEntityPlayingAnim(ped, 'anim@heists@box_carry@', 'idle', 3) then
            TriggerServerEvent('rapozillha:server:BusyResult', true, OtherId, type)
        else
            TriggerServerEvent('rapozillha:server:BusyResult', false, OtherId, type)
        end
    end
end)

RegisterNetEvent('rapozillha:client:Result')
AddEventHandler('rapozillha:client:Result', function(IsBusy, type)
    local inBedDicts = "anim@gangops@morgue@table@"
    local inBedAnims = "ko_front"
    local PlayerPed = PlayerPedId()
    local PlayerPos = GetEntityCoords(PlayerPed)
    local Object = GetClosestObjectOfType(PlayerPos.x, PlayerPos.y, PlayerPos.z, 3.0, GetHashKey("prop_ld_binbag_01"), false, false, false)
    
    if type == "lay" then
        if not IsBusy then
            NetworkRequestControlOfEntity(BrancardObject)
            LoadAnim(inBedDicts)
            TaskPlayAnim(PlayerPedId(), inBedDicts, inBedAnims, 8.0, 8.0, -1, 69, 1, false, false, false)
            AttachEntityToEntity(PlayerPed, Object, 0, 0, 0.0, 1.1, 0.0, 0.0, 360.0, 0.0, false, false, false, false, 2, true)
            IsLayingOnBed = true
        else
            --QBCore.Functions.Notify("Deze brancard is al in gebruik!", "error")
            exports['mythic_notify']:SendAlert('error', 'Esta maca já está a ser utilizada!')
            IsLayingOnBed = false
        end
    else
        if not IsBusy then
            NetworkRequestControlOfEntity(BrancardObject)
            LoadAnim("anim@heists@box_carry@")
            TaskPlayAnim(PlayerPed, 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
            SetTimeout(150, function()
                AttachEntityToEntity(BrancardObject, PlayerPed, GetPedBoneIndex(PlayerPed, 28422), 0.0, -1.0, -0.58, 195.0, 180.0, 180.0, 90.0, false, false, true, false, 2, true)
            end)
            FreezeEntityPosition(Obj, false)
            IsAttached = true
        else
            --QBCore.Functions.Notify("This brancard is already in use!", "error")
            exports['mythic_notify']:SendAlert('error', 'Esta maca já está a ser utilizada!')
            IsAttached = false
        end
    end
end)

function GetOffBrancard()
    local PlayerPed = PlayerPedId()
    local PlayerPos = GetEntityCoords(PlayerPed)
    local Coords = GetOffsetFromEntityInWorldCoords(BrancardObject, 0.85, 0.0, 0)

    ClearPedTasks(PlayerPed)
    DetachEntity(PlayerPed, false, true)
    SetEntityCoords(PlayerPed, Coords.x, Coords.y, Coords.z)
    IsLayingOnBed = false
end

local DetachKeys = {157, 158, 160, 164, 165, 73, 36}
Citizen.CreateThread(function()
    while true do
        if IsAttached then
            for _, PressedKey in pairs(DetachKeys) do
                if IsControlJustPressed(0, PressedKey) or IsDisabledControlJustPressed(0, PressedKey) then
                    DetachBrancard()
                end
            end

            if IsPedShooting(PlayerPedId()) or IsPlayerFreeAiming(PlayerId()) or IsPedInMeleeCombat(PlayerPedId()) then
                DetachBrancard()
            end

            if IsPedDeadOrDying(PlayerPedId(), false) then
                DetachBrancard()
            end

            if IsPedRagdoll(PlayerPedId()) then
                DetachBrancard()
            end
        else
            Citizen.Wait(1000)
        end 
        Citizen.Wait(5)
    end
end)

function AttachToBrancard()
    local PlayerPed = PlayerPedId()
    -- local ClosestPlayer, distance = GetClosestPlayer()
    local ClosestPlayer, distance = ESX.Game.GetClosestPlayer()
    local PlayerPed = PlayerPedId()
    local PlayerPos = GetEntityCoords(PlayerPed)

    if BrancardObject ~= nil then
        if ClosestPlayer == -1 then
            NetworkRequestControlOfEntity(BrancardObject)
            LoadAnim("anim@heists@box_carry@")
            TaskPlayAnim(PlayerPed, 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
            SetTimeout(150, function()
                AttachEntityToEntity(BrancardObject, PlayerPed, GetPedBoneIndex(PlayerPed, 28422), 0.0, -1.0, -0.58, 195.0, 180.0, 180.0, 90.0, false, false, true, false, 2, true)
            end)
            FreezeEntityPosition(Obj, false)
        else
            if distance < 2.0 then
                TriggerServerEvent('rapozillha:Brancard:BusyCheck', GetPlayerServerId(ClosestPlayer), "attach")
            else
                NetworkRequestControlOfEntity(BrancardObject)
                LoadAnim("anim@heists@box_carry@")
                TaskPlayAnim(PlayerPed, 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
                SetTimeout(150, function()
                    AttachEntityToEntity(BrancardObject, PlayerPed, GetPedBoneIndex(PlayerPed, 28422), 0.0, -1.0, -0.58, 195.0, 180.0, 180.0, 90.0, false, false, true, false, 2, true)
                end)
                FreezeEntityPosition(Obj, false)
            end
        end
    end
end


function DetachBrancard()
    local PlayerPed = PlayerPedId()
    DetachEntity(BrancardObject, false, true)
    ClearPedTasksImmediately(PlayerPedId())
    IsAttached = false
end

-- Citizen.CreateThread(function()
--     Wait(1000)
--     local Ped = PlayerPedId()
--     local Pos = GetEntityCoords(Ped)
--     local Object = GetClosestObjectOfType(Pos.x, Pos.y, Pos.z, 5.0, GetHashKey("prop_ld_binbag_01"), false, false, false)
--     DeleteObject(Object)
--     ClearPedTasksImmediately(PlayerPedId())
-- end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if BrancardObject ~= nil then
            DetachBrancard()
            DeleteObject(BrancardObject)
            -- ClearPedTasksImmediately(PlayerPedId())
        end
    end
end)

function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(1)
    end
end

function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(1)
    end
end
