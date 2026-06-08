if Launch then return end
function Launch(inst, launcher, basespeed)
    if inst ~= nil and inst.Physics ~= nil and inst.Physics:IsActive() and launcher ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = launcher.Transform:GetWorldPosition()
        local vx, vz = x - x1, z - z1
        local spd = math.sqrt(vx * vx + vz * vz)
        local angle =
            spd > 0 and
            math.atan2(vz / spd, vx / spd) + (math.random() * 20 - 10) * DEGREES or
            math.random() * 2 * PI
        spd = (basespeed or 5) + math.random() * 2
        inst.Physics:Teleport(x, .1, z)
        inst.Physics:SetVel(math.cos(angle) * spd, 10, math.sin(angle) * spd)
    end
end
expose("Launch",Launch)