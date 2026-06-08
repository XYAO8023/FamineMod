return function(SpellCaster)
    function SpellCaster:SetCanCastFn(fn)
        return self:SetSpellTestFn(function(inst, doer, target, pos, ...)
            return target and fn(doer, target, pos, ...)
        end)
    end
    local CanCast = SpellCaster.CanCast
    function SpellCaster:CanCast(doer, target, pos, ...)
        if not CanCast(self, doer, target, pos, ...) then
            return false
        elseif target == nil then
            if pos == nil then
                return self.canusefrominventory
            end

            if self.canuseonpoint then
                local px, py, pz = pos:Get()
                return true -- TheWorld.Map:IsAboveGroundAtPoint(px, py, pz, self.canuseonpoint_water) and
                --   not TheWorld.Map:IsGroundTargetBlocked(pos)--#TODO: find equivalent
            elseif self.canuseonpoint_water then
                return true -- TheWorld.Map:IsOceanAtPoint(pos:Get()) and not TheWorld.Map:IsGroundTargetBlocked(pos)
            else
                return false
            end
        elseif target:IsInLimbo() or not target.entity:IsVisible() or
            (target.components.health ~= nil and target.components.health:IsDead() and not self.canuseondead) or
            (target.sg ~= nil and
                (target.sg.currentstate.name == "death" or target.sg:HasStateTag("flight") or
                    target.sg:HasStateTag("invisible") or target.sg:HasStateTag("nospellcasting"))) then
            return false
        end
        do
            return true
        end
        -- ignore them
        return self.canuseontargets and ((self.canonlyuseonrecipes and AllRecipes[target.prefab] ~= nil and
                   not FunctionOrValue(AllRecipes[target.prefab].no_deconstruction, target)) or
                   (target.components.locomotor ~= nil and
                       ((self.canonlyuseonlocomotors and not self.canonlyuseonlocomotorspvp) or
                           (self.canonlyuseonlocomotorspvp and
                               (target == doer or TheNet:GetPVPEnabled() or
                                   not (target:HasTag("player") and doer:HasTag("player")))))) or
                   (self.canonlyuseonworkable and target.components.workable ~= nil and
                       target.components.workable:CanBeWorked() and
                       IsWorkAction(target.components.workable:GetWorkAction())) or
                   (self.canonlyuseoncombat and doer.components.combat ~= nil and
                       doer.components.combat:CanTarget(target)) or
                   (self.can_cast_fn ~= nil and self.can_cast_fn(doer, target, pos)))
    end
end
