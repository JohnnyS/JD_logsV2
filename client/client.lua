--[[
    #####################################################################
    #                _____           __          _                      #
    #               |  __ \         / _|        | |                     #
    #               | |__) | __ ___| |_ ___  ___| |__                   #
    #               |  ___/ '__/ _ \  _/ _ \/ __| '_ \                  #
    #               | |   | | |  __/ ||  __/ (__| | | |                 #
    #               |_|   |_|  \___|_| \___|\___|_| |_|                 #
    #                                                                   #
    #                 JD_logs By Prefech 01-11-2021                     #
    #                         www.prefech.com                           #
    #                                                                   #
    #####################################################################
]]

local configFile = LoadResourceFile(GetCurrentResourceName(), "config/config.json")
local cfgFile = json.decode(configFile)

local localsFile = LoadResourceFile(GetCurrentResourceName(), "locals/"..cfgFile['locals']..".json")
local lang = json.decode(localsFile)

if lang == nil then
    print('^5[JD_logs] ^1Error: Could not load language file. Make sure you didn\'t make a typo.^0')
    return StopResource(GetCurrentResourceName())
end

if cfgFile == nil then
    print('^5[JD_logs] ^1Error: Could not load config file. Make sure you didn\'t make a typo.^0')
    return StopResource(GetCurrentResourceName())
end

CreateThread(function()
	local DeathReason, Killer, DeathCauseHash, Weapon
	while true do
		Wait(250)
		if IsEntityDead(PlayerPedId()) then
			local PedKiller = GetPedSourceOfDeath(PlayerPedId())
			local killername = GetPlayerName(PedKiller)
			DeathCauseHash = GetPedCauseOfDeath(PlayerPedId())
			Weapon = ClientWeapons.WeaponNames[tostring(DeathCauseHash)]
			if IsEntityAPed(PedKiller) and IsPedAPlayer(PedKiller) then
				Killer = NetworkGetPlayerIndexFromPed(PedKiller)
			elseif IsEntityAVehicle(PedKiller) and IsEntityAPed(GetPedInVehicleSeat(PedKiller, -1)) and IsPedAPlayer(GetPedInVehicleSeat(PedKiller, -1)) then
				Killer = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(PedKiller, -1))
			end
			if (Killer == PlayerId()) then
				DeathReason = lang['DeathReasons'].Suicide
			elseif (Killer == nil) then
				DeathReason = lang['DeathReasons'].Died
			else
				if ClientFunc.IsMelee(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].Murdered
				elseif ClientFunc.IsTorch(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].Torched
				elseif ClientFunc.IsKnife(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].Knifed
				elseif ClientFunc.IsPistol(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].Pistoled
				elseif ClientFunc.IsSub(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].Riddled
				elseif ClientFunc.IsRifle(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].Rifled
				elseif ClientFunc.IsLight(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].MachineGunned
				elseif ClientFunc.IsShotgun(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].Pulverized
				elseif ClientFunc.IsSniper(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].Sniped
				elseif ClientFunc.IsHeavy(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].Obliterated
				elseif ClientFunc.IsMinigun(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].Shredded
				elseif ClientFunc.IsBomb(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].Bombed
				elseif ClientFunc.IsVeh(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].MowedOver
				elseif ClientFunc.IsVK(DeathCauseHash) then
					DeathReason = lang['DeathReasons'].Flattened
				else
					DeathReason = lang['DeathReasons'].Killed
				end
			end

			if DeathReason == lang['DeathReasons'].Suicide or DeathReason == lang['DeathReasons'].Died then
				TriggerServerEvent('Prefech:playerDied', { type = 1, player_id = GetPlayerServerId(PlayerId()), death_reason = DeathReason, weapon = Weapon })
			else
				TriggerServerEvent('Prefech:playerDied', { type = 2, player_id = GetPlayerServerId(PlayerId()), player_2_id = GetPlayerServerId(Killer), death_reason = DeathReason, weapon = Weapon })
			end
			Killer = nil
			DeathReason = nil
			DeathCauseHash = nil
			Weapon = nil
		end
		while IsEntityDead(PlayerPedId()) do
			Wait(1000)
		end
	end
end)

RegisterNetEvent('Prefech:ClientCreateScreenshot')
AddEventHandler('Prefech:ClientCreateScreenshot', function(args)
	if args.url ~= "" and args.url ~= nil and args.url ~= 'DISCORD_WEBHOOK' then
		exports['screenshot-basic']:requestScreenshotUpload(args.url, 'files[]', function(data)
			local resp = json.decode(data)
			if resp.attachments then
				args['responseUrl'] = resp.attachments[1].url
				TriggerServerEvent('Prefech:ClientUploadScreenshot', args)
			else
				TriggerServerEvent('Prefech:JD_logs:Debug', 'Code: SB1005')
			end
		end)
	else
		TriggerServerEvent('Prefech:JD_logs:Debug', 'Code: SB1010')
	end
end)

RegisterNetEvent('ACScreenshot')
AddEventHandler('ACScreenshot', function(args)
	exports['screenshot-basic']:requestScreenshotUpload(args.url, 'files[]', function(data)
		local resp = json.decode(data)
		if resp.attachments then
			args['responseUrl'] = resp.attachments[1].url
			args.screenshot = nil
			TriggerServerEvent('ACCheatAlert', args)
		end
	end)
end)

CreateThread(function()
	local currWeapon = 0
	local fireWeapon = nil
	local timeout = 0
	local fireCount = 0
	while true do
		Wait(0)
		local playerped = GetPlayerPed(PlayerId())
		if IsPedShooting(playerped) then
			fireWeapon = GetSelectedPedWeapon(playerped)
			fireCount = fireCount + 1
			timeout = 1000
		elseif not IsPedShooting(playerped) and fireCount ~= 0 and timeout ~= 0 then
			if timeout ~= 0 then
				timeout = timeout - 1
			end
			if fireWeapon ~= GetSelectedPedWeapon(playerped) then
				timeout = 0
			end
			if fireCount ~= 0 and timeout == 0 then
				if not ClientWeapons.WeaponNames[tostring(fireWeapon)] then
					TriggerServerEvent('Prefech:playerShotWeapon', lang['WeaponFired'].Undefined)
					TriggerServerEvent('Prefech:JD_logs:Debug', 'GF1001')
					return
				end

				isLoggedWeapon = true
				for k,v in pairs(cfgFile['WeaponsNotLogged']) do
					if GetSelectedPedWeapon(playerped) == GetHashKey(v) then
						isLoggedWeapon = false
					end
				end
				if isLoggedWeapon then
					TriggerServerEvent('Prefech:playerShotWeapon', ClientWeapons.WeaponNames[tostring(fireWeapon)], fireCount)
				end
				fireCount = 0
			end
		end
	end
end)

exports('discord', function(message, id, id2, color, channel)
	args ={
		['EmbedMessage'] = msg,
		['color'] = color,
		['channel'] = channel
	}
	if player_1 ~= 0 then
		args['player_id'] = player_1
	end
	if player_2 ~= 0 then
		args['player_2_id'] = player_2
	end
	TriggerServerEvent('Prefech:ClientDiscord', args)
	local resource = GetInvokingResource()
	TriggerServerEvent('Prefech:JD_logs:Debug', 'Client Old Export from '..resource)
end)

exports('createLog', function(args)
	TriggerServerEvent('Prefech:ClientDiscord', args)
	local resource = GetInvokingResource()
	TriggerServerEvent('Prefech:JD_logs:Debug', 'Client New Export from '..resource)
end)

local clientStorage = {}
RegisterNetEvent('Prefech:ClientLogStorage')
AddEventHandler('Prefech:ClientLogStorage', function(args)
    if #clientStorage <= 4 then
		table.insert(clientStorage, args)
	else
		table.remove(clientStorage, 1)
		table.insert(clientStorage, args)
	end
end)

RegisterNetEvent('Prefech:getClientLogStorage')
AddEventHandler('Prefech:getClientLogStorage', function()
    TriggerServerEvent('Prefech:sendClientLogStorage', clientStorage)
end)

local eventsLoadFile = LoadResourceFile(GetCurrentResourceName(), "config/eventLogs.json")
local eventsFile = json.decode(eventsLoadFile)
if type(eventsFile) == "table" then
	for k,v in pairs(eventsFile) do
		if not v.Server then
			TriggerServerEvent('Prefech:JD_logs:Debug', 'Added Client Event Log: '..v.Event)
			AddEventHandler(v.Event, function()
				TriggerServerEvent('Prefech:ClientDiscord', {EmbedMessage = 'EventLogger: '..v.Message, channel = v.Channel})
				TriggerServerEvent('Prefech:eventLoggerClient', {EmbedMessage = 'EventLogger: '..v.Message, channel = v.Channel})
			end)
		end
	end
end