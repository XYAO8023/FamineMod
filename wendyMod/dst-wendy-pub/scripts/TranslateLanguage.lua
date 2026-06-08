-- why the game engine don't do this? Maybe because there is no Chinese involved.
-- but the string is utf-8 coded, so it has to be lua file work
local function separator(sentence)
    local maxlength = 16
    local len = string.len(sentence)
    if len <= maxlength then return sentence end
    local accumulated = 0
    local sep = {}
    for i = 1, len do
        if string.sub(sentence, i, i) == " " then
            table.insert(sep, string.sub(sentence, i - accumulated, i - 1))
            accumulated = 0
        else
            accumulated = accumulated + 1
        end
        if accumulated == maxlength then
            table.insert(sep, string.sub(sentence, i - maxlength + 1, i))
            accumulated = 0
        end
    end
    table.insert(sep, string.sub(sentence, len - accumulated + 1, len))
    return table.concat(sep, " ")
end

local function PatchMissingTables(strings, startdepth, sep)
    if not strings then return end
    startdepth = startdepth or 1
    for k, v in pairs(strings) do
        local keys = {undotted(k)}
        for i = 1, startdepth do table.remove(keys, 1) end
        local leaf = table.remove(keys, #keys)
        local root = STRINGS
        for i, node in ipairs(keys) do
            local oldval = root[node]
            if type(oldval) ~= "table" then root[node] = {} end
            root = root[node]
        end
        if type(tonumber(leaf)) == "number" then
            root[tonumber(leaf)] = v -- patched number circumstances
        else
            -- root[leaf] = sep and separator(v) or v
            root[leaf] = v
        end
    end
end

local MergeTranslationFromPO = function(base_path, filename, override_lang)
    local _defaultlang = LanguageTranslator.defaultlang
    local lang = override_lang or _defaultlang
    if not lang then return end
    local filepath = base_path .. "/" .. filename .. ".po"
    if not softresolvefilepath(filepath) then
        print("[MergeTranslationFromPO]Could not find a language file matching " .. filepath)
        return
    end
    local temp_lang = lang .. tostring(math.random())
    LanguageTranslator:LoadPOFile(filepath, temp_lang)
    if not LanguageTranslator.languages[lang] then LanguageTranslator.languages[lang] = {} end
    table.mergeinto(LanguageTranslator.languages[lang], LanguageTranslator.languages[temp_lang])
    -- insert logic for patch
    PatchMissingTables(LanguageTranslator.languages[temp_lang])
    LanguageTranslator.languages[temp_lang] = nil
    LanguageTranslator.defaultlang = _defaultlang
end
local function MergeTranslationFromLUA(dir, filename, lang, sep)
    local content = require(dir .. filename .. "_" .. lang)
    PatchMissingTables(content, 1, sep)
end

local function mergeinto_inner(src, key, val)
    local oldval = src[key]
    if oldval == nil then
        src[key] = {}
    elseif type(oldval) ~= "table" then
        print("automatically joined old value to generic", key, val, src[key])
        src[key] = {GENERIC = oldval}
    end
    for k, v in pairs(val) do
        if type(v) == "table" then
            mergeinto_inner(src[key], k, v)
        else
            local key2 = k
            if type(tonumber(k)) == "number" then key2 = tonumber(k) end
            src[key][key2] = v
        end
    end
end

local function mergeinto(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            mergeinto_inner(t1, k, v)
        else
            t1[k] = v
        end
    end
end

local function MergeTranslationFromJSON(dir, filename, lang)
    local f = MakeFile(softresolvefilepath(dir .. filename .. "_" .. lang .. ".json"))
    f.persist = false
    local data = f:read()
    if data then
        local success, result = pcall(json.decode, data)
        if success then
            mergeinto(STRINGS, result)
        else
            print("[TranslateLanguages] file: " .. filename .. "cannot be parsed")
        end
    else
        print("[TranslateLanguages] file: " .. filename .. "cannot be opened")
    end
end

local itemfiles = {}
local jsonfiles = {
    "ABIGAIL",
    "ACTIONS",
    "GHOSTFLOWER",
    "GHOSTLYELIXIR",
    "SISTURN",
    "GHOSTLYBOND",
    "reviver",
    "TAB",
    "UI"
}
local charfiles = {"walani", "woodlegs", "wilbur", "wilba", "wagstaff", "wheeler"}
local fbase = "languages/"
local jbase = "scripts/languages/"
local supported = {zh = true, en = false}
local lang = LanguageTranslator.defaultlang
lang = supported[lang] ~= nil and lang or "en"
for i, v in ipairs(itemfiles) do MergeTranslationFromLUA(fbase, v, lang) end
for i, v in ipairs(jsonfiles) do MergeTranslationFromJSON(jbase, v, lang) end
for name, sep in pairs(charfiles) do
    local uname = string.upper(name)
    if STRINGS.CHARACTERS[uname] then -- DLC characters may not exist
        local characterspeech = require(fbase .. name .. "_" .. lang)
        for category, tbl in pairs(characterspeech) do
            if not STRINGS.CHARACTERS[uname][category] then STRINGS.CHARACTERS[uname][category] = {} end
            table.mergeinto(STRINGS.CHARACTERS[uname][category], tbl)
        end
        characterspeech = nil
    end
end
itemfiles, jsonfiles, charfiles, fbase, jbase, supported, lang = nil, nil, nil, nil, nil, nil, nil
