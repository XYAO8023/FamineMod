return function(self)
    local Open = self.Open
    function self:Open(container, doer, ...)
        local ret = {Open(self, container, doer, ...)}
        local slotbg = container and container.components.container.widget and
                           container.components.container.widget.slotbg
        if slotbg then
            for i = 1, #self.inv do
                local slot = self.inv[i]
                if slotbg[i] then slot.bgimage:SetTexture(slotbg[i].atlas, slotbg[i].image) end
            end
        end
        return unpack(ret)
    end
end
