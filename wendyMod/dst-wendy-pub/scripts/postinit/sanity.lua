local function fn(Sanity)
    local self = Sanity
    self.sanity_penalties = {}
    function Sanity:AddSanityAuraImmunity(tag)
        if self.sanity_aura_immunities == nil then self.sanity_aura_immunities = {} end
        self.sanity_aura_immunities[tag] = true
    end
    function Sanity:SetPlayerGhostImmunity(immunity)
        self.player_ghost_immune = immunity
    end
    if not Sanity.IsInsane then
        function Sanity:IsInsane()
            return Sanity:IsCrazy()
        end
    end
end
return fn
