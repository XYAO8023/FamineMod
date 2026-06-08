return function(t)
    local seg_time = t.SEG_TIME
    local total_day_time = t.TOTAL_DAY_TIME
    local wilson_health = t.WILSON_HEALTH
    local wilson_hunger = t.WILSON_HUNGER
    local wilson_sanity = t.WILSON_SANITY
    return {
        -- game mode
        GAMEMODE_STARTING_ITEMS = {
            DEFAULT = {
                WILSON = {},
                WILLOW = {"lighter", "bernie_inactive"},
                WENDY = {"abigail_flower"},
                WOLFGANG = {"dumbbell"},
                WX78 = {},
                WICKERBOTTOM = {"papyrus", "papyrus"},
                WES = {"balloons_empty"},
                WAXWELL = {"waxwelljournal", "nightmarefuel", "nightmarefuel", "nightmarefuel", "nightmarefuel",
                           "nightmarefuel", "nightmarefuel"},
                WOODIE = {"lucy"},
                WATHGRITHR = {"spear_wathgrithr", "wathgrithrhat", "meat", "meat", "meat", "meat"},
                WEBBER = {"spidereggsack", "monstermeat", "monstermeat", "spider_whistle"},
                WINONA = {"sewing_tape", "sewing_tape", "sewing_tape"},
                WORTOX = {"wortox_soul", "wortox_soul", "wortox_soul", "wortox_soul", "wortox_soul", "wortox_soul"},
                WORMWOOD = {},
                WARLY = {"portablecookpot_item", "potato", "potato", "garlic"},
                WURT = {},
                WALTER = {"walterhat", "slingshot", "slingshotammo_rock", "slingshotammo_rock", "slingshotammo_rock",
                          "slingshotammo_rock", "slingshotammo_rock", "slingshotammo_rock", "slingshotammo_rock",
                          "slingshotammo_rock", "slingshotammo_rock", "slingshotammo_rock"},
                WANDA = {"pocketwatch_heal", "pocketwatch_parts", "pocketwatch_parts", "pocketwatch_parts"}
            },

            LAVAARENA = {
                WILSON = {"blowdart_lava", "lavaarena_armormedium"},
                WILLOW = {"blowdart_lava", "lavaarena_armorlightspeed"},
                WENDY = {"blowdart_lava", "lavaarena_armorlightspeed"},
                WOLFGANG = {"hammer_mjolnir", "lavaarena_armormedium"},
                WX78 = {"hammer_mjolnir", "lavaarena_armormedium"},
                WICKERBOTTOM = {"book_fossil", "lavaarena_armorlight"},
                WES = {"blowdart_lava", "lavaarena_armorlightspeed"},
                WAXWELL = {"book_fossil", "lavaarena_armorlight"},
                WOODIE = {"lavaarena_lucy", "lavaarena_armormedium"},
                WATHGRITHR = {"spear_gungnir", "lavaarena_armorlightspeed"},
                WEBBER = {"blowdart_lava", "lavaarena_armorlightspeed"},
                WINONA = {"hammer_mjolnir", "lavaarena_armormedium"},
                WORTOX = {}, -- VITO do something here
                WORMWOOD = {}, -- TODO
                WARLY = {}, -- TODO
                WURT = {}, -- TODO
                WALTER = {}, -- TODO
                WANDA = {} -- TODO
            },
            QUAGMIRE = {
                WILSON = {},
                WILLOW = {},
                WENDY = {"spoiled_food"},
                WOLFGANG = {},
                WX78 = {},
                WICKERBOTTOM = {},
                WES = {},
                WAXWELL = {},
                WOODIE = {},
                WATHGRITHR = {},
                WEBBER = {},
                WINONA = {},
                WORTOX = {}, -- VITO do something here
                WORMWOOD = {}, -- TODO
                WARLY = {}, -- TODO
                WURT = {}, -- TODO
                WALTER = {}, -- TODO
                WANDA = {} -- TODO
            }
        }
    }
end
