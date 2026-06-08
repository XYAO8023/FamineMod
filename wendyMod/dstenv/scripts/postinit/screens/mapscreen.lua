return function(MapScreen)
    function MapScreen:GetWorldPositionAtCursor()
        local x, y = self:GetCursorPosition()
        x, y = self.minimap:MapPosToWorldPos(x, y, 0)
        return x, 0, y -- Coordinate conversion from minimap widget to world.
    end
    function MapScreen:GetCursorPosition()
        -- This function uses the origin at the center of the screen.
        -- Outputs are normalized from -1 to 1 on both axii.
        local x, y
        if TheInput:ControllerAttached() then
            x, y = 0, 0 -- Controller users do not have a cursor to control so center it.
        else
            x, y = TheSim:GetPosition()
            local w, h = TheSim:GetScreenSize()
            x = 2 * x / w - 1
            y = 2 * y / h - 1
        end
        return x, y
    end
end
