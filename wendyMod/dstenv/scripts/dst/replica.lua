local old = EntityScript._ctor
EntityScript._ctor = function(self, ...)
    old(self, ...)
    if not self.replica then
        self.replica = self.replica or {}
        setmetatable(self.replica, {
            __index = function(_, t)
                return self.components[t]
            end
        })
    end
end
