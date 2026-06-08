if _G.rawget(_G, "dbgkey") then return end
-- Leonidas IV has provided these functions, he is a legend!
function _G.dbgkey()
    _G.CHEATS_ENABLED = true
    require('debugkeys')
end

function _G.DumpBT(bnode, indent)
    indent = indent or 0

    local s = ""
    for i = 1, indent do s = s .. "|   " end
    local name = s .. bnode.name
    nolineprint(name)

    if bnode.children then
        for i, childnode in ipairs(bnode.children) do DumpBT(childnode, indent + 1) end
    else
        for i, k in pairs(bnode) do nolineprint(s .. "|   " .. i .. " = " .. tostring(k)) end
    end
end

function _G.dmpp(_table, force_indent, indent, inst_GUIDS)
    if type(_table) ~= "table" then return nolineprint(string.format("Variable:  %s    (%s)", _table, type(_table))) end

    inst_GUIDS = inst_GUIDS or {}

    if _table.GUID then
        if inst_GUIDS[_table.GUID] then return end
        inst_GUIDS[_table.GUID] = true
    end

    if not indent then
        local inst = (_table.inst and _table.inst.prefab) or _table.name or "dump table!"
        nolineprint("\n")
        nolineprint(string.upper(inst))
    end

    indent = indent or 1

    local s = ""
    for i = 1, indent do s = s .. "|   " end

    indent = force_indent or indent

    for k, v in pairs(deepcopy(_table)) do
        if type(k) == "table" then k = "{...}" end
        if k == "inst" or k == "task" then v = nil end

        local v_is_table = type(v) == "table"

        if v == nil then
            -- Do Nothing...

        elseif v_is_table and not next(v) then
            nolineprint(s .. k .. " = { }")

        elseif v_is_table and indent < 4 then
            nolineprint(s .. k .. " >")
            dmpp(v, nil, indent + 1, inst_GUIDS)

        else
            nolineprint(s .. k .. " = " .. (v_is_table and "{...}" or tostring(v)))
        end
    end
end

_G.dmp = function(t, l)
    l = l or 0
    dumptable(t, 1, l)
end

function _G.c_removeall(prefab)
    local count = 0
    for _, ent in pairs(Ents) do
        if ent.prefab and ent.prefab == prefab then
            ent:Remove()
            count = count + 1
        end
    end
    print(count, " entities removed.")
end

function _G.printfab()
    print(c_select().prefab)
end

function _G.c_revealmap()
    GetWorld().minimap.MiniMap:ShowArea(0, 0, 0, 10000)
end

local function GetArgs(func, info)
    local args = {}
    info = info or debug.getinfo(func)
    for i = 1, info.nparams, 1 do
        local param = debug.getlocal(func, i)
        if param ~= "self" then table.insert(args, param) end
    end

    if info.isvararg then table.insert(args, "...") end

    return table.concat(args, ", ")
end

local function pprint(str)
    nolineprint("\t" .. str)
end

function _G.debugfn(fn)
    if type(fn) ~= "function" then return pprint(('"%s" is not a function.'):format(fn)) end

    local info = debug.getinfo(fn)

    if info.what == "C" then return pprint("C side functions don't have acessible info...") end

    local parse_str = "/data/"
    local parse_index = info.source:find(parse_str)
    local source = parse_index and info.source:sub(parse_index + #parse_str, #info.source) or info.source

    pprint(("Defined at:  %s:%s"):format(source, info.linedefined))
    pprint(("Parameters:  (%s)"):format(GetArgs(fn, info)))
end

local class_fns = {"__index", "_ctor", "is_a", "__newindex"}
local buildin_types = {"string", "number", "function", "boolean"}

function _G.GetFns(table_, _inMetatable)
    if type(table_) ~= "table" then
        if not table.contains(buildin_types, type(table_)) then
            table_ = getmetatable(table_).__index
        else
            return pprint(('\n \n"%s" is not a table.\n'):format(table_))
        end
    end

    local fns = {}
    local index = 0
    for k, v in pairs(table_) do
        if type(v) == "function" and not table.contains(class_fns, k) then
            local string = string.format("%s(%s)", k, GetArgs(v))

            print(string)
            table.insert(fns, string .. "\t" .. string.rep(" ", 40 - #string))
            index = index + 1
            if index % 3 == 0 then table.insert(fns, "\n") end
        end
    end

    if #fns ~= 0 then
        nolineprint("\n \n", table.concat(fns))
        nolineprint("")
    elseif not _inMetatable then
        GetFns(getmetatable(table_), true)
    else
        pprint("The table don't contains any function.")
    end
end

--[[
AddGlobalDebugKey(KEY_END, function()
    TheSim:ResetErrorShown()
    -- FrontEnd:ShowTitle("RESTARTING...")
    TheFrontEnd:HideConsoleLog()
    TheSim:SetDebugRenderEnabled(false)

    TheFrontEnd:Fade(false, 1, function()
        EnableAllDLC()
        StartNextInstance()
    end)
end)
]]

_G.c_circle = function(radius, prefab)
    local inst = c_select() or GetPlayer()
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local theta = math.random() * 2 * math.pi
    local itemdensity = 0.5 -- (X items per unit)

    local circ = 2 * math.pi * radius
    local numitems = circ * itemdensity

    for i = 1, numitems do
        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
        local wander_point = pt + offset
        local spawn = SpawnPrefab(prefab or "blueprint")
        spawn.Transform:SetPosition(wander_point.x, wander_point.y, wander_point.z)
        theta = theta - (2 * math.pi / numitems)
    end
end

------------------------------------------------------------------------------------

local NewReignMod = "A-New-Reign-Solo-Mod"
if KnownModIndex and KnownModIndex.savedata and KnownModIndex:IsModEnabled(NewReignMod) then return end
local function godmode(inst)
    local c = inst and inst.components
    if not c then return end
    if c.health then
        c.health:SetInvincible(true)
        c.health:SetPercent(1)
        c.health:SetMinHealth(0.01)
    end
    if c.sanity then c.sanity:SetPercent(1) end
    if c.health then c.health:SetInvincible(true) end
    if c.hunger then c.hunger:SetPercent(1) end
    if c.moisture then c.moisture:SetMoistureLevel(0) end
    if c.temperature then c.temperature:SetTemperature(10) end
    local boat = c.driver and c.driver.vehicle
    if boat and boat.components.boathealth then
        boat.components.boathealth:SetPercent(1)
        boat.components.boathealth:SetInvincible(true)
    end
    if c.builder then c.builder:GiveAllRecipes() end
    if c.poisonable then c.poisonable:Cure() end
end
_G.godmode = function(inst)
    godmode(inst or ThePlayer)
end

---------------------------------------------

_G.save = function()
    if not GetPlayer() then return end
    GetPlayer().components.autosaver:DoSave()
end

---------------------------------------------

function _G.c_reset()
    env.SaveConsoleHistory(true)
    GetPlayer().HUD:Hide()
    TheFrontEnd:HideConsoleLog()
    TheSim:SetDebugRenderEnabled(false)

    TheFrontEnd:Fade(false, 1, function()
        StartNextInstance({reset_action = RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot()}, true)
    end)
end

---------------------------------------------

_G.c_reload = function()
    c_save()
    GetPlayer():DoTaskInTime(3, c_reset)
end

_G.reset = c_reset
_G.c_sanity = function(n)
    c_setsanity(n)
end

_G.c_wet = function(n)
    local wet = GetPlayer().components.moisture
    if wet then wet:SetMoistureLevel(n) end
end

function ConsoleWorldEntityUnderMouse()
    if TheInput.overridepos == nil then
        return TheInput:GetWorldEntityUnderMouse()
    else
        local x, y, z = TheInput.overridepos:Get()
        local ents = TheSim:FindEntities(x, y, z, 1)
        for i, v in ipairs(ents) do if v.entity:IsVisible() then return v end end
    end
end

function ConsoleWorldPosition()
    return TheInput.overridepos or TheInput:GetWorldPosition()
end

function _G.c_select(inst)
    if not inst then inst = ConsoleWorldEntityUnderMouse() end
    if not inst then inst = TheInput.hoverinst end
    print("Selected: " .. tostring(inst or "<nil>"))
    SetDebugEntity(inst)
    return inst
end

function _G.c_parent(inst)
    timer.delay(function()
        local w = inst or c_select()
        if w.widget ~= nil then w = w.widget end
        local names = {}
        local parents = {w}
        while w do
            table.insert(names, tostring(w))
            table.insert(names, w)
            w = w.parent
        end
        consoleprint(table.tostring(names))
        rawset(_G, "parents", parents)
    end)
end

_G.sel = function(inst)
    if not inst then inst = ConsoleWorldEntityUnderMouse() end
    if not inst then inst = TheInput.hoverinst end
    if inst then SetDebugEntity(inst) end
    return inst or c_sel()
end
local u, print_loggers, n = UPVALUE.get(nolineprint, "print_loggers")
local dir = CWD or ""
dir = string.gsub(dir, "\\", "/") .. "/"
dir = "^" .. escape_lua_pattern(dir)
-- @D:/Steam/steamapps/common/dont_starve/data/../mods/dst-wendy/scripts/apis.lua
-- @dir path
if u and print_loggers and n then
    local oldp = _G.print
    local FN, LINE, FILE, PARSEDFILE, STRING, HEAD, MOD = 1, 2, 3, 4, 5, 6, 7
    local caches = {last = {}, count = {}}
    function caches:add(key, value)
        self.last[key] = value

    end

    function caches:get(key)
        return self.last[key]
    end

    function caches:diff(key, value)
        return self.last[key] ~= value
    end

    function caches:save()
        local key = self.last[STRING]
        if not key then return end
        self:increase(key)
        self:decrease()
    end

    function caches:decrease()
        for k, v in pairs(self.count) do
            if v < -5 then
                self.count[k] = nil
            else
                self.count[k] = v - 1
            end
        end
    end

    function caches:increase(key)
        local key = key or self.last[STRING]
        if not self.count[key] then
            -- self.data[self.last[key]]=self.last
            self.count[key] = 4
        else
            self.count[key] = self.count[key] + 4
        end
    end

    function caches:getcount()
        return (not self.last[MOD]) and (self.count[self.last[STRING]] and self.count[self.last[STRING]] or 0)
                   or (self.count[self.last[STRING]] and self.count[self.last[STRING]] or 0)
    end

    local consoleprint = function(...)
        local txt = packstring(...)
        for i, v in ipairs(print_loggers) do v(txt) end
    end
    local function rawprint(txt)
        for i, v in ipairs(print_loggers) do v(txt) end
    end

    print = function(...)
        local level = 2
        local info = debug.getinfo(level) or {source = "[engine]"}
        local filename = info.source or "?"
        if string.sub(filename, 1, 1) ~= "@" then return consoleprint(...) end
        local defaultvalue = "(anonymous)"
        local fnname = info.name or defaultvalue
        local dirty = false
        local str = {}
        local modidentity = "/mods/"
        local ismod = false
        local function prt(x)
            table.insert(str, x)
        end
        --[[
        local upperfns = {"dumptable", "print"}
        for i, v in ipairs(upperfns) do
            if fnname == v then
                level = level + 1
                info = debug.getinfo(level) or {source = "[engine]"}
                filename = info.source or "?"
                fnname = info.name or defaultvalue
            end
        end
        ]]
        if string.sub(filename, 1, 1) ~= "@" then return consoleprint(...) end
        if dirty or caches:diff(FN, fnname) then
            caches:add(FN, fnname)
            dirty = true
        end
        if dirty or caches:diff(FILE, filename) then
            dirty = true
            caches:add(FILE, filename)
            filename = string.sub(filename, 2)
            filename = string.gsub(filename, dir, "")
            if string.len(filename) > 100 then
                filename = string.sub(filename, 1, 20) .. "..."
            else
                filename = string.gsub(filename, "scripts/", "")
                filename = string.gsub(filename, "[.]lua$", "")
                local i, j = string.find(filename, modidentity)
                if i then
                    -- prt("[mod]")
                    ismod = true
                    filename = string.sub(filename, j + 1)
                end
            end
            caches:add(PARSEDFILE, filename)
        else
            filename = caches:get(PARSEDFILE)
        end
        caches:add(MOD, ismod)
        prt(filename)
        prt("@")
        local line = info.currentline ~= -1 and info.currentline or info.linedefined
        if dirty or caches:diff(LINE, line) then
            dirty = true
            caches:add(LINE, line)
        end
        prt(fnname)
        prt(":")
        prt(tostring(line))
        prt(" ")
        --[[
        if info and info.source and string.sub(info.source, 1, 1) == "@" then
            source = source:sub(2)
            source = source:gsub("^" .. escape_lua_pattern(dir), "")
            str = string.format("%s(%d,1) %s", tostring(source), info.currentline, packstring(...))
        else
            str = packstring(...)
        end
        ]]
        local txt = caches:get(HEAD)
        if dirty then
            txt = table.concat(str)
            caches:add(HEAD, txt)
        end
        local strin = packstring(...)
        caches:add(STRING, strin)
        local duplicate_count = caches:getcount()
        -- rawprint(tostring(duplicate_count))
        if duplicate_count > 15 then
            if not ismod then
                -- maybe this is from Hamlet nuisance, ignore it
                if duplicate_count < 19 then
                    strin = "Duplicate String Detected, Cut!"
                else
                    caches:increase()
                    return
                end
            elseif duplicate_count > 100 then
                -- maybe a mod chattering
                if duplicate_count < 104 then
                    strin = "Duplicate mod String Detected, Cut!"
                else
                    caches:increase()
                    return
                end
            end
        end
        caches:save()
        txt = txt .. strin
        rawprint(txt)
    end
    local neverprint = function()
    end
    nodebugprint = function(...)
        return rawprint(packstring(...))
    end
    _G.neverprint = neverprint
    _G.print = print
    _G.rawprint = rawprint
    _G.consoleprint = consoleprint
end
_G.cdbg = CONSOLE and CONSOLE.dbg
_G.console = CONSOLE
_G.theplayer = {}
setmetatable(_G.theplayer, {
    __index = function(_, k)
        return ThePlayer[k]
    end,
    __newindex = function(_, t, k)
        ThePlayer[t] = k
    end
})

function _G.c_setpeice(name, raw_name) -- eaw_name is a BOOL
    local obj_layout = require("custom_object_layout")
    local entities = {}
    local map_width, map_height = GetWorld().Map:GetSize()
    local add_fn = {
        fn = function(
            prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list, prefab_data,
            rand_offset)
            local x = (points_x[current_pos_idx] - width / 2.0) * TILE_SCALE
            local y = (points_y[current_pos_idx] - height / 2.0) * TILE_SCALE
            x = math.floor(x * 100) / 100.0
            y = math.floor(y * 100) / 100.0
            SpawnPrefab(prefab).Transform:SetPosition(x, 0, y)
        end,
        args = {
            entitiesOut = entities,
            width = map_width,
            height = map_height,
            rand_offset = false,
            debug_prefab_list = nil
        }
    }

    local x, y, z = ConsoleWorldPosition():Get()
    x, z = GetWorld().Map:GetTileCoordsAtPoint(x, y, z)
    obj_layout.Place({math.floor(x), math.floor(z)}, name, add_fn, nil, raw_name)
end

--[[--------------------------------------------------------
[00:08:44]: 100022 -  age 56.37
GUID:100022 Name: UIAnim Tags: UI widget
Prefab:
Parent:100021
AnimState: bank: OUTOFSPACE build: hamlet_title_shield anim: idle anim/hamlet_title_shield.zip:idle Frame: 1690.98/140
UITransform: Pos=(0.00,-360.00,0.00) Scale=(0.98,0.98,0.98) Rot=0.00
Buffered Action: nil

]]
function string.plainfind(s, m, b)
    return string.find(s, m, b or 1, true)
end

local function strip(str, s, e, p)
    local s1, e1 = string.plainfind(str, s, p)
    if not s1 then return "", nil end
    local s2, e2
    if e then
        s2, e2 = string.plainfind(str, e, e1 + 1)
    else
        s2, e2 = (string.len(str) + 1), -1
    end
    if not s2 then return "", nil end
    return string.sub(str, e1 + 1, s2 - 1), e2 + 1
end

local function trim(str, e)
    return str:gsub("^[ ]+", ""):gsub("[ ]+$", ""), e
end

local unknown = "UNKNOWN"
local function convertoos(str)
    local oos = "OUTOFSPACE"
    if str == "" or str == oos then
        return unknown
    else
        return str
    end
end

local parser
parser = {
    animstate = function(str)
        local start, endd = string.plainfind(str, "AnimState", 2)
        if start then
            local bank, p = trim(strip(str, "bank:", "build:"))
            bank = convertoos(bank)
            local build, p = trim(strip(str, "build:", "anim:", p))
            build = convertoos(build)
            local anim, p = trim(strip(str, "anim: ", " "), p)
            anim = convertoos(anim)
            local file, p = trim(strip(str, "/", ":", p))
            file = parser.parsefile(file)
            if anim == unknown then
                -- out of space
                anim, p = trim(strip(str, ":", " ", p - 1))
                anim = convertoos(anim)
            end
            local frame, p = trim(strip(str, "Frame:", "/", p))
            local length = string.sub(str, p, string.plainfind(str, "\n", p))
            return table.concat({
                "bank:",
                bank,
                "\nbuild:",
                build,
                "\nanim:",
                anim,
                "\nfile:",
                file,
                "\nframe:",
                frame,
                "\nlength:",
                length
            })
        end
        return ""
    end,
    pos = function(inst)
        if not inst then return end
        local pos = inst.Transform and Vector3(inst.Transform:GetLocalPosition())
        pos = pos or inst.widget and inst.widget.Transform and Vector3(inst.widget.Transform:GetLocalPosition())
        pos = pos or inst.UITransform and Vector3(inst.UITransform:GetLocalPosition())
        pos = pos or inst.widget and inst.widget.UITransform and Vector3(inst.widget.UITransform:GetLocalPosition())
        if pos then return "Position:" .. tostring(pos) end
        return ""
    end,
    image = function(inst)
        if not inst then return "" end
        if not inst.atlas then return "" end
        local atlas = parser.parsefile(inst.atlas)
        local tex = inst.texture
        return table.concat({"xml:", atlas, "\ntex:", tex})
    end,
    sg = function(inst)
        if inst.sg ~= nil then
            local name = inst.sg.currentstate.name
            return table.concat({"state:", name})
        end
        return ""
    end,
    parsefile = function(path)
        local ismod = "mods/"
        local moddir, p, filedir = "", 1, path
        if string.plainfind(path, ismod) then moddir, p = strip(path, "mods/", "/") end
        if p >= 0 then
            filedir = string.sub(path, p)
            moddir = "[" .. moddir .. "]"
        end
        return catstring(moddir, filedir)
    end,
    debug = function(inst)
        if inst.entity then inst = inst.entity end
        return inst.GetDebugString and inst:GetDebugString() or ""
    end,
    full = function()
        local _print = consoleprint or print
        local str = {}
        local print = function(...)
            table.insert(str, packstring(...))
        end
        local inst = TheInput:GetHUDEntityUnderMouse() or TheInput:GetWorldEntityUnderMouse() or TheInput.hoverinst
        if not inst then
            print("Nothing under mouse")
        else
            local flag = false
            local errorstring = "No anim or image!"
            if inst.inst then inst = inst.inst end
            print("This is", inst.widget or inst)
            local str = parser.debug(inst)
            local anim = inst.AnimState or (inst.GetAnimState and inst:GetAnimState())
            if anim then
                local info = parser.animstate(str)
                if str ~= "" then
                    print(info)
                    flag = true
                end
            end
            local image = (inst.SetTexture and inst) or (inst.widget and inst.widget.SetTexture and inst.widget)
            if image then
                local info = parser.image(image)
                if info ~= "" then
                    print(info)
                    flag = true
                end
            end
            local info = parser.pos(inst)
            if info ~= "" then
                print(info)
                flag = true
            end
            if not flag then print(errorstring) end
        end
        return table.concat(str, "\n"), inst
    end
}
_G.lookparser = parser
_G.lookat = function()
    timer.tick(function()
        local str, inst = parser.full()
        consoleprint(str)
        c_select(inst)
    end, 1)
    return "looking"
end
_G.startlook = function()
    if not rawget(_G, "lookwidget") then rawset(_G, "lookwidget", require("lookwidget")()) end
end
_G.pause = function()
    if IsPaused() then
        _G.SetPause(false)
    else
        _G.SetPause(true)
    end
end
local function init()
    if AddKeyHandler then
        AddKeyHandler(KEY_P, function()
            if not HasModKeys({CONTROL_FORCE_STACK, CONTROL_FORCE_ATTACK, CONTROL_FORCE_TRADE, CONTROL_FORCE_INSPECT}) then
                _G.pause()
            end
        end, true)
    end
end
-- timer.tick(init, 1)
local maxlevel = 6
local blacklist = {parent = true, _parent = true}
local forceexpand = false
local function CanExpand(key, level)
    if forceexpand then return true end
    if blacklist[key] then return false end
    -- exclude class
    if level and level > 0 then if key and key.is_a then return false end end
    return true
end
local truncated = "...(truncated)\n"
local visited = {} -- wow this local!
local vis = 0
local last = nil
_G.vst = function(index)
    if last and index == visited[last] then return last end
    for k, v in pairs(visited) do
        if v == index then
            last = k
            return k
        end
    end
    return nil
end
_G.visitt = {}
setmetatable(_G.visitt, {
    __index = function(_, k)
        if k then
            return vst(k)
        else
            return last
        end
    end,
    __call = function(_, ...)
        return last
    end
})
local smartprint
local function SpecialPrint(obj, level)
    local str = ""
    local function out(x)
        str = table.concat({str, x}, " ")
    end
    local function append(x)
        str = table.concat({str, x})
    end
    if obj.entity then
        -- this is a prefab
        local maxitems = 50
        for k, v in pairs(obj) do
            if EntityScript[k] then
            else
                maxitems = maxitems - 1
                if maxitems <= 0 then
                    out(truncated)
                    out("size=" .. tostring(table.size(obj)) .. "\n")
                    break
                end
                out(smartprint(k, true, level))
                out("=")
                if type(v) == "userdata" then
                    out(tostring(v))
                else
                    out(smartprint(v, true, level))
                end
                append("\n")
                if #str > 1000 then break end
            end
        end
        return str
    end
    return nil
end
function smartprint(obj, compact, level, expandall)
    if level then
        if level > maxlevel then
            return ""
        else
            level = level + 1
        end
    else
        level = 0
        visited = {}
        vis = 0
        forceexpand = not not expandall
    end
    local str = {}
    local function out(s)
        if #str > 1000 then return end
        table.insert(str, s)
    end
    local function append(s)
        if #str == 0 then
            str[1] = s
        else
            str[#str] = table.concat({str[#str], s})
        end
    end
    local function put()
        return table.concat(str, " ")
    end
    if type(obj) == "string" then
        str[1] = '"'
        -- check its length
        local len = string.len(obj)
        if len == 0 then
            append("[empty string]")
        elseif len > 500 then
            append(string.sub(obj, 1, 100))
            append(truncated)
        else
            append(obj)
        end
        append('"')
    elseif type(obj) == "number" then
        append(tostring(obj))
    elseif type(obj) == "nil" then
        append("nil")
    elseif type(obj) == "boolean" then
        append(tostring(obj))
    elseif type(obj) == "function" then
        append(tostring(obj))
    elseif type(obj) == "thread" then
        append(tostring(obj))
    elseif type(obj) == "userdata" then
        append(tostring(obj))
        if getmetatable(obj) then
            if getmetatable(obj).__index then
                out("-metatable: ")
                append(smartprint(getmetatable(obj).__index, false, level))
                append("\n")
            end
        end
    elseif type(obj) == "table" then
        -- table!
        if visited[obj] then
            append("table<" .. tostring(visited[obj]) .. ">")
            return put()
        end
        visited[obj] = vis
        vis = vis + 1
        if compact then
            append(tostring(obj) .. "<" .. tostring(visited[obj]) .. ">")
        elseif next(obj) == nil then
            -- check its metatable
            if getmetatable(obj) and getmetatable(obj).__index then
                append("empty-metatable: ")
                out(smartprint(getmetatable(obj).__index, false, level))
                append("\n")
            else
                -- empty
                append("{}")
            end
        elseif #obj > 0 then
            append(tostring(obj))
            -- perhaps this is an array?
            append("[")
            local maxnum = 0
            local maxitems = 50
            for i, v in ipairs(obj) do
                maxitems = maxitems - 1
                if maxitems <= 0 then
                    append(truncated)
                    out("size=" .. tostring(#obj) .. "\n")
                    break
                end
                out(smartprint(i, true, level))
                out("=")
                out(smartprint(obj[i], false, level))
                append("\n")
                maxnum = i
            end
            -- but are there more?
            maxitems = 50
            for k, v in pairs(obj) do
                if type(k) == "number" and k <= maxnum then
                else
                    maxitems = maxitems - 1
                    if maxitems <= 0 then
                        out(truncated)
                        out("size=" .. tostring(table.size(obj)) .. "\n")
                        break
                    end
                    out(smartprint(k, true, level))
                    out("=")
                    out(smartprint(v, not CanExpand(k), level))
                    append("\n")
                end
                if #str > 1000 then break end
            end
            out("]\n")
        else
            append(tostring(obj))
            local special_text = SpecialPrint(obj, level)
            if compact == false or CanExpand(obj, level) then
                append("{")
                if special_text then
                    out(special_text)
                    append("\n")
                else
                    local maxitems = 50
                    for k, v in pairs(obj) do
                        maxitems = maxitems - 1
                        if maxitems <= 0 then
                            out(truncated)
                            out("size=" .. tostring(table.size(obj)) .. "\n")
                            break
                        end
                        out(smartprint(k, true, level))
                        out("=")
                        out(smartprint(v, CanExpand(k), level))
                        append("\n")
                        if #str > 1000 then break end
                    end
                end
                out("}")
            end
        end
    else
        -- a nil
        append("nil")
    end
    return table.concat(str, " ")
end
GLOBAL.smartprint = smartprint
local MIN_NO_RECURSE = 5
function GetMetaField(t, k)
    local mt = getmetatable(t)
    return mt and mt[k]
end
function AnotherPrettyPrint(v)
    consoleprint(smartprint(v))
end
function PrettyPrint(v)
    local print = consoleprint
    if type(v) == "table" then
        -- If it has a tostring method, call it
        if GetMetaField(v, '__tostring') then
            print(v)
        else
            -- table.inspect can really struggle with big tables (at least with PUC-Lua)
            local tbl = v
            local count = 0
            for _ in pairs(tbl) do
                count = count + 1
                if count >= MIN_NO_RECURSE then break end
            end
            print(table.inspect(tbl, count < MIN_NO_RECURSE and 2 or 1))
        end
    else
        print(tostring(v))
    end
end
local CONSOLE_HISTORY = nil
local MAXHISTORY = 15 -- #FIXME the extra commands are not loaded
function env.AddHistory(str)
    if not CONSOLE_HISTORY then
        CONSOLE_HISTORY = GetConsoleHistory and GetConsoleHistory()
        if not CONSOLE_HISTORY then return end
    end
    if #CONSOLE_HISTORY == 0 or CONSOLE_HISTORY[#CONSOLE_HISTORY] ~= str then
        if #CONSOLE_HISTORY > MAXHISTORY then table.remove(CONSOLE_HISTORY, 1) end
        table.insert(CONSOLE_HISTORY, str)
    end
end
function env.SaveConsoleHistory(force)
    if not CONSOLE_HISTORY then
        CONSOLE_HISTORY = GetConsoleHistory and GetConsoleHistory()
        if not CONSOLE_HISTORY then return end
    end
    -- if force or (#CONSOLE_HISTORY % 3 == 0) then
    local file, err = io.open("console_history.txt", "w")
    if file then
        for i = 1, #CONSOLE_HISTORY do file:write(CONSOLE_HISTORY[i] .. "\n") end
        file:close()
    else
        consoleprint("COULD NOT OPEN console_history.txt")
        if err then consoleprint(err) end
    end
    -- end
end
-- good function from Console++, made by FriendlyGlass
_G.ExecuteConsoleCommand = function(fnstr, output)
    if not fnstr or fnstr == "" then return false end
    output = output or AnotherPrettyPrint
    -- First try evaluate as expression, then itself
    local result1 = {loadstring("return " .. fnstr, "console")}
    local result2 = {loadstring(fnstr, "console")}
    local fn = result1[1]
    -- If eval failed
    if not result1[1] then
        -- if itself failed , bad syntax
        if not result2[1] then
            consoleprint(strip(result2[2], ":"))
            AddHistory(fnstr)
            return
        end
        fn = result2[1]
    end
    local result = {pcall(fn)}
    if #result > 1 then
        for i = 2, #result do output(result[i]) end
    elseif result[1] then
        output(nil)
    end
    AddHistory(fnstr)
    env.SaveConsoleHistory()
end
_G.evalall = function(str)
    ExecuteConsoleCommand(str, PrettyPrint)
end
_G.eval = function(str)
    ExecuteConsoleCommand(str, consoleprint)
end
