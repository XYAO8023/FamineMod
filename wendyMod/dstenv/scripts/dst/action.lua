if DSTAction then return end
local ACTION_MOD_IDS = {}
local MOD_ACTIONS_BY_ACTION_CODE = {}
local MOD_COMPONENT_ACTIONS = {}
local MOD_ACTION_COMPONENT_NAMES = {}
local MOD_ACTION_COMPONENT_IDS = {}
DSTAction = Class(Action,
    function(self, data, instant, rmb, distance, ghost_valid, ghost_exclusive, canforce, rangecheckfn,
        crosseswaterboundary, overrides_direct_walk) -- added
        if data == nil then data = {} end
        if type(data) ~= "table" then
            print("WARNING: Positional Action parameters are deprecated. Please pass action a table instead.")
            local priority = data
            data = {
                priority = priority,
                instant = instant,
                rmb = rmb,
                ghost_valid = ghost_valid,
                ghost_exclusive = ghost_exclusive,
                canforce = canforce,
                rangecheckfn = rangecheckfn,
                crosseswaterboundary = crosseswaterboundary,
                overrides_direct_walk = overrides_direct_walk
            }
        end
        -- patched
        data.mount_enabled = data.mount_valid
        Action._ctor(self, data, data.priority, data.instant, data.rmb, data.distance, crosseswaterboundary,
            overrides_direct_walk)

        --[[
            self.priority = data.priority or 0
        self.fn = function()
            return false
        end
        self.strfn = nil
        self.instant = data.instant or false
        self.rmb = data.rmb or nil -- note! This actually only does something for tools, everything tests 'right' in componentactions
        self.distance = data.distance or nil
        self.mindistance = data.mindistance or nil
        ]]
        self.ghost_exclusive = data.ghost_exclusive or false
        self.ghost_valid = self.ghost_exclusive or data.ghost_valid or false -- If it's ghost-exclusive, then it must be ghost-valid
        self.mount_valid = data.mount_valid or false
        self.encumbered_valid = data.encumbered_valid or false
        self.canforce = data.canforce or nil
        self.rangecheckfn = self.canforce ~= nil and data.rangecheckfn or nil
        self.mod_name = nil
        self.silent_fail = data.silent_fail or nil

        -- new params, only supported by passing via data field
        self.paused_valid = data.paused_valid or false
        self.actionmeter = data.actionmeter or nil
        self.customarrivecheck = data.customarrivecheck
        self.is_relative_to_platform = data.is_relative_to_platform
        self.disable_platform_hopping = data.disable_platform_hopping
        self.skip_locomotor_facing = data.skip_locomotor_facing
        self.do_not_locomote = data.do_not_locomote
        self.extra_arrive_dist = data.extra_arrive_dist
        self.tile_placer = data.tile_placer
        self.show_tile_placer_fn = data.show_tile_placer_fn
        self.theme_music = data.theme_music
        self.theme_music_fn = data.theme_music_fn -- client side function
        self.pre_action_cb = data.pre_action_cb -- runs and client and server
        self.invalid_hold_action = data.invalid_hold_action

        self.show_primary_input_left = data.show_primary_input_left
        self.show_secondary_input_right = data.show_secondary_input_right

        self.map_action = data.map_action -- Should only be handled from the map and has action translations.
    end)
function DSTAddComponentAction(actiontype, component, fn)
    local modname = env.modname
    if not actiontype or not component or not fn then
        print("Invalid Component Action", modname, actiontype, component, fn)
        return
    end
    -- DST logic
    if MOD_COMPONENT_ACTIONS[modname] == nil then
        MOD_COMPONENT_ACTIONS[modname] = {
            [actiontype] = {}
        }
        MOD_ACTION_COMPONENT_NAMES[modname] = {}
        MOD_ACTION_COMPONENT_IDS[modname] = {}
    elseif MOD_COMPONENT_ACTIONS[modname][actiontype] == nil then
        MOD_COMPONENT_ACTIONS[modname][actiontype] = {}
    end
    MOD_COMPONENT_ACTIONS[modname][actiontype][component] = fn
    table.insert(MOD_ACTION_COMPONENT_NAMES[modname], component)
    MOD_ACTION_COMPONENT_IDS[modname][component] = #MOD_ACTION_COMPONENT_NAMES[modname]
    -- DS logic
    local fnname = string.lower(actiontype)
    if fnname == "useitem" then fnname = "use" end
    fnname = string.upper(string.sub(actiontype, 1, 1)) .. string.sub(fnname, 2)
    fnname = "Collect" .. fnname .. "Actions"
    -- #TODO: run this once and for all for every mod, and prevent multiple add
    AddComponentPostInit(component, function(com)
        local old = com[fnname]
        if old then
            com[fnname] = function(self, ...)
                old(self, ...)
                return fn(self.inst, ...)
            end
        else
            com[fnname] = function(self, ...) return fn(self.inst, ...) end
        end
    end)
end
function DSTAddAction(id, str, fn)
    local action
    if type(id) == "table" and id.is_a and id:is_a(Action) then
        -- backwards compatibility with old AddAction
        action = id
    else
        assert(str ~= nil and type(str) == "string",
            "Must specify a string for your custom action! Example: \"Perform My Action\"")
        assert(fn ~= nil and type(fn) == "function",
            "Must specify a fn for your custom action! Example: \"function(act) --[[your action code]] end\"")
        action = DSTAction({
            id = id,
            str = str,
            fn = fn
        })
    end
    action.mod_name = env.modname

    assert(action.id ~= nil and type(action.id) == "string",
        "Must specify an ID for your custom action! Example: \"MYACTION\"")

    -- initprint("DSTAddAction", action.id)
    ACTIONS[action.id] = action

    -- put it's mapping into a different IDS table, one for each mod
    if ACTION_MOD_IDS[action.mod_name] == nil then ACTION_MOD_IDS[action.mod_name] = {} end
    table.insert(ACTION_MOD_IDS[action.mod_name], action.id)
    action.code = #ACTION_MOD_IDS[action.mod_name]
    if MOD_ACTIONS_BY_ACTION_CODE[action.mod_name] == nil then MOD_ACTIONS_BY_ACTION_CODE[action.mod_name] = {} end
    MOD_ACTIONS_BY_ACTION_CODE[action.mod_name][action.code] = action

    STRINGS.ACTIONS[action.id] = STRINGS.ACTIONS[action.id] or action.str -- modified

    return ACTIONS[action.id]
end

expose{
    DSTAction = DSTAction,
    DSTAddAction = DSTAddAction,
    DSTAddComponentAction = DSTAddComponentAction
}
