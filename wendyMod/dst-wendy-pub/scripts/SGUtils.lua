local function AddPlayerActionHandler(a, ...)
    if type(a) == "string" then a = ActionHandler(ACTIONS[a], ...) end
    AddStategraphActionHandler("wilson", a)
    AddStategraphActionHandler("wilsonboating", a)
end
local function AddPlayerState(st)
    AddStategraphState("wilson", st)
    AddStategraphState("wilsonboating", st)
end
local function AddPlayerStatePostInit(name, fn)
    AddStategraphPostInit("wilson", function(sg) if sg.states and sg.states[name] then fn(sg.states[name]) end end)
    AddStategraphPostInit("wilsonboating",
        function(sg) if sg.states and sg.states[name] then fn(sg.states[name]) end end)
end
-- #TODO: merge into a table
local function AddPlayerEventPostInit(name, fn)
    AddStategraphPostInit("wilson", function(sg) if sg.events and sg.events[name] then fn(sg.events[name]) end end)
    AddStategraphPostInit("wilsonboating",
        function(sg) if sg.events and sg.events[name] then fn(sg.events[name]) end end)
end
local function AddPlayerActionPostInit(action, fn)
    AddStategraphPostInit("wilson", function(sg)
        local a = ACTIONS[action]
        if sg.actionhandlers and sg.actionhandlers[a] then fn(sg.actionhandlers[a]) end
    end)
    AddStategraphPostInit("wilsonboating", function(sg)
        local a = ACTIONS[action]
        if sg.actionhandlers and sg.actionhandlers[a] then fn(sg.actionhandlers[a]) end
    end)
end
function AddDSTSG(sg)
    local actions = sg.ACTIONS or {}
    local patched_actions = sg.PATCHEDACTIONS or {}
    local states = sg.STATES or {}
    local patched_states = sg.PATCHEDSTATES or {}
    local patched_events = sg.PATCHEDEVENTS or {}
    for k, v in pairs(states) do AddPlayerState(v) end
    for k, v in pairs(patched_states) do AddPlayerStatePostInit(k, v) end
    for k, v in pairs(patched_events) do AddPlayerEventPostInit(k, v) end
    for k, v in pairs(patched_actions) do AddPlayerActionPostInit(k, v) end
    for i, v in ipairs(actions) do AddPlayerActionHandler(v) end
end
