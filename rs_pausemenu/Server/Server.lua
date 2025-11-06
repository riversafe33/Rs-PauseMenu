RegisterServerEvent('pausemenu:quit')
AddEventHandler('pausemenu:quit', function()
    DropPlayer(source, Config.QuitMessage)
end)

RegisterNetEvent("pausemenu:getRules")
AddEventHandler("pausemenu:getRules", function()
    TriggerClientEvent("pausemenu:receiveRules", source, Config.Reglas)
end)
