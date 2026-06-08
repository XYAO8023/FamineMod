local function Nothing()
end
do
    local fns = {
        SetFollowEmitter = Nothing,
        SetSortOffset = Nothing,
        SetGroundPhysics = Nothing,
        SetKillOnEntityDeath = Nothing,
        InitEmitters = Nothing,
        SetRotateOnVelocity = Nothing
    }
    for k, v in pairs(fns) do ParticleEmitter[k] = ParticleEmitter[k] or v end
end
