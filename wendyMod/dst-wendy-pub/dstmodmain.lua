GLOBAL.setmetatable(GLOBAL.getmetatable(env).__index, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})
modimport("scripts/apis.lua")
utils.mod({"scripts/entityapis","scripts/main"})
