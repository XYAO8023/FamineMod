GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})
local function prequire(filename)
    local name = "postinit/" .. filename
    package.loaded[name] = nil
    return require(name)
end
-- the strict mode is disabled!
__STRICT = false
local gmeta = getmetatable(GLOBAL)
if gmeta then
    gmeta.__newindex = function(t, n, v)
        if not gmeta.__declared[n] then gmeta.__declared[n] = true end
        rawset(t, n, v)
    end
    gmeta.__index = function(t, n)
        return rawget(t, n)
    end
end
modimport("scripts/apis.lua")
utils.mod("scripts/dst/", {
    "globals",
    "TheNet",
    "entity",
    "netvar",
    "physics",
    "entityscript",
    "replica",
    "sim",
    "inventoryitematlas",
    "action",
    "asset",
    "animstate",
    "retrofit",
    "inventory",
    "stringutils",
    "recipe",
    "skin",
    "minimap",
    "particleemitter"
})
utils.mod("scripts/", {"modwrangler"})
-- import console command
if not GetIsWorkshop() or GetConfig("develop") == "true" then
    print("DST Wendy Mod import console")
    utils.mod("scripts/uiapis")
    utils.mod("scripts/entityapis")
    utils.mod("scripts/console")
    -- utils.mod("scripts/dbgapis")
    -- attach our optimization locally
    utils.mod("scripts/load_optim")
end
local level = GetConfig("printlevel")
if level == "none" then
    _G.print = neverprint
elseif level == "less" then
    _G.print = nodebugprint
elseif level == "never" then
    local u, print_loggers, n = UPVALUE.get(nolineprint, "print_loggers")
    if print_loggers then for k, v in pairs(print_loggers) do print_loggers[k] = nil end end
end
utils.game(function()
    for k, v in pairs({"dst/TheWorld", "dst/ThePlayer", "dstmodcompatibility"}) do require(v)() end
end)
utils.class("widgets/controls", function(self)
    local f = require "dst/ThePlayer"
    f()
end)
utils.player_raw(require "dst/ThePlayer")
-- import tunings as a function
local DSTTuning = require("dst_tuning")
local NewTUNING = DSTTuning(TUNING)
table.mergeinto(TUNING, NewTUNING)
NewTUNING = nil
DSTTunings = nil
local AllPostinit = require("dst_postinits")
for i, v in ipairs(AllPostinit.components) do utils.com(v, prequire("components/" .. v)) end
for i, v in ipairs(AllPostinit.prefab) do utils.prefab(v, prequire("prefabs/" .. v)) end
for i, v in ipairs(AllPostinit.widgets) do utils.class("widgets/" .. v, prequire("widgets/" .. v)) end
for i, v in ipairs(AllPostinit.screens) do utils.class("screens/" .. v, prequire("screens/" .. v)) end
for i, v in ipairs(AllPostinit.brain) do utils.brain(v .. "brain", prequire("brain/" .. v)) end
for i, v in ipairs(AllPostinit.root) do utils.class(v, prequire(v)) end
AllPostinit = nil
-- import direct requires as a table
local AllRequires = require("dst_complementary")
for i, v in ipairs(AllRequires.widget) do prequire("widgets/" .. v)(require("widgets/" .. v)) end
for i, v in ipairs(AllRequires.component) do prequire("components/" .. v)(require("components/" .. v)) end
AllRequires = nil
-- load dst modmain, this happens before modmain since we always load first
ModManager:LoadModsDST()
-- utils
if GetConfig("godmode") == "true" then utils.player_raw(godmode or c_supergodmode) end
