name = "[DST]Wendy Rework"
description = "Port DST Reworked Wendy, QoLs."
author = "zzzzzzzs"
version = "20230112"
forumthread = ""
icon_atlas = "modicon.xml"
icon = "modicon.tex"
api_version = 6
priority = 0
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true
configuration = {{
    name = "combined",
    label = "Combined Status",
    options = {{
        description = "Yes",
        data = "true"
    }, {
        description = "Auto",
        data = "false"
    }},
    default = "false"
}, {
    name = "method",
    label = "Clock Number",
    options = { {
        description = "One",
        data = 1
    }, {
        description = "Two",
        data = 2
    } },
    default = 1
},{
        name = "dontkillcitypig",
        label = "Citizen-Friendly Abigail",
        options = {{description = "Yes", data = "true"}, {description = "No", data = "false"}}
    },}
translation = {{
    matchLanguage = function(lang)
        return lang == "zh" or lang == "zht" or lang == "zhr" or lang == "chs" or lang == "cht"
    end,
    translateFunction = function(key) return translation[1].dict[key] or nil end,
    dict = {
        name = "[DST]温蒂重做",
        unusable = "不可用",
        description = [[
搬运温蒂重做、生活质量提升。
]],
        version = "",
        No = "否",
        Yes = "是",
        language = "语言",
        combined = "兼容Combined Status",
        Auto = "自动",
        English = "英语",
        Chinese = "中文",
        ["Traditional Chinese"] = "繁体",
        Default = "默认",
        method = "有几个时钟",
        One = "一",
        Two = "俩",
        hud = "兼容联机HUD",
        ["Accord to the game"] = "跟随游戏设置",            dontkillcitypig = "阿比盖尔对市民友好"
    }
}, {
    matchLanguage = function(lang) return lang == "en" end,
    dict = {
        name = name,
        description = description,
        version = ""
    },
    translateFunction = function(key) return translation[2].dict[key] or key end
}}
local function makeConfigurations(conf, translate, baseTranslate, language)
    local index = 0
    local config = {}
    local function trans(str) return translate(str) or baseTranslate(str) end

    local string = ""
    for i = 1, #conf do
        local v = conf[i]
        if not v.disabled then
            index = index + 1
            config[index] = {
                name = v.name or "",
                label = v.name ~= "" and translate(v.name) or (v.label and trans(v.label)) or baseTranslate(v.name) or
                    nil,
                hover = v.name ~= "" and (v.hover and trans(v.hover)) or nil,
                default = v.default or "",
                options = v.name ~= "" and {{
                    description = "",
                    data = ""
                }} or nil,
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
