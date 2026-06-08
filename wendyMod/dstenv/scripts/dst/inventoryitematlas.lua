--  ================================================================== --
-- |      Library Designed by Leonidas IV  - Copyright 2022-2022      |
--  ================================================================== --
-- edited by zzzzzzzs 2022.11.08
------------------------------------------------------------------------------------
if RegisterInventoryItemAtlas then return end
local HAMenabled = IsDLCEnabled(PORKLAND_DLC)
local inventoryItemAtlasLookup = _G.inventoryItemAtlasLookup or {}
local InventoryItemAtlas = _G.InventoryItemAtlas or {}
InventoryItemAtlas.defaultatlas = InventoryItemAtlas.defaultatlas or "images/inventoryimages.xml"
InventoryItemAtlas.atlasLookup = inventoryItemAtlasLookup
local io = require("io")
local function ProcessAtlas(atlas, ...)
    local path = softresolvefilepath(atlas)
    if not path then
        print("[API]: The atlas \"" .. atlas .. "\" cannot be found.")
        return
    end
    local success, file = pcall(io.open, path)
    if not success or not file then
        print("[API]: The atlas \"" .. atlas .. "\" cannot be found.")
        return
    end
    local xml = file:read("*all")
    file:close()
    local images = xml:gmatch("<Element name=\"(.-)\"")
    for tex in images do RegisterInventoryItemAtlas(atlas, tex, ...) end
end

function RegisterInventoryItemAtlas(atlas, imagename, canoverride)
    if canoverride == nil then canoverride = true end
    if atlas ~= nil and imagename ~= nil then
        if inventoryItemAtlasLookup[imagename] ~= nil then
            if inventoryItemAtlasLookup[imagename] ~= atlas then
                nolineprint("RegisterInventoryItemAtlas: Image '" ..
                    imagename .. "' is already registered to atlas '" ..
                    inventoryItemAtlasLookup[imagename] .. "'")
                if not canoverride then return end
            else
                return -- added
            end
        end
        -- else --deleted
        inventoryItemAtlasLookup[imagename] = atlas
        -- compatible with API
        if TheInvImagesAPI then TheInvImagesAPI.atlasLookup[imagename] = atlas end
    end
end

ProcessAtlas(InventoryItemAtlas.defaultatlas)
if HAMenabled then
    InventoryItemAtlas.hamatlas = InventoryItemAtlas.hamatlas or "images/inventoryimages_2.xml"
    ProcessAtlas(InventoryItemAtlas.hamatlas)
end
function GetInventoryItemAtlas(imagename, no_fallback)
    local atlas = inventoryItemAtlasLookup[imagename]
    if atlas then return atlas end
    if imagename == ".tex" then return "" end --bug fix:shop_pedestals
    if not string.find(imagename, "tex") and not string.find(imagename, "png") then
        if CONSOLE then CONSOLE.traceback() end
    end
    local base_atlas = InventoryItemAtlas.defaultatlas -- changed, DS name is "inventoryimages" and "inventoryimages_2"
    local alt_atlas = InventoryItemAtlas.hamatlas -- Hamlet compatibility added
    atlas = TheSim:AtlasContains(base_atlas, imagename) and base_atlas or
        (alt_atlas and TheSim:AtlasContains(alt_atlas, imagename) and alt_atlas)
    if not atlas then
        if no_fallback then
            nolineprint("[InventoryAtlas]cannot find " .. imagename)
            if CONSOLE then CONSOLE.traceback() end
        else
            atlas = base_atlas
        end
    else
        if no_fallback then inventoryItemAtlasLookup[imagename] = atlas end
    end
    return atlas
end

local function HookOnDrawnFn(inst)
    local _OnDrawnFn = inst.components.drawable.ondrawnfn
    inst.components.drawable.ondrawnfn = function(inst, image, src)
        _OnDrawnFn(inst, image, src)

        local atlas = GetInventoryItemAtlas(image .. ".tex", true)
        if image and atlas then inst.AnimState:OverrideSymbol("SWAP_SIGN", atlas, image .. ".tex") end
    end
end

AddPrefabPostInit("minisign", HookOnDrawnFn)
AddPrefabPostInit("minisign_drawn", HookOnDrawnFn)

------------------------------------------------------------------------------------

local function ChangedGetAtlas(image, pre_atlas)
    return GetInventoryItemAtlas(image, true) or (pre_atlas and resolvefilepath(pre_atlas))
end

local old = _G.Ingredient.GetAtlas
if old then
    function _G.Ingredient:GetAtlas(imagename)
        self.atlas = ChangedGetAtlas(imagename, self.atlas) or old(self, imagename)
        return self.atlas
    end
else
    function _G.Ingredient:GetAtlas(imagename)
        self.atlas = ChangedGetAtlas(imagename, self.atlas)
        return self.atlas
    end
end
local old = _G.Recipe.GetAtlas
if old then
    function _G.Recipe:GetAtlas()
        self.atlas = ChangedGetAtlas(self.image, self.atlas) or old(self)
        return self.atlas
    end
else
    function _G.Recipe:GetAtlas()
        self.atlas = ChangedGetAtlas(self.image, self.atlas)
        return self.atlas
    end
end

expose({
    RegisterInventoryItemAtlas = RegisterInventoryItemAtlas,
    GetInventoryItemAtlas = GetInventoryItemAtlas,
    RegisterInventoryItemAtlasFromXML = ProcessAtlas,
    InventoryItemAtlas = InventoryItemAtlas, -- put this into global scope so that you can directly modifiy this.
    inventoryItemAtlasLookup = inventoryItemAtlasLookup -- put this into global scope so that you can directly modifiy this.
}, true)
