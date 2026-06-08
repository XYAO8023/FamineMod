return function(UIAnim)
    if UIAnim.SetFacing then return end
    function UIAnim:SetFacing(dir)
        -- self.inst.UITransform:SetFacing(dir)--#FIXME:??? no this function?
    end
end
