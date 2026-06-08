return function(Leader)
    local self = Leader
    local oldAddFollower = self.AddFollower
    function Leader:AddFollower(follower, ...)
        if self.followers[follower] == nil and follower.components.follower then
            self.inst:ListenForEvent("onremove", function(inst, data)
                self.inst:DoTaskInTime(0, function()
                    self:RemoveFollower(follower)
                end)
            end, follower)
        end
        oldAddFollower(self, follower, ...)
    end
end
