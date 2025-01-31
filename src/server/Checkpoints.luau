local dataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local obbyDataStore = dataStoreService:GetDataStore("ObbyDataStore")

local checkpoints = workspace.Checkpoints
local checkpointsEvent = game.ReplicatedStorage.RemoteEvents.Checkpoints

local CycleStages
local CheckStageRequirements
local AnchorCheckpoints
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

        local tempStage = Instance.new("IntValue", stage)
        tempStage.Name = "TempStage"
        tempStage.Value = 1

        local data = LoadData(player)
        if data ~= nil or data ~= 0 then
            stage.Value = data
            tempStage.Value = data
        end
    
        player.CharacterAdded:Connect(function(character)
            SpawnCharacter(character, tempStage)
        end)
    
        task.spawn(CycleStages)
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        SaveData(player)
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
    if hit.Parent:FindFirstChild("Humanoid").Health <= 0 then return end
    local playerStage = game.Players:FindFirstChild(hit.Parent.Name).leaderstats.Stage
    local playerTempStage = playerStage.TempStage
    playerTempStage.Value = stage.Name
    checkpointsEvent:FireClient(game.Players:FindFirstChild(hit.Parent.Name), playerTempStage)
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

SpawnCharacter = function(character, tempStage)
    character:FindFirstChild("HumanoidRootPart").CFrame = checkpoints:FindFirstChild(tempStage.Value).CFrame + Vector3.new(0, 2, 0)
end

Back = function(player)
    local playerStage = player.leaderstats.Stage
    local playerCurrentStage = playerStage.TempStage

    if playerCurrentStage.Value == 1 then
        playerCurrentStage.Value = playerStage.Value
        SpawnCharacter(workspace:FindFirstChild(player.Name), playerCurrentStage)
    else
        playerCurrentStage.Value -= 1
        SpawnCharacter(workspace:FindFirstChild(player.Name), playerCurrentStage)
    end
end

Forward = function(player)
    local playerStage = player.leaderstats.Stage
    local playerCurrentStage = playerStage.TempStage

    if playerCurrentStage.Value == playerStage.Value then
        playerCurrentStage.Value = 1
        SpawnCharacter(workspace:FindFirstChild(player.Name), playerCurrentStage)
    else
        playerCurrentStage.Value += 1
        SpawnCharacter(workspace:FindFirstChild(player.Name), playerCurrentStage)
    end
end

task.spawn(AnchorCheckpoints)

return checkpointsModule