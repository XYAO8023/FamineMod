return function(ItemTile)
    local self = ItemTile
    local invitem = self.item -- changed
    if invitem:HasClientSideInventoryImageOverrides() then
        self.inst:ListenForEvent("clientsideinventoryflagschanged", function(player)
            -- print("inventoryflagschanged!!!", invitem)
            if invitem and invitem.components.inventoryitem then
                self.image:SetTexture(invitem.components.inventoryitem:GetAtlas(),
                    invitem.components.inventoryitem:GetImage())
            end
        end, ThePlayer)
    end

end
