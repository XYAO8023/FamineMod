if PREFAB_SKINS then return end
local PrefabSkins = {}
local SkinPrefabs = {}
-- DST functions are polluting the global scope with unnecessary names, I move these functions to a table
SKINFNS = {
    basic_init_fn = function(inst, build_name, def_build)
        inst.AnimState:SetSkin(build_name, def_build)
        if inst.components.inventoryitem ~= nil then
            -- print("change image_name",inst:GetSkinName())
            inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
        end
    end,
    basic_clear_fn = function(inst, def_build)
        if def_build then inst.AnimState:SetBuild(def_build) end
        if inst.components.inventoryitem ~= nil then inst.components.inventoryitem:ChangeImageName() end
    end
}
local function AddSkinnerComponent(inst)
    if inst:HasTag("player") then
        if not inst.components.skinner then inst:AddComponent("skinner") end
    else
        if not inst.components.itemskinner then inst:AddComponent("itemskinner") end
    end
end
local function GetSpecialItemCategories()
    -- We build this in a function because these symbols don't exist when this
    -- file is first loaded.
    return {SkinPrefabs}
    --[[
	{
		MISC_ITEMS,
		CLOTHING,
		EMOTE_ITEMS,
		EMOJI_ITEMS,
		BEEFALO_CLOTHING,
	}]] -- deleted
end
function GetAllItemCategories()
    return {Prefabs, unpack(GetSpecialItemCategories())}
end
local function InitSkinnablePrefab(prefab)
    AddPrefabPostInit(prefab, AddSkinnerComponent)
end
function CreatePrefabSkin(name, data)
    if not name then return end
    local p = data.base_prefab
    local d = shallowcopy(data)
    SkinPrefabs[name] = d
    d.type = d.type or "base"
    if not PrefabSkins[p] then
        if TheInventory:AddRestrictedItem(name, d) then
            InitSkinnablePrefab(p)
            PrefabSkins[p] = {name}
        end
    else
        if not table.contains(PrefabSkins[p], name) then
            table.insert(PrefabSkins[p], name)
            TheInventory:AddRestrictedItem(name, d)
        end
    end
    return nil
end
function GetTypeForItem(item)
    local itemName = string.lower(item) -- they come back from the server in caps
    local type = "unknown"
    local data = GetSkinData(item)
    -- print("Getting type for ", itemName)
    if data then type = data.type end
    return type, itemName
end
SKIN_RARITY_COLORS = {Common = {0.718, 0.824, 0.851, 1}}
DEFAULT_SKIN_COLOR = SKIN_RARITY_COLORS["Common"]

function GetColorForItem(item)
    local skin_data = GetSkinData(item)
    return _G.SKIN_RARITY_COLORS[skin_data and skin_data.rarity] or _G.DEFAULT_SKIN_COLOR
end
local ghost_preview_y_offset = -25
local ghost_preview_scale = 0.75
skintypesbycharacter = {
    default = {
        {type = "normal_skin", play_emotes = true},
        {
            type = "ghost_skin",
            anim_bank = "ghost",
            idle_anim = "idle",
            scale = ghost_preview_scale,
            offset = {0, ghost_preview_y_offset}
        }
    }
}
---@param prefab string
function GetSkinModes(character)
    return skintypesbycharacter.default
end
function IsValidClothing(name)
    return name ~= nil and name ~= "" and CLOTHING[name] ~= nil and not CLOTHING[name].is_default
end
local function _ItemStringRedirect(item)
    if string.sub(item, -8) == "_builder" then item = string.sub(item, 1, -9) end
    if string.sub(item, -8) == "default1" then item = "none" end
    return item
end
function GetSkinDescription(item)
    item = _ItemStringRedirect(item)
    return STRINGS.SKIN_DESCRIPTIONS and (STRINGS.SKIN_DESCRIPTIONS[item] or STRINGS.SKIN_DESCRIPTIONS["missing"]) or ""
end
function GetCharacterSkinBases(pb)
    local ret = {}
    if PREFAB_SKINS[pb] then for k, v in ipairs(PREFAB_SKINS[pb]) do ret[v] = SKIN_PREFABS[v] end end
    return ret
end
function GetRarityModifierForItem(item)
    local skin_data = GetSkinData(item)
    local rarity_modifier = skin_data.rarity_modifier
    return rarity_modifier
end
function GetModifiedRarityStringForItem(item)
    if not STRINGS.UI.RARITY then return "" end
    if GetRarityModifierForItem(item) ~= nil then
        if STRINGS.UI.RARITY[GetRarityModifierForItem(item)] == nil then
            print("Error! Unknown rarity modifier. Needs to be defined in strings.lua.", GetRarityModifierForItem(item))
        end
        return (STRINGS.UI.RARITY[GetRarityModifierForItem(item)] or "") .. STRINGS.UI.RARITY[GetRarityForItem(item)]
    else
        return STRINGS.UI.RARITY[GetRarityForItem(item)]
    end
end

function GetSkinInvIconName(item)
    local image_name = item
    if image_name == "" then
        image_name = "default"
    else
        if string.sub(image_name, -8) == "_builder" then image_name = string.sub(image_name, 1, -9) end
        image_name = string.gsub(image_name, "_none", "")
    end

    return image_name
end
function GetSkinData(item)
    return SkinPrefabs[item]
end
function GetFrameSymbolForRarity(rarity)
    local r = string.lower(rarity)
    if string.find(r, "heirloom") then return "heirloom" end
    if r == "complimentary" then return "common" end
    return r
end
function GetRarityForItem(name)
    local skin_data = GetSkinData(name)
    return skin_data and skin_data.rarity or "common"
end
function GetSkinModeFromBuild(player,build)
    -- this relies on builds not being shared across states
    build = build or player.AnimState:GetBuild()

    if PrefabSkins[player.prefab] == nil then return nil end
    for _, skin in pairs(PrefabSkins[player.prefab]) do
        local skindata = GetSkinData(skin)
        if skindata and skindata.skins then
            for skintype, skinbuild in pairs(skindata.skins) do
                if build == skinbuild then return skintype end
            end
        end
    end
    return nil
end
-- add
function GetSuffixFromSkinName(skinname)
    if type(skinname) ~= "string" then return "" end
    local first_ = string.find(skinname, "_")
    if not first_ then return "" end
    local second_ = string.find(skinname, "_", first_ + 2)
    if not second_ then return "" end
    local suffix = string.sub(skinname, second_ + 1)
    return suffix
end
expose {
    PREFAB_SKINS = PrefabSkins,
    SKIN_PREFABS = SkinPrefabs,
    SKINFNS = SKINFNS,
    GetTypeForItem = GetTypeForItem,
    GetSkinModes = GetSkinModes,
    CLOTHING = {},
    BEEFALO_CLOTHING = {},
    IsValidClothing = IsValidClothing,
    GetColorForItem = GetColorForItem,
    SKIN_RARITY_COLORS = SKIN_RARITY_COLORS,
    DEFAULT_SKIN_COLOR = DEFAULT_SKIN_COLOR,
    GetSkinName = function(name)
        return STRINGS.SKIN_NAMES and (STRINGS.SKIN_NAMES[name] or STRINGS.SKIN_NAMES["missing"]) or ""
    end,
    GetSkinInvIconName = GetSkinInvIconName,
    GetFrameSymbolForRarity = GetFrameSymbolForRarity,
    GetRarityForItem = GetRarityForItem,
    IsDefaultSkinOwned = function()
        return true -- TODO:investigate if "default skin" is really default, in DS all characters are defaultly owned so maybe all default skins are owned
    end,
    GetSkinModeFromBuild = GetSkinModeFromBuild,
    SKIN_AFFINITY_INFO = {},
    GetSkinData = GetSkinData,
    GetBuildForItem = function(name)
        local skin_data = GetSkinData(name)
        if skin_data and skin_data.build_name_override ~= nil then return skin_data.build_name_override end
        return name
    end,
    skintypesbycharacter = skintypesbycharacter,
    CreatePrefabSkin = CreatePrefabSkin,
    GetSkinDescription = GetSkinDescription,
    GetCharacterSkinBases = GetCharacterSkinBases,
    GetModifiedRarityStringForItem = GetModifiedRarityStringForItem,
    GetSuffixFromSkinName = GetSuffixFromSkinName
}
