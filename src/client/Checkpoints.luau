local checkpointsEvent = game.ReplicatedStorage.RemoteEvents.Checkpoints
local stageMainFrame = game.Players.LocalPlayer.PlayerGui:WaitForChild("Stage").MainFrrame
local stageText = stageMainFrame.StageText
local backButton = stageMainFrame.Back
local forwardButton = stageMainFrame.Forward

local checkpointsModule = {}

checkpointsModule.Events = function()
    checkpointsEvent.OnClientEvent:Connect(function(stage)
        stageText.Text = stage.Value
    end)
    backButton.MouseButton1Click:Connect(function()
        checkpointsEvent:FireServer("Back")
    end)
    forwardButton.MouseButton1Click:Connect(function()
        checkpointsEvent:FireServer("Forward")
    end)
end

return checkpointsModule