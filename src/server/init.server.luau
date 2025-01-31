workspace.Part.Touched:Connect(function(hit)
    if hit.Parent:FindFirstChild("Humanoid") then
        workspace.Part.CanCollide = false
    end
end)