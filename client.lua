local QBCore = exports['qb-core']:GetCoreObject()

local repairPeds = {}

CreateThread(function()
    for i, loc in pairs(Config.RepairLocations) do
        RequestModel(loc.model)
        while not HasModelLoaded(loc.model) do Wait(0) end

        local ped = CreatePed(0, loc.model, loc.coords.x, loc.coords.y, loc.coords.z - 1.0, loc.coords.w, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        repairPeds[#repairPeds+1] = ped

        if loc.blip.enabled then
            local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
            SetBlipSprite(blip, loc.blip.sprite)
            SetBlipColour(blip, loc.blip.color)
            SetBlipScale(blip, loc.blip.scale)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(loc.blip.name)
            EndTextCommandSetBlipName(blip)
        end

        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    label = "Repair Vehicle ($" .. loc.repairCost .. ")",
                    icon = "fas fa-tools",
                    action = function()
                        TriggerServerEvent("kza_roadside:attemptRepair", i)
                    end,
                },
            },
            distance = 4.5
        })
    end
end)

RegisterNetEvent("kza_roadside:doRepair", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then
        QBCore.Functions.Notify("You're not in a vehicle.", "error")
        return
    end

    QBCore.Functions.Progressbar("roadside_repair", "Repairing vehicle...", 7500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        local fuelLevel = exports['lc_fuel']:GetFuel(veh) or 100.0

        SetVehicleFixed(veh)
        SetVehicleDirtLevel(veh, 0.0)
        SetVehicleEngineHealth(veh, 1000.0)

        -- Restore fuel level after fix
        Wait(100)
        exports['lc_fuel']:SetFuel(veh, fuelLevel)

        QBCore.Functions.Notify("Vehicle repaired.", "success")
    end)
end)
