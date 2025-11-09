local Open = false
local mapProp = nil
local canOpenMenu = false

CreateThread(function()
    while true do
        Wait(0)
        DisableControlAction(0, 'INPUT_FRONTEND_PAUSE') 
        DisableControlAction(0, 'INPUT_FRONTEND_PAUSE_ALTERNATE') 
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if IsDisabledControlJustPressed(0, 'INPUT_FRONTEND_PAUSE_ALTERNATE') 
        or IsDisabledControlJustPressed(0, 'INPUT_FRONTEND_PAUSE') then
            if canOpenMenu then
                OpenPauseMenu()
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(500)
        if Open then
            local ped = PlayerPedId()
            if IsPedDeadOrDying(ped, false) or IsUiappRunningByHash(`MAP`) == 1 then
                ClosePauseMenu()
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(100)

        local ped = PlayerPedId()
        canOpenMenu = false

        if not IsPauseMenuActive() and not Open then
            if IsUiappRunningByHash(`MAP`) ~= 1 then 
                
                if Config.Framework == 'vorp' then
                    local invActive = LocalPlayer.state.IsInvActive
                    if LocalPlayer.state.IsInSession
                    and not LocalPlayer.state.PlayerIsInCharacterShops
                    and not LocalPlayer.state.IsInvOpen
                    and not invActive then
                        canOpenMenu = true
                    end

                elseif Config.Framework == 'rsg' then
                    if LocalPlayer.state.isLoggedIn
                    and not LocalPlayer.state.inClothingStore
                    and not LocalPlayer.state.inv_busy
                    and not LocalPlayer.state.isDead then
                        canOpenMenu = true
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    local lastMinute = -1
    while true do
        Wait(0)
        if Open then
            local hour = GetClockHours()
            local minute = GetClockMinutes()
            if minute ~= lastMinute then
                lastMinute = minute
                local timeString = string.format("%02d:%02d", hour, minute)
                SendNUIMessage({ action = "updateClock", time = timeString })
            end
        end
    end
end)

RegisterNetEvent("pausemenu:receiveRules")
AddEventHandler("pausemenu:receiveRules", function(data)
    SendNUIMessage({
        action = "loadRules",
        rules = data
    })
end)

RegisterNUICallback('ToggleMenu', function(_, cb)
    if Open then
        ClosePauseMenu()
    end
    cb('ok')
end)

RegisterNUICallback('exit', function(_, cb)
    ClosePauseMenu()
    cb('ok')
end)

RegisterNUICallback('SendAction', function(data, cb)
    cb('ok')

    if data.action == 'settings' then
        LaunchUiAppByHash(`settings_menu`)
    elseif data.action == 'map' then
        LaunchUiAppByHash(`map`)
    elseif data.action == 'exit' then
        TriggerServerEvent("pausemenu:quit")
    end

    if data.action ~= 'rules' then
        ClosePauseMenu()
    end
end)

function LaunchUiAppByHash(hash)
    Citizen.InvokeNative(0xC8FC7F4E4CF4F581, hash)
end

function OpenPauseMenu()
    if not Open and not IsPauseMenuActive() then
        Wait(200)
        SetNuiFocus(true, true)
        SendNUIMessage({ 
            action = 'show',
            labels = Config.MenuLabels
        })

        Open = true
        TriggerServerEvent("pausemenu:getRules")

        local playerPed = PlayerPedId()

        if mapProp then
            DeleteObject(mapProp)
            mapProp = nil
        end

        local animDict = "mech_inspection@mini_map@base"
        local animName = "hold"

        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(10)
        end

        TaskPlayAnim(playerPed, animDict, animName, 1.0, 1.0, -1, 25, 0, false, false, false)
        Wait(500)
        SetEntityAnimSpeed(playerPed, animDict, animName, 0.8)

        local model = GetHashKey("mp001_mp_map01x")
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(10)
        end

        mapProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
        local boneIndex = GetEntityBoneIndexByName(playerPed, "XH_L_Hand00")
        AttachEntityToEntity(mapProp, playerPed, boneIndex, -0.05, 0.12, 0.36, -31.0, -119.0, 14.0, true, true, false, true, 1, true)
    end
end

function ClosePauseMenu()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    Open = false

    local playerPed = PlayerPedId()
    if IsEntityPlayingAnim(playerPed, "mech_inspection@mini_map@base", "hold", 3) then
        StopAnimTask(playerPed, "mech_inspection@mini_map@base", "hold", 1.0)
    end

    if mapProp then
        DetachEntity(mapProp, true, true)
        DeleteObject(mapProp)
        mapProp = nil
    end
end
