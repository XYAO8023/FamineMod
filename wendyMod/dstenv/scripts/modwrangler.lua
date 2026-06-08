--[[
    Note for modders: dstmodmain.lua allows you to build DST environment before modmain
    But you are advised to work directly in _G
    Assets and PrefabFiles are better only written in modmain if you don't want to handle them twice
    Other things can be done here, and later you can get them in modmain because they share the same environment
]] --
local ModWrangler = ModManager
local function AddDSTEnv(e)
    local function Nothing() end
    e.Assets = e.Assets or {}
    e.PrefabFiles = e.PrefabFiles or {}
    local newenv = {
        _G = _G,
        Asset = DSTAsset,
        Prefab = DSTPrefab,
        Action = DSTAction,
        RegisterInventoryItemAtlas = RegisterInventoryItemAtlas,
        Recipe2 = Recipe2,
        Ingredient = DSTIngredient,
        AddAction = DSTAddAction,
        AddComponentAction = DSTAddComponentAction,
        AddModRPCHandler = AddModRPCHandler,
        AddClientModRPCHandler = AddClientModRPCHandler,
        AddShardModRPCHandler = AddShardModRPCHandler,
        GetModRPCHandler = GetModRPCHandler,
        GetClientModRPCHandler = GetClientModRPCHandler,
        GetShardModRPCHandler = GetShardModRPCHandler,
        SendModRPCToServer = SendModRPCToServer,
        SendModRPCToClient = SendModRPCToClient,
        SendModRPCToShard = SendModRPCToShard,
        MOD_RPC = MOD_RPC,
        CLIENT_MOD_RPC = CLIENT_MOD_RPC,
        SHARD_MOD_RPC = SHARD_MOD_RPC,
        GetModRPC = GetModRPC,
        GetClientModRPC = GetClientModRPC,
        GetShardModRPC = GetShardModRPC,
        AddLoadingTip = Nothing,
        AddUserCommand = Nothing -- #TODO: implement this
    }
    local env = CreateEnvironment(e.modname)
    table.mergeinto(env, newenv, true)
    -- let postinitfns fall into old environment
    env.postinitfns = nil
    env.postinitdata = nil
    -- convenience
    setmetatable(env, {
        __index = e or _G,
        __newindex = function(_, k, v) e[k] = v end
    })
    return env
end
function ModWrangler:InitializeDSTModMain(modname, env, mainfile)
    if not KnownModIndex:IsModCompatibleWithMode(modname) then return end
    local fn = kleiloadlua("../mods/" .. modname .. "/" .. mainfile)
    if type(fn) == "string" then
        print("Mod: " .. ModInfoname(modname), "  Error loading dst mod!\n" .. fn .. "\n")
        return false
    elseif not fn then
        return true
    else
        local status, r = RunInEnvironment(fn, AddDSTEnv(env))
        if status == false then
            print("Mod: " .. ModInfoname(modname), "  Error loading dst mod!\n" .. r .. "\n")
            return false
        else
            print("Mod: " .. ModInfoname(modname), " Loading " .. mainfile)
            return true
        end
    end
end
function ModWrangler:LoadModsDST()
    if not MODS_ENABLED then return end
    local oldpath = package.path
    for i, mod in ipairs(self.mods) do
        package.path = "..\\mods\\" .. mod.modname .. "\\scripts\\?.lua;" .. package.path
        self:InitializeDSTModMain(mod.modname, mod, "dstmodmain.lua")
    end
    package.path = oldpath
end
