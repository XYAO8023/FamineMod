local function AuraTest(inst, target)
    if inst.components.combat:TargetIs(target)
        or (target.components.combat.target ~= nil and target.components.combat:TargetIs(inst)) then return true end

    return not target:HasTag("ghostlyfriend") and not target:HasTag("abigail")
end
return function(inst)
    if not inst.components.aura.auratestfn then inst.components.aura.auratestfn = AuraTest end
end
