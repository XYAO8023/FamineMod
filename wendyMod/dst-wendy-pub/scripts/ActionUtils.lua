function AddDSTActions(a)
    local actions = a.ACTIONS or {} -- DST Exclusive actions here
    local fns = a.FNS or {}
    local patched_fns = a.PATCHEDFNS or {}
    local strfns = a.STRFNS or {}
    local patched_strfns = a.PATCHEDSTRFNS or {}
    local stroverridefns = a.STROVERRIDEFNS or {}
    local patched_stroverridefns = a.PATCHEDSTROVERRIDEFNS or {}
    for k, v in pairs(actions) do
        v.str = STRINGS.ACTIONS[k] or k
        v.id = k
        v.fn = fns[k]
        v.strfn = strfns[k]
        v.stroverridefn = stroverridefns[k]
        DSTAddAction(v)
    end
    for k, v in pairs(patched_fns) do
        if ACTIONS[k] then
            local old = ACTIONS[k].fn
            if old then
                ACTIONS[k].fn = function(...)
                    local newret = {v(...)}
                    if newret[1] == nil then
                        return old(...)
                    else
                        return unpack(newret)
                    end
                end
            else
                print("[AddDSTActions]" .. k .. ".fn don't exist")
                ACTIONS[k].fn = v
            end
        else
            print("[AddDSTActions]" .. k .. " don't exist in ACTIONS")
        end
    end
    for k, v in pairs(patched_strfns) do
        if ACTIONS[k] then
            local old = ACTIONS[k].strfn
            if old then
                ACTIONS[k].fn = function(...) return v(...) or old(...) end
            else
                print("[AddDSTActions]" .. k .. ".strfn don't exist")
                ACTIONS[k].strfn = v
            end
        else
            print("[AddDSTActions]" .. k .. " don't exist in ACTIONS")
        end
    end
    for k, v in pairs(patched_stroverridefns) do
        if ACTIONS[k] then
            local old = ACTIONS[k].stroverridefn
            if old then
                ACTIONS[k].fn = function(...) return v(...) or old(...) end
            else
                print("[AddDSTActions]" .. k .. ".stroverridefn don't exist")
                ACTIONS[k].stroverridefn = v
            end
        else
            print("[AddDSTActions]" .. k .. " don't exist in ACTIONS")
        end
    end
end
