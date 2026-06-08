if nethash then return end
local NetVar = {}
local hashval = {}
function NetVar:value()
    return self.val
end
function NetVar:set(v)
    if type(v) ~= self.type then print("error: invalid type", self.type, v) end
    local oldval = self.val
    self.val = v
    if self.localval ~= nil then
        self:push()
        self.localval = nil
    elseif v ~= oldval then
        self:push()
    end
end
function NetVar:set_local(v)
    if type(v) ~= self.type then print("error: invalid type", self.type, v) end
    self.localval = v
    self.val = v
end
function NetVar:push()
    if self.event then
        local inst = Ents[self.guid]
        if inst then
            inst:DoTaskInTime(0, function(inst)
                self:push_inner(inst)
            end)
        end
    end
end
function NetVar:push_inner(inst)
    if inst:IsValid() then inst:PushEvent(self.event) end
end
local netvar = function(default)
    return function(guid, name, event)
        local newvar = {
            type = default ~= nil and type(default) or "table",
            guid = guid,
            name = name,
            event = event or name, -- for net_event patch this, perhaps should make a standalone netvar
            val = default,
            localval = nil
        }
        setmetatable(newvar, {__index = NetVar})
        local ret = (newvar)
        return ret
    end
end
local nethash = function(guid, name, event)
    local newvar = {type = "number", guid = guid, name = name, event = event, val = 0, localval = nil}
    function newvar:set(v)
        local h = type(v) == "string" and hash(v) or v
        hashval[h] = v
        return NetVar.set(self, h)
    end
    setmetatable(newvar, {__index = NetVar})
    local ret = (newvar)
    return ret
end
-- the values are of weak type compared to DST
expose {
    net_bool = netvar(false),
    net_tinybyte = netvar(0),
    net_smallbyte = netvar(0),
    net_byte = netvar(0),
    net_shortint = netvar(0),
    net_ushortint = netvar(0),
    net_uint = netvar(0),
    net_int = netvar(0),
    net_float = netvar(0),
    net_hash = nethash,
    net_string = netvar(""),
    net_entity = netvar(),
    net_bytearray = netvar({}),
    net_smallbytearray = netvar({}),
    net_event = netvar(false),
    net_reversehash = function(h)
        return hashval[h]
    end -- because DS Animation Manager doesn't support hash value index, all the relevant hash values must be converted back, and I think it is best to maintain the type instead of the value. So the consequence is that you need to change all "self.a=net_hash()"&"self.inst.AnimState:xxx(self.a)" pairs to "self.AnimState:xxx(net_reversehash(self.a))". If the function is not c/c++ level one it is likely to work as intended.
}
