name = "DST Library"
description = "A DST library."
author = "zzzzzzzs"
version = "20230128"
version_compatible = version
forumthread = ""
api_version = 6
icon_atlas = "modicon.xml"
icon = "modicon.tex"
-- this is a library so raise its priority to infinity so I hope it always load first
local loops = 1000
priority = 2.0
while priority < 2.0 * priority and loops > 0 do
    priority = 2.0 * priority
    loops = loops - 1
end
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true
configuration = {
    {
        name = "develop",
        label = "Development Mode",
        options = {{description = "Yes", data = "true"}, {description = "No", data = "false"}},
        default = "false"
    },
    {
        name = "printlevel",
        label = "Print Level",
        options = {
            {description = "Debug(Vanilla)", data = "debug"},
            {description = "Less", data = "less"},
            {description = "Never", data = "none"},
            {description = "Never Ever!", data = "never"}
        },
        default = "debug"
    },
    {
        name = "godmode",
        label = "God Mode",
        options = {{description = "Yes", data = "true"}, {description = "No", data = "false"}},
        default = "false"
    }
}
translation = {
    {
        matchLanguage = function(lang)
            return lang == "zh" or lang == "zht" or lang == "zhr" or lang == "chs" or lang == "cht"
        end,
        translateFunction = function(key)
            return translation[1].dict[key] or nil
        end,
        dict = {
            name = "联机库",
            unusable = "不可用",
            description = [[
]],
            version = "",
            No = "否",
            Yes = "是",
            language = "语言",
            develop = "开发模式",
            godmode = "上帝模式"
        }
    },
    {
        matchLanguage = function(lang)
            return lang == "en"
        end,
        dict = {name = name, description = description, version = ""},
        translateFunction = function(key)
            return translation[2].dict[key] or key
        end
    }
}
local function makeConfigurations(conf, translate, baseTranslate, language)
    local index = 0
    local config = {}
    local function trans(str)
        return translate(str) or baseTranslate(str)
    end

    local string = ""
    for i = 1, #conf do
        local v = conf[i]
        if not v.disabled then
            index = index + 1
            config[index] = {
                name = v.name or "",
                label = v.name ~= "" and translate(v.name) or (v.label and trans(v.label)) or baseTranslate(v.name)
                    or nil,
                hover = v.name ~= "" and (v.hover and trans(v.hover)) or nil,
                default = v.default or "",
                options = v.name ~= "" and {{description = "", data = ""}} or nil,
                client = v.client
            }
            if v.unusable then config[index].label = config[index].label .. "[" .. trans("unusable") .. "]" end
            if v.options then
                for j = 1, #v.options do
                    local opt = v.options[j]
                    config[index].options[j] = {
                        description = opt.description and trans(opt.description) or "",
                        hover = opt.hover and trans(opt.hover) or "",
                        data = opt.data ~= nil and opt.data or ""
                    }
                end
            end
        end
    end
    configuration_options = config
end

local function makeInfo(translation)
    local localName = translation("name")
    local localDescription = translation("description")
    local localVersionInfo = translation("version") or ""
    if localVersionInfo ~= "" then
        if not localDescription then localDescription = "" end
        localDescription = localVersionInfo .. "\n" .. localDescription
    end
    if localName then name = localName end
    if localDescription then description = localDescription end
end

local function getLang()
    local lang = locale or "en"
    return lang
end

local function generate()
    local lang = getLang()
    local localTranslation = translation[#translation].translateFunction
    local baseTranslation = translation[#translation].translateFunction
    for i = 1, #translation - 1 do
        local v = translation[i]
        if v.matchLanguage(lang) then
            localTranslation = v.translateFunction
            break
        end
    end
    makeInfo(localTranslation)
    makeConfigurations(configuration, localTranslation, baseTranslation, lang)
end
generate()
