ESX = nil
local Vehicles = {}
local PlayerData = {}
local MenuIsShowed = false
local isInMarker = false
local myCar = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

Citizen.CreateThread(function(id)
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(playerPed)
                local car = GetEntityModel(vehicle)		
		local coords = GetEntityCoords(PlayerPedId())

                sleep = true
                
                for k,v in pairs(Config.Zones) do
			local Coords = vector3(v.Pos.x, v.Pos.y, v.Pos.z)
                        isInMarker  = false
			if #(coords - Coords) < v.View and IsPedInAnyVehicle(playerPed, true) then 
				sleep = false                         
                        		for _, WhitelistedVehicles in pairs(Config.WhitelistedVehicles) do
						if GetEntityModel(vehicle) == GetHashKey(WhitelistedVehicles) then
                       						
					        	if (PlayerData.job and PlayerData.job.name == v.Job) then
								if #(coords - Coords) < v.View and not MenuIsShowed then
                                                			DrawText3D(v.Pos.x, v.Pos.y, v.Pos.z + 0.5, tostring(_U('press_custom_3DText')))
                                                        	end

                                                                if #(coords - Coords) < v.Activate and not MenuIsShowed then
						                        isInMarker  = true
                                                        	end

								if IsControlJustReleased(0, 38) and not MenuIsShowed and isInMarker then

									MenuIsShowed = true

									FreezeEntityPosition(vehicle, true)
									myCar = ESX.Game.GetVehicleProperties(vehicle)

									ESX.UI.Menu.CloseAll()
									ExtrasLiveryMenu()   
								end
                                                	end
						end
					end
				end
 
				if isInMarker and not hasAlreadyEnteredMarker then
					hasAlreadyEnteredMarker = true
				end

				if not isInMarker and hasAlreadyEnteredMarker then
					hasAlreadyEnteredMarker = false
				end
			end
                if sleep then
			Wait(500)
		end
	
	end
end)

function ExtrasLiveryMenu()
local elements = {
	{label = 'Extras', value = 'extras'},
	{label = 'Liveries', value = 'livery'},
}	

	local player = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(player,false)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_controls', {
			title    = _U('vehicle_control'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'extras' then
				ExtrasMenu()
			elseif data.current.value == 'livery' then
				LiveriesMenu()
			end			
		end, function(data, menu)
			menu.close()
                        MenuIsShowed = false
			local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
			FreezeEntityPosition(vehicle, false)
		end)
end

function ExtrasMenu()
	local ped = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(ped)
	local elements = {}
	for extras = 0, 20 do
		if DoesExtraExist(vehicle, extras) then
			if IsVehicleExtraTurnedOn(vehicle, extras) then
				table.insert(elements, {label = 'EXTRA '..extras.." <FONT color='green'>ON</FONT>", value = extras})
			elseif not IsVehicleExtraTurnedOn(vehicle, extras) then
				table.insert(elements, {label = 'EXTRA '..extras.." <FONT color='red'>OFF</FONT>", value = extras})
			end
		end
	end
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_extras', {
			title    = 'Extras',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			for extras = 0, 20 do
				if data.current.value == extras then
					if IsVehicleExtraTurnedOn(vehicle, extras) then
						SetVehicleExtra(vehicle, extras, 1)
						ESX.UI.Menu.CloseAll()
						ExtrasMenu()
					elseif not IsVehicleExtraTurnedOn(vehicle, extras) then
						SetVehicleExtra(vehicle, extras, 0)
						ESX.UI.Menu.CloseAll()
						ExtrasMenu()
					end
				end
			end
		end, function(data, menu)
			menu.close()
                        MenuIsShowed = false
			local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
			FreezeEntityPosition(vehicle, false)
		end)

end

function LiveriesMenu()

	local ped = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(ped)
	local elements = {}

	for value = 0, GetVehicleLiveryCount(vehicle) do
		table.insert(elements, {label = 'Livery '..value, value = value})
	end

	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_liveries', {
			title    = 'Liveries',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			for x = 0, GetVehicleLiveryCount(vehicle) do
				if data.current.value == value then

					SetVehicleLivery(vehicle, value)

				end
			end
		end, function(data, menu)
			menu.close()
                        MenuIsShowed = false
			FreezeEntityPosition(vehicle, false)
	end, function(data, menu)
		SetVehicleLivery(vehicle, data.current.value)
	end)

end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if MenuIsShowed then
			DisableControlAction(2, 288, true)
			DisableControlAction(2, 289, true)
			DisableControlAction(2, 170, true)
			DisableControlAction(2, 167, true)
			DisableControlAction(2, 168, true)
			DisableControlAction(2, 23, true)
			DisableControlAction(0, 75, true)  
			DisableControlAction(27, 75, true) 
		else
			Citizen.Wait(500)
		end
	end
end)

function DrawText3D(x,y,z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    if onScreen then
      SetTextScale(0.65, 0.41)
      SetTextFont(4)
  
      SetTextDropshadow(10, 100, 100, 100, 255)
      SetTextProportional(1)
      SetTextColour(255, 255, 255, 215)
      SetTextEntry("STRING")
      SetTextCentre(1)
      AddTextComponentString(text)
      DrawText(_x,_y)
        local factor = (string.len(text)) / 400
        DrawRect(_x,_y+0.0135, 0.025+ factor, 0.03, 0, 0, 0, 68)
    end
end
