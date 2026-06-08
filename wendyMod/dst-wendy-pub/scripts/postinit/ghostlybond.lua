local function fn(GhostlyBond)
    --[[
    local self = GhostlyBond
    local old = self.SpawnGhost
    function self:SpawnGhost()
        if self.ghost_prefab == "abigail" then
            self.inst:DoTaskInTime(0, function()
                for i, v in pairs(Ents) do
                    if v.prefab == "abigail" and not v.components.follower:GetLeader() then
                        v:DoTaskInTime(0, v.Remove)
                    end
                end
            end)
        end
        return old(self)
    end
    ]]
end
return fn
