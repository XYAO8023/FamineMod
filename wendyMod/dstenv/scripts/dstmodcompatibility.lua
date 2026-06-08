return function()
    if TheInvImagesAPI and TheInvImagesAPI.atlasLookup then
        table.mergeinto(TheInvImagesAPI.atlasLookup, inventoryItemAtlasLookup, true)
    end
end
