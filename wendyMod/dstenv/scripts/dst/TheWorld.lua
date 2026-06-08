return function(inst)
    inst = inst or GetWorld()
    if inst and not rawget(inst.state, "phase") then
        rawset(_G, "TheWorld", inst)
        setmetatable(inst.state, {
            __index = function(_, k)
                return GetClock()[k]
            end,
            __newindex = function(_, k, v)
                GetClock()[k] = v
            end
        })
        TheWorld:PushEvent("DSTTheWorldReady")
    end
end
