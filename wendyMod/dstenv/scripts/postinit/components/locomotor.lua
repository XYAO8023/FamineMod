return function(LocoMotor)
    local self = LocoMotor
    self._externalspeedmultipliers = {}
    self.externalspeedmultiplier = 1
    function LocoMotor:RecalculateExternalSpeedMultiplier(sources)
        local m = 1
        for source, src_params in pairs(sources) do
            for k, v in pairs(src_params.multipliers) do
                m = m * v
            end
        end
        return m
    end
    function LocoMotor:SetExternalSpeedMultiplier(source, key, m)
        if key == nil then
            return
        elseif m == nil or m == 1 then
            self:RemoveExternalSpeedMultiplier(source, key)
            return
        end
        local src_params = self._externalspeedmultipliers[source]
        if src_params == nil then
            self._externalspeedmultipliers[source] = {
                multipliers = {
                    [key] = m
                },
                onremove = function(source)
                    self._externalspeedmultipliers[source] = nil
                    self.externalspeedmultiplier = self:RecalculateExternalSpeedMultiplier(
                        self._externalspeedmultipliers)
                end
            }
            self.inst:ListenForEvent("onremove", self._externalspeedmultipliers[source].onremove, source)
            self.externalspeedmultiplier = self:RecalculateExternalSpeedMultiplier(self._externalspeedmultipliers)
        elseif src_params.multipliers[key] ~= m then
            src_params.multipliers[key] = m
            self.externalspeedmultiplier = self:RecalculateExternalSpeedMultiplier(self._externalspeedmultipliers)
        end
    end

    -- key is optional if you want to remove the entire source
    function LocoMotor:RemoveExternalSpeedMultiplier(source, key)
        local src_params = self._externalspeedmultipliers[source]
        if src_params == nil then
            return
        elseif key ~= nil then
            src_params.multipliers[key] = nil
            if next(src_params.multipliers) ~= nil then
                -- this source still has other keys
                self.externalspeedmultiplier = self:RecalculateExternalSpeedMultiplier(self._externalspeedmultipliers)
                return
            end
        end
        -- remove the entire source
        self.inst:RemoveEventCallback("onremove", src_params.onremove, source)
        self._externalspeedmultipliers[source] = nil
        self.externalspeedmultiplier = self:RecalculateExternalSpeedMultiplier(self._externalspeedmultipliers)
    end

    -- key is optional if you want to calculate the entire source
    function LocoMotor:GetExternalSpeedMultiplier(source, key)
        local src_params = self._externalspeedmultipliers[source]
        if src_params == nil then
            return 1
        elseif key == nil then
            local m = 1
            for k, v in pairs(src_params.multipliers) do
                m = m * v
            end
            return m
        end
        return src_params.multipliers[key] or 1
    end

    local old = self.GetSpeedMultiplier
    function self:GetSpeedMultiplier()
        local speed = old(self)
        return speed * self.externalspeedmultiplier
    end
end
