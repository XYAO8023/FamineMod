local widgetprops = {"numslots", "acceptsstacks", "usespecificslotsforitems", "issidewidget", "type", "widget",
                     "itemtestfn", "priorityfn", "openlimit"}
local containers = dstrequire("containers")
return function(Container)
    local self = Container
    self.usespecificslotsforitems = false
    self.issidewidget = self.side_widget
    self.itemtestfn = nil
    self.priorityfn = nil
    self.openlist = {}
    self.opencount = 0
    function Container:WidgetSetup(prefab, data)
        for i, v in ipairs(widgetprops) do removesetter(self, v) end

        --containers.widgetsetup(self, prefab, data)
        self:ReplicaWidgetSetup(prefab, data)

        --for i, v in ipairs(widgetprops) do makereadonly(self, v) end
    end
    function Container:ReplicaWidgetSetup(prefab, data)
        containers.widgetsetup(self, prefab, data)
        if self.classified ~= nil then self.classified:InitializeSlots(self:GetNumSlots()) end

        if self._onputininventory == nil then
            self._owner = nil
            self._ondropped = function(inst)
                if self._owner ~= nil then
                    local owner = self._owner
                    self._owner = nil
                    if owner.HUD ~= nil then owner:PushEvent("refreshcrafting") end
                end
            end
            self._onputininventory = function(inst, owner)
                self._ondropped(inst)
                self._owner = owner
                if owner ~= nil and owner.HUD ~= nil then owner:PushEvent("refreshcrafting") end
            end
            self.inst:ListenForEvent("onputininventory", self._onputininventory)
            self.inst:ListenForEvent("ondropped", self._ondropped)
        end
    end
    local old = self.CanTakeItemInSlot
    function Container:CanTakeItemInSlot(item, slot, ...)
        return old(self, item, slot, ...) and not item.components.inventoryitem.canonlygoinpocket and
                   (slot == nil or (slot >= 1 and slot <= self.numslots)) and
                   not (GetGameModeProperty("non_item_equips") and item.components.equippable ~= nil)
    end

end
