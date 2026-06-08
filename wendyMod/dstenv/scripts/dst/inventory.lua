if InventoryProxy then return end
local TheInventory = {} -- aka. InventoryProxy
local TheCInventory = _G.TheInventory or _userdata(TheInventory)
if not getmetatable(TheCInventory) then setmetatable(TheCInventory, {__index = TheInventory}) end
function TheInventory:ClearSkinsDataset()
end
function TheInventory:AddRestrictedBuildFromLua(name, build, instant)
end
function TheInventory:AddSkinSetInput()
end
function TheInventory:AddSkinLinkInput()
end
function TheInventory:AddSkinDLCInput()
end
function TheInventory:AddRestrictedItem()
    return false
end
function TheInventory:AddEmoji()
end -- #TODO
function TheInventory:AddCookBookKey()
end
function TheInventory:AddPlantRegistryKey()
end
function TheInventory:GetOwnership() -- for modders:you should not modify this function!
    return true
end
function TheInventory:CheckOwnership(v, ...) -- for modders:you can modify this function
    return self:GetOwnership(v)
end
function TheInventory:GetFullInventory()
    local i = {}
    for k, v in pairs(SKIN_PREFABS) do
        table.insert(i, {item_type = k, modified_time = 0, item_id = tostring(math.random(0, 10000))})
    end
    return i
end
function TheInventory:CheckClientOwnership(user_id, ...)
    return self:CheckOwnership(...)
end
TheInventory.CheckOwnershipGetLatest = TheInventory.CheckOwnership
function TheInventory:HasSupportForOfflineSkins()
    return true
end
function TheInventory:CheckBuild() -- added
    return true
end
function TheInventory:LookupSkinname(hashval)
    if hashval == 0 then return "" end
    return net_reversehash(hashval)
end
function TheInventory:SetItemOpened()
end
expose("TheInventory", TheCInventory)
expose("InventoryProxy", TheInventory)
