local function drequire(filename)
    return utils.onemod("dst_wendy_" .. filename)
end

local function prequire(filename)
    return utils.onemod("postinit/" .. filename)
end
local print = print
if not GetConfig("debug") and GetIsWorkshop() then
    print = function()
    end
end
print("DST Wendy Mod init")
-- import inventory images as a table
-- replace with DST variables
local Asset = DSTAsset
local InvImages = drequire("inventoryimages")
RegInvImage(InvImages)
for xml, v in pairs(InvImages) do RegAssets(xml, v) end
InvImages = nil
local TabsImages = "images/tabs_dst.xml"
RegisterInventoryItemAtlasFromXML(TabsImages)
-- import languages
print("DST Wendy Mod import language")
utils.mod("scripts/TranslateLanguage")
-- import libs
print("DST Wendy Mod import libs")
utils.mod("scripts/", {"ActionUtils", "SGUtils"})
-- import tunings
print("DST Wendy Mod import tunings")
local DSTTuning = drequire("tuning")
table.mergeinto(TUNING, DSTTuning())
DSTTunings = nil
-- expose my API
expose("UPVALUE", UPVALUE)
print("DST Wendy Mod import postinits")
-- import postinit as a table
local AllPostinit = drequire("postinits")
for i, v in ipairs(AllPostinit.component) do utils.com(v, prequire(v)) end
for i, v in ipairs(AllPostinit.prefab) do utils.prefab(v, prequire(v)) end
for i, v in ipairs(AllPostinit.widget) do utils.class("widgets/" .. v, prequire("widgets/" .. v)) end
for i, v in ipairs(AllPostinit.screens) do utils.class("screens/" .. v, prequire("screens/" .. v)) end
for i, v in ipairs(AllPostinit.brain) do utils.brain(v .. "brain", prequire("brain/" .. v)) end
for i, v in ipairs(AllPostinit.root) do utils.class(v, prequire(v)) end
AllPostinit = nil
-- import shaders
-- table.insert(Assets, Asset("SHADER", resolvefilepath "shaders/anim_bloom_ghost.ksh"))
-- import prefabs as a table
PrefabFiles = drequire("prefabs")
-- add minimap atlas
utils.minimap("minimap/minimap_dst_wendy.xml")
table.insert(Assets, Asset("IMAGE", "minimap/minimap_dst_wendy.tex"))
table.insert(Assets, Asset("ATLAS", "minimap/minimap_dst_wendy.xml"))
-- import non prefab assets
local extaassets = drequire("extraassets")
local canload = GetConfig("hud") ~= "true"
for k, v in ipairs(extaassets) do
    if not canload and v[2] == "status_meter" then
    else
    end
    table.insert(Assets, MakeAsset(unpack(v)))
end
extaassets = nil
-- import actions as a table
print("DST Wendy Mod import actions")
local AllActions = drequire("actions")
AddDSTActions(AllActions)
AllActions = nil
local AllComponentActions = drequire("componentactions")
for k, v in pairs(AllComponentActions) do for comp, fn in pairs(v) do DSTAddComponentAction(k, comp, fn) end end
AllComponentActions = nil
-- import stategraph
local AllSG = drequire("sg")
AddDSTSG(AllSG)
AllSG = nil
-- import recipes as a function
print("DST Wendy Mod import assets")
local function MakeRecipeTabs(inst)
    local RecipeTabs = drequire("recipetab")
    for i, v in ipairs(RecipeTabs) do
        if not RECIPETABS[v.str] then
            if v.playertag == nil or inst:HasTag(v.playertag) then
                v.crafting_station = v.hascrafting_station
                v.atlas = v.atlas or v.icon_atlas
                v.icon_atlas = v.icon_atlas or v.atlas
                v.hascrafting_station = v.crafting_station
                v.crafting_station = true
                RECIPETABS[v.str] = v
                STRINGS.TABS[v.str] = STRINGS.TABS[v.str] or v.name or v.str
            end
        end
    end
end

utils.player_raw(function(inst)
    local sort = 4
    MakeRecipeTabs(inst)
    drequire("recipes")(inst)
    for k, t in pairs(RECIPETABS) do
        -- fix bug, but not really necessary
        if not t.priority then
            t.priority = sort
            sort = sort + 1
        end
    end
end)
-- retrofit Abigail's flower
RetrofitItem("abigail_flower", function()
    if ThePlayer.components and ThePlayer.components.inventory and ThePlayer.prefab == "wendy" then
        ThePlayer.components.inventory:GiveItem(SpawnPrefab("abigail_flower"))
    end
end)
-- import brain
-- nothing to do
-- Combined Status manual compatibility
TUNING.combined_status = GetConfig("combined") == "true"
TUNING.combined_status_method = GetConfig("method")
-- HUD skin mod
utils.game(function()
    local function AddRule(ret)
        ret["images/sisturn_slot_petals.xml"] = {
            ["sisturn_slot_petals.tex"] = ret["images/hud.xml"]["sisturn_slot_petals.tex"]
        }
    end
    if TUNING.HUDSKIN then
        for k, v in pairs(TUNING.HUDSKIN) do if type(v) == "table" and v.rule then AddRule(v.rule) end end
    end
end)
-- #TODO: add sound
-- #fix shader(aborted)
-- #add sound effects
-- #add _G to modinfo