if DSTIngredient then return end

DSTIngredient = Class(Ingredient, function(self, ingredienttype, amount, atlas, deconstruct, imageoverride)
    Ingredient._ctor(self, ingredienttype, amount, atlas, deconstruct, imageoverride)
    self.atlas = atlas and resolvefilepath(atlas) or self:GetAtlas(true)
end)

function DSTIngredient:GetAtlas(force)
    if self.atlas == nil or force then self.atlas = resolvefilepath(GetInventoryItemAtlas(self:GetImage())) end
    return self.atlas
end

function DSTIngredient:GetImage(force)
    if self.image == nil or force then self.image = self.type .. ".tex" end
    return self.image
end

local num = 0
AllRecipes = {}

local is_tech_ingredient = nil
function IsTechIngredient(ingredienttype)
    if is_tech_ingredient == nil then
        is_tech_ingredient = {}
        for k, v in pairs(TECH_INGREDIENT) do is_tech_ingredient[v] = true end
    end
    return ingredienttype ~= nil and is_tech_ingredient[ingredienttype] == true
end

function GetValidRecipe(recname)
    if not IsRecipeValidInGameMode(TheNet:GetServerGameMode(), recname) then return end
    local rec = AllRecipes[recname]
    return rec ~= nil and not rec.is_deconstruction_recipe and
        (rec.require_special_event == nil or IsSpecialEventActive(rec.require_special_event)) and rec or nil
end

function IsRecipeValid(recname) return GetValidRecipe(recname) ~= nil end

function RemoveAllRecipes()
    AllRecipes = {}
    num = 0
end

-- add dst character tabs
local DSTCHARACTERTABS = {
    BOOKBUILDER = "BOOKS",
    SHADOWMAGIC = "SHADOW",
    HANDYPERSON = "ENGINEERING",
    ELIXIRBREWER = "ELIXIRBREWING",
    GHOSTLYFRIEND = "MAGIC",
    BATTLESINGER = "BATTLESONGS",
    VALKYRIE = "WAR",
    SPIDERWHISPERER = "SPIDERCRAFT",
    PLANTKIN = "NATURE",
    PEBBLEMAKER = "SLINGSHOTAMMO",
    PINETREEPIONEER = "DRESS",
    BALLOONOMANCER = "BALLOONOMANCY",
    CLOCKMAKER = "CLOCKMAKER",
    STRONGMAN = "STRONGMAN",
    UPGRADEMODULEOWNER = "UPGRADEMODULEOWNER",
    PROFESSIONALCHEF = "FOODPROCESSING",
    MASTERCHEF = "FARM",
    MERM_BUILDER = "TOWN",
    PYROMANIAC = "LIGHT",
    WEREHUMAN = "MAGIC"
}
-- old new translation
local RFLookup = {
    ["CRAFTING_STATION"] = "modstation",
    ["SPECIAL_EVENT"] = "modstation",
    ["MODS"] = "mod",
    ["CHARACTER"] = "mod",
    ["TOOLS"] = "tools",
    ["LIGHT"] = "light",
    ["PROTOTYPERS"] = "science",
    ["REFINE"] = "refine",
    ["WEAPONS"] = "war",
    ["ARMOUR"] = "war",
    ["CLOTHING"] = "dress",
    ["RESTORATION"] = "survival",
    ["MAGIC"] = "magic",
    ["DECOR"] = "town",
    ["STRUCTURES"] = "town",
    ["CONTAINERS"] = "town",
    ["COOKING"] = "farm",
    ["GARDENING"] = "farm",
    ["FISHING"] = "fishing",
    ["SEAFARING"] = "seafaring",
    ["RIDING"] = "tools",
    ["WINTER"] = "survival",
    ["SUMMER"] = "survival",
    ["RAIN"] = "survival"
}
local function GuessTab(name, ingredients, tech, config)
    if config.tab and RECIPETABS[string.upper(config.tab)] then return RECIPETABS[string.upper(config.tab)] end
    if config and config.builder_tag then
        local guess = DSTCHARACTERTABS[string.upper(config.builder_tag)]
        if guess then return RECIPETABS[guess] end
    end
end

-- patched
local Recipe = _G.Recipe -- hate modutils
local Recipe2 = Class(Recipe, function(self, name, ingredients, tech, config) -- add new optional params to config
    if type(config) == "string" then
        config = {
            placer = config
        }
    end
    if type(config) ~= "table" then config = {} end
    local tab = GuessTab(name, ingredients, tech, config)
    if not tab then
        -- do not add if can't guess
        return
    end
    config.distance = config.distance or config.build_distance or 1
    if config.aquatic == nil then config.aquatic = config.build_mode == 2 end
    self.product = config.product or name
    self.description = config.description -- override the description string in the crafting menu
    self.sortkey = num
    self.rpc_id = num
    -- self.level = TechTree.Create(level)
    config.level = config.level or tech -- added

    self.testfn = config.testfn -- custom placer test function if default test isn't enough
    self.canbuild = config.canbuild -- custom test function to see if we should be allowed to craft this recipe, return a build action fail message if false
    self.builder_tag = config.builder_tag or nil
    self.sg_state = config.sg_state or config.buildingstate or nil -- overrides the SG state to use when crafting the item (buildingstate is the old variable name)

    self.build_mode = config.build_mode or (self.aquatic ~= nil and (self.aquatic and 2 or 1)) or 0
    self.build_distance = config.distance

    self.no_deconstruction = config.no_deconstruction -- function or bool
    self.require_special_event = config.require_special_event

    self.dropitem = config.dropitem

    self.actionstr = config.actionstr

    self.manufactured = config.manufactured -- if true, then it is up to the crafting station to handle creating the item, not the builder component

    self.is_deconstruction_recipe = false -- maybe?
    local params = { self, name, ingredients, tab, config.level, config.game_type, config.placer, config.min_spacing,
        config.nounlock, config.numtogive, config.aquatic, config.distance, config.decor, config.flipable,
        type(config.image) == "string" and config.image, config.wallitem, config.alt_ingredients }
    if IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(PORKLAND_DLC) then
    else
        for i = 6, 16 do params[i] = params[i + 1] end
    end
    Recipe._ctor(unpack(params, 1, 17))
    -- Recipe._ctor(self, name, ingredients, tab, tech, placer,
    --    config.min_spacing, config.nounlock, config.numtogive, config.builder_tag, config.atlas, config.image,
    --     config.testfn, config.product, config.build_mode, config.build_distance)
    self.imagefn = type(config.image) == "function" and config.image or nil
    self.image = type(config.image) == "string" and config.image or nil
    self:GetImage()
    if config.atlas then
        self.atlas = config.atlas
    else
        self.atlas = GetInventoryItemAtlas(self:GetImage())
    end
end)
function Recipe2:GetAtlas()
    if self.atlas then return self.atlas end
    if GetInventoryItemAtlas(self:GetImage(), true) then
        self.atlas = GetInventoryItemAtlas(self:GetImage())
    end
    return self.atlas or ""
end

function Recipe2:GetImage()
    if self.imagefn then return self:imagefn() end
    if self.image then return self.image end
    self.image = self.product and self.product .. ".tex" or self.name and self.name .. ".tex" or ""
    return self.image
end

function Recipe2:SetModRPCID() self.rpc_id = smallhash(self.name) end

require("widgets/widgetutil")
local oldDoRecipeClick = DoRecipeClick
local RECIPECATEGORIES = RECIPECATEGORIES or {}
function DoRecipeClick(owner, recipe, skin)
    skin = skin or recipe.skin -- must fetch this from recipe
    if skin == recipe.name then skin = nil end
    if skin and skin ~= "" and TheInventory:CheckClientOwnership(owner.userid, skin) and
        table.contains(PREFAB_SKINS[recipe.product or ""], skin) then
        recipe.validateskin = skin -- useless
        owner.__validateskin = skin -- I don't want to override builder.MakeRecipe, so I have to sneak it into here
    else
        skin = nil
    end
    return oldDoRecipeClick(owner, recipe, skin)
    -- owner.__validateskin = nil -- clear twice. The SpawnPrefabWithSkin also clear this
end

local function HackCraftTabs(CraftTabs)
    if CraftTabs.CheckBuilderTag then return end
    function CraftTabs:CheckBuilderTag(tabname)
        if not tabname then return true end
        if self.shouldShowTabFns and self.shouldShowTabFns[tabname] then
            return true
        end
        local tab = RECIPETABS[tabname]
        if not tab then
            --this is a DS character tab, so it is always visible
            return true
        end
        return tab.builder_tag == nil or self.owner:HasTag(tab.builder_tag)
    end

    local old = CraftTabs.ShouldShowTab
    function CraftTabs:ShouldShowTab(...)
        return self:CheckBuilderTag(...) and old(self, ...)
    end

    local old2 = CraftTabs.HandleMultiCraftingStationTabs
    if old2 then
        function CraftTabs:HandleMultiCraftingStationTabs(...)
            local ret = { old2(self, ...) }
            for i, v in ipairs(RECIPECATEGORIES) do
                if RECIPETABS[v.name] then if RECIPETABS[v.name].atlas then v.atlas = RECIPETABS[v.name].icon_atlas end end
            end
            return unpack(ret)
        end
    end
end

local oldc = RecipeCategory and RecipeCategory._ctor
if oldc then
    RecipeCategory._ctor = function(self, ...)
        oldc(self, ...)
        table.insert(RECIPECATEGORIES, self)
    end
end

HackCraftTabs(require("widgets/crafttabs"))
expose {
    Recipe2 = Recipe2,
    DSTIngredient = DSTIngredient,
    AllRecipes = AllRecipes,
    RECIPECATEGORIES = RECIPECATEGORIES
}
expose({
    DoRecipeClick = DoRecipeClick
}, true)
