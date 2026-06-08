if AnimState.OverrideSkinSymbol then return end
local DATA = {}
local period = 60 * 10 -- 10minutes
local short_period = 60 -- 1minutes, in case the collector fails, not used for now
local function ReportProgress(t, name)
    local count = table.size(t)
    print(name .. " size: " .. count)
end
local function GarbageCollect()
    if not Ents then return true end
    print("AnimState Garbage Collector Report Progress:")
    ReportProgress(DATA, "data")
    local newdata = {}
    for k, v in pairs(Ents) do
        -- IsValid seems always true, so it is redundant
        if v and v.AnimState then newdata[v.AnimState] = DATA[v.AnimState] end
    end
    DATA = newdata
    ReportProgress(DATA, "data")
    return true
end
local function gc_instance()
    while true do
        Sleep(period)
        while not GarbageCollect() do Sleep(short_period) end
    end
end
local gcname = "ANIMSTATEGARBAGECOLLECTOR"
if not _G[gcname] then
    local garbage_collector = StartThread(gc_instance)
    rawset(_G, gcname, garbage_collector)
end
AnimState.Get = function(as)
    if not DATA[as] then DATA[as] = {} end
    return DATA[as]
end
function AnimState:GetBuild()
    return self:Get().build
end
local oldSetBuild = AnimState.SetBuild
function AnimState:SetBuild(x)
    if not TheInventory:CheckBuild(x) then return end
    self:Get().build = x
    oldSetBuild(self, x)
end
function AnimState:AnimateWhilePaused(b)
end
function AnimState:Dump()
    dumptable(self, 0, 0)
end
function AnimState:GetSkinBuild()
    return self:Get().skinbuild
end
function AnimState:OverrideItemSkinSymbol(symbol, build, skinsymbol, guid, defaultbuild)
    return self:OverrideSymbol(symbol, build, skinsymbol)
end
local oldOverrideSymbol = AnimState.OverrideSymbol
local oldClearOverrideSymbol = AnimState.ClearOverrideSymbol
function AnimState:ClearOverrideSymbol(sym, ...)
    if not sym then return end
    local m = self:Get()
    if m.symbols then m.symbols[sym] = nil end
    return oldClearOverrideSymbol(self, sym, ...)
end
function AnimState:ClearAllOverrideSymbols()
    local m = self:Get()
    if m.symbols then
        for k, v in pairs(m.symbols) do oldClearOverrideSymbol(self, k) end
        m.symbols = {}
    end
end
function AnimState:OverrideSymbol(sym, build, build_sym)
    if not TheInventory:CheckBuild(build) then return end
    local m = self:Get()
    if not m.symbols then m.symbols = {} end
    m.symbols[sym] = {build, build_sym}
    return oldOverrideSymbol(self, sym, build, build_sym)
end
function AnimState:GetOverrideSymbol(sym)
    local m = self:Get()
    if not m.symbols then return end
    if not m.symbols[sym] then return end
    return unpack(m.symbols[sym])
end
AnimState.OverrideSkinSymbol = AnimState.OverrideSymbol
function AnimState:SetSkin(build, defaultbuild)
    local b = build or defaultbuild or ""
    local m = self:Get()
    if b == "" then
        -- this is not allowed in DST
        print("[AnimState:SetSkin]build is invalid")
        m.skinbuild = nil
        return
    else
        m.skinbuild = b
    end
    return self:SetBuild(b)
end

function AnimState:AssignItemSkins(userid, body, hand, legs, feet)
end
function AnimState:ClearSymbolExchanges()
    for i, v in ipairs(CLOTHING_SYMBOLS) do self:ClearOverrideSymbol(v) end
end
-- This is impossible without a tool to read build.bin, I doubt anyone has the interest to invent such a tool in Lua.
function AnimState:BuildHasSymbol(symbol)
    return self:HasSymbol(self:GetBuild() or "", symbol)
end
function AnimState:GetCurrentAnimationTime()
    return self:GetPercent() * self:GetCurrentAnimationLength()
end
AnimState.ShowSymbol = AnimState.Show
AnimState.HideSymbol = AnimState.Hide
