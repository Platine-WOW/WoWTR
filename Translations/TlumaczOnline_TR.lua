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
                
                -- Tooltip içeriğini yazdır
                local numLines = f:NumLines()
                print("    -> Satır Sayısı:", numLines)
                
                -- ID Kontrolü (processingInfo)
                if f.processingInfo and f.processingInfo.tooltipData then
                    print("    -> Tooltip Data Found:")
                    if f.processingInfo.tooltipData.id then
                        print("       -> ID: ", f.processingInfo.tooltipData.id)
                    end
                    if f.processingInfo.tooltipData.type then
                        print("       -> Type: ", f.processingInfo.tooltipData.type)
                    end
                else
                    print("    -> processingInfo/tooltipData YOK (Nil)")
                end

                -- Owner Kontrolü (Widget ID var mı?)
                if f.GetOwner and f:GetOwner() then
                    local owner = f:GetOwner()
                    local ownerName = owner:GetName() or tostring(owner)
                    print("    -> Sahibi:", ownerName)
                    
                    -- Widget ID Kontrolü
                    if owner.widgetID then print("       -> Owner.widgetID: ", owner.widgetID) end
                    if owner.widgetSetID then print("       -> Owner.widgetSetID: ", owner.widgetSetID) end
                    if owner.GetID then print("       -> Owner:GetID(): ", owner:GetID()) end
                    
                    -- Debug: Tablodaki diğer potansiyel ID'leri dök
                    if type(owner) == "table" then
                         for k, v in pairs(owner) do
                             if (type(k) == "string") and (string.find(string.lower(k), "id")) and (type(v) == "number" or type(v) == "string") then
                                 print("       -> Bulunan Key ["..k.."]: ", v)
                             end
                         end
                    end
                end

                for i = 1, numLines do
                   local line = _G[name.."TextLeft"..i]
                   if not line and f["TextLeft"..i] then line = f["TextLeft"..i] end
                   
                   if line then
                      local text = line:GetText()
                      if text then
                         print("       ["..i.."]: " .. string.gsub(text, "|", "||")) -- Escape colors for visibility
                         if ST_UsunZbedneZnaki and StringHash then
                            local cleanText = ST_UsunZbedneZnaki(text)
                            local hash = StringHash(cleanText)
                            print("           -> Hash: " .. hash)
                         end
                      else
                         print("       ["..i.."]: <nil text>")
                      end
                   else
                      print("       ["..i.."]: <nil region>")
                   end
                end

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


function TTest2()
print("3 SN İÇİNDE İKONA GEL...") C_Timer.After(3,function() local t=GameTooltip if t:IsVisible() then print("--- TOOLTIP OKUNDU ---") for i=1,t:NumLines() do local L=_G[t:GetName().."TextLeft"..i] if L then print(i,L:GetText()) end end else print("Tooltip YOK") end end)
end

-- --Mouse ile üzerine geldiğin tooltip'ı bulma
-- -- Check if 12.0 protection is needed (optional, just to be safe)
-- local _, _, _, uiVersion = GetBuildInfo()
-- local is1200 = uiVersion and uiVersion >= 120000

-- local function HookTooltip(tooltip, name)
--     if not tooltip then return end
    
--     local function OnShow(self)
--         if is1200 and WOWTR_IsSafeToProcess and not WOWTR_IsSafeToProcess(self) then return end
        
--         local owner = self:GetOwner()
--         local ownerName = owner and owner:GetName() or tostring(owner)
        
--         -- Try to get text from standard Left1 region
--         local left1 = _G[self:GetName().."TextLeft1"] or self.TextLeft1
--         local text = left1 and (left1.GetText and left1:GetText() or "nil (no GetText)") or "nil (no region)"
        
--         print(string.format("|cff55ff55[WoWTR Debug]|r %s OnShow", name))
--         print(string.format("  Owner: |cff00ffff%s|r", ownerName))
--         print(string.format("  TextLeft1: |cffffaa00%s|r", text:gsub("|", "||"))) -- Escape pipes for display
        
--         -- If text is empty, maybe check TextRight1 or others?
--     end

--     tooltip:HookScript("OnShow", OnShow)
--     -- Also hook SetText if feasible, but OnShow is usually enough for "hover" detection
-- end

-- print("|cff00ff00WoWTR Debug Active. Hover over Settings options!|r")

-- HookTooltip(GameTooltip, "GameTooltip")
-- HookTooltip(EmbeddedItemTooltip, "EmbeddedItemTooltip")

-- -- SettingsTooltip might be the one used in the options menu
-- if SettingsTooltip then
--     HookTooltip(SettingsTooltip, "SettingsTooltip")
-- else
--     print("SettingsTooltip not found globally.")
-- end

-- -- Sometimes tips are shown via GameTooltip:SetOwner(frame, ...); GameTooltip:SetText(...) 
-- -- verify if specific hooks are needed.