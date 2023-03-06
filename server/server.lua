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

local JD_Debug = false
local configFile = LoadResourceFile(GetCurrentResourceName(), "./config/config.json")
local cfgFile = json.decode(configFile)

local localsFile = LoadResourceFile(GetCurrentResourceName(), "locals/"..cfgFile['locals']..".json")
local lang = json.decode(localsFile)

if lang == nil then
    print('^5[JD_logs] ^1Code: Could not load language file. Make sure you didn\'t make a typo.^0')
    return StopResource(GetCurrentResourceName())
end

if cfgFile == nil then
    print('^5[JD_logs] ^1Code: Could not load config file. Make sure you didn\'t make a typo.^0')
    return StopResource(GetCurrentResourceName())
end

RegisterNetEvent('Prefech:JD_logs:Debug')
AddEventHandler('Prefech:JD_logs:Debug', log)

RegisterNetEvent('Prefech:JD_logs:errorLog')
AddEventHandler('Prefech:JD_logs:errorLog', errorLog)

RegisterCommand('jdlogs', function(source, args, RawCommand) --[[Console command to enable debug and error logs.]]
	if source == 0 then
		if args[2]:lower() == "false" then state = 'false' else state = 'true' end
		if args[1]:lower() == "debuglog" then
			SetResourceKvp('JD_logs:DebugLog', state)
			print('^5[JD_logs]^1: Updated the debug log status to: '..state)
		elseif args[1]:lower() == "errorlog" then
			SetResourceKvp('JD_logs:ErrorLog', state)
			print('^5[JD_logs]^1: Updated the error log status to: '..state)
		end
	end
end)

function debugLog(x)
	if GetResourceKvpString('JD_logs:DebugLog') == 'true' then
		print("^5[JD_logs]^0: " .. x)
	end
end

function errorLog(x)
	if GetResourceKvpString('JD_logs:ErrorLog') == 'true' or GetResourceKvpString('JD_logs:ErrorLog') == nil then
		print("^5[JD_logs]^1: " .. x .."^0")
	end
end

RegisterNetEvent("Prefech:discordLogs")
AddEventHandler("Prefech:discordLogs", function(message, color, channel)
    discordLog(message, color, channel)
end)

RegisterNetEvent("Prefech:ClientUploadScreenshot")
AddEventHandler("Prefech:ClientUploadScreenshot", function(args)
	ServerFunc.CreateLog(args)
end)

exports('discord', function(msg, player_1, player_2, color, channel)
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
	ServerFunc.CreateLog(args)
	local resource = GetInvokingResource()
	debugLog('Server Old Export from '.. resource)
end)

exports('createLog', function(args)
	if args.screenshot then
		if GetResourceState('screenshot-basic') == "started" then
			local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./config/webhooks.json")
			local webhooksFile = json.decode(webhooksLaodFile)
			if webhooksFile['imageStore'].webhook ~= "" and webhooksFile['imageStore'].webhook ~= "DISCORD_WEBHOOK" then
				args['url'] = webhooksFile['imageStore'].webhook
				TriggerClientEvent('Prefech:ClientCreateScreenshot', args.player_id, args)
			else
				errorLog('Code: SB1010')
			end
		else
			errorLog('Code: SB1000 (You need to have screenshot-basic to use screenshot logs.)')
		end
	else
		ServerFunc.CreateLog(args)
	end
	local resource = GetInvokingResource()
	debugLog('Code: EX1000 (Server New Export from: '..resource..')')
end)

RegisterNetEvent("ACCheatAlert")
AddEventHandler("ACCheatAlert", function(args)
	debugLog('Code: AC1000')
	if IsPlayerAceAllowed(source, cfgFile['AntiCheatBypass']) then return end
	if args.screenshot and GetResourceState('screenshot-basic') == "started" then
		debugLog('Code: AC1001')
		PerformHttpRequest('https://cdn.prefech.dev/api/ac-screen', function(code, res, headers)
			args['url'] = res
			TriggerClientEvent('ACScreenshot', args.target, args)
		end, 'GET')
	else
		local ids = ExtractIdentifiers(source)
		local args = { ['ids'] = ids, ['reason'] = args.reason, ['username'] = GetPlayerName(source), ['screenshot'] = args.responseUrl }
		debugLog('Code: AC1002')
		PerformHttpRequest('https://cdn.prefech.dev/api/cheatAlert', function(err, text, headers)
		end, 'POST', json.encode(args), {
			['Content-Type'] = 'application/json'
		})
		if args.kick then
			debugLog('Code: AC1010')
			DropPlayer(source, '\nYou have been kicked by the Prefech Auto kick system.')
		end
	end
end)

AddEventHandler("playerConnecting", function(name, setReason, deferrals)
	local _source = source
	local ids = ExtractIdentifiers(_source)
	debugLog('Code: GB1010')
	ServerFunc.CreateLog({EmbedMessage = lang['DefaultLogs'].Join:format(name), player_id = _source, channel = 'joins'})
end)

AddEventHandler("playerJoining", function(source, oldID)
	local loadFile = LoadResourceFile(GetCurrentResourceName(), "./json/names.json")
	local loadedFile = json.decode(loadFile)
    local ids = ExtractIdentifiers(source)

	if ids.steam then
		debugLog('Code: NC1000')
		if loadedFile[ids.steam] ~= nil then
			if loadedFile[ids.steam] ~= GetPlayerName(source) then
				for _, i in ipairs(GetPlayers()) do
					if IsPlayerAceAllowed(i, cfgFile.nameChangePerms) then
						TriggerClientEvent('chat:addMessage', i, {
							template = '<div style="background-color: rgba(90, 90, 90, 0.9); text-align: center; border-radius: 0.5vh; padding: 0.7vh; font-size: 1.7vh;"><b>Player ^1{0} ^0{1} ^1{2}</b></div>',
							args = { lang['DefaultLogs'].NameChangeChat:format(GetPlayerName(source), loadedFile[ids.steam]) }
						})
					end
				end
				ServerFunc.CreateLog({EmbedMessage = lang['DefaultLogs'].NameChange:format(GetPlayerName(source), loadedFile[ids.steam]), player_id = source, channel = 'nameChange'})
			end
		end
		loadedFile[ids.steam] = GetPlayerName(source)
		SaveResourceFile(GetCurrentResourceName(), "./json/names.json", json.encode(loadedFile), -1)
	else
		if cfgFile.forceSteam then
			debugLog('Code: NC1001')
			ServerFunc.CreateLog({EmbedMessage = lang['Other'].ForceSteamLog:format(GetPlayerName(source)), player_id = source, channel = 'nameChange'})
			DropPlayer(source, lang['Other'].ForceSteam)
		else
			debugLog('Code: NC1002')
			for _, i in ipairs(GetPlayers()) do
				if IsPlayerAceAllowed(i, cfgFile.nameChangePerms) then
					TriggerClientEvent('chat:addMessage', i, {
						template = '<div style="background-color: rgba(90, 90, 90, 0.9); text-align: center; border-radius: 0.5vh; padding: 0.7vh; font-size: 1.7vh;"><b>Player ^1{0} ^0{1}</b></div>',
						args = { GetPlayerName(source), lang['Other'].NoSteam }
					})
				end
			end
			ServerFunc.CreateLog({EmbedMessage = lang['Other'].NoSteamLog:format(GetPlayerName(source)), player_id = source, channel = 'nameChange'})
		end
	end
end)

AddEventHandler('playerDropped', function(reason)
	debugLog('Code: JD1001')
	ServerFunc.CreateLog({EmbedMessage = lang['DefaultLogs'].Left:format(GetPlayerName(source), reason), player_id = source, channel = 'leaving'})
end)

AddEventHandler('chatMessage', function(source, name, msg)
	debugLog('Code: JD1002')
	if msg:sub(1, 1) ~= '/' then
		ServerFunc.CreateLog({EmbedMessage = '**'..GetPlayerName(source) .. '**: `' .. msg..'`', player_id = source, channel = 'chat'})
	end
end)

RegisterServerEvent('Prefech:playerDied')
AddEventHandler('Prefech:playerDied',function(args)
	debugLog('Code: JD1003')
	if args.weapon == nil then _Weapon = "" else _Weapon = ""..args.weapon.."" end
	if args.type == 1 then  -- Suicide/died
		ServerFunc.CreateLog({
			EmbedMessage = '**'..GetPlayerName(source) .. '** `'..args.death_reason..'` '.._Weapon,
			player_id = source,
			channel = 'deaths'
		})
	elseif args.type == 2 then -- Killed by other player
		ServerFunc.CreateLog({
			EmbedMessage = '**' .. GetPlayerName(args.player_2_id) .. '** '..args.death_reason..' **' .. GetPlayerName(source).. '** `('.._Weapon..')`',
			player_id = source,
			player_2_id = args.player_2_id,
			channel = 'deaths'
		})
	else -- When gets killed by something else
		ServerFunc.CreateLog({
			EmbedMessage = '**'..GetPlayerName(source) .. '** `'..args.death_reason..'` '.._Weapon,
			player_id = source,
			channel = 'deaths'
		})
	end
end)

RegisterServerEvent('Prefech:playerShotWeapon')
AddEventHandler('Prefech:playerShotWeapon', function(weapon, count)
	debugLog('Code: JD1004')
	if cfgFile['weaponLog'] then
		ServerFunc.CreateLog({EmbedMessage = lang['DefaultLogs'].Shooting:format(GetPlayerName(source), weapon, count), player_id = source, channel = 'shooting'})
    end
end)

local explosionTypes = {'GRENADE', 'GRENADELAUNCHER', 'STICKYBOMB', 'MOLOTOV', 'ROCKET', 'TANKSHELL', 'HI_OCTANE', 'CAR', 'PLANE', 'PETROL_PUMP', 'BIKE', 'DIR_STEAM', 'DIR_FLAME', 'DIR_GAS_CANISTER', 'BOAT', 'SHIP_DESTROY', 'TRUCK', 'BULLET', 'SMOKEGRENADELAUNCHER', 'SMOKEGRENADE', 'BZGAS', 'FLARE', 'GAS_CANISTER', 'EXTINGUISHER', 'PROGRAMMABLEAR', 'TRAIN', 'BARREL', 'PROPANE', 'BLIMP', 'DIR_FLAME_EXPLODE', 'TANKER', 'PLANE_ROCKET', 'VEHICLE_BULLET', 'GAS_TANK', 'BIRD_CRAP', 'RAILGUN', 'BLIMP2', 'FIREWORK', 'SNOWBALL', 'PROXMINE', 'VALKYRIE_CANNON', 'AIR_DEFENCE', 'PIPEBOMB', 'VEHICLEMINE', 'EXPLOSIVEAMMO', 'APCSHELL', 'BOMB_CLUSTER', 'BOMB_GAS', 'BOMB_INCENDIARY', 'BOMB_STANDARD', 'TORPEDO', 'TORPEDO_UNDERWATER', 'BOMBUSHKA_CANNON', 'BOMB_CLUSTER_SECONDARY', 'HUNTER_BARRAGE', 'HUNTER_CANNON', 'ROGUE_CANNON', 'MINE_UNDERWATER', 'ORBITAL_CANNON', 'BOMB_STANDARD_WIDE', 'EXPLOSIVEAMMO_SHOTGUN', 'OPPRESSOR2_CANNON', 'MORTAR_KINETIC', 'VEHICLEMINE_KINETIC', 'VEHICLEMINE_EMP', 'VEHICLEMINE_SPIKE', 'VEHICLEMINE_SLICK', 'VEHICLEMINE_TAR', 'SCRIPT_DRONE', 'RAYGUN', 'BURIEDMINE', 'SCRIPT_MISSIL'}
AddEventHandler('explosionEvent', function(source, ev)
	debugLog('Code: JD1005')
    if ev.explosionType < -1 or ev.explosionType > 77 then
        ev.explosionType = 'UNKNOWN'
    else
        ev.explosionType = ServerExplotions.ExplotionNames[explosionTypes[ev.explosionType + 1]]
    end
    ServerFunc.CreateLog({EmbedMessage = lang['DefaultLogs'].Explosion:format(GetPlayerName(source), ev.explosionType), player_id = source, channel = 'explosion'})
end)

RegisterServerEvent('Prefech:ClientDiscord')
AddEventHandler('Prefech:ClientDiscord', function(args)
	if args.screenshot or args.channel == "AntiCheat" then
		--if IsPlayerAceAllowed(source, cfgFile['AntiCheatBypass']) then return end
		if GetResourceState('screenshot-basic') == "started" then
			debugLog('Code: EX2001 (Client Export Requesting Screenshot)')
			local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./config/webhooks.json")
			local webhooksFile = json.decode(webhooksLaodFile)
			if webhooksFile['imageStore'].webhook ~= "" and webhooksFile['imageStore'].webhook ~= "DISCORD_WEBHOOK" then
				args['url'] = webhooksFile['imageStore'].webhook
				TriggerClientEvent('Prefech:ClientCreateScreenshot', args.player_id, args)
			else
				errorLog('Code: SB1010')
			end
		else
			errorLog('Code: SB1001 (You need to have screenshot-basic to use screenshot logs.)')
			ServerFunc.CreateLog(args)
		end
	else
		debugLog('Code: EX2002')
		ServerFunc.CreateLog(args)
	end
end)

AddEventHandler('onResourceStop', function (resourceName)
	debugLog('Code: JD1006')
	ServerFunc.CreateLog({EmbedMessage = lang['DefaultLogs'].ResourceStop:format(resourceName), channel = 'resources'})
end)

AddEventHandler('onResourceStart', function (resourceName)
    Wait(100)
	debugLog('Code: JD1007')
	ServerFunc.CreateLog({EmbedMessage = lang['DefaultLogs'].ResourceStart:format(resourceName), channel = 'resources'})
end)

local storage = nil
RegisterNetEvent('Prefech:sendClientLogStorage')
AddEventHandler('Prefech:sendClientLogStorage', function(_storage)
	storage = _storage
end)

Commands= {}

Commands.logs = function(source, args, RawCommand)
	if IsPlayerAceAllowed(source, cfgFile.logHistoryPerms) then
		if tonumber(args[1]) then
			debugLog('Code: CM1001')
			TriggerClientEvent('Prefech:getClientLogStorage', args[1])
			Wait(500)
			if tablelength(storage) == 0 then
				Notify.Custom(source, "Recent logs for: "..GetPlayerName(args[1]).." (0)", lang['Commands']['LogHistory'].NoLogs)
			else
				for k,v in pairs(storage) do
					Notify.Custom(source, lang['Commands']['LogHistory'].Success:format(GetPlayerName(args[1]), k), "Channel: "..v.Channel.."\nMessage: "..v.Message:gsub("**",""):gsub("`","").."\nTimeStamp: "..v.TimeStamp)
				end
			end
		else
			Notify.Error(source, lang['Commands']['LogHistory'].InvalidId)
		end
	else
		Notify.Error(source, lang['Commands']['LogHistory'].InvalidPerms)
	end
end

Commands.screenshot = function(source, args, RawCommand)
	if source == 0 then
		if args[1] and has_val(GetPlayers(), args[1]) then
			if GetResourceState('screenshot-basic') == "started" then
				debugLog('Code: CM2002')
				local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./config/webhooks.json")
				local webhooksFile = json.decode(webhooksLaodFile)
				args['url'] = webhooksFile['imageStore'].webhook
				args['EmbedMessage'] = lang['Commands']['Screenshot'].Log:format(GetPlayerName(args[1]), args[1], 'Console', source)
				args['channel'] = "screenshot"
				TriggerClientEvent('Prefech:ClientCreateScreenshot', args[1], args)
				print(lang['Commands']['Screenshot'].Success:format(GetPlayerName(args[1])))
			else
				errorLog('Code: SB2002 (You need to have screenshot-basic to use screenshot logs.)')
			end
		end
	elseif IsPlayerAceAllowed(source, cfgFile.screenshotPerms) then
		if args[1] and has_val(GetPlayers(), args[1]) then
			if GetResourceState('screenshot-basic') == "started" then
				debugLog('Code: CM1002')
				local webhooksLaodFile = LoadResourceFile(GetCurrentResourceName(), "./config/webhooks.json")
				local webhooksFile = json.decode(webhooksLaodFile)
				args['url'] = webhooksFile['imageStore'].webhook
				args['EmbedMessage'] = lang['Commands']['Screenshot'].Log:format(GetPlayerName(args[1]), args[1], GetPlayerName(source), source)
				args['channel'] = "screenshot"
				TriggerClientEvent('Prefech:ClientCreateScreenshot', args[1], args)
				Notify.Success(source, lang['Commands']['Screenshot'].Success:format(GetPlayerName(args[1])))
			else
				errorLog('Code: SB1002 (You need to have screenshot-basic to use screenshot logs.)')
			end
		else
			Notify.Error(source, lang['Commands']['Screenshot'].InvalidId)
		end
	else
		Notify.Error(source, lang['Commands']['Screenshot'].InvalidPerms)
	end
end

for k,v in pairs(cfgFile['Commands']) do
	for _,i in pairs(v) do
		RegisterCommand(i, Commands[k])
	end
end

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function has_val(tab, val)
	for k,v in pairs(tab) do
	   if v == val then
		return true
	   end
	end
	return false
end

local eventsLoadFile = LoadResourceFile(GetCurrentResourceName(), "./config/eventLogs.json")
local eventsFile = json.decode(eventsLoadFile)
if type(eventsFile) == "table" then
	for k,v in pairs(eventsFile) do
		if v.Server then
			debugLog('Added Server Event Log: '..v.Event)
			AddEventHandler(v.Event, function()
				ServerFunc.CreateLog({EmbedMessage = '**EventLogger:** '..v.Message, channel = v.Channel})
			end)
		end
	end
end

RegisterServerEvent('Prefech:eventLoggerClient')
AddEventHandler('Prefech:eventLoggerClient', function(args)
	ServerFunc.CreateLog(args)
end)

if GetCurrentResourceName() ~= "JD_logs" then
    errorLog('This recource should be named "JD_logs" for the exports to work properly.')
end