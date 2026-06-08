if DSTPrefab then return end
-- require("prefabskins")--deleted
local function Nothing()
end
DSTPrefab = Class(Prefab, function(self, name, fn, assets, deps, force_path_search)
    Prefab._ctor(self, name or "", fn or Nothing, assets, deps, force_path_search)
    self.force_path_search = force_path_search or false

    if PREFAB_SKINS and PREFAB_SKINS[self.name] then -- patched
        for _, prefab_skin in pairs(PREFAB_SKINS[self.name]) do
            table.insert(self.deps, prefab_skin)
        end
    end
end)

function DSTPrefab:__tostring()
    return string.format("Prefab %s - %s", self.name, self.desc)
end

DSTAsset = function(type, file, param, ...)
    type = string.gsub(type, "DYNAMIC_", "")
    return Asset(type, file, param, ...)
end
expose {
    DSTPrefab = DSTPrefab,
    DSTAsset = DSTAsset
}
