function RetrofitItem(item, postinitfn)
    local itemfound = false
    AddPrefabPostInit(item, function()
        itemfound = true
    end)
    AddGamePostInit(function()
        if not itemfound then
            postinitfn(item)
        end
    end)
end
function RemoveDuplicate(item, postinitfn)
    local itemfound = false
    AddPrefabPostInit(item, function(inst)
        if not itemfound then
            itemfound = inst
        else
            inst:DoTaskInTime(0, inst.Remove)
        end
    end)
    AddGamePostInit(item, function()
        if itemfound then
            postinitfn(itemfound)
        end
    end)
end
expose {
    RetrofitItem = RetrofitItem,
    RemoveDuplicate = RemoveDuplicate
}
