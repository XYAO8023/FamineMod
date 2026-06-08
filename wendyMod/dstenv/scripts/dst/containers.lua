local params = {}
local containers = {
    MAXITEMSLOTS = 0
}
function containers.widgetsetup(container, prefab, data)
    local t = data or params[prefab or container.inst.prefab or ""]
    if not t then return end
    -- patched
    t.side_widget = t.side_widget or container.issidewidget
    -- end patched
    for k, v in pairs(t) do container[k] = v end
    container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    -- patched, transfer data format
    container.widgetslotpos = t.widget.slotpos
    -- do not support
    -- container.widgetbgimage = t.widget.slotbg and t.widget.slotbg[1] and t.widget.slotbg[1].image
    -- container.widgetbgatlas = t.widget.slotbg and t.widget.slotbg[1] and t.widget.slotbg[1].atlas
    container.widgetanimbank = t.widget.animbank
    container.widgetanimbuild = t.widget.animbuild
    container.side_align_tip = t.widget.side_align_tip
    container.side_widget = t.issidewidget
end
params.sisturn = {
    widget = {
        slotpos = {Vector3(-37.5, 32 + 4, 0), Vector3(37.5, 32 + 4, 0), Vector3(-37.5, -(32 + 4), 0),
                   Vector3(37.5, -(32 + 4), 0)},
        slotbg = {{
            image = "sisturn_slot_petals.tex",
            atlas = "images/sisturn_slot_petals.xml"
        }, {
            image = "sisturn_slot_petals.tex",
            atlas = "images/sisturn_slot_petals.xml"
        }, {
            image = "sisturn_slot_petals.tex",
            atlas = "images/sisturn_slot_petals.xml"
        }, {
            image = "sisturn_slot_petals.tex",
            atlas = "images/sisturn_slot_petals.xml"
        }},
        animbank = "ui_chest_2x2",
        animbuild = "ui_chest_2x2",
        pos = Vector3(200, 0, 0),
        side_align_tip = 120
    },
    acceptsstacks = false,
    type = "cooker"
}

function params.sisturn.itemtestfn(container, item, slot) return item.prefab == "petals" end

containers.params = params
for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end
return containers
