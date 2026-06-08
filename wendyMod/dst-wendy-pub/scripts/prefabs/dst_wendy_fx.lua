local function FinalOffset1(inst) inst.AnimState:SetFinalOffset(1) end

local function FinalOffset2(inst) inst.AnimState:SetFinalOffset(2) end

local function FinalOffset3(inst) inst.AnimState:SetFinalOffset(3) end

local function FinalOffsetNegative1(inst) inst.AnimState:SetFinalOffset(-1) end

local function GroundOrientation(inst)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
end

local function Bloom(inst)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
end

local function BloomOrange(inst)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    --    inst.AnimState:SetMultColour(204/255,131/255,57/255,1)
    inst.AnimState:SetMultColour(219 / 255, 168 / 255, 117 / 255, 1)
    inst.AnimState:SetFinalOffset(1)
end

local function OceanTreeLeafFxFallUpdate(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.Transform:SetPosition(x, y - inst.fall_speed * FRAMES, z)
end

local fx = {{
    name = "ghostflower_spirit1_fx",
    bank = "ghostflower",
    build = "ghostflower",
    anim = "fx1",
    sound = "dontstarve/characters/wendy/small_ghost/wisp"
}, {
    name = "ghostflower_spirit2_fx",
    bank = "ghostflower",
    build = "ghostflower",
    anim = "fx1",
    sound = "dontstarve/characters/wendy/small_ghost/wisp"

}, {
    name = "ghostlyelixir_slowregen_fx",
    bank = "abigail_vial_fx",
    build = "abigail_vial_fx",
    anim = "buff_regen",
    sound = "dontstarve/characters/wendy/abigail/buff/gen",
    fn = FinalOffset3
}, {
    name = "ghostlyelixir_fastregen_fx",
    bank = "abigail_vial_fx",
    build = "abigail_vial_fx",
    anim = "buff_heal",
    sound = "dontstarve/characters/wendy/abigail/buff/gen",
    fn = FinalOffset3
}, {
    name = "ghostlyelixir_shield_fx",
    bank = "abigail_vial_fx",
    build = "abigail_vial_fx",
    anim = "buff_shield",
    sound = "dontstarve/characters/wendy/abigail/buff/shield",
    fn = FinalOffset3
}, {
    name = "ghostlyelixir_attack_fx",
    bank = "abigail_vial_fx",
    build = "abigail_vial_fx",
    anim = "buff_attack",
    sound = "dontstarve/characters/wendy/abigail/buff/attack",
    fn = FinalOffset3
}, {
    name = "ghostlyelixir_speed_fx",
    bank = "abigail_vial_fx",
    build = "abigail_vial_fx",
    anim = "buff_speed",
    sound = "dontstarve/characters/wendy/abigail/buff/speed",
    fn = FinalOffset3
}, {
    name = "ghostlyelixir_retaliation_fx",
    bank = "abigail_vial_fx",
    build = "abigail_vial_fx",
    anim = "buff_retaliation",
    sound = "dontstarve/characters/wendy/abigail/buff/retaliation",
    fn = FinalOffset3
}, {
    name = "ghostlyelixir_slowregen_dripfx",
    bank = "abigail_buff_drip",
    build = "abigail_vial_fx",
    anim = "abigail_buff_drip",
    fn = function(inst)
        inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_regen_02")
        inst.AnimState:SetFinalOffset(3)
    end
}, {
    name = "ghostlyelixir_fastregen_dripfx",
    bank = "abigail_buff_drip",
    build = "abigail_vial_fx",
    anim = "abigail_buff_drip",
    fn = function(inst)
        inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_heal_02")
        inst.AnimState:SetFinalOffset(3)
    end
}, {
    name = "ghostlyelixir_shield_dripfx",
    bank = "abigail_buff_drip",
    build = "abigail_vial_fx",
    anim = "abigail_buff_drip",
    fn = function(inst)
        inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_shield_02")
        inst.AnimState:SetFinalOffset(3)
    end
}, {
    name = "ghostlyelixir_attack_dripfx",
    bank = "abigail_buff_drip",
    build = "abigail_vial_fx",
    anim = "abigail_buff_drip",
    fn = function(inst)
        inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_attack_02")
        inst.AnimState:SetFinalOffset(3)
    end
}, {
    name = "ghostlyelixir_speed_dripfx",
    bank = "abigail_buff_drip",
    build = "abigail_vial_fx",
    anim = "abigail_buff_drip",
    fn = function(inst)
        inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_speed_02")
        inst.AnimState:SetFinalOffset(3)
    end
}, {
    name = "ghostlyelixir_retaliation_dripfx",
    bank = "abigail_buff_drip",
    build = "abigail_vial_fx",
    anim = "abigail_buff_drip",
    fn = function(inst)
        inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_retaliation_02")
        inst.AnimState:SetFinalOffset(3)
    end
}}
local function PlaySound(inst, sound) inst.SoundEmitter:PlaySound(sound) end

local function MakeFx(t)
    local assets = {Asset("ANIM", "anim/" .. t.build .. ".zip")}

    local function startfx(proxy)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        local parent = proxy.entity:GetParent()
        if parent ~= nil then inst.entity:SetParent(parent.entity) end

        if t.nameoverride == nil and t.description == nil then inst:AddTag("FX") end
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        -- inst.Transform:SetFromProxy(proxy.GUID)--deleted
        -- inst.Transform:SetPosition((parent or proxy).Transform:GetWorldPosition())

        if t.autorotate and parent ~= nil then inst.Transform:SetRotation(parent.Transform:GetRotation()) end

        if t.sound ~= nil then
            inst.entity:AddSoundEmitter()
            if t.update_while_paused then
                inst:DoStaticTaskInTime(t.sounddelay or 0, PlaySound, t.sound)
            else
                inst:DoTaskInTime(t.sounddelay or 0, PlaySound, t.sound)
            end
        end

        if t.sound2 ~= nil then
            if inst.SoundEmitter == nil then inst.entity:AddSoundEmitter() end
            if t.update_while_paused then
                inst:DoStaticTaskInTime(t.sounddelay2 or 0, PlaySound, t.sound2)
            else
                inst:DoTaskInTime(t.sounddelay2 or 0, PlaySound, t.sound2)
            end
        end

        inst.AnimState:SetBank(t.bank)
        inst.AnimState:SetBuild(t.build)
        inst.AnimState:PlayAnimation(FunctionOrValue(t.anim)) -- THIS IS A CLIENT SIDE FUNCTION
        if t.update_while_paused then inst.AnimState:AnimateWhilePaused(true) end
        if t.tint ~= nil then
            inst.AnimState:SetMultColour(t.tint.x, t.tint.y, t.tint.z, t.tintalpha or 1)
        elseif t.tintalpha ~= nil then
            inst.AnimState:SetMultColour(t.tintalpha, t.tintalpha, t.tintalpha, t.tintalpha)
        end
        -- print(inst.AnimState:GetMultColour())
        if t.transform ~= nil then inst.AnimState:SetScale(t.transform:Get()) end

        if t.nameoverride ~= nil then
            if inst.components.inspectable == nil then inst:AddComponent("inspectable") end
            inst.components.inspectable.nameoverride = t.nameoverride
            inst.name = t.nameoverride
        end

        if t.description ~= nil then
            if inst.components.inspectable == nil then inst:AddComponent("inspectable") end
            inst.components.inspectable.descriptionfn = t.description
        end

        if t.bloom then inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh") end

        if t.animqueue then
            inst:ListenForEvent("animqueueover", inst.Remove)
        else
            inst:ListenForEvent("animover", inst.Remove)
        end

        if t.fn ~= nil then
            if t.fntime ~= nil then
                if t.update_while_paused then
                    inst:DoStaticTaskInTime(t.fntime, t.fn)
                else
                    inst:DoTaskInTime(t.fntime, t.fn)
                end
            else
                t.fn(inst)
            end
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        -- Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            -- Delay one frame so that we are positioned properly before starting the effect
            -- or in case we are about to be removed
            if t.update_while_paused then
                inst:DoStaticTaskInTime(0, startfx, inst)
            else
                inst:DoTaskInTime(0, startfx, inst)
            end
        end

        if t.twofaced then
            inst.Transform:SetTwoFaced()
        elseif t.eightfaced then
            inst.Transform:SetEightFaced()
        elseif t.sixfaced then
            inst.Transform:SetSixFaced()
        elseif not t.nofaced then
            inst.Transform:SetFourFaced()
        end

        inst:AddTag("FX")

        -- inst.entity:SetPristine()

        if not TheWorld.ismastersim then return inst end

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end

    return Prefab(t.name, fn, assets)
end

local prefs = {}

for k, v in pairs(fx) do table.insert(prefs, MakeFx(v)) end

return unpack(prefs)
