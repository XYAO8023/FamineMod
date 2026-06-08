if UICOLOURS then return end
local function nothing() end

function FunctionOrValue(func_or_val, ...)
    if type(func_or_val) == "function" then return func_or_val(...) end
    return func_or_val
end
function IsPrefabSkinned(prefab) return PREFAB_SKINS[prefab] ~= nil end
SURVIVAL_GAME_MODE = {
    text = "",
    description = "",
    level_type = "SURVIVAL",
    mod_game_mode = false,
    spawn_mode = "fixed",
    resource_renewal = false,
    ghost_sanity_drain = true,
    ghost_enabled = true,
    portal_rez = false,
    reset_time = {
        time = 120,
        loadingtime = 180
    },
    invalid_recipes = nil
}
function RGB(r, g, b, a) return {r / 255, g / 255, b / 255, 1} end
UICOLOURS = {
    GOLD_CLICKABLE = RGB(215, 210, 157), -- interactive text & menu
    GOLD_FOCUS = RGB(251, 193, 92), -- menu active item
    GOLD_SELECTED = RGB(245, 243, 222), -- titles and non-interactive important text
    GOLD_UNIMPORTANT = RGB(213, 213, 203), -- non-interactive non-important text
    HIGHLIGHT_GOLD = RGB(243, 217, 161),
    GOLD = RGB(202, 174, 118),
    BROWN_MEDIUM = RGB(107, 84, 58),
    BROWN_DARK = RGB(80, 61, 39),
    BLUE = RGB(80, 143, 244),
    GREY = RGB(145, 145, 145),
    BLACK = RGB(10, 10, 10),
    WHITE = RGB(255, 255, 255),
    BRONZE = RGB(180, 116, 36, 1),
    EGGSHELL = RGB(252, 230, 201),
    IVORY = RGB(236, 232, 223, 1),
    IVORY_70 = RGB(165, 162, 156, 1),
    PURPLE = RGB(152, 86, 232, 1),
    RED = RGB(207, 61, 61, 1),
    SLATE = RGB(155, 170, 177, 1),
    SILVER = RGB(192, 192, 192, 1)
}
DST_CHARACTERLIST = {"wilson", "willow", "wolfgang", "wendy", "wx78", "wickerbottom", "woodie", "wes", "waxwell",
                     "wathgrithr", "webber", "winona", "warly", "wortox", "wormwood", "wurt", "walter", "wanda",
                     "wonkey"}
local gvals = {
    AllPlayers = {},
    DST_CHARACTERLIST = DST_CHARACTERLIST,
    UICOLOURS = UICOLOURS,
    IsPrefabSkinned = IsPrefabSkinned,
    MODCHARACTERMODES = {},
    NUM_SKIN_PRESET_SLOTS = 25,
    HEADERFONT = "bp50", -- UIFONT
    CHATFONT = DIALOGFONT,
    NEWFONT = DIALOGFONT,
    NEWFONT_OUTLINE = DIALOGFONT,
    CHATFONT_OUTLINE = DIALOGFONT

}
local function MakePatch(fn, postinit, newvars)
    local patched = {}
    local inited = false
    if newvars then for k, v in pairs(newvars) do patched[k] = v end end
    setmetatable(patched, {
        __index = function(_, k)
            local p = fn()
            if p then
                -- transfer already registered variables
                for k2, v2 in pairs(patched) do rawset(p, k2, v2) end
                if not inited then
                    inited = true
                    if postinit then postinit(p, k) end
                end
            end
            return p and p[k]
        end,
        __newindex = function(_, k, v)
            local p = fn()
            if p then
                -- transfer already registered variables
                for k2, v2 in pairs(patched) do rawset(p, k2, v2) end
                p[k] = v
                if not inited then
                    inited = true
                    if postinit then postinit(p, k) end
                end
            end
        end
    })
    return patched
end
function GetGameModeProperty(prop) return SURVIVAL_GAME_MODE[prop] end
function shallowcopy(orig, dest)
    local copy
    if type(orig) == "table" then
        copy = dest or {}
        for k, v in pairs(orig) do copy[k] = v end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
-- from componentutil
function IsEntityDead(inst, require_health)
    if inst.components.health == nil then -- patched
        return require_health == true
    end
    return inst.components.health:IsDead() -- patched
end
function IsEntityDeadOrGhost(inst, require_health)
    if inst:HasTag("playerghost") then return true end
    return IsEntityDead(inst, require_health)
end
local function PlayerPostInit(inst) table.insert(_G.AllPlayers, inst) end
local function WorldPostInit(inst)
    if not rawget(_G.TheWorld.state, "phase") then
        local postinitfn = require"dst/TheWorld"
        postinitfn(inst)
    end
end
local gvars = {
    ThePlayer = MakePatch(GetPlayer, PlayerPostInit),
    TheWorld = MakePatch(GetWorld, WorldPostInit, {
        ismastersim = true,
        state = {}
    })
}
dstrequire = function(path) return require("dst/" .. path) end
local gfns = {
    -- MakeInventoryFloatable = nothing,
    MakeHauntable = nothing, -- these functions may not always be nothing
    MakeHauntableLaunch = nothing,
    MakeHauntableLaunchAndSmash = nothing,
    MakeHauntableWork = nothing,
    MakeHauntableWorkAndIgnite = nothing,
    MakeHauntableFreeze = nothing,
    MakeHauntableIgnite = nothing,
    MakeHauntableLaunchAndIgnite = nothing,
    MakeHauntableChangePrefab = nothing,
    MakeHauntableLaunchOrChangePrefab = nothing,
    MakeHauntablePerish = nothing,
    MakeHauntableLaunchAndPerish = nothing,
    MakeHauntablePanic = nothing,
    MakeHauntablePanicAndIgnite = nothing,
    MakeHauntablePlayAnim = nothing,
    MakeHauntableGoToState = nothing,
    MakeHauntableGoToStateWithChanceFunction = nothing,
    MakeHauntableDropFirstItem = nothing,
    MakeHauntableLaunchAndDropFirstItem = nothing,
    NOTHING = nothing,
    shallowcopy = shallowcopy,
    IsEntityDead = IsEntityDead,
    IsEntityDeadOrGhost = IsEntityDeadOrGhost,
    MakeSnowCoveredPristine = nothing -- since master init will do MakeSnowCovered
    ,
    GetGameModeProperty = GetGameModeProperty,
    FunctionOrValue = FunctionOrValue,
    dstrequire = dstrequire,
    SetAutopaused = function(paused) return SetPause(paused) end,
    Clamp=math.clamp
}
local goverride = {}
local grequires = {
    SourceModifierList = "dst/util/sourcemodifierlist"
}
function table.getkeys(t)
    local keys = {}
    for key,val in pairs(t) do
        table.insert(keys, key)
    end
    return keys
end
function InitGlobal(G)
    G = G or _G
    for k, v in pairs(gvars) do if not G[k] then G[k] = v end end
    for k, v in pairs(gvals) do if not G[k] then G[k] = v end end
    for k, v in pairs(gfns) do if not G[k] then G[k] = v end end
    for k, v in pairs(grequires) do if not G[k] then G[k] = require(v) end end
    for k, v in pairs(goverride) do G[k] = v end
end
InitGlobal(GLOBAL)
gvars, gvals, gfns, grequires, goverride = nil, nil, nil, nil, nil

