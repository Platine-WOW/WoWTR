-- Çevrilmiş metinlerin Türkçe veri tabanı (ÇEVRİMİÇİ)
-- WoWTR_Quests eklentisi

TO_lang = "TR";
TO_date = "2023-05-26";

-- ÇEVRİMİÇİ çeviri tablosu
QTR_Tlumacz_Online = {
};

function pairsByKeys (t)
   local a = {}
   for n in pairs(t) do table.insert(a, n) end
   table.sort(a, function(a, b) return a > b end)
   local i = 0      -- iterator variable
   local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
         else return a[i], t[a[i]]
      end
   end
   return iter
end

-- /run TTest()
function TTest()
    print("|cff00ff00[WoWTR]|r 3 saniye geri sayım başladı. Mouse'u hedefin üzerine götür ve BEKLE...")
    
    C_Timer.After(3, function()
        print("--------------------------------------------------")
        
        -- 1. Mouse'un Tam Altındaki Nesneyi Bul (YENİ SİSTEM DÜZELTMESİ)
        local focus = nil
        if GetMouseFoci then
            local foci = GetMouseFoci() -- Mouse altındaki tüm çerçeveleri liste olarak alır
            if foci and foci[1] then
                focus = foci[1] -- En üstteki çerçeveyi al
            end
        end

        if focus then
            local focusName = focus:GetName() or "İsimsiz Frame ("..tostring(focus)..")"
            print("Mouse Altındaki Nesne (OWNER):", focusName)
            
            -- Eğer nesnenin bir .tooltip özelliği varsa (Bazı butonlarda olur)
            if focus.tooltip then print("  -> Nesnenin .tooltip özelliği var.") end
            -- Eğer nesnenin bir başlık metni varsa
            if focus.title then print("  -> Nesnenin .title özelliği var: ", focus.title) end
            
            -- DebugStack: Bu frame hangi dosyada oluşturulmuş? (İpucu verebilir)
            -- print("  -> Frame Türü:", focus:GetObjectType())
        else
            print("Mouse altında bir UI nesnesi yok (WorldFrame üzerinde).")
        end

        -- 2. Yaygın Tooltip'leri Kontrol Et (Hangisi Görünür?)
        local found = false
        local commonTooltips = {
            "GameTooltip", 
            "ShoppingTooltip1", 
            "ItemRefTooltip", 
            "ItemRefShoppingTooltip1",
            "SharedTooltip",             -- Yeni arayüzler
            "WorldMapTooltip",
            "SmallTextTooltip",
            "ElvUI_SpellBookTooltip",    -- ElvUI
            "ElvUI_ToolTip",
            "TinyTooltip",
            "VignetteTooltip",           -- Harita ikonları için
            "EmbeddedItemTooltip"        -- Bazı özel eşyalar için
        }

        for _, name in pairs(commonTooltips) do
            local f = _G[name]
            if f and f:IsVisible() then
                print("|cff00ff00--> AÇIK TOOLTIP BULUNDU:|r", name)
                found = true
                -- Eğer sahibi varsa onu da yaz
                if f.GetOwner and f:GetOwner() then
                     local ownerName = f:GetOwner():GetName() or tostring(f:GetOwner())
                     print("    -> Bu Tooltip'in Sahibi:", ownerName)
                end
            end
        end

        if not found then
            print("|cffff0000--> Hiçbir standart Tooltip görünür değil.|r Çok özel bir frame olabilir.")
        end
        print("--------------------------------------------------")
    end)
end
