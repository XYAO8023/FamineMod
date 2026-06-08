-- DST is the same
-- local DSTActionHandler=ActionHandler
-- local ActionHandler=DSTActionHandler
local function EquipPaddle(inst)
    if not inst:HasTag("mime") then inst.AnimState:OverrideSymbol("paddle", "swap_paddle", "paddle") end
    -- IA: TODO allow custom paddles?
    inst.AnimState:OverrideSymbol("wake_paddle", "swap_paddle", "wake_paddle")
end
local PatchPaddle = function(sg)
    -- from Island Adventures
    local old = sg.onenter
    sg.onenter = function(inst)
        EquipPaddle(inst)
        old(inst)
    end
end
local PatchPaddleEvent = function(self)
    -- from Island Adventures
    local old = self.fn
    self.fn = function(inst, ...)
        EquipPaddle(inst)
        return old(inst, ...)
    end
end
return {
    ACTIONS = {
        ActionHandler(ACTIONS.CASTSUMMON, function(inst, action)
            return action.invobject ~= nil and action.invobject:HasTag("abigail_flower") and "summon_abigail"
                       or "castspell"
        end),
        ActionHandler(ACTIONS.CASTUNSUMMON, function(inst, action)
            return action.invobject ~= nil and action.invobject:HasTag("abigail_flower") and "unsummon_abigail"
                       or "castspell"
        end),
        ActionHandler(ACTIONS.COMMUNEWITHSUMMONED, function(inst, action)
            return action.invobject ~= nil and action.invobject:HasTag("abigail_flower") and "commune_with_abigail"
                       or "dolongaction"
        end)
    },
    STATES = {
        State {
            name = "summon_abigail",
            tags = {"doing", "busy", "anodangle", "canrotate"},

            onenter = function(inst)
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("wendy_channel")
                inst.AnimState:PushAnimation("wendy_channel_pst", false)

                if inst.bufferedaction ~= nil then
                    local flower = inst.bufferedaction.invobject
                    if flower ~= nil then
                        local skin_build = flower:GetSkinBuild()
                        if skin_build ~= nil then
                            inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID,
                                flower.AnimState:GetBuild())
                        else
                            inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                        end
                    end

                    inst.sg.statemem.action = inst.bufferedaction
                end
            end,

            timeline = {
                TimeEvent(0 * FRAMES, function(inst)
                    if inst.components.talker ~= nil and inst.components.ghostlybond ~= nil then
                        inst.components.talker:Say(GetString(inst, "ANNOUNCE_ABIGAIL_SUMMON", "LEVEL"
                            .. tostring(math.max(inst.components.ghostlybond.bondlevel, 1))), nil, nil, true)
                    end
                end),
                TimeEvent(6 * FRAMES, function(inst)
                    --deleted--inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/summon_pre")
                end),
                TimeEvent(53 * FRAMES, function(inst)
                    --deleted--inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/summon")
                end),
                TimeEvent(52 * FRAMES, function(inst)
                    inst.sg.statemem.fx = SpawnPrefab(inst.components.rider:IsRiding() and "abigailsummonfx_mount"
                                                          or "abigailsummonfx")
                    inst.sg.statemem.fx.entity:SetParent(inst.entity)
                    inst.sg.statemem.fx.AnimState:SetTime(0) -- hack to force update the initial facing direction

                    if inst.bufferedaction ~= nil then
                        local flower = inst.bufferedaction.invobject
                        if flower ~= nil then
                            local skin_build = flower:GetSkinBuild()
                            if skin_build ~= nil then
                                inst.sg.statemem.fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower",
                                    flower.GUID, flower.AnimState:GetBuild())
                            end
                        end
                    end

                    if inst.components.talker ~= nil then inst.components.talker:ShutUp() end
                end),
                TimeEvent(62 * FRAMES, function(inst)
                    if inst:PerformBufferedAction() then
                        inst.sg.statemem.fx = nil
                    else
                        inst.sg:GoToState("idle")
                    end
                end),
                TimeEvent(74 * FRAMES, function(inst)
                    inst.sg:RemoveStateTag("busy")
                end)
            },

            events = {
                EventHandler("animqueueover", function(inst)
                    if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end
                end)
            },

            onexit = function(inst)
                inst.AnimState:ClearOverrideSymbol("flower")
                if inst.sg.statemem.fx ~= nil then inst.sg.statemem.fx:Remove() end
                if inst.bufferedaction == inst.sg.statemem.action
                    and (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction
                        ~= inst.bufferedaction) then inst:ClearBufferedAction() end
            end
        },
        State {
            name = "unsummon_abigail",
            tags = {"doing", "busy", "nodangle"},

            onenter = function(inst)
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("wendy_recall")
                inst.AnimState:PushAnimation("wendy_recall_pst", false)

                if inst.bufferedaction ~= nil then
                    local flower = inst.bufferedaction.invobject
                    if flower ~= nil then
                        local skin_build = flower:GetSkinBuild()
                        if skin_build ~= nil then
                            inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID,
                                flower.AnimState:GetBuild())
                        else
                            inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                        end
                    end

                    inst.sg.statemem.action = inst.bufferedaction

                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_ABIGAIL_RETRIEVE"), nil, nil, true)
                end
            end,

            timeline = {
                TimeEvent(6 * FRAMES, function(inst)
                    --deleted--inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/summon_pre")
                end),
                TimeEvent(30 * FRAMES, function(inst)
                    --deleted--inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/recall")
                end),
                TimeEvent(26 * FRAMES, function(inst)
                    inst.sg:RemoveStateTag("busy")

                    if inst.components.talker ~= nil then inst.components.talker:ShutUp() end

                    local flower = nil
                    if inst.bufferedaction ~= nil then flower = inst.bufferedaction.invobject end

                    if inst:PerformBufferedAction() then
                        local fx = SpawnPrefab(inst.components.rider:IsRiding() and "abigailunsummonfx_mount"
                                                   or "abigailunsummonfx")
                        fx.entity:SetParent(inst.entity)
                        fx.AnimState:SetTime(0) -- hack to force update the initial facing direction

                        if flower ~= nil then
                            local skin_build = flower:GetSkinBuild()
                            if skin_build ~= nil then
                                fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID,
                                    flower.AnimState:GetBuild())
                            end
                        end
                    else
                        inst.sg:GoToState("idle")
                    end
                end)
            },

            events = {
                EventHandler("animqueueover", function(inst)
                    if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end
                end)
            },

            onexit = function(inst)
                inst.AnimState:ClearOverrideSymbol("flower")
                if inst.bufferedaction == inst.sg.statemem.action
                    and (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction
                        ~= inst.bufferedaction) then inst:ClearBufferedAction() end
            end
        },
        State {
            name = "commune_with_abigail",
            tags = {"doing", "busy", "nodangle"},

            onenter = function(inst)
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("wendy_commune_pre")
                inst.AnimState:PushAnimation("wendy_commune_pst", false)

                if inst.bufferedaction ~= nil then
                    local flower = inst.bufferedaction.invobject
                    if flower ~= nil then
                        local skin_build = flower:GetSkinBuild()
                        if skin_build ~= nil then
                            inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID,
                                flower.AnimState:GetBuild())
                        else
                            inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                        end
                    end

                    inst.sg.statemem.action = inst.bufferedaction

                end
            end,

            timeline = {
                TimeEvent(14 * FRAMES, function(inst)
                    inst:PerformBufferedAction()
                end),
                TimeEvent(35 * FRAMES, function(inst)
                    inst.sg:RemoveStateTag("busy")
                end)
            },

            events = {
                EventHandler("animqueueover", function(inst)
                    if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end
                end)
            },

            onexit = function(inst)
                inst.AnimState:ClearOverrideSymbol("flower")
                if inst.bufferedaction == inst.sg.statemem.action
                    and (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction
                        ~= inst.bufferedaction) then inst:ClearBufferedAction() end
            end
        }
    },
    PATCHEDSTATES = {
        row_start = PatchPaddle,
        funnyidle = function(state)
            local old = state.onenter
            local function outof(val, min, max)
                return val < min or val > max
            end
            local function CheckNotHealthy(inst)
                return (inst.components.poisonable and inst.components.poisonable:IsPoisoned())
                           or (inst.components.temperature and outof(inst.components.temperature:GetCurrent(), 5, 60))
                           or (inst.components.hunger and inst.components.hunger:GetPercent() < TUNING.HUNGRY_THRESH)
                           or (inst.components.sanity and inst.components.sanity:IsCrazy()) or inst:HasTag("groggy")
            end
            local new = function(inst)
                if not CheckNotHealthy(inst) then
                    if inst.customidleanim then
                        inst.AnimState:PlayAnimation(FunctionOrValue(inst.customidleanim, inst))
                        return true
                    end
                end
                return false
            end
            state.onenter = function(inst)
                if new(inst) then return end
                return old(inst)
            end
        end
    },
    PATCHEDEVENTS = {sailunequipped = PatchPaddleEvent}
}
