return function(builder)
    local Ingredient = DSTIngredient
    local _Recipe2 = Recipe2
    local function Recipe2(name, ingredient, tech, config)
        if config and config.builder_tag then
            if not builder or builder:HasTag(config.builder_tag) then
                return _Recipe2(name, ingredient, tech, config)
            end
        else
            return _Recipe2(name, ingredient, tech, config)
        end
    end

    Recipe2("abigail_flower", {Ingredient("ghostflower", 1), Ingredient("nightmarefuel", 1)}, TECH.NONE,
        {builder_tag = "ghostlyfriend"})
    Recipe2("sisturn", {Ingredient("cutstone", 3), Ingredient("boards", 3), Ingredient("ash", 1)}, TECH.NONE, {
        builder_tag = "ghostlyfriend",
        placer = "sisturn_placer",
        tab = "town" -- added
    })
    Recipe2("ghostlyelixir_slowregen", {Ingredient("spidergland", 1), Ingredient("ghostflower", 1)}, TECH.NONE,
        {builder_tag = "elixirbrewer"})
    Recipe2("ghostlyelixir_fastregen", {Ingredient("reviver", 1), Ingredient("ghostflower", 3)}, TECH.NONE,
        {builder_tag = "elixirbrewer"})
    Recipe2("ghostlyelixir_shield", {Ingredient("log", 1), Ingredient("ghostflower", 1)}, TECH.NONE,
        {builder_tag = "elixirbrewer"})
    Recipe2("ghostlyelixir_retaliation", {Ingredient("livinglog", 1), Ingredient("ghostflower", 3)}, TECH.NONE,
        {builder_tag = "elixirbrewer"})
    Recipe2("ghostlyelixir_attack", {Ingredient("stinger", 1), Ingredient("ghostflower", 3)}, TECH.NONE,
        {builder_tag = "elixirbrewer"})
    Recipe2("ghostlyelixir_speed", {Ingredient("honey", 1), Ingredient("ghostflower", 1)}, TECH.NONE,
        {builder_tag = "elixirbrewer"})
    -- reviver
    Recipe2("reviver", {
        Ingredient("cutgrass", 3),
        Ingredient("spidergland", 1),
        CHARACTER_INGREDIENT and Ingredient(CHARACTER_INGREDIENT.HEALTH, 40) or nil -- patched
    }, TECH.NONE, {
        tab = "survival" -- added
    })
end
-- #TODO: add character ingredient to below Hamlet
