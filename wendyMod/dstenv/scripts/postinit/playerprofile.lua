return function(PlayerProfile)
    local self = PlayerProfile
    table.mergeinto(self.persistdata, {
        collection_name = nil,
        install_id = os.time(),
        play_instance = 0,
        favorite_mods = {}
        -- characterskins = {} --legacy variable, don't use it.
    }, true)
    function PlayerProfile:GetItemSortMode() return nil end--#FIXME
    function PlayerProfile:GetIntegratedBackpack() return false end--#FIXME
    function PlayerProfile:GetSkinsForPrefab(prefab)
        local owned_skins = {}
        table.insert(owned_skins, prefab .. "_none") -- everyone always has access to the nothing option

        local skins = PREFAB_SKINS[prefab]
        if skins ~= nil then
            for k, v in pairs(skins) do
                if TheInventory:CheckOwnership(v) then
                    -- if v ~= "backpack_mushy" then
                    table.insert(owned_skins, v)
                    -- end
                end
            end
        end
        return owned_skins
    end
    function PlayerProfile:GetSkinsForCharacter(character)
        if not self.persistdata.character_skins then self.persistdata.character_skins = {} end

        if not self.persistdata.character_skins[character] then
            if self.persistdata.characterskins ~= nil and self.persistdata.characterskins[character] ~= nil then
                print("Read back legacy skins data from profile for character", character)
                self.persistdata.character_skins[character] =
                    self.persistdata.characterskins[character][self.persistdata.characterskins[character].last_base]
                -- strip out old "" legacy items
                if self.persistdata.character_skins[character] ~= nil then
                    for k, v in pairs(self.persistdata.character_skins[character]) do
                        if v == "" then self.persistdata.character_skins[character][k] = nil end
                    end
                else
                    self.persistdata.character_skins[character] = {
                        base = character .. "_none"
                    }
                end
            else
                self.persistdata.character_skins[character] = {
                    base = character .. "_none"
                }
            end
        end

        -- Do skins validation to ensure that the saved skins aren't available anymore
        -- ValidateItemsLocal(character, self.persistdata.character_skins[character])--do not

        -- Never return internal data to prevent accidental profile modification.
        -- Modify via Set functions.
        return shallowcopy(self.persistdata.character_skins[character]) or {}
    end
    function PlayerProfile:SetSkinsForCharacter(character, skinList)
        if not self.persistdata.character_skins then self.persistdata.character_skins = {} end

        if not self.persistdata.character_skins[character] then self.persistdata.character_skins[character] = {} end

        self.dirty = true
        self.persistdata.character_skins[character] = shallowcopy(skinList)

        self:Save()
    end
    function PlayerProfile:GetLastUsedSkinForItem(item)
        -- #TODO
    end
    function PlayerProfile:SetSkinPresetForCharacter()
        -- #TODO
    end
    function PlayerProfile:GetSkinPresetForCharacter()
        -- #TODO
        return
    end
    function PlayerProfile:SetLastUsedSkinForItem()
        -- #TODO
        return
    end
end
