return function(MapWidget)
    function MapWidget:WorldPosToMapPos(x,y,z)
        return self.minimap:WorldPosToMapPos(x,y,z)
    end

    function MapWidget:MapPosToWorldPos(x,y,z)
        return self.minimap:MapPosToWorldPos(x,y,z)
    end
end