return function(Perishable)
    function Perishable:Perish()
        if self.updatetask ~= nil then
            self.updatetask:Cancel()
            self.updatetask = nil
        end

        if self.perishfn ~= nil then self.perishfn(self.inst) end

        if self.inst:IsValid() then self.inst:PushEvent("perished") end

        -- NOTE: callbacks may have removed this inst!

        if self.inst:IsValid() and self.onperishreplacement ~= nil then
            local goop = SpawnPrefab(self.onperishreplacement)
            if goop ~= nil then
                if goop.components.stackable ~= nil and self.inst.components.stackable ~= nil then
                    goop.components.stackable:SetStackSize(self.inst.components.stackable.stacksize)
                end
                local x, y, z = self.inst.Transform:GetWorldPosition()
                goop.Transform:SetPosition(x, y, z)

                if self.onreplacedfn ~= nil then self.onreplacedfn(self.inst, goop) end
                local owner = self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner
                                  or nil
                local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
                if holder ~= nil then
                    local slot = holder:GetItemSlot(self.inst)
                    self.inst:Remove()
                    holder:GiveItem(goop, slot)
                else
                    self.inst:Remove()
                end
            end
        end
    end
end
