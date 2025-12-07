local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent("crp_roadside:attemptRepair", function(locationIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cfg = Config.RepairLocations[locationIndex]
    if not cfg then return end

    -- 🔽 NEW: Apply discount for emergency jobs
    local discount = 1.0
    local jobName = Player.PlayerData.job.name
    if jobName == "police" or jobName == "ambulance" then
        discount = 0.5
    end

    -- 🧰 Check if a mechanic/tuner is on duty and block repair if true
    for _, pid in pairs(QBCore.Functions.GetPlayers()) do
        local p = QBCore.Functions.GetPlayer(pid)
        if p then
            for _, job in pairs(Config.BlockJobs) do
                if p.PlayerData.job.name == job and p.PlayerData.job.onduty then
                    TriggerClientEvent('QBCore:Notify', src, "A mechanic is available. Seek professional help.", "error")
                    return
                end
            end
        end
    end

    -- 💵 Charge adjusted cost
    local cost = math.floor(cfg.repairCost * discount)
    if Player.Functions.RemoveMoney('cash', cost, "roadside-repair") then
        TriggerClientEvent("crp_roadside:doRepair", src)
    else
        TriggerClientEvent('QBCore:Notify', src, "Not enough cash.", "error")
    end
end)
