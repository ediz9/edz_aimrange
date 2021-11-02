local target, targetCoords = nil, nil
local score, count = 0, 0
local start = false
local message, messageTime = false, 5
local animTime = 1500
local check = true
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
end)

function LoadingPrompt()
    exports['mythic_notify']:SendAlert('inform', '3')
    PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS")
    Wait(1000)
    exports['mythic_notify']:SendAlert('inform', '2')
    PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS")
    Wait(1000)
    exports['mythic_notify']:SendAlert('inform', '1')
    PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS")
    Wait(1000)
    exports['mythic_notify']:SendAlert('inform', 'Başla!')
end

function CreateGame(time, targets)
    if not start then
        start = true
        Wait(1000)
        ESX.UI.Menu.CloseAll()
        TriggerServerEvent('edz_aimrange:sendToServer', false)
        LoadingPrompt()
        repeat
            count = count + 1
            x = math.random(#Config.AimRange.targets)
            targetCoords = Config.AimRange.targets[x]
            target = CreateObject(GetHashKey('prop_range_target_01'), targetCoords.x, targetCoords.y, targetCoords.z, true, true, true)
            SetEntityRotation(target, -74.99995, 1.5008e-07, 2.299998)
            Wait(15)
            repeat
                animTime = animTime - 100
                Wait(15)
                rotation = GetEntityRotation(target)
                SetEntityRotation(target, rotation.x + 5, rotation.y, rotation.z)
            until animTime == 0
            animTime = 1500
            Wait(time)
            repeat
                animTime = animTime - 100
                Wait(15)
                rotation = GetEntityRotation(target)
                SetEntityRotation(target, rotation.x - 5, rotation.y, rotation.z)
            until animTime == 0
            animTime = 1500
            DeleteObject(target)
            target = nil
            targetCoords = nil
        until count == targets

        TriggerServerEvent('edz_aimrange:sendToServer', true)
        exports['mythic_notify']:SendAlert('inform', 'SKOR: '..score, 7500)
        start = false
        score = 0
        count = 0
    end
end

function DrawText3D(x,y,z, text)
    local onScreen, _x, _y = World3dToScreen2d(x,y,z)
    if onScreen then
        local factor = #text / 420
        SetTextScale(0.30, 0.30)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry('STRING')
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        DrawRect(_x, _y + 0.0120, 0.006 + factor, 0.024, 0, 0, 0, 155)
    end
end

function OpenGameMenu()
    local elements = {}

    if check then
        table.insert(elements, { label = 'Bilgilendirme', value = 'bilgi'})
        table.insert(elements, { label = Config.AimRange.level.easy.label, value = 'easy'})
        table.insert(elements, { label = Config.AimRange.level.medium.label, value = 'medium'})
        table.insert(elements, { label = Config.AimRange.level.hard.label, value = 'hard'})
    else
        table.insert(elements, { label = Config.AimRange.busyText, value = '#'})
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'aimrange',
    {
        title    = 'Poligon',
        align    = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'easy' then
            CreateGame(Config.AimRange.level.easy.spawnTime, Config.AimRange.targetCount)
        elseif data.current.value == 'medium' then
            CreateGame(Config.AimRange.level.medium.spawnTime, Config.AimRange.targetCount)
        elseif data.current.value == 'hard' then
            CreateGame(Config.AimRange.level.hard.spawnTime, Config.AimRange.targetCount)
        elseif data.current.value == 'bilgi' then
            exports['mythic_notify']:SendAlert('inform', Config.AimRange.infoText, 7500)
        end
    end, function(data, menu)
        menu.close()
    end)
end

function DrawScore(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

RegisterNetEvent('edz_aimrange:sendToClient')
AddEventHandler('edz_aimrange:sendToClient', function(value)
    check = value
end)

Citizen.CreateThread( function()
    while true do
        sleepThread = 1000
        local ped = PlayerPedId()
        local pedCo = GetEntityCoords(ped)
        local rangeCo = Config.AimRange.coords
        local dist = GetDistanceBetweenCoords(pedCo, rangeCo, true)

        if dist <= 5.0 then
            sleepThread = 5
            DrawMarker(2, rangeCo.x, rangeCo.y, rangeCo.z-0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 32, 236, 54, 100, 0, 1, 0, 0, 0, 0, 0)
            if dist <= 2.0 then
                sleepThread = 5
                DrawText3D(rangeCo.x, rangeCo.y, rangeCo.z+0.1, Config.AimRange.intText)
                if IsControlJustPressed(0, 38) then
                    OpenGameMenu()
                end
            end 
        end
        Citizen.Wait(sleepThread)
    end
end)

-- thx to s0ig for shoot detect method
Citizen.CreateThread( function()
    while true do
    sleepThread = 1000
    if start then
        sleepThread = 1
        if target then
            sleepThread = 1
            if HasEntityBeenDamagedByAnyPed(target) then
                if HasBulletImpactedInBox(targetCoords.x+0.06,targetCoords.y+0.12,targetCoords.z+0.46,  targetCoords.x-0.06,targetCoords.y,targetCoords.z+0.6,true,true) then
                    score = score + 5
                elseif HasBulletImpactedInBox(targetCoords.x+0.11,targetCoords.y+0.12,targetCoords.z+0.41,  targetCoords.x-0.11,targetCoords.y,targetCoords.z+0.69,true,true) then
                    score = score + 4
                elseif HasBulletImpactedInBox(targetCoords.x+0.16,targetCoords.y+0.12,targetCoords.z+0.33,  targetCoords.x-0.16,targetCoords.y,targetCoords.z+0.76,true,true) then
                    score = score + 3
                elseif HasBulletImpactedInBox(targetCoords.x+0.21,targetCoords.y+0.12,targetCoords.z+0.25,  targetCoords.x-0.21,targetCoords.y,targetCoords.z+0.85,true,true) then
                    score = score + 2
                else
                    score = score + 1
                end
                --## target anim problem ##--
                -- repeat
                --     animTime = animTime - 100
                --     Wait(15)
                --     rotation = GetEntityRotation(target)
                --     SetEntityRotation(target, rotation.x - 10, rotation.y, rotation.z)
                -- until animTime == 0
                -- animTime = 1500
                DeleteObject(target)
                target = nil
                targetCoords = nil
            end
        end
    end
    Citizen.Wait(sleepThread)
    end
end)
