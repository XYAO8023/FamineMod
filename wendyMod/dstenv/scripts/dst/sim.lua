if Sim.ReskinEntity then return end
function Sim:ReskinEntity(guid, targetskinname, reskinname, skin_id, userid, ...)
    --print("ReskinEntity", Ents[guid] or "?", targetskinname or "-", reskinname or "-", ...)
    local inst = Ents[guid]
    if inst then
        if inst.components and inst.components.skinner then
            inst.components.skinner:SetSkinName(reskinname)
        elseif inst.components and inst.components.itemskinner then
            inst.components.itemskinner:SetSkin(reskinname, targetskinname)
        end
    end
end
