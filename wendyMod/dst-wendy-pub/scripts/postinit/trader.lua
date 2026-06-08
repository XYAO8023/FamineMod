local function fn(Trader)
    local self = Trader
    self.acceptnontradable = not not self.acceptnontradable
    function Trader:OnRemoveFromEntity()
        self.inst:RemoveTag("trader")
        self.inst:RemoveTag("alltrader")
    end

    function Trader:Enable()
        self.enabled = true
        self.inst:AddTag("trader")
        if self.acceptnontradable then self.inst:AddTag("alltrader") end
    end

    function Trader:Disable()
        self.enabled = false
        self.inst:RemoveTag("trader")
        if self.acceptnontradable then self.inst:RemoveTag("alltrader") end
    end

    function Trader:SetAbleToAcceptTest(fn)
        self.abletoaccepttest = fn
    end

    function Trader:AbleToAccept(item, giver)
        local on_inventory = self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner
                                 ~= nil

        if not self.enabled or item == nil then
            return false
        elseif self.abletoaccepttest ~= nil then
            return self.abletoaccepttest(self.inst, item, giver)
        elseif self.inst.components.health ~= nil and self.inst.components.health:IsDead() then
            return false, "DEAD"
        elseif (self.inst.components.sleeper ~= nil and self.inst.components.sleeper:IsAsleep()) and not on_inventory then
            return false, "SLEEPING"
        elseif self.inst.sg ~= nil and self.inst.sg:HasStateTag("busy") and not on_inventory then
            return false, "BUSY"
        end
        return true
    end

    function Trader:WantsToAccept(item, giver)
        return self.enabled and (not self.test or self.test(self.inst, item, giver))
    end

    function Trader:GetDebugString()
        return self.enabled and "true" or "false"
    end

    -- Compatibility Warning: This function overrides the default one!!!
    local oldAcceptGift = self.AcceptGift
    function Trader:AcceptGift(giver, item, count, extra)
        -- print("Accept gift")
        -- print(giver, item, count, extra)
        if extra ~= nil then return oldAcceptGift(self, giver, item, count, extra) end
        local can, reason = self:CanAccept(item, giver)
        if can then
            local stack_num = nil
            if count == true or self.always_accept_stack and item.components.stackable then
                if extra == nil then
                    local slot = self.inst.components.inventory:GetItemSlotByName(item.prefab)
                    if not slot then
                        stack_num = item.components.stackable.stacksize
                    else
                        stack_num = self.inst.components.inventory:GetItemInSlot(slot).components.stackable:RoomLeft()
                    end

                end
            end
            count = type(count) == "number" and count or stack_num or 1

            if item.components.stackable ~= nil and item.components.stackable.stacksize > count then
                item = item.components.stackable:Get(count)
            else
                item.components.inventoryitem:RemoveFromOwner(true)
            end
            -- tweak logic here
            if self.abletoaccepttest then
                if self.deleteitemonaccept then
                    item:Remove()
                elseif self.inst.components.inventory ~= nil then
                    item.prevslot = nil
                    item.prevcontainer = nil
                    self.inst.components.inventory:GiveItem(item, nil, giver ~= nil and giver:GetPosition() or nil)
                end
            else
                if self.inst.components.inventory then
                    self.inst.components.inventory:GiveItem(item)
                elseif self.deleteitemonaccept then
                    item:Remove()
                end
            end

            if self.onaccept ~= nil then self.onaccept(self.inst, giver, item) end

            self.inst:PushEvent("trade", {giver = giver, item = item})

            return can, reason
        end

        if self.onrefuse ~= nil then self.onrefuse(self.inst, giver, item) end
        return can, reason
    end

    self.OldCanAccept = self.CanAccept
    function Trader:CanAccept(...)
        local reason = {self:AbleToAccept(...)}
        if reason[1] == false then return unpack(reason) end
        reason = {self:OldCanAccept(...)}
        if reason[1] == false then return unpack(reason) end
        return self:WantsToAccept(...)
    end
end

return fn
