if RPC then return end
RPC = {}
MOD_RPC = {}
MOD_RPC_HANDLERS = {}
CLIENT_MOD_RPC = {}
CLIENT_MOD_RPC_HANDLERS = {}
SHARD_MOD_RPC = {}
SHARD_MOD_RPC_HANDLERS = {}
local function __index_lower(t, k) return rawget(t, string.lower(k)) end
local function __newindex_lower(t, k, v) rawset(t, string.lower(k), v) end
local function setmetadata(tab)
    setmetatable(tab, {
        __index = __index_lower,
        __newindex = __newindex_lower
    })
end
setmetadata(MOD_RPC)
setmetadata(RPC)
setmetadata(MOD_RPC_HANDLERS)
setmetadata(CLIENT_MOD_RPC)
setmetadata(CLIENT_MOD_RPC_HANDLERS)
setmetadata(SHARD_MOD_RPC)
setmetadata(SHARD_MOD_RPC_HANDLERS)
local function Nothing() end
expose{
    AddModRPCHandler = function(namespace, name, fn)
        if MOD_RPC[namespace] == nil then
            MOD_RPC[namespace] = {}
            MOD_RPC_HANDLERS[namespace] = {}
            setmetadata(MOD_RPC[namespace])
            setmetadata(MOD_RPC_HANDLERS[namespace])
        end
        table.insert(MOD_RPC_HANDLERS[namespace], fn)
        MOD_RPC[namespace][name] = {
            namespace = namespace,
            id = #MOD_RPC_HANDLERS[namespace]
        }
        setmetadata(MOD_RPC[namespace][name])
    end,
    AddClientModRPCHandler = function(namespace, name, fn)
        if CLIENT_MOD_RPC[namespace] == nil then
            CLIENT_MOD_RPC[namespace] = {}
            CLIENT_MOD_RPC_HANDLERS[namespace] = {}
            setmetadata(CLIENT_MOD_RPC[namespace])
            setmetadata(CLIENT_MOD_RPC_HANDLERS[namespace])
        end
        table.insert(CLIENT_MOD_RPC_HANDLERS[namespace], fn)
        CLIENT_MOD_RPC[namespace][name] = {
            namespace = namespace,
            id = #CLIENT_MOD_RPC_HANDLERS[namespace]
        }
        setmetadata(CLIENT_MOD_RPC[namespace][name])
    end,
    AddShardModRPCHandler = function(namespace, name, fn)
        if SHARD_MOD_RPC[namespace] == nil then
            SHARD_MOD_RPC[namespace] = {}
            SHARD_MOD_RPC_HANDLERS[namespace] = {}
            setmetadata(SHARD_MOD_RPC[namespace])
            setmetadata(SHARD_MOD_RPC_HANDLERS[namespace])
        end
        table.insert(SHARD_MOD_RPC_HANDLERS[namespace], fn)
        SHARD_MOD_RPC[namespace][name] = {
            namespace = namespace,
            id = #SHARD_MOD_RPC_HANDLERS[namespace]
        }
        setmetadata(SHARD_MOD_RPC[namespace][name])
    end,
    GetModRPCHandler = function(namespace, name) return MOD_RPC_HANDLERS[namespace][MOD_RPC[namespace][name].id] end,
    GetClientModRPCHandler = function(namespace, name)
        return CLIENT_MOD_RPC_HANDLERS[namespace][CLIENT_MOD_RPC[namespace][name].id]
    end,
    GetShardModRPCHandler = function(namespace, name)
        return SHARD_MOD_RPC_HANDLERS[namespace][SHARD_MOD_RPC[namespace][name].id]
    end,
    SendModRPCToServer = Nothing,
    SendModRPCToClient = Nothing,
    SendModRPCToShard = Nothing,
    MOD_RPC = MOD_RPC,
    CLIENT_MOD_RPC = CLIENT_MOD_RPC,
    SHARD_MOD_RPC = SHARD_MOD_RPC,
    RPC = RPC,
    GetModRPC = function(namespace, name) return MOD_RPC[namespace][name] end,
    GetClientModRPC = function(namespace, name) return CLIENT_MOD_RPC[namespace][name] end,
    GetShardModRPC = function(namespace, name) return SHARD_MOD_RPC[namespace][name] end,
    checkbool = function(val) return val == nil or type(val) == "boolean" end,
    optbool = function(val) return val == nil or type(val) == "boolean" end,
    checknumber = function(val) return type(val) == "number" end,
    checkuint = function(val) return type(val) == "number" and tostring(val):find("%D") == nil end,
    checkstring = function(val) return type(val) == "string" end,
    checkentity = function(val) return type(val) == "table" end,
    optnumber = function(val) return val == nil or type(val) == "number" end,
    optuint = function(val) return val == nil or (type(val) == "number" and tostring(val):find("%D") == nil) end,
    optstring = function(val) return val == nil or type(val) == "string" end,
    optentity = function(val) return val == nil or type(val) == "table" end
}
