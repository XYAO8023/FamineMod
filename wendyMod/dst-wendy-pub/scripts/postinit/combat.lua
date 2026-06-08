local function fn(Combat)
    local self = Combat
    self.damagemultiplier = self.damagemultiplier or 1
    self.externaldamagemultipliers = self.externaldamagemultipliers or SourceModifierList(self.inst)
    self.externaldamagetakenmultipliers = self.externaldamagetakenmultipliers or SourceModifierList(self.inst)
    local old = self.GetAttacked
    function Combat:GetAttacked(attacker, damage, weapon, stimuli, ...)
        if self.getattackedexternaldamagetakenmultipliers then
            return old(self, attacker, damage, weapon, stimuli, ...)
        end
        self.getattackedexternaldamagetakenmultipliers = true
        local v = self.externaldamagetakenmultipliers:Get()
        -- #TODO:investigate if other component needs this too
        self.inst:PushEvent("externaldamagetakenmultipliers", {value = v})
        -- share this value with health components to get an absorption
        local h = self.inst.components.health
        if h then h.externaldamagetakenmultipliers = self.externaldamagetakenmultipliers end
        local ret = old(self, attacker, damage, weapon, stimuli, ...)
        self.getattackedexternaldamagetakenmultipliers = false
        return ret
    end
    local old2 = self.CalcDamage
    function Combat:CalcDamage(target, weapon, multiplier, ...)
        if self.DSTCalcDamageDone then return old2(self, target, weapon, multiplier, ...) end
        self.DSTCalcDamageDone = true
        multiplier = multiplier or self.multiplier or 1
        local mult = self.externaldamagemultipliers:Get()
        local oldv = self.GetDamageModifier and self:GetDamageModifier() or self.damagemultiplier
        local mount = self.inst.components.rider and self.inst.components.rider:GetMount() or nil
        local custommult = self.customdamagemultfn ~= nil
                               and self.customdamagemultfn(self.inst, target, weapon, multiplier, mount) or 1
        self.damagemultiplier = 1
        multiplier = multiplier * mult * custommult
        local ret = old2(self, target, weapon, multiplier, ...)
        self.damagemultiplier = oldv
        self.DSTCalcDamageDone = false
        return ret
    end
    -- Compatibility Warning
    -- sorry this bugfix must override the default one
    function Combat:DoAreaAttack(target, range, weapon, validfn, stimuli, excludetags)
        local hitcount = 0
        local x, y, z = target.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, range, nil, excludetags
            or {"falling", "FX", "NOCLICK", "DECOR", "INLIMBO", "notarget", "invisible", "noattack"})
        for i, ent in ipairs(ents) do
            if ent.components.combat and ent ~= target and ent ~= self.inst and self:CanAreaHitTarget(ent)
                and (not validfn or validfn(ent)) then
                self.inst:PushEvent("onareaattackother", {target = ent, weapon = weapon, stimuli = stimuli})
                ent.components.combat:GetAttacked(self.inst, self:CalcDamage(ent, weapon, self.areahitdamagepercent),
                    weapon, stimuli)
                hitcount = hitcount + 1
            end
        end
        return hitcount
    end
    --vanilla fix
    if not Combat.TargetIs then
        function Combat:TargetIs(target)
            return self.target and self.target == target
        end
    end
end
return fn
