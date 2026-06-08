local Action = DSTAction
return {
    ACTIONS = {
        CASTSUMMON = Action({
            rmb = true,
            mount_valid = true
        }),
        CASTUNSUMMON = Action({
            mount_valid = true,
            distance = math.huge
        }),
        COMMUNEWITHSUMMONED = Action({
            rmb = true,
            mount_valid = true
        }),
        GIVETOPLAYER = Action(), -- empty
        GIVEALLTOPLAYER = Action() -- empty
        --[[
        USEELIXIR = Action({
            rmb = true,
            mount_valid = true
        })]]
    },
    FNS = {
        CASTSUMMON = function(act)
            if act.invobject ~= nil and act.invobject.components.summoningitem and act.doer ~= nil and
                act.doer.components.ghostlybond ~= nil then
                return act.doer.components.ghostlybond:Summon(act.invobject.components.summoningitem.inst)
            end
        end,

        CASTUNSUMMON = function(act)
            if act.invobject ~= nil and act.invobject.components.summoningitem and act.doer ~= nil and
                act.doer.components.ghostlybond ~= nil then
                return act.doer.components.ghostlybond:Recall(false)
            end
        end,
        COMMUNEWITHSUMMONED = function(act)
            if act.invobject ~= nil and act.invobject.components.summoningitem and act.doer ~= nil and
                act.doer.components.ghostlybond ~= nil then
                return act.doer.components.ghostlybond:ChangeBehaviour()
            end
        end,
        USEELIXIR = function(act)
            if act.target.components.ghostlyelixirable ~= nil then
                local autotarget = act.doer and act.doer:CanUseElixir()
                if autotarget then
                    return act.invobject.components.ghostlyelixir:Apply(act.doer, autotarget)
                end
            end
            return false
        end
    },
    PATCHEDFNS = {
        GIVE = function(act)
            if act.target ~= nil then
                if act.target.components.ghostlyelixirable ~= nil and act.invobject.components.ghostlyelixir ~= nil then
                    return act.invobject.components.ghostlyelixir:Apply(act.doer, act.target)
                elseif act.target.components.trader ~= nil then
                    -- changed to DS style
                    return act.target.components.trader:AcceptGift(act.doer, act.invobject)
                elseif act.target.components.moontrader ~= nil then
                    return act.target.components.moontrader:AcceptOffering(act.doer, act.invobject)
                elseif act.target.components.quagmire_cookwaretrader ~= nil then
                    return act.target.components.quagmire_cookwaretrader:AcceptCookware(act.doer, act.invobject)
                elseif act.target.components.quagmire_altar ~= nil then
                    return act.target.components.quagmire_altar:AcceptFoodTribute(act.doer, act.invobject)
                end
            end
        end
    },
    STRFNS = {
        COMMUNEWITHSUMMONED = function(act)
            return act.doer:HasTag("has_aggressive_follower") and "MAKE_DEFENSIVE" or "MAKE_AGGRESSIVE"
        end
    },
    PATCHEDSTROVERRIDEFNS = {
        GIVE = function(act)
            -- Quagmire & Winter's Feast action strings
            if act.target ~= nil and act.invobject ~= nil then
                if act.target:HasTag("ghostlyelixirable") and act.invobject:HasTag("ghostlyelixir") then
                    return subfmt(STRINGS.ACTIONS.GIVE.APPLY, {
                        item = act.invobject:GetBasicDisplayName()
                    })
                elseif act.target:HasTag("wintersfeasttable") then
                    return subfmt(STRINGS.ACTIONS.GIVE.PLACE_ITEM, {
                        item = act.invobject:GetBasicDisplayName()
                    })
                elseif act.target.nameoverride ~= nil and act.invobject:HasTag("quagmire_stewer") then
                    return subfmt(STRINGS.ACTIONS.GIVE[string.upper(act.target.nameoverride)], {
                        item = act.invobject:GetBasicDisplayName()
                    })
                elseif act.target:HasTag("quagmire_altar") then
                    if act.invobject.prefab == "quagmire_portal_key" then
                        return STRINGS.ACTIONS.GIVE.SOCKET
                    elseif act.invobject.prefab:sub(1, 14) == "quagmire_food_" then
                        local dish = act.invobject.basedish
                        if dish == nil then
                            local i = act.invobject.prefab:find("_", 15)
                            if i ~= nil then
                                dish = STRINGS.NAMES[string.upper(act.invobject.prefab:sub(1, i - 1))]
                            end
                        end
                        local str = dish ~= nil and STRINGS.ACTIONS.GIVE.QUAGMIRE_ALTAR[string.upper(dish)] or nil
                        if str ~= nil then
                            return subfmt(str, {
                                food = act.invobject:GetBasicDisplayName()
                            })
                        end
                    end
                    return subfmt(STRINGS.ACTIONS.GIVE.QUAGMIRE_ALTAR.GENERIC, {
                        food = act.invobject:GetBasicDisplayName()
                    })
                end
            end
        end
    }

}
