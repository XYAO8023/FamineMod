-- replica->components
return {
    USEITEM = {
        ghostlyelixir = function(inst, doer, target, actions)
            if target:HasTag("ghostlyelixirable") then table.insert(actions, ACTIONS.GIVE) end
        end,
        summoningitem = function(inst, doer, target, actions, right)
            if not target.inlimbo and target.components.follower ~= nil and target.components.follower:GetLeader() ==
                doer and doer:HasTag("ghostfriend_summoned") and target:HasTag("abigail") then
                table.insert(actions, ACTIONS.CASTUNSUMMON)
            end
        end,
        inventoryitem = function(inst, doer, target, actions, right)
            local inventoryitem = inst.components.inventoryitem

            if inventoryitem ~= nil and inventoryitem:CanOnlyGoInPocket() then
                -- not tradable
            elseif inventoryitem ~= nil and target.components.container ~= nil and
                target.components.container.CanBeOpened and target.components.container:CanBeOpened() -- patched
            and inventoryitem.IsGrandOwner and inventoryitem:IsGrandOwner(doer) then
                if not (GetGameModeProperty("non_item_equips") and inst.components.equippable ~= nil) and
                    ((inst.prefab ~= "spoiled_food" and inst:HasTag("quagmire_stewable") and
                        target:HasTag("quagmire_stewer") and target.components.container:IsOpenedBy(doer)) or
                        not (target:HasTag("BURNABLE_fueled") and inst:HasTag("BURNABLE_fuel"))) then
                    table.insert(actions, target:HasTag("bundle") and ACTIONS.BUNDLESTORE or ACTIONS.STORE)
                end
            elseif target.components.constructionsite ~= nil then
                if not (GetGameModeProperty("non_item_equips") and inst.components.equippable ~= nil) and
                    not (target:HasTag("BURNABLE_fueled") and inst:HasTag("BURNABLE_fuel")) then
                    table.insert(actions, target.components.constructionsite:IsBuilder(doer) and ACTIONS.BUNDLESTORE or
                        ACTIONS.CONSTRUCT)
                end
            elseif target:HasTag("playerghost") then
                if inst.prefab == "reviver" then table.insert(actions, ACTIONS.GIVETOPLAYER) end
            elseif target:HasTag("player") then
                if not (target.components.rider ~= nil and target.components.rider:IsRiding()) and
                    not target:HasTag("wereplayer") and
                    not (GetGameModeProperty("non_item_equips") and inst.components.equippable ~= nil) then
                    table.insert(actions,
                        not (doer.components.playercontroller ~= nil and
                            doer.components.playercontroller:IsControlPressed(CONTROL_FORCE_STACK)) and
                            inst.components.stackable ~= nil and inst.components.stackable:IsStack() and
                            ACTIONS.GIVEALLTOPLAYER or ACTIONS.GIVETOPLAYER)
                end
            elseif not (doer.components.rider ~= nil and doer.components.rider:IsRiding()) then
                if target:HasTag("alltrader") then
                    table.insert(actions, ACTIONS.GIVE)
                elseif inst.prefab == "reviver" and target:HasTag("ghost") then
                    table.insert(actions, ACTIONS.GIVE)
                elseif target:HasTag("boatcannon") and not target:HasTag("burnt") and not target:HasTag("fire") and
                    inst:HasTag("boatcannon_ammo") and not target:HasTag("ammoloaded") then
                    table.insert(actions, ACTIONS.BOAT_CANNON_LOAD_AMMO)
                end
            end
        end
    },
    INVENTORY = {
        summoningitem = function(inst, doer, actions)
            if doer:HasTag("ghostfriend_notsummoned") then
                table.insert(actions, ACTIONS.CASTSUMMON)
            elseif doer:HasTag("ghostfriend_summoned") then
                table.insert(actions, ACTIONS.COMMUNEWITHSUMMONED)
            end
        end
        -- QoL ghostlyelixir usable via inventory
        --[[ghostlyelixir = function(inst, doer, actions)
            if doer:HasTag("elixirbrewer") and doer:CanUseElixir(inst) then
                table.insert(actions, ACTIONS.USEELIXIR)
            end
        end]]
    }
}
