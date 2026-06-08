if _G.TheNet then return end
local function True()
    return true
end

local function False()
    return false
end

local function Nothing()
end
local function IsInitializing()
    return Settings.last_asset_set == nil
end
local function IsInGame()
    return inGamePlay
end
local function IsLoadingGame()
    return Settings.last_asset_set == "BACKEND"
end
local function Illegal(...)
    print("[call]illegal function call happened!")
    if CONSOLE then CONSOLE.traceback() end
end

local TheNet = {
    IsInGame = IsInGame, -- aka. player can interact
    IsLoadingGame = IsLoadingGame, -- #FIXME
    GetIsServer = True,
    GetIsClient = False,
    IsDedicatedOfflineCluster = True,
    GetServerIsClientHosted = True,
    IsServerPaused = False, -- ?
    IsDedicated = False,
    GetIsHosting = True,
    GetPVPEnabled = False,
    GetServerGameMode = function()
        return "survival" -- #FIXME, adventure & lost fragments(adventure?)
    end,
    GetClientTable = function()
        return AllPlayers
    end,
    SendModRPCToServer = Illegal,
    SendModRPCToClient = Nothing,
    SendModRPCToShard = Illegal,
    CallRPC = Illegal,
    CallClientRPC = Illegal,
    CallShardRPC = Illegal,
    IsOnlineMode = False,
    GetClientTableForUser = function()
        local data = ThePlayer.components.skinner and ThePlayer.components.skinner:GetClothing() or {}
        return data
    end,
    SetLobbyCharacter = Nothing,
    IsConsecutiveMatchForPlayer = True,
    SetIsMatchStarting = Nothing,
    GetDeferredServerShutdownRequested = Nothing,
    SetAllowNewPlayersToConnect = True,
    isdontstarve = true
}
setmetatable(TheNet, {
    __index = function(_, t)
        print("[call]TheNet:" .. t)
        return Nothing
    end
})
local TheCNet = _userdata(TheNet)
expose {TheNet = TheCNet}
