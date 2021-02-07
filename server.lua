ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('edz_aimrange:sendToServer')
AddEventHandler('edz_aimrange:sendToServer', function(value)
    TriggerClientEvent('edz_aimrange:sendToClient', -1, value)
end)