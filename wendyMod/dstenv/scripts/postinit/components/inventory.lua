return function(Inventory)
    if Inventory.Hide then return end
    function Inventory:Hide() if self.inst.HUD and self.inst.HUD.shown then self.inst.HUD:Toggle() end end
    function Inventory:Show() if self.inst.HUD and not self.inst.HUD.shown then self.inst.HUD:Toggle() end end
end
