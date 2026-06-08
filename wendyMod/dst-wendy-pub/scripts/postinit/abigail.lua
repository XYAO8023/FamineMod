local dontkillcitypig = GetConfig("dontkillcitypig") == "true" -- also inited variable
local function fn(inst)
    inst:DoTaskInTime(1, function()
        if not inst.components.follower:GetLeader() then
            -- print("this abigail has no leader")
            -- inst:Remove()
            return
        end
    end)
    if dontkillcitypig then
        table.insert(TUNING.ABIGAIL_COMBAT_CANT_TAGS, "city_pig")
        dontkillcitypig = false
    end
end
return fn
