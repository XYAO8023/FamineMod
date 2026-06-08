if SPECIALCHARACTERSTRING then return end
local function getmodifiedstring(topic_tab, modifier)
    if type(modifier) == "table" then
        local ret = topic_tab
        for i, v in ipairs(modifier) do
            if ret == nil then return nil end
            ret = ret[v]
        end
        return ret
    elseif modifier ~= nil then
        local ret = topic_tab[modifier]
        return (type(ret) == "table" and #ret > 0 and ret[math.random(#ret)]) or ret or topic_tab.GENERIC or
                   (#topic_tab > 0 and topic_tab[math.random(#topic_tab)]) or nil
    else
        return topic_tab.GENERIC or (#topic_tab > 0 and topic_tab[math.random(#topic_tab)]) or nil
    end
end

local function getcharacterstring(tab, item, modifier)
    if not tab then return end

    local topic_tab = tab[item]
    if not topic_tab then
        return
    elseif type(topic_tab) == "string" then
        return topic_tab
    elseif type(topic_tab) ~= "table" then
        return
    end

    if type(modifier) == "table" then
        for i, v in ipairs(modifier) do v = string.upper(v) end
    else
        modifier = modifier and string.upper(modifier)
    end

    return getmodifiedstring(topic_tab, modifier)
end
local DST_CHARACTER_GENDERS = {
    FEMALE = {"willow", "wendy", "wickerbottom", "wathgrithr", "winona", "wurt", "wanda"},
    MALE = {"wilson", "woodie", "waxwell", "wolfgang", "wes", "webber", "warly", "wortox", "wormwood", "walter"},
    ROBOT = {"wx78", "pyro"},
    NEUTRAL = {},
    PLURAL = {}
}
for k, v in pairs(DST_CHARACTER_GENDERS) do
    if not CHARACTER_GENDERS[k] then
        CHARACTER_GENDERS[k] = v
    else
        CHARACTER_GENDERS[k] = table.union(CHARACTER_GENDERS[k], DST_CHARACTER_GENDERS[k])
    end
end

function GetGenderStrings(charactername)
    for gender, characters in pairs(CHARACTER_GENDERS) do
        if table.contains(characters, charactername) then return gender end
    end
    return "DEFAULT"
end

---------------------------------------------------------
-- "Oooh" string stuff
local Oooh_endings = {"h", "oh", "ohh"}
local Oooh_punc = {".", "?", "!"}

local function ooohstart(isstart)
    local str = isstart and "O" or "o"
    local l = math.random(2, 4)
    for i = 2, l do str = str .. (math.random() > 0.3 and "o" or "O") end
    return str
end

local function ooohspace()
    local c = math.random()
    local str = (c <= .1 and "! ") or (c <= .2 and ". ") or (c <= .3 and "? ") or (c <= .4 and ", ") or " "
    return str, c <= .3
end

local function ooohend() return Oooh_endings[math.random(#Oooh_endings)] end

local function ooohpunc() return Oooh_punc[math.random(#Oooh_punc)] end

local function CraftOooh() -- Ghost speech!
    local isstart = true
    local length = math.random(6)
    local str = ""
    for i = 1, length do
        str = str .. ooohstart(isstart) .. ooohend()
        if i ~= length then
            local space
            space, isstart = ooohspace()
            str = str .. space
        end
    end
    return str .. ooohpunc()
end

-- V2C: Left this here as a global util function so mods or other characters can use it easily.
function Umlautify(string)
    if not Profile:IsWathgrithrFontEnabled() then return string end

    local ret = ""
    local last = false
    for i = 1, #string do
        local c = string:sub(i, i)
        if not last and (c == "o" or c == "O") then
            ret = ret .. ((c == "o" and "ö") or (c == "O" and "Ö") or c)
            last = true
        else
            ret = ret .. c
            last = false
        end
    end
    return ret
end

---------------------------------------------------------

local wilton_sayings = {"Ehhhhhhhhhhhhhh.", "Eeeeeeeeeeeer.", "Rattle.", "click click click click", "Hissss!",
                        "Aaaaaaaaa.", "mooooooooooooaaaaan.", "..."}
function CraftWereWilbaString()
    local growl_count = math.random(1, 4)
    local growl_str = ""

    for i = 1, growl_count do
        growl_str = growl_str .. " " .. STRINGS.WEREWILBA_SPEECH[math.random(1, #STRINGS.WEREWILBA_SPEECH)]
    end

    return growl_str
end
SPECIALCHARACTERSTRING = {
    mime = "",
    wes = "",
    ghost = CraftOooh,
    playerghost = CraftOooh,
    wilton = function() return wilton_sayings[math.random(#wilton_sayings)] end,
    wilbur = function(stringtype, modifier)
        return getcharacterstring(STRINGS.CHARACTERS.WILBUR.DESCRIBE, stringtype, modifier) or
                   (CraftMonkeyString and CraftMonkeyString())
    end,
    wilba = function() return GetPlayer().were and CraftWereWilbaString() end
}
function GetSpecialCharacterString(character, stringtype, modifier, ...)
    if not character then return nil end

    character = string.lower(character)

    return FunctionOrValue(SPECIALCHARACTERSTRING[character], stringtype, modifier, ...)
end
function GetSpecialCharacterPostProcess(character, string) return string end
function GetString(inst, stringtype, modifier, nil_missing)
    local character = type(inst) == "string" and inst or (inst ~= nil and inst.prefab or nil)

    character = character and string.upper(character) or nil
    stringtype = stringtype and string.upper(stringtype) or nil
    if type(modifier) == "table" then
        for i, v in ipairs(modifier) do v = v and string.upper(v) end
    else
        modifier = modifier and string.upper(modifier) or nil
    end

    local specialcharacter = type(inst) == "table" and
                                 ((inst:HasTag("mime") and "mime") or (inst:HasTag("playerghost") and "ghost")) or
                                 character

    return GetSpecialCharacterString(specialcharacter) or
               getcharacterstring(STRINGS.CHARACTERS[character], stringtype, modifier) or
               getcharacterstring(STRINGS.CHARACTERS.GENERIC, stringtype, modifier) or
               (not nil_missing and
                   ("UNKNOWN STRING: " .. (character or "") .. " " .. (stringtype or "") .. " " .. (modifier or ""))) or
               nil
end
function GetDescription(inst, item, modifier)
    local character = type(inst) == "string" and inst or (inst and inst.prefab) or false

    character = character and string.upper(character)
    local itemname = item.nameoverride or item.components.inspectable.nameoverride or item.prefab or false
    itemname = itemname and string.upper(itemname)
    if type(modifier) == "table" then
        for i, v in ipairs(modifier) do v = v and string.upper(v) end
    else
        modifier = modifier and string.upper(modifier)
    end

    local specialcharacter = type(inst) == "table" and
                                 ((inst:HasTag("mime") and "mime") or (inst:HasTag("playerghost") and "ghost")) or
                                 character

    local ret = GetSpecialCharacterString(specialcharacter, itemname, modifier)
    if ret then return ret end
    if STRINGS.CHARACTERS[character] then
        ret = getcharacterstring(STRINGS.CHARACTERS[character].DESCRIBE, itemname, modifier)
    end
    ret = ret or getcharacterstring(STRINGS.CHARACTERS.GENERIC.DESCRIBE, itemname, modifier)
    if ret then
        if item and item.components.repairable ~= nil and not item.components.repairable.noannounce and
            item.components.repairable:NeedsRepairs() then
            return ret ..
                       (getcharacterstring(STRINGS.CHARACTERS[character or "GENERIC"], "ANNOUNCE_CANFIX", modifier) or
                           "")
        end
    end
    return ret or STRINGS.CHARACTERS.GENERIC.DESCRIBE_GENERIC
end
function GetActionFailString(inst, action, reason)
    if not inst then return STRINGS.CHARACTERS.GENERIC.ACTIONFAIL_GENERIC end
    local character = type(inst) == "string" and inst or inst.prefab or ""

    character = string.upper(character)

    local specialcharacter = type(inst) == "table" and
                                 ((inst:HasTag("mime") and "mime") or (inst:HasTag("playerghost") and "ghost")) or inst
    local ret = GetSpecialCharacterString(specialcharacter)
    if ret then return ret end

    if STRINGS.CHARACTERS[character] then
        ret = getcharacterstring(STRINGS.CHARACTERS[character].ACTIONFAIL, action, reason)
    end

    if not ret then ret = getcharacterstring(STRINGS.CHARACTERS.GENERIC.ACTIONFAIL, action, reason) end

    return ret or STRINGS.CHARACTERS.GENERIC.ACTIONFAIL_GENERIC
end
-- override default
expose({
    GetString = GetString,
    GetSpecialCharacterString = GetSpecialCharacterString,
    GetDescription = GetDescription,
    SPECIALCHARACTERSTRING = SPECIALCHARACTERSTRING,
    GetActionFailString = GetActionFailString

}, true)
