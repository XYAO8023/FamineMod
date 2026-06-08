local function fn(Follower)
    local self = Follower
    -- not compatible with other mods
    function EntityScript:RemoveThisEventCallback(event, listener)
        if not event then return end
        listener = listener or self
        local root = self.event_listening
        if root then root = root[event] end
        if root then root[listener] = nil end
        root = listener.event_listeners
        if root then root = root[event] end
        if root then root[self] = nil end
    end
    -- Must hack this to prevent Abigail from not following
    function Follower:RefollowAfterAttacked(oldleader)
        local oldleader = oldleader or self:GetLeader()
        if oldleader and oldleader:IsValid() then
            self.inst:DoTaskInTime(0, function()
                if self:GetLeader() ~= oldleader then self:SetLeader(oldleader) end
            end)
            self.inst:DoTaskInTime(0.1, function()
                if self:GetLeader() ~= oldleader then self:SetLeader(oldleader) end
            end)
        end
    end
    function Follower:KeepLeaderOnAttacked()
        self.keepleaderonattacked = true
        self.inst:RemoveThisEventCallback("attacked")
        self.inst:ListenForEvent("attacked", function()
            self:RefollowAfterAttacked()
        end)
        self.inst:ListenForEvent("stopfollowing", function(inst, data)
            self:RefollowAfterAttacked(data and data.leader)
        end)
    end
    function Follower:GetLeader()
        return self.leader
    end
end
return fn
