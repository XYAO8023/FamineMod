return function(Controls)
    local old = Controls.ShowStatusNumbers
    function Controls:ShowStatusNumbers(...)
        for k, v in pairs(self.status) do if v.num then v:Show() end end
        return old(...)
    end
    local old2 = Controls.HideStatusNumbers
    function Controls:HideStatusNumbers(...)
        for k, v in pairs(self.status) do if v.num then v:Hide() end end
        return old2(...)
    end
end
