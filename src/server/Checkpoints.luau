local dataStoreService = game:GetService("DataStoreService")
local obbyDataStore = dataStoreService:GetDataStore("ObbyDataStore")

local configs = require(game.ReplicatedStorage.Shared.CheckpointConfigs)

local checkpoints = workspace.Checkpoints
local checkpointsEvent = game.ReplicatedStorage.RemoteEvents.Checkpoints

local CycleStages
local CheckStageRequirements
local AnchorCheckpoints
local SendText
local SaveData
local LoadData
local SpawnCharacter
local Back
local Forward

local checkpointsModule = {}

checkpointsModule.Events = function()
    game.Players.PlayerAdded:Connect(function(player)
        local leaderstats = Instance.new("Folder", player)
        leaderstats.Name = "leaderstats"

        local stage = Instance.new("IntValue", leaderstats)
        stage.Name = "Stage"
        stage.Value = 1

        local tempStage

        if configs.TemporaryStage.Enabled then
            tempStage = Instance.new("IntValue", stage)
            tempStage.Name = "TempStage"
            tempStage.Value = 1
        else
            tempStage = stage
        end

        if configs["Save"] then
                local data = LoadData(player)
            if data ~= nil or data ~= 0 then
                stage.Value = data
                tempStage.Value = data
            end
        else
            print("Save Config is disabled")
        end

        player.CharacterAdded:Connect(function(character)
            if configs["TemporaryStage"]["SpawnOnTempStage"] then
                SpawnCharacter(character, tempStage)
                SendText(player, tempStage)
            else
                SpawnCharacter(character, stage)
                SendText(player, stage)
            end
        end)

        task.spawn(CycleStages)
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        if configs["Save"] then
            SaveData(player)
        else
            print("Save Config is disabled")
        end
    end)

    checkpointsEvent.OnServerEvent:Connect(function(player, event)
        if event == "Back" then
           Back(player)
        elseif event == "Forward" then
            Forward(player)
        end
    end)
end

CycleStages = function()
    for i, stage in pairs(checkpoints:GetChildren()) do
        if stage:IsA("Part") then
            stage.Touched:Connect(function(hit)
                CheckStageRequirements(stage, hit)
            end)
        end
    end
end

CheckStageRequirements = function(stage, hit)
    if not hit.Parent:FindFirstChild("Humanoid") then return end
    if hit.Parent:FindFirstChild("Humanoid").Health <= 0 and not configs["AdvanceOnDeath"] then return end
    local playerStage = game.Players:FindFirstChild(hit.Parent.Name).leaderstats.Stage
    if playerStage:FindFirstChild("TempStage") and configs["TemporaryStage"]["UpdateTempStage"] then
        playerStage.TempStage.Value = stage.Name
        checkpointsEvent:FireClient(game.Players:FindFirstChild(hit.Parent.Name), playerStage.TempStage)
    else
        if playerStage.Value ~= tonumber(stage.Name) - 1 then return end
        playerStage.Value = stage.Name
        checkpointsEvent:FireClient(game.Players:FindFirstChild(hit.Parent.Name), playerStage)
        return
    end
    if playerStage.Value ~= tonumber(stage.Name) - 1 then return end
    playerStage.Value = stage.Name
end

AnchorCheckpoints = function()
    for i, stage in pairs(checkpoints:GetChildren()) do
        if stage:IsA("Part") then
            stage.Anchored = true
        end
    end
end

SendText = function(player, stage)
    checkpointsEvent:FireClient(game.Players:FindFirstChild(player.Name), stage)
end

SaveData = function(player)
    local success, errormessage = pcall(function()
        obbyDataStore:SetAsync(player.UserId, player.leaderstats.Stage.Value)
    end)

    if errormessage then
        warn(errormessage)
    end
end

LoadData = function(player)
    local data
    local success, errormessage = pcall(function()
        data = obbyDataStore:GetAsync(player.UserId)
    end)

    if success then
        return data
    else
        warn(errormessage)
    end
end

SpawnCharacter = function(character, stage)
    character:FindFirstChild("HumanoidRootPart").CFrame = checkpoints:FindFirstChild(stage.Value).CFrame + Vector3.new(0, 2, 0)
end

Back = function(player)
    local playerStage = player.leaderstats.Stage
    local playerCurrentStage = playerStage.TempStage

    if playerCurrentStage.Value == 1 then
        playerCurrentStage.Value = playerStage.Value
    else
        playerCurrentStage.Value -= 1
    end
    SpawnCharacter(workspace:FindFirstChild(player.Name), playerCurrentStage)
    SendText(player, playerCurrentStage)
end

Forward = function(player)
    local playerStage = player.leaderstats.Stage
    local playerCurrentStage = playerStage.TempStage

    if playerCurrentStage.Value == playerStage.Value then
        playerCurrentStage.Value = 1
    else
        playerCurrentStage.Value += 1
    end
    SpawnCharacter(workspace:FindFirstChild(player.Name), playerCurrentStage)
    SendText(player, playerCurrentStage)
end

task.spawn(AnchorCheckpoints)

return checkpointsModule