local function fn(InventoryItem)
    if InventoryItem.CanOnlyGoInPocket then return end
    -- InventoryItem.canonlygoinpocket = false
    function InventoryItem:CanOnlyGoInPocket()
        return self.canonlygoinpocket
    end

    function InventoryItem:SetSinks(should_sink)
        self.sinks = should_sink

        -- If we've already landed, check to see if the new value should make us sink.
        if self.is_landed then self:TryToSink() end
    end
    -- #FIXME
    local function IsLand(inst)
        local world = GetWorld()
        local x, y, z = inst.Transform:GetWorldPosition()
        local tile, tileinfo = inst:GetCurrentTileType(x, y, z)
        return world.Map:IsLand(tile)
    end
    function ShouldEntitySink(entity, entity_sinks_in_water)
        local inventory = (entity.components ~= nil and entity.components.inventoryitem) or nil
        if not entity:IsInLimbo() and (not inventory or not inventory:IsHeld()) then
            -- local px, _, pz = entity.Transform:GetWorldPosition()
            -- return not (TheWorld.Map and TheWorld.Map.IsPassableAtPoint
            --           and TheWorld.Map:IsPassableAtPoint(px, 0, pz, not entity_sinks_in_water))
            return not IsLand(entity)
        end
    end

    function SinkEntity()
    end

    function InventoryItem:TryToSink()
        if ShouldEntitySink(self.inst, self.sinks) then self.inst:DoTaskInTime(0, SinkEntity) end
    end

    local function GetClientSideInventoryImageOverride(self)
        if self.inst:HasClientSideInventoryImageOverrides() then
            return self.imagename and self.inst:GetClientSideInventoryImageOverride(self.imagename .. ".tex")
                       or self.inst:GetClientSideInventoryImageOverride(self.inst.prefab .. ".tex")
        end
    end

    local GetImage = InventoryItem.GetImage
    function InventoryItem:GetImage()
        local override = GetClientSideInventoryImageOverride(self)
        return (override and override.image) or GetImage(self)
    end

    -- Override default function
    function InventoryItem:GetAtlas()
        local override = GetClientSideInventoryImageOverride(self)
        return (override and override.atlas) or self.atlasname or GetInventoryItemAtlas(self:GetImage())
    end

    -- For Geometric Placement
    function InventoryItem:DeploySpacingRadius()
        return self.inst.components.deployable and self.inst.components.deployable.min_spacing or 0
    end

    -- Saddler
    function InventoryItem:SetWalkSpeedMult()
    end

end

return fn
