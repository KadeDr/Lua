local checkpointConfigs = 
{
    AdvanceOnDeath = false, -- True/False, will the player advance to the next stage if they are dead when they touch the stage
    TemporaryStage = 
    {
        Enabled = true,
        SpawnOnTempStage = true, -- True/False, is the player spawn on their temporary stage (true), or their actual stage (false)
        UpdateTempStage = true, -- True/False, will the temporary stage automatically update when they step on the next checkpoint (true), or will they have to click the button themselves (false)
    }; -- True/False, is the player allowed to move between stages they have already completed. Defaults all other tempstages to false, regardless of set value if this is set to false
    Save = true, -- True/False, will the checkpoints save
}

return checkpointConfigs