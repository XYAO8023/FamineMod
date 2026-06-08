return function(Image)
    if Image.ScaleToSize then return end
    function Image:ScaleToSize(w, h)
        local w0, h0 = self.inst.ImageWidget:GetSize()
        local scalex = w / w0
        local scaley = h / h0
        self:SetScale(scalex, scaley, 1)
    end

    local oldSetTexture = Image.SetTexture
    function Image:SetTexture(atlas, image)
        if not atlas or not image then
            print("Image:SetTexture failed at", atlas or "nil", image or "nil")
            return
        end
        -- if not resolvefilepath(atlas) then return end
        return oldSetTexture(self, atlas, image)
    end

end
