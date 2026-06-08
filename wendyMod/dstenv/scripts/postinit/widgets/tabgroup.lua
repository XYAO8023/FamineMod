return function(TabGroup)
    local oldAddTab = TabGroup.AddTab
    function TabGroup:AddTab(name, atlas, icon_atlas, icon, imnorm, imselected, imhighlight, imalthighlight, imoverlay,
        highlightpos, onselect, ondeselect, collapsed, ...)
        icon_atlas = icon_atlas or (icon and GetInventoryItemAtlas(icon)) or
                         (name and GetInventoryItemAtlas(name .. ".tex"))
        return oldAddTab(self, name, atlas, icon_atlas, icon, imnorm, imselected, imhighlight, imalthighlight,
            imoverlay, highlightpos, onselect, ondeselect, collapsed, ...)
    end
end
