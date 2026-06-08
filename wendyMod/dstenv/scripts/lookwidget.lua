local Text = require "widgets/text"
local Widget = require "widgets/widget"
require("constants")
local YOFFS = -100
local YOFFSETUP = -100
local YOFFSETDOWN = 100
local XOFFSET = 0

local HoverText = Class(Widget, function(self, owner)
    Widget._ctor(self, "LookWidget")
    self.owner = owner
    self.isFE = false
    self:SetClickable(false)
    -- self:MakeNonClickable()
    self.text = self:AddChild(Text(UIFONT, 30))
    self.text:SetPosition(0, YOFFS, 0)
    self.secondarytext = self:AddChild(Text(UIFONT, 30))
    self.secondarytext:SetPosition(0, -YOFFSETDOWN, 0)
    self:FollowMouseConstrained()
    self:StartUpdating()
    TheInput:AddControlHandler(CONTROL_SECONDARY, function(s, down)
        if not down then
            self:DisableDrag()
        else
            self:EnableDrag()
        end
    end)
end)

function HoverText:OnUpdate()
    if not self.shown then return end

    local str = nil
    local secondarystr = nil
    local colour = nil
    --[[
    if self.isFE == false then
        str = self.owner.HUD.controls:GetTooltip() or self.owner.components.playercontroller:GetHoverTextOverride()
        if self.owner.HUD.controls:GetTooltip() then
            colour = self.owner.HUD.controls:GetTooltipColour()
        end
    else
        str = self.owner:GetTooltip()
    end


    if not str and self.isFE == false then
        local lmb = self.owner.components.playercontroller:GetLeftMouseAction()
        if lmb then

            str = lmb:GetActionString()

            if not colour and lmb.target then
                colour = (lmb.target and lmb.target:GetIsWet()) and WET_TEXT_COLOUR or NORMAL_TEXT_COLOUR
                if lmb.invobject and not (lmb.invobject.components.weapon or lmb.invobject.components.tool) then
                    colour = (lmb.invobject and lmb.invobject:GetIsWet()) and WET_TEXT_COLOUR or NORMAL_TEXT_COLOUR
                end
            elseif not colour and lmb.invobject then
                colour = (lmb.invobject and lmb.invobject:GetIsWet()) and WET_TEXT_COLOUR or NORMAL_TEXT_COLOUR
            end

            if lmb.target and lmb.invobject == nil and lmb.target ~= lmb.doer then
                local name = lmb.target:GetDisplayName() or
                    (lmb.target.components.named and lb.target.components.named.name)
                if name then

                    -- fixes a crash where a table can sneak in here. If it does, we just use the first entry
                    if type(name) == "table" then
                        local newname = nil
                        for code, text in pairs(name) do
                            print(code, text)
                            newname = text
                            break
                        end
                        name = newname
                    end

                    local adjective = lmb.target:GetAdjective()

                    if adjective then
                        str = str .. " " .. adjective .. " " .. name
                    elseif not lmb.action.blanktarget or not lmb.action.blanktarget(lmb) then
                        str = str .. " " .. name
                    else
                        str = str
                    end

                    if lmb.target.components.stackable and lmb.target.components.stackable.stacksize > 1 then
                        str = str .. " x" .. tostring(lmb.target.components.stackable.stacksize)
                    end
                    if lmb.target.components.inspectable and lmb.target.components.inspectable.recordview and
                        lmb.target.prefab then
                        ProfileStatsSet(lmb.target.prefab .. "_seen", true)
                    end
                end
            end
        end
        local rmb = self.owner.components.playercontroller:GetRightMouseAction()
        if rmb then
            secondarystr = STRINGS.RMB .. ": " .. rmb:GetActionString()
        end
    end
    ]]
    str = lookparser.full()

    if not colour then colour = NORMAL_TEXT_COLOUR end
    if str then
        self.text:SetColour(colour[1], colour[2], colour[3], colour[4])
        self.text:SetString(str)
        self.text:Show()
    else
        self.text:SetColour(colour[1], colour[2], colour[3], colour[4])
        self.text:Hide()
    end
    if secondarystr then
        YOFFSETUP = -80
        YOFFSETDOWN = -50
        self.secondarytext:SetString(secondarystr)
        self.secondarytext:Show()
    else
        self.secondarytext:Hide()
    end

    local changed = (self.str ~= str) or (self.secondarystr ~= secondarystr)
    self.str = str
    self.secondarystr = secondarystr
    if changed then
        local pos = TheInput:GetScreenPosition()
        self:UpdatePosition(pos.x, pos.y)
    end
end

function HoverText:UpdatePosition(x, y)

    local scale = self:GetScale()

    local scr_w, scr_h = TheSim:GetScreenSize()

    local w = 0
    local h = 0

    if self.text and self.str then
        local w0, h0 = self.text:GetRegionSize()
        w = math.max(w, w0)
        h = math.max(h, h0)
    end
    if self.secondarytext and self.secondarystr then
        local w1, h1 = self.secondarytext:GetRegionSize()
        w = math.max(w, w1)
        h = math.max(h, h1)
    end

    w = w * scale.x
    h = h * scale.y

    x = math.max(x, w / 2 + XOFFSET)
    x = math.min(x, scr_w - w / 2 - XOFFSET)

    y = math.max(y, h / 2 + YOFFSETDOWN * scale.y)
    y = math.min(y, scr_h - h / 2 - YOFFSETUP * scale.x)

    self:SetPosition(x, y, 0)
end

function HoverText:FollowMouseConstrained()
    if not self.followhandler then
        self.followhandler = TheInput:AddMoveHandler(function(x, y)
            self:UpdatePosition(x, y)
        end)
        local pos = TheInput:GetScreenPosition()
        self:UpdatePosition(pos.x, pos.y)
    end
end
--[[
    mouse=0left|1right,
    type param=0start|1change|2stop
    ]]
function HoverText:AddDragHandler(_self, startfn, changefn, stopfn)
    if not _self.pos then _self.pos = _self:GetPosition() end
    if not _self.draghandlers then
        _self.draghandlers = {start = {}, change = {}, stop = {}}
        local old = _self.OnMouseButton
        local new = function(inst, button, down, x, y)
            if _self.disabledrag then return end
            if down then
                _self.dragging = true
                _self.startpos = _self.startpos or TheInput:GetScreenPosition()
                for i, v in ipairs(_self.draghandlers.start) do v(inst, button, down, x, y, 0) end
            else
                _self.dragging = false
                for i, v in ipairs(_self.draghandlers.stop) do v(inst, button, down, x, y, 2) end
                _self.pos = _self:GetPosition()
                _self.startpos = nil
            end
        end
        local function MakeWrapper(oldfn, fn)
            if not oldfn then return fn end
            return function(...)
                fn(...)
                return oldfn(...)
            end
        end
        _self.OnMouseButton = MakeWrapper(old, new)
        _self.followhandler = TheInput:AddMoveHandler(function(x, y)
            if not _self.dragging then return end
            if _self.disabledrag then
                _self.dragging = false
                return
            end
            local pos = x
            if type(x) == "number" then pos = Vector3(x, y, 0) end
            _self.dragpos = pos
            for i, v in ipairs(_self.draghandlers.change) do v(_self, pos, 1) end
        end)
    end
    if startfn then table.insert(_self.draghandlers.start, startfn) end
    if changefn then table.insert(_self.draghandlers.change, changefn) end
    if stopfn then table.insert(_self.draghandlers.stop, stopfn) end
end
function HoverText:EnableDrag()
    local inst = TheInput.hoverinst or TheInput:GetHUDEntityUnderMouse()
    local w = inst and inst.widget
    if w then
        if not w.draghandlers then
            self:AddDragHandler(w, function(s)
                s.originalpos = s:GetPosition()
            end, function(s, pos)
                local sc = s.parent and s.parent:GetScale() or Vector3(1, 1, 1)
                local sx, sy = sc.x, sc.y
                local ps = pos - s.startpos
                local px, py = ps.x, ps.y
                local ox, oy = sx * px, sy * py
                s:SetPosition(Vector3(ox, oy, 0) + s.originalpos)
            end)
        end
        w.disabledrag = false
        self.dragtarget = w
    end
end
function HoverText:DisableDrag()
    if self.dragtarget then
        self.dragtarget.disabledrag = true
        self.dragtarget = nil
    end
end

return HoverText
