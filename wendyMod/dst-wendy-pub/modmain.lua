GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})
modimport("scripts/apis.lua")
if not GetIsWorkshop() then utils.mod("scripts/dbgapis.lua") end
local function OnFail()
    -- import tunings
    print("DST Wendy Mod import tunings")
    local function drequire(filename)
        return utils.onemod("dst_wendy_" .. filename)
    end
    local DSTTuning = drequire("tuning")
    table.mergeinto(TUNING, DSTTuning())
    DSTTunings = nil
    -- import translation
    print("DST Wendy Mod import translation")
    utils.mod("scripts/TranslateLanguage")
    -- show error message
    utils.class("screens/scripterrorscreen", function(self)
        local text = STRINGS.UI.MAINSCREEN.MODTITLE
        if self.title then
            --if self.title:GetString() == text then
                self.title:SetString(STRINGS.UI.MAINSCREEN.MODDSTENVNOTENABLED)
            --end
        end
    end)
end

local function OnFound(name)
    if not name then return end
    print("now enable dst library")
    KnownModIndex:Enable(name)
    local entry = "../mods/" .. name .. "/modmain.lua"
    if kleifileexists and kleifileexists(entry) then
        package.path = "..\\mods\\" .. name .. "\\scripts\\?.lua;" .. package.path
        local newenv = CreateEnvironment(name)
        newenv.modname = name
        ModManager:InitializeModMain(name, newenv, "modmain.lua")
    end
end

if not TheNet then
    print("The DST Library is not enabled!")
    -- try to enable it then.
    local dstmodname = {"DST Library", "联机库"}
    local modinfo = modutils.hasnames(dstmodname)
    if modinfo then
        OnFound(modinfo.name)
    else
        OnFail()
        return
    end
end
