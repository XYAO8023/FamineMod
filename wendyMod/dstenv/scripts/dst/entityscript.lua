if EntityScript.SetClientSideInventoryImageOverride then return end
local ClientSideInventoryImageFlags = {}

function EntityScript:GetClientSideInventoryImageOverride(imagename)
    for flag, remaps in pairs(self.inventoryimageremapping) do
        if ClientSideInventoryImageFlags[flag] and remaps[imagename] then return remaps[imagename] end
    end
end

function EntityScript:HasClientSideInventoryImageOverrides()
    return self.inventoryimageremapping ~= nil
end

-- Note: srcinventoryimage has not been hashed anymore
function EntityScript:SetClientSideInventoryImageOverride(flagname, srcinventoryimage, destinventoryimage, destatlas)
    -- destatlas is optional
    self.inventoryimageremapping = self.inventoryimageremapping or {}
    self.inventoryimageremapping[flagname] = self.inventoryimageremapping[flagname] or {}
    self.inventoryimageremapping[flagname][srcinventoryimage] = {image = destinventoryimage, atlas = destatlas}
    if ClientSideInventoryImageFlags[flagname] and ThePlayer then
        ThePlayer:PushEvent("clientsideinventoryflagschanged")
    end
end

function EntityScript:SetClientSideInventoryImageOverrideFlag(name, value)
    value = (not value) ~= true or nil
    local updated = ClientSideInventoryImageFlags[name] ~= value
    ClientSideInventoryImageFlags[name] = value
    if updated and ThePlayer then ThePlayer:PushEvent("clientsideinventoryflagschanged") end
end

function EntityScript:SetPhysicsRadiusOverride(radius)
    self.physicsradiusoverride = radius
end

function EntityScript:HasDebuff(name)
    if self.components.debuffable == nil then return false end
    return self.components.debuffable:HasDebuff(name)
end

function EntityScript:DebuffsEnabled()
    return self.components.debuffable == nil or self.components.debuffable:IsEnabled()
end

function EntityScript:GetDebuff(name)
    if self.components.debuffable == nil then return nil end
    return self.components.debuffable:GetDebuff(name)
end

function EntityScript:AddDebuff(name, prefab, data, skip_test, pre_buff_fn)
    if self.components.debuffable == nil then self:AddComponent("debuffable") end

    if skip_test or (self:DebuffsEnabled() and not IsEntityDeadOrGhost(self)) then
        if pre_buff_fn then pre_buff_fn() end
        self.components.debuffable:AddDebuff(name, prefab, data)
        return true
    end

    return false
end

function EntityScript:RemoveDebuff(name)
    if self.components.debuffable == nil then return end
    self.components.debuffable:RemoveDebuff(name)
end

function EntityScript:GetSkinBuild()
    if self.skin_build_name == nil then self.skin_build_name = GetBuildForItem(self.skinname) end
    return self.skin_build_name
end

function EntityScript:WatchWorldState(event, fn)
    local world = TheWorld
    if event == "phase" then
        self:ListenForEvent("dusktime", fn, world)
        self:ListenForEvent("daytime", fn, world)
        self:ListenForEvent("nighttime", fn, world)
    else
        self:ListenForEvent(event, fn, world)
    end
end

function EntityScript:DoStaticTaskInTime(...)
    return self:DoTaskInTime(...)
end

function EntityScript:GetBasicDisplayName()
    return (self.displaynamefn ~= nil and self:displaynamefn())
               or (self.nameoverride ~= nil and STRINGS.NAMES[string.upper(self.nameoverride)]) -- or (self.name_author_netid ~= nil and ApplyLocalWordFilter(self.name, TEXT_FILTER_CTX_CHAT, self.name_author_netid)) -- this is more lika a TEXT_FILTER_CTX_NAME but its all user input (eg, naming a beefalo) so lets go with TEXT_FILTER_CTX_CHAT
    or self.name
end

function EntityScript:GetSkinName()
    return self.override_skinname or self.skinname
               or (self.components.itemskinner and self.components.itemskinner.skin_name)
               or (self.components.skinner and self.components.skinner.skin_name)
end

function EntityScript:HasTags(tags)
    for i = 1, #tags do if not self.entity:HasTag(tags[i]) then return false end end
    return true
end

function EntityScript:HasOneOfTags(tags)
    for i = 1, #tags do if self.entity:HasTag(tags[i]) then return true end end
    return false
end

function EntityScript:ShowPopUp(popup, ...)
    return popup.fn(ThePlayer, ...)
end

function EntityScript:GetParent()
    return self.entity:GetParent()
end
expose {}
