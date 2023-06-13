-- Made by Rapozillha

RegisterServerEvent('rapozillha:server:RemoveBrancard')
AddEventHandler('rapozillha:server:RemoveBrancard', function(PlayerPos, BrancardObject)
    TriggerClientEvent('rapozillha:client:RemoveBrancardFromArea', -1, PlayerPos, BrancardObject)
end)

RegisterServerEvent('rapozillha:Brancard:BusyCheck')
AddEventHandler('rapozillha:Brancard:BusyCheck', function(id, type)
    local MyId = source
    TriggerClientEvent('rapozillha:Brancard:client:BusyCheck', id, MyId, type)
end)

RegisterServerEvent('rapozillha:server:BusyResult')
AddEventHandler('rapozillha:server:BusyResult', function(IsBusy, OtherId, type)
    TriggerClientEvent('rapozillha:client:Result', OtherId, IsBusy, type)
end)


-- 2 parte
RegisterCommand("openbaydoors", function(source, args, raw)
	local player = source 
	if (player > 0) then
		TriggerClientEvent("ARPF-EMS:opendoors", source)
		CancelEvent()
	end
end, false)

RegisterCommand("togglestr", function(source, args, raw)
	local player = source 
	if (player > 0) then
		TriggerClientEvent("ARPF-EMS:togglestrincar", source)
		CancelEvent()
	end
end, false)