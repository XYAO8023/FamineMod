local UNINITIALIZED = 0
local JOINED = 1
local ACTIVATED = 2
local READY = 3
local function fn(inst, delayed)
    if delayed and delayed > 10 then
        return
    end
    inst = inst or GetPlayer()
    if inst then
        rawset(inst, "_loadstage", rawget(inst, "_loadstage") or UNINITIALIZED)
        -- print("player: ", inst, "stage", inst._loadstage)
        if inst._loadstage == UNINITIALIZED then
            TheWorld:PushEvent("ms_playerjoined", inst)
        elseif not rawget(_G.ThePlayer, "entity") then
            _G.ThePlayer = inst
            inst._loadstage = UNINITIALIZED
            TheWorld:PushEvent("DSTThePlayerReady")
            inst:ListenForEvent("onremove", function()
                inst:PushEvent("playerdeactivated")
            end)
            inst:DoTaskInTime(0.1, fn)
        elseif inst._loadstage <= JOINED then
            table.insert(AllPlayers, inst)
            TheWorld:PushEvent("ms_playerspawn", inst)
            inst:PushEvent("playeractivated")
            inst:DoTaskInTime(0.1, fn)
        elseif inst._loadstage <= ACTIVATED then
            if inst.HUD and inst.HUD.controls and inst.HUD.controls.status then
                if inst.HUD.controls.status.SetGhostMode then
                    inst.HUD.controls.status:SetGhostMode(false) -- patched, will move to separate file
                end
            else
                inst:DoTaskInTime((delayed or 0.1) * 2, fn)
                return
            end
        else
            return
        end
        inst._loadstage = inst._loadstage + 1
    end
end
return fn
