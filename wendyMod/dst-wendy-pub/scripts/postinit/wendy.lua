local function fn(inst)
    -- QoL use CanUseElixir
    function inst:CanUseElixir(elixir)
        local target = FindEntity(inst, 1, function(guy)
            return guy:HasTag("ghostlyelixirable")
        end)
        if target then return target end
        return FindEntity(inst, 20, function(guy)
            return guy:HasTag("ghostlyelixirable")
        end)
    end
end
return fn
