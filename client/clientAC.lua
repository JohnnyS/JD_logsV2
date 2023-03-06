local configFile = LoadResourceFile(GetCurrentResourceName(), "config/config.json")
local cfgFile = json.decode(configFile)

local localsFile = LoadResourceFile(GetCurrentResourceName(), "locals/"..cfgFile['locals']..".json")
local lang = json.decode(localsFile)
local CooldownWait = false
local sleep = false

if cfgFile['EnableAcFunctions'] then

    CreateThread(function()
        TriggerServerEvent('Prefech:getACConfig')
        while true do
            Wait(60 * 1000)
            TriggerServerEvent('Prefech:getACConfig')
        end
    end)

	local acConfig = {}
	RegisterNetEvent('Prefech:SendACConfig')
	AddEventHandler('Prefech:SendACConfig', function(_config)
		acConfig = _config
	end)

	local lastVehicle        = nil
	local lastVehicleModel   = nil
	local warnLimit = 0

	CreateThread(function()
		while true do
			Wait(250)
			local playerPed = PlayerPedId()
			local vehicle = GetVehiclePedIsUsing(playerPed)
			local model = GetEntityModel(vehicle)
			if (IsPedInAnyVehicle(playerPed, false)) then
				for k, v in pairs(acConfig['BlacklistedVehicles']) do
					if (IsVehicleModel(vehicle, v)) then
						DeleteVehicle(vehicle)
						if GetPlayerServerId(PlayerId()) ~= nil then
							TriggerServerEvent('Prefech:ClientDiscord', {EmbedMessage = lang['AntiCheat'].ACBlacklistedVehLog:format(GetPlayerName(PlayerId()), v), player_id = GetPlayerServerId(PlayerId()), channel = 'AntiCheat'})
						end
						warnLimit = warnLimit + 1
						if acConfig['KickSettings'].BlacklistedVehicles then
							if warnLimit == acConfig['KickSettings'].BlacklistedVehicleLimit then
								TriggerServerEvent('ACCheatAlert', {target = GetPlayerServerId(PlayerId()), reason = 'BV01: '..v, screenshot = true, kick = false})
								Wait(100)
								TriggerServerEvent('Prefech:DropPlayer', lang['AntiCheat'].ACBlacklistedVehKick)
							end
						end
					end
				end
			end

			if (IsPedSittingInAnyVehicle(playerPed)) then
				if (vehicle == lastVehicle and model ~= lastVehicleModel and lastVehicleModel ~= nil and lastVehicleModel ~= 0) then
					N_0xEA386986E786A54F(vehicle)
					return
				end
			end

			lastVehicle = vehicle
			lastVehicleModel = model

			local handle, object = FindFirstObject()
			local finished = false
			while not finished do
				Wait(1)
				for k,v in pairs(acConfig['BlacklistedObjects']) do
					if (GetEntityModel(object) == GetHashKey(v)) then
						DeleteObject(object)
						if GetPlayerServerId(PlayerId()) ~= nil then
							TriggerServerEvent('Prefech:ClientDiscord', {EmbedMessage = lang['AntiCheat'].BlacklistedObject:format(v), player_id = GetPlayerServerId(PlayerId()), channel = 'AntiCheat'})
							TriggerServerEvent('ACCheatAlert', {target = GetPlayerServerId(PlayerId()), reason = 'BO01: '..k, screenshot = true, kick = false})
						end
					end
				end
				finished, object = FindNextObject(handle)
			end
			EndFindObject(handle)
		end
	end)

	CreateThread(function()
		Wait(1000)
		while true do
			Wait(0)
			for k,v in pairs(acConfig['BlacklistedKeys']) do
				if IsControlJustReleased(0, tonumber(k)) and IsUsingKeyboard(0) and not IsNuiFocused() and not CooldownWait then
					Wait(1000)
					if GetPlayerServerId(PlayerId()) ~= nil then
						TriggerServerEvent('Prefech:ClientDiscord', {EmbedMessage = lang['AntiCheat'].BlacklistedKey:format(k, v), player_id = GetPlayerServerId(PlayerId()), channel = 'AntiCheat',})
						TriggerServerEvent('ACCheatAlert', {target = GetPlayerServerId(PlayerId()), reason = 'BK01: '..k, screenshot = true, kick = false})
						CooldownWait = true
					end
				end
			end
		end
	end)

	CreateThread(function()
		while true do
			Wait(60000)
			local resourceList = {}
			for i=0,GetNumResources()-1 do
				resourceList[i+1] = GetResourceByFindIndex(i)
				Wait(500)
			end
			Wait(5000)
			TriggerServerEvent("Prefech:resourceCheck", resourceList)
		end
	end)

	CreateThread(function()
		while true do
			Wait(60 * 1000)
			local prefixCheck = {"+", "_", "-", "-", "|", "\\","/",""}
			for k,v in ipairs(GetRegisteredCommands()) do
				for k,x in pairs(acConfig['BlacklistedCommands']) do
					for k,z in pairs(prefixCheck) do
						if string.lower(v.name) == string.lower(z..""..x) then
							if GetPlayerServerId(PlayerId()) ~= nil then
								TriggerServerEvent('Prefech:ClientDiscord', {EmbedMessage = lang['AntiCheat'].BlacklistedCommand:format(x), player_id = GetPlayerServerId(PlayerId()), channel = 'AntiCheat'})
							end
							TriggerServerEvent('ACCheatAlert', {target = GetPlayerServerId(PlayerId()), reason = 'BC01: '..z..''..x, screenshot = true, kick = true})
							if acConfig['KickSettings'].BlacklistedCommands then
								TriggerServerEvent('Prefech:DropPlayer', lang['AntiCheat'].BlacklistedCommandKick)
							end
						end
					end
				end
			end
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		sleep = 1500
		if CooldownWait then
			sleep = 10000
			CooldownWait = false
		end
		Citizen.Wait(sleep)	
	end
end)