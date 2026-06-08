return function(PlayerController)
    local self = PlayerController
    function self:RemotePausePrediction()
    end
    function self:EnableMapControls(enabled)
        --FIXME
        if enabled == false and TheWorld.minimap.MiniMap:IsVisible() then ThePlayer.HUD.controls:ToggleMap() end
    end
    function self:IsControlPressed(control)
        return TheSim:GetDigitalControl(control)
    end
end
