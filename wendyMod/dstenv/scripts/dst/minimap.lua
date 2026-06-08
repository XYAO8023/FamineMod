if MiniMap.MapPosToWorldPos then return end
local DATA = {} -- I guess it is small enough
setmetatable(DATA, {
    __index = function(_, k)
        local t = {x = 0, y = 0, zoom = 1}
        DATA[k] = t
        return t
    end
})
local ResetOffset = MiniMap.ResetOffset
function MiniMap:ResetOffset()
    local m = DATA[self]
    m.x, m.y, m.zoom = 0, 0, 1
    return ResetOffset(self)
end
local Offset = MiniMap.Offset
function MiniMap:Offset(x, y)
    local m = DATA[self]
    m.x = m.x + x
    m.y = m.y + y
    return Offset(self, x, y)
end
local Zoom = MiniMap.Zoom
function MiniMap:Zoom(x)
    local zoom1 = self:GetZoom()
    local ret = Zoom(self, x)
    local zoom2 = self:GetZoom()
    local m = DATA[self]
    m.zoom = zoom2
    if zoom1 ~= zoom2 then
        m.x = m.x * zoom1 / zoom2
        m.y = m.y * zoom1 / zoom2
    end
    return ret
end
local constant = math.pi / 180
function MiniMap:WorldPosToMapPos(wx, wy, wz) -- #FIXME
    local m = DATA[self]
    local screenwidth, screenheight = TheSim:GetScreenSize()
    local px, _, pz = ThePlayer.Transform:GetWorldPosition()
    local ox = wx - px
    local oz = wz - pz
    local wd = math.sqrt(ox * ox + oz * oz)
    local wa = math.acos((px - wx) / wd)
    local wz = pz + wd * math.sin(wa)
    local x = ((ox / m.zoom * 9) + m.x * 9) / screenwidth
    local z = ((oz / m.zoom * 9) + m.y * 9) / screenheight
    return x, z
end
function MiniMap:MapPosToWorldPos(x, y)
    local m = DATA[self]
    local screenwidth, screenheight = TheSim:GetScreenSize()
    local ox = x * screenwidth - m.x * 9
    local oy = y * screenheight - m.y * 9
    local angle = TheCamera:GetHeadingTarget() * constant
    local wd = math.sqrt(ox * ox + oy * oy) * m.zoom / 9
    local wa = math.atan2(ox, oy) - angle
    local px, _, pz = ThePlayer.Transform:GetWorldPosition()
    local wx = px - wd * math.cos(wa)
    local wz = pz + wd * math.sin(wa)
    return wx, wz, 0
end
do
    local function Nothing()
    end
    local vars = {SetDrawOverFogOfWar = Nothing, SetCanUseCache = Nothing, SetIsProxy = Nothing}
    for k, v in pairs(vars) do MiniMapEntity[k] = MiniMapEntity[k] or v end
end
