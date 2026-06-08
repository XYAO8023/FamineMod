--[[
    FrontEnd is main screen
    Backend is in game
    enter game: load fe
    enter world:unload fe, load be
    exit world:unload be, load fe
    reset/rollback:nothing
]] local FE, BE = 'FRONTEND', 'BACKEND'
local function CanUnloadEnd(END)
    if END == FE then
        return Settings.last_asset_set == BE
    elseif END == BE then
        return Settings.last_asset_set == FE
    end
    return false
end

local old = Sim.UnloadPrefabs
function Sim:UnloadPrefabs(prefabset)
    local END = Settings.current_asset_set
    if prefabset == RECIPE_PREFABS or prefabset == BACKEND_PREFABS then
        if END ~= FE then
            print("ERROR: FrontEnd name is " .. END)
            return old(self, prefabset)
        end
        if CanUnloadEnd(END) then return old(self, prefabset) end
    elseif prefabset == FRONTEND_PREFABS then
        if END ~= BE then
            print("ERROR: BackEnd name is " .. END)
            return old(self, prefabset)
        end
        if CanUnloadEnd(END) then return old(self, prefabset) end
    end
end

-- not possible
--[[
local old2 = ModIndex.InitializeModInfo
local newenv = { print = function(str, ...)
    if string.find(str, "WARNING loading modinfo.lua", 1, true) then return end
    return _G.print(str, ...)
end, _G = _G }
setmetatable(newenv, { __index = getfenv(old2) })
setfenv(ModIndex.InitializeModInfo, newenv)
]]
