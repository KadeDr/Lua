local configs = require(game.ReplicatedStorage.Shared.CheckpointConfigs)

local checkpointsEvent = game.ReplicatedStorage.RemoteEvents.Checkpoints
local stageMainFrame = configs.TemporaryStage.Filepath
local stageText = stageMainFrame.StageText
local backButton = stageMainFrame.Back
local forwardButton = stageMainFrame.Forward

local checkpointsModule = {}

checkpointsModule.Events = function()
    checkpointsEvent.OnClientEvent:Connect(function(stage)
        stageText.Text = stage.Value
    end)
    if configs.TemporaryStage then
        backButton.MouseButton1Click:Connect(function()
            checkpointsEvent:FireServer("Back")
        end)
        forwardButton.MouseButton1Click:Connect(function()
            checkpointsEvent:FireServer("Forward")
        end)
    else
        backButton.Visible = false
        forwardButton.Visible = false
    end
end

return checkpointsModule
