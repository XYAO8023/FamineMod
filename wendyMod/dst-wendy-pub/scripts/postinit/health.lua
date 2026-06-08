local function fn(Health)
    local self = Health
    local inst = self.inst
    self.externalabsorbmodifiers = self.externalabsorbmodifiers
                                       or SourceModifierList(inst, 0, SourceModifierList.additive)
    self.externaldamagetakenmultipliers = self.externaldamagetakenmultipliers or SourceModifierList(inst)
    self.externalfiredamagemultipliers = self.externalfiredamagemultipliers or SourceModifierList(inst)
    function Health:GetFireDamageScale()
        return self.fire_damage_scale * self.externalfiredamagemultipliers:Get()
    end
    function Health:SetCurrentHealth(amount)
        self.currenthealth = amount
    end
    function Health:Max()
        return self.maxhealth
    end
    -- add absorb
    local oldDelta = self.DoDelta
    function Health:DoDelta(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
        if self.oldabsorb ~= nil or (ignore_absorb and self.externaldamagetakenmultipliers:Get() == 1) then
            -- this has been handled earlier
            return oldDelta(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
        end
        local old = self.externalabsorbmodifiers:Get()
        if not ignore_absorb then
            self.oldabsorb = self.absorb
            local newabsorb = math.min(1 - (1 - self.externalabsorbmodifiers:Get()) * (1 - self.oldabsorb), 1)
            if self.SetAbsorptionAmount then
                self:SetAbsorptionAmount(newabsorb)
            elseif self.SetAbsorbAmount then
                self:SetAbsorbAmount(newabsorb)
            else
                self.absorb = newabsorb
            end
            self.externalabsorbmodifiers._modifier = 0
        end
        -- add externaldamagetakenmultipliers
        local old2 = self.externaldamagetakenmultipliers:Get()
        if old2 ~= 1 and amount < 0 then
            self.externaldamagetakenmultipliers._modifier = 1
            amount = amount * math.max(old2, 0)
        end
        local ret = oldDelta(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
        self.externaldamagetakenmultipliers._modifier = old2
        if not ignore_absorb then
            self.externalabsorbmodifiers._modifier = old
            self.absorb = self.oldabsorb
            self.oldabsorb = nil
        end
        return ret
    end
end
return fn
