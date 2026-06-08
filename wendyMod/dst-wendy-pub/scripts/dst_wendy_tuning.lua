local ret = function()
    return {
        ABIGAIL_SPEED = 5,
        ABIGAIL_HEALTH = wilson_health * 4,
        ABIGAIL_HEALTH_LEVEL1 = wilson_health * 1,
        ABIGAIL_HEALTH_LEVEL2 = wilson_health * 2,
        ABIGAIL_HEALTH_LEVEL3 = wilson_health * 4,
        ABIGAIL_FORCEFIELD_ABSORPTION = 1.0,
        ABIGAIL_DAMAGE_PER_SECOND = 20, -- deprecated
        ABIGAIL_DAMAGE = {day = 15, dusk = 25, night = 40},
        ABIGAIL_VEX_DURATION = 2,
        ABIGAIL_VEX_DAMAGE_MOD = 1.1,
        ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD = 1.4,
        ABIGAIL_DMG_PERIOD = 1.5,
        ABIGAIL_DMG_PLAYER_PERCENT = 0.25,
        ABIGAIL_FLOWER_DECAY_TIME = total_day_time * 3,
        ABIGAIL_BOND_LEVELUP_TIME = total_day_time * 1,
        ABIGAIL_BOND_LEVELUP_TIME_MULT = 4,
        ABIGAIL_MAX_STAGE = 3,
        ABIGAIL_LIGHTING = {
            {l = 0.0, r = 0.0},
            {l = 0.1, r = 0.3, i = 0.7, f = 0.5},
            {l = 0.5, r = 0.7, i = 0.6, f = 0.6}
        },
        ABIGAIL_FLOWER_PROX_DIST = 6 * 6,
        ABIGAIL_COMBAT_TARGET_DISTANCE = 15,
        ABIGAIL_DEFENSIVE_MIN_FOLLOW = 1,
        ABIGAIL_DEFENSIVE_MAX_FOLLOW = 5,
        ABIGAIL_DEFENSIVE_MED_FOLLOW = 3,
        ABIGAIL_AGGRESSIVE_MIN_FOLLOW = 3,
        ABIGAIL_AGGRESSIVE_MAX_FOLLOW = 10,
        ABIGAIL_AGGRESSIVE_MED_FOLLOW = 6,
        ABIGAIL_DEFENSIVE_MAX_CHASE_TIME = 3,
        ABIGAIL_AGGRESSIVE_MAX_CHASE_TIME = 6,
        -- from foodaffinity
        AFFINITY_15_CALORIES_TINY = 2.6,
        AFFINITY_15_CALORIES_SMALL = 2.2,
        AFFINITY_15_CALORIES_MED = 1.6,
        AFFINITY_15_CALORIES_LARGE = 1.4,
        AFFINITY_15_CALORIES_HUGE = 1.2,
        AFFINITY_15_CALORIES_SUPERHUGE = 1.1,
        -- wendy
        WENDY_HEALTH = wilson_health,
        WENDY_HUNGER = wilson_hunger,
        WENDY_SANITY = wilson_sanity,

        WENDY_DAMAGE_MULT = .75,
        WENDY_SANITY_MULT = .75,
        -- minigame
        MINIGAME_CROWD_DIST_MIN = 12,
        MINIGAME_CROWD_DIST_TARGET = 14,
        MINIGAME_CROWD_DIST_MAX = 20,
        -- ghostlyelixir
        GHOSTLYELIXIR_SLOWREGEN_HEALING = 2,
        GHOSTLYELIXIR_SLOWREGEN_TICK_TIME = 1,
        GHOSTLYELIXIR_SLOWREGEN_DURATION = total_day_time, -- 960 hp

        GHOSTLYELIXIR_FASTREGEN_HEALING = 20,
        GHOSTLYELIXIR_FASTREGEN_TICK_TIME = 1,
        GHOSTLYELIXIR_FASTREGEN_DURATION = seg_time, -- 600 hp

        GHOSTLYELIXIR_DAMAGE_DURATION = total_day_time,

        GHOSTLYELIXIR_SPEED_LOCO_MULT = 1.75,
        GHOSTLYELIXIR_SPEED_DURATION = total_day_time,
        GHOSTLYELIXIR_SPEED_PLAYER_GHOST_DURATION = 3,

        GHOSTLYELIXIR_SHIELD_DURATION = total_day_time,

        GHOSTLYELIXIR_RETALIATION_DAMAGE = 20,
        GHOSTLYELIXIR_RETALIATION_DURATION = total_day_time,

        GHOSTLYELIXIR_DRIP_FX_DELAY = seg_time / 2,
        -- ghost
        GHOST_FOLLOW_DSQ = 30 * 30 -- Used in ghost.lua and ghostbrain.lua
    }
end
local TuningHack = {}
setmetatable(TuningHack, {
    __index = function(_, k)
        if k == nil then return nil end
        if type(k) == "string" and TUNING[string.upper(k)] then
            return TUNING[string.upper(k)]
        else
            return env[k]
        end
    end
})
setfenv(ret, TuningHack)
return ret
