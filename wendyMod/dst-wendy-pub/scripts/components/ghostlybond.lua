local function setsummoned(self)
    if self.summoned then
        self.inst:AddTag("ghostfriend_summoned")
    else
        self.inst:RemoveTag("ghostfriend_summoned")
    end
end

local function setnotsummoned(self)
    if self.notsummoned then
        self.inst:AddTag("ghostfriend_notsummoned")
    else
        self.inst:RemoveTag("ghostfriend_notsummoned")
    end
end

local function _ghost_onremove(self)
    -- self:SpawnGhost()--patched because remove when despawn
    if not self._spawn_ghost_task then
        self._spawn_ghost_task = self.inst:DoTaskInTime(0, function() self:SpawnGhost() end)
    end
end

local function _ghost_death(self)
    self:SetBondLevel(1)
    self:Recall(true)
end

local GhostlyBond = Class(function(self, inst)
    self.inst = inst
    self.ghost = nil
    self.ghost_prefab = nil

    self.bondleveltimer = nil
    self.bondlevelmaxtime = nil
    self.paused = false

    self.bondlevel = 1
    self.maxbondlevel = 3

    self._ghost_onremove = function(ghost) _ghost_onremove(self) end
    self._ghost_death = function(ghost) _ghost_death(self, ghost) end

    self.externalbondtimemultipliers = SourceModifierList(self.inst)

    inst:StartUpdatingComponent(self)
end, nil, {
    notsummoned = setnotsummoned,
    summoned = setsummoned
})

function GhostlyBond:OnRemoveEntity()
    self.summoned = false
    self.notsummoned = false

    -- hack to remove ghosts when spawned due to session state reconstruction for autosave snapshots
    if self.ghost ~= nil and self.ghost.spawntime == GetTime() then
        self.inst:RemoveEventCallback("onremove", self._ghost_onremove, self.ghost)
        self.ghost:Remove()
    end
end

function GhostlyBond:OnSave()
    local time_remaining = self.bondleveltask ~= nil and GetTaskRemaining(self.bondleveltask) or nil

    local ret = {
        bondlevel = self.bondlevel,
        elapsedtime = self.bondleveltimer,

        ghost_prefab = self.ghost and self.ghost.prefab or self.ghost_prefab,
        ghost = self.ghost and self.ghost:GetSaveRecord(),
        ghostinlimbo = self.ghost and self.ghost.inlimbo or self.ghostinlimbo
    }
    return ret
end

function GhostlyBond:OnLoad(data)
    if data ~= nil then
        self:SetBondLevel(data.bondlevel, data.elapsedtime, true)
        self.ghostdata = data
        self.ghostinlimbo = data.ghostinlimbo
        self.ghost_prefab = data.ghost_prefab or (data.ghost and data.ghost.prefab)
    end
end
function GhostlyBond:InitSpawnedGhost(ghost)
    self.ghost = ghost
    ghost:LinkToPlayer(self.inst)
    self.inst:ListenForEvent("onremove", self._ghost_onremove, ghost)
    self.inst:ListenForEvent("death", self._ghost_death, ghost)

    if self.ghostinlimbo == true then
        self:RecallComplete()
    elseif self.ghostinlimbo == false then
        self:SummonComplete()
    end
    self.ghostdata = nil
    self.ghostinlimbo = nil
end
function GhostlyBond:LoadPostPass(newents, data, spawnnew)
    if self.ghost then return end
    if not data then
        if spawnnew then self:SpawnGhost() end
        return
    end
    -- here to get my abigail back
    if self.inst.components.leader then
        for ghost, v in pairs(self.inst.components.leader.followers) do
            if ghost.prefab == data.ghost_prefab and not self.ghost then
                if self.spawnghosttask ~= nil then
                    self.spawnghosttask:Cancel()
                    self.spawnghosttask = nil
                end
                self:InitSpawnedGhost(ghost)
                break
            end
        end
    end
    if self.ghost then return end
    if spawnnew then self:SpawnFromData(data) end
end
function GhostlyBond:SpawnFromData(data)
    if not data or not data.ghost then return self:SpawnGhost() end
    local ghost = SpawnSaveRecord(data.ghost)
    self:InitSpawnedGhost(ghost)
end
-------------------------------------------------------------------------------

function GhostlyBond:OnUpdate(dt)
    if self.bondleveltimer == nil or self.pause then
        self.inst:StopUpdatingComponent(self)
        return
    end

    self.bondleveltimer = self.bondleveltimer + (dt * self.externalbondtimemultipliers:Get())
    if self.bondleveltimer >= self.bondlevelmaxtime then
        self:SetBondLevel(self.bondlevel + 1, self.bondleveltimer - self.bondlevelmaxtime)
    end
end

function GhostlyBond:LongUpdate(dt) self:OnUpdate(dt) end

function GhostlyBond:SetBondTimeMultiplier(src, mult, key) self.externalbondtimemultipliers:SetModifier(src, mult, key) end

function GhostlyBond:ResumeBonding()
    self.pause = false
    if self.bondleveltimer ~= nil then self.inst:StartUpdatingComponent(self) end
end

function GhostlyBond:PauseBonding()
    self.pause = true
    self.inst:StopUpdatingComponent(self)
end

function GhostlyBond:SetBondLevel(level, time, isloading)
    time = time or 0
    local prev_level = self.bondlevel
    self.bondlevel = math.min(level, self.maxbondlevel)
    self.bondleveltimer = level < self.maxbondlevel and time or nil
    if self.bondleveltimer ~= nil and not self.paused then self.inst:StartUpdatingComponent(self) end
    if self.bondlevel ~= prev_level then
        if self.onbondlevelchangefn ~= nil then
            self.onbondlevelchangefn(self.inst, self.ghost, level, prev_level, isloading)
        end
        self.inst:PushEvent("ghostlybond_level_change", {
            ghost = self.ghost,
            level = level,
            prev_level = prev_level,
            isloading = isloading
        })
    end
end

function GhostlyBond:Init(ghost_prefab, bond_levelup_time)
    self.bondleveltimer = 0
    self.bondlevelmaxtime = bond_levelup_time
    self.ghost_prefab = ghost_prefab

    self.spawnghosttask = self.inst:DoTaskInTime(0, function() self:LoadPostPass(Ents, self.ghostdata, true) end)
end

function GhostlyBond:SpawnGhost()
    local ghost = SpawnPrefab(self.ghost_prefab)
    self.ghost = ghost
    ghost:LinkToPlayer(self.inst)

    self.inst:ListenForEvent("onremove", self._ghost_onremove, ghost)
    self.inst:ListenForEvent("death", self._ghost_death, ghost)

    self:SetBondLevel(1)
    self:RecallComplete()
end

function GhostlyBond:Summon(summoningitem)
    if self.ghost ~= nil and self.notsummoned then
        self.ghost.entity:SetParent(nil)
        self.ghost.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
        self.ghost:ReturnToScene()

        TheSim:ReskinEntity(self.ghost.GUID, self.ghost.skinname, summoningitem.linked_skinname, summoningitem.skin_id)
        self.inst.components.pethealthbar:SetPetSkin(summoningitem.linked_skinname)

        self.notsummoned = false

        if self.onsummonfn ~= nil then self.onsummonfn(self.inst, self.ghost) end

        return true
    end

    return false
end

function GhostlyBond:SummonComplete()
    self.notsummoned = false
    self.summoned = true

    if self.onsummoncompletefn ~= nil then self.onsummoncompletefn(self.inst, self.ghost) end
end

function GhostlyBond:Recall(was_killed)
    if self.ghost ~= nil and self.summoned and not self.inst.sg:HasStateTag("dissipate") then
        self.summoned = false

        if self.onrecallfn ~= nil then self.onrecallfn(self.inst, self.ghost, was_killed) end

        return true
    end
end

function GhostlyBond:RecallComplete()
    self.ghost:RemoveFromScene()
    self.ghost.entity:SetParent(self.inst.entity)
    self.ghost.Transform:SetPosition(0, 0, 0)

    self.summoned = false
    self.notsummoned = true

    if self.onrecallcompletefn ~= nil then self.onrecallcompletefn(self.inst, self.ghost) end
end

function GhostlyBond:ChangeBehaviour()
    if self.ghost ~= nil and self.summoned and self.changebehaviourfn ~= nil then
        return self.changebehaviourfn(self.inst, self.ghost)
    end
    return false
end

function GhostlyBond:GetDebugString()
    return tostring(self.ghost) .. ", " .. tostring(self.bondlevel) ..
               (self.bondleveltimer ~= nil and
                   (", " .. string.format("%0.2f", self.bondlevelmaxtime - self.bondleveltimer)) or "max") .. ", mult: " ..
               string.format("%0.2f", self.externalbondtimemultipliers:Get()) .. (self.paused and ", paused" or "")
end

return GhostlyBond
