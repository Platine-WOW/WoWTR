-- Description: The AddOn displays the translated text information in chosen language
-- Author: Platine [platine.wow@gmail.com]
-- Co-Author: Dragonarab[WoWAR], Hakan YILMAZ[WoWTR]
-------------------------------------------------------------------------------------------------------

-- Local Variables
local _G = _G;
local ST_miasto = "";      -- miejsce powrotu przedmiotu Heartstone
local ST_GameGossip_Show = false;
local ST_width2 = math.floor(UIParent:GetWidth() / 2 + 0.5);
local ST_height2 = math.floor(UIParent:GetHeight() / 2 + 0.5);
local ST_lastNumLines = 0;
local ST_load1 = false;
local ST_load2 = false;
local ST_load3 = false;
local ST_load4 = false;
local ST_load5 = false;
local ST_load6 = false;
local ST_load7 = false;
local ST_load8 = false;
local ST_load9 = false;
local ST_load10 = false;
local ST_load11 = false;
local ST_firstBoss = true;
local ST_nameBoss = { };
local ST_navBar1, ST_navBar2, ST_navBar3, ST_navBar4, ST_navBar5 = false;

------------------------------------------------------------------------------------

--The plugin name and version number temporarily appear at the bottom left of the Chat Panel. WOWTR_Font1 and WOWTR_Font2 are triggered.
local firstloginframe = CreateFrame("Frame", nil, UIParent);
firstloginframe:SetSize(100, 50);
firstloginframe:SetPoint("BOTTOMLEFT", 12, 5);
local addonlogintext = firstloginframe:CreateFontString(nil, "OVERLAY", "GameFontNormal");
--local a1, a2, a3 = addonlogintext:GetFont();
addonlogintext:SetPoint("LEFT");
addonlogintext:SetText(WoWTR_Localization.addonName);
addonlogintext:SetTextColor(1, 1, 1, 0.1);
addonlogintext:SetFont(WOWTR_Font1, 20);
local addonlogintext2 = firstloginframe:CreateFontString(nil, "OVERLAY", "GameFontNormal");
--local a1, a2, a3 = addonlogintext2:GetFont();
addonlogintext2:SetPoint("LEFT", 0, -15);
addonlogintext2:SetText("ver. "..WOWTR_version);
addonlogintext2:SetTextColor(1, 1, 1, 0.1);
addonlogintext2:SetFont(WOWTR_Font2, 15);
local function OnLogin()
   firstloginframe:Show();
   C_Timer.After(15, function() firstloginframe:Hide() end);
end
firstloginframe:RegisterEvent("PLAYER_LOGIN");
firstloginframe:SetScript("OnEvent", OnLogin);

-------------------------------------------------------------------------------------------------------

function ST_UsunZbedneZnaki(txt)          -- przed obliczeniem kodu Hash
   if (not txt) then return ""; end
   text = string.gsub(txt,"|cFFFFFFFF","");
   text = string.gsub(text,"|r","");
   text = string.gsub(text,"\r","");
   text = string.gsub(text,"\n","");
   text = string.gsub(text,'%f[%a]'..WOWTR_player_name..'%f[%A]',"$N");
   text = string.gsub(text,"(%d),(%d)","%1%2");      -- usuń przecinek między cyframi (odstęp tysięczny)
   text = string.gsub(text,"0","");
   text = string.gsub(text,"1","");
   text = string.gsub(text,"2","");
   text = string.gsub(text,"3","");
   text = string.gsub(text,"4","");
   text = string.gsub(text,"5","");
   text = string.gsub(text,"6","");
   text = string.gsub(text,"7","");
   text = string.gsub(text,"8","");
   text = string.gsub(text,"9","");
   return text;
end

-------------------------------------------------------------------------------------------------------

function ST_PrzedZapisem(txt)
   local text = string.gsub(txt,"(%d),(%d)","%1%2");      -- usuń przecinek między cyframi (odstęp tysięczny)
   text = string.gsub(text,"\r","");
   text = string.gsub(text,'%f[%a]'..WOWTR_player_name..'%f[%A]',"$N");
   return text;
end

-------------------------------------------------------------------------------------------------------

function ST_RenkKoduSil(txt)
   if (not txt) then return ""; end
   local text = string.gsub(txt,"|r","");
   text = string.gsub(text,"Dragon Isles ","");
   text = string.gsub(text," Specializations","");
   text = string.gsub(text,"Classic ","");
   text = string.gsub(text,"|cffffd100","");
   text = string.gsub(text,"|cff0070dd","");
   text = string.gsub(text,"|cffffffff","");
   text = string.gsub(text,"|cff1eff00","");
   text = string.gsub(text,"|cffa335ee","");
   text = string.gsub(text,"|cffffd200","");
   return text;
end

-------------------------------------------------------------------------------------------------------

local ignoreSettings = {
    words = {
        "Seller: ",
        "Sellers: ",
        "Equipment Sets: ",
        "|cff00ff00<Made ",
        "Leader: ",
        "Realm: ",
        "Waiting on: ",
        "Reagents: |n",
        "  |A:raceicon",
        "Achievement in progress by",
        "Achievement earned by",
        "You completed this on ",
        "AllTheThings",
        "|cffb4b4ffATT|r",
        "|cff0070dd",
        "|Hachievement:",
        "  |T",
        "   |c",
        "|A:groupfinder-icon",
        "|TInterface\\FriendsFrame\\UI-FriendsFrame-Note:",
        "|cff00ff00+1|r",
        "Dependencies: ",
        "|TInterface\\ICONS\\Ability_Hunter_SurvivalInstincts.blp|t ",
        "|TInterface\\ICONS\\INV_Eng_BombFire.BLP:20|t ",
        "|TInterface\\ICONS\\Spell_Frost_FrozenCore.blp:20|t ",
        "|TInterface\\ICONS\\Spell_Shadow_SoulGem.blp:20|t ",
        "|cFFC0C0C0%[",
        "|cFF40C040%[",
        "|cFFFFFF00%[",
        "|cFFFF8040%[",
        "|cFFFF1A1A%[",
        "Requires ",
        "Classes: "
    },
    pattern = "[Яа-яĄ-Źą-źŻ-żЀ-ӿΑ-Ωα-ω]"
}

local function shouldIgnore(text)
    for _, pattern in ipairs(ignoreSettings.words) do
        if text:match("^" .. pattern) then  -- Başlangıç kontrolü için ^ eklendi
            return true
        end
    end
    if text:match(ignoreSettings.pattern) then
        return true
    end
    return false
end

-- ST_CheckAndReplaceTranslationText(obj, sav, prefix, font1, onlyReverse, ST_corr)
function ST_CheckAndReplaceTranslationText(obj, sav, prefix, font1, onlyReverse, ST_corr)
   if (obj and obj.GetText) then
      local txt = obj:GetText();
      if (txt and string.find(txt," ") == nil and not shouldIgnore(txt)) then
         local ST_Hash = StringHash(ST_UsunZbedneZnaki(txt));
         
         if (ST_TooltipsHS[ST_Hash]) then
            local ST_tlumaczenie = ST_TooltipsHS[ST_Hash];
            ST_tlumaczenie = ST_TranslatePrepare(txt, ST_tlumaczenie);
            if not ST_corr then
               ST_corr = 0;
            end
            if (onlyReverse) then
               obj:SetText(QTR_ReverseIfAR(ST_tlumaczenie).." ");
            else
               obj:SetText(QTR_ExpandUnitInfo(ST_tlumaczenie,false,obj,WOWTR_Font2,ST_corr).." ");
            end
            -- Don't try to set font if the object doesn't support it
            if obj.SetFont then
               obj:SetFont(WOWTR_Font2, select(2, obj:GetFont()));
            end
            return
         else
            -- >>> Modified Part: No translation => revert to object's original font <<<
            if obj.SetFont then
               local originalFont, originalSize, originalFlags = obj:GetFont();
               obj:SetFont(originalFont, originalSize, originalFlags);
            end
            -- Save only if we don't have a translation and saving is enabled
            if (sav and (ST_PM["saveNW"]=="1")) then
               ST_PH[ST_Hash] = prefix.."@"..ST_PrzedZapisem(txt);
            end
         end
      end
   end
end


-------------------------------------------------------------------------------------------------------
-- obj=object with stingtext,  sav=permission to save untranstaled tekst (true/false)
-- prefix=text to save group,  font1=if present:SetFont to given font file
-- Font Files: WOWTR_Font1, Original_Font1, Original_Font2
-- ST_CheckAndReplaceTranslationTextUI(obj, sav, prefix, font1)

function ST_CheckAndReplaceTranslationTextUI(obj, sav, prefix, font1)
   if (obj and obj.GetText) then
       local txt = obj:GetText();
       if (txt and string.find(txt, " ") == nil and not shouldIgnore(txt)) then
           local ST_Hash = StringHash(ST_UsunZbedneZnaki(txt));
           local destroyText = "Do you want to destroy";
           local deleteText = "DELETE";

           if (string.sub(txt, 1, #destroyText) == destroyText) then
               if (string.find(txt, deleteText)) then
                   ST_Hash = 2437810493;
               else
                   ST_Hash = 219524473;
               end
           end
           
           if (ST_TooltipsHS[ST_Hash]) then
               local a1, a2, a3 = obj:GetFont();
               local new_trans = ST_TooltipsHS[ST_Hash];
               if ((ST_Hash == 2437810493) or (ST_Hash == 219524473)) then
                   local pos_end = string.find(txt, "?");
                   if (pos_end) then
                       local new_item = string.sub(txt, #destroyText + 2, pos_end - 1);
                       new_trans = string.gsub(new_trans, "$I", new_item);
                   end
               end
               obj:SetText(QTR_ReverseIfAR(ST_TranslatePrepare(txt, new_trans)).." ");
               if (font1) then
                   obj:SetFont(font1, a2);
               else
                   obj:SetFont(WOWTR_Font2, a2);
               end

           elseif (sav and (TT_PS["saveui"] == "1")) then
               ST_PH[ST_Hash] = prefix.."@"..ST_PrzedZapisem(txt);

           else
               -- >>> Modified Part: No translation => revert to object's original font <<<
               if obj.SetFont then
                  local originalFont, originalSize, originalFlags = obj:GetFont();
                  obj:SetFont(originalFont, originalSize, originalFlags);
               end
           end
       end
   end
end

-------------------------------------------------------------------------------------------------------

-- Przygotowuje tłumaczenie właściwe: zamienia $x w tłumaczeniu na odpowiednie liczby z oryginału
function ST_TranslatePrepare(ST_origin, ST_tlumacz)
   local tlumaczenie = WOW_ZmienKody(ST_tlumacz);
   if (not ST_miasto) then
      ST_miasto = WoWTR_Localization.your_home;
   end
   tlumaczenie = string.gsub(tlumaczenie, "$L", QTR_ReverseIfAR(ST_miasto));    -- miasto lokalizacji do Kamienia Powrotu
   local wartab = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};         -- max. 20 liczb całkowitych w tekście
   local arg0 = 0;
   ST_origin = string.gsub(ST_origin,"(%d),(%d)","%1%2");            -- usuń przecinek tysięczny przy liczbach
   for w in string.gmatch(ST_origin, "%d+") do
      arg0 = arg0 + 1;                                               -- formatowanie do postaci: 99.123.456
      if (WoWTR_Localization.lang == 'TR') then
         wartab[arg0] = w:gsub("(%d+)", function(num)
           if #num > 1 and num:sub(1,1) == "0" then
            return num
           else
            return tonumber(num)
           end
         end)
      elseif (WoWTR_Localization.lang == 'JP') then                      -- formatowanie do postaci: 99,123,456 (JP)
         if (math.floor(w)>999999) then
            wartab[arg0] = tostring(math.floor(w)):reverse():gsub("(%d%d%d)(%d%d%d)", "%1,%2,"):gsub("(%-?)$", "%1"):reverse();   -- tu mamy kolejne cyfry z oryginału
         elseif (math.floor(w)>99999) then
            wartab[arg0] = tostring(math.floor(w)):reverse():gsub("(%d%d%d)(%d%d%d)", "%1,%2"):gsub("(%-?)$", "%1"):reverse();    -- tu mamy kolejne cyfry z oryginału
         elseif (math.floor(w)>999) then
            wartab[arg0] = tostring(math.floor(w)):reverse():gsub("(%d%d%d)", "%1,"):gsub("(%-?)$", "%1"):reverse();   -- tu mamy kolejne cyfry z oryginału
         else   
            wartab[arg0] = tostring(math.floor(w));
         end
      else                                                           -- formatowanie do postaci: 99.123.456 (Europe)
         if (math.floor(w)>999999) then
            wartab[arg0] = tostring(math.floor(w)):reverse():gsub("(%d%d%d)(%d%d%d)", "%1.%2."):gsub("(%-?)$", "%1"):reverse();   -- tu mamy kolejne cyfry z oryginału
         elseif (math.floor(w)>99999) then
            wartab[arg0] = tostring(math.floor(w)):reverse():gsub("(%d%d%d)(%d%d%d)", "%1.%2"):gsub("(%-?)$", "%1"):reverse();   -- tu mamy kolejne cyfry z oryginału
         elseif (math.floor(w)>999) then
            wartab[arg0] = tostring(math.floor(w)):reverse():gsub("(%d%d%d)", "%1."):gsub("(%-?)$", "%1"):reverse();   -- tu mamy kolejne cyfry z oryginału
         else   
            wartab[arg0] = tostring(math.floor(w));
         end
      end
   end;
   if (WoWTR_Localization.lang == 'TR') then
      for i = 40, 1, -1 do
        local pattern = string.format("{%02d}", i)
        local dollarPattern = "$" .. i
        if arg0 >= i then
          tlumaczenie = string.gsub(tlumaczenie, pattern, WOWTR_AnsiReverse(wartab[i]))
          tlumaczenie = string.gsub(tlumaczenie, dollarPattern, WOWTR_AnsiReverse(wartab[i]))
        end
      end
   else
      for i = 1, 40 do
         if (arg0 >= i) then
            -- Reverse "i" to match the curly-brace pattern (e.g. 12 => "{21}")
            local reversedI = tostring(i):reverse()
            tlumaczenie = string.gsub(tlumaczenie, "{" .. reversedI .. "}", WOWTR_AnsiReverse(wartab[i]))
            tlumaczenie = string.gsub(tlumaczenie, "$"  .. i,           WOWTR_AnsiReverse(wartab[i]))
         end
      end
   end
   if (WoWTR_Localization.lang ~= 'AR') then
      tlumaczenie = string.gsub(tlumaczenie, "$o", "$O");
      local nr_1, nr_2, nr_3 = 0;
      local QTR_forma = "";
      local nr_poz = string.find(tlumaczenie, "$O");    -- gdy nie znalazł, jest: nil
      while (nr_poz and nr_poz>0) do
         nr_1 = nr_poz + 1;   
         while (string.sub(tlumaczenie, nr_1, nr_1) ~= "(") do
            nr_1 = nr_1 + 1;
         end
         if (string.sub(tlumaczenie, nr_1, nr_1) == "(") then
            nr_2 =  nr_1 + 1;
            while (string.sub(tlumaczenie, nr_2, nr_2) ~= ";") do
               nr_2 = nr_2 + 1;
            end
            if (string.sub(tlumaczenie, nr_2, nr_2) == ";") then
               nr_3 = nr_2 + 1;
               while (string.sub(tlumaczenie, nr_3, nr_3) ~= ")") do
                  nr_3 = nr_3 + 1;
               end
               if (string.sub(tlumaczenie, nr_3, nr_3) == ")") then
                  if (QTR_PS["ownname"] == "1") then        -- forma polska
                     QTR_forma = string.sub(tlumaczenie,nr_2+1,nr_3-1);
                  else                                      -- forma angielska
                     QTR_forma = QTR_ReverseIfAR(string.sub(tlumaczenie,nr_1+1,nr_2-1));
                  end
                  tlumaczenie = string.sub(tlumaczenie,1,nr_poz-1) .. QTR_forma .. string.sub(tlumaczenie,nr_3+1);
               end   
            end
         end
         nr_poz = string.find(tlumaczenie, "$O");
      end
   end

   return tlumaczenie;
end

-------------------------------------------------------------------------------------------------------

function OkreslKodKoloru(k1,k2,k3)
   local kol1=('%.0f'):format(k1);
   local kol2=('%.0f'):format(k2);
   local kol3=('%.0f'):format(k3);
   local c_out='c?';
   if (kol1=="0" and kol2=="0" and kol3=="0") then
      c_out='c1';
   elseif (kol1=="0" and kol2=="0" and kol3=="1") then
      c_out='c2';
   elseif (kol1=="0" and kol2=="1" and kol3=="0") then
      c_out='c3';
   elseif (kol1=="0" and kol2=="1" and kol3=="1") then
      c_out='c4';
   elseif (kol1=="1" and kol2=="0" and kol3=="0") then
      c_out='c5';
   elseif (kol1=="1" and kol2=="0" and kol3=="1") then
      c_out='c6';
   elseif (kol1=="1" and kol2=="1" and kol3=="0") then
      c_out='c7';
   else
      c_out='c8';
   end
   return c_out;   
end

-------------------------------------------------------------------------------------------------------

if ((GetLocale()=="enUS") or (GetLocale()=="enGB")) then

-- funkcja wywoływana po wyświetleniu się oryginalnego okienka Tooltip
   GameTooltip:HookScript('OnUpdate', function(self, ...)
      if (not WOWTR_wait(0, ST_GameTooltipOnShow)) then
      -- opóźnienie 0.01 sek
      end
   end );

-------------------------------------------------------------------------------------------------------

-- funkcja wywoływana po ukryciu oryginalnego okienka Tooltip
   GameTooltip:HookScript('OnHide', function(self, ...)
      ST_lastNumLines = 0;
   end );

-------------------------------------------------------------------------------------------------------

-- funkcja wywoływana po wyświetleniu się oryginalnego okienka Tooltip
   GameTooltip:HookScript('OnUpdate', function(self, ...)
      if ((ST_PM["active"]=="1") and (ST_lastNumLines > 0)) then                        -- dodatek aktywny
         if ((ST_PM["constantly"] == "1") and (UnitLevel("player") > 10)) then
            if ((ST_PM["showID"] == "1") or (ST_PM["showHS"] == "1")) then
               if (ST_lastNumLines ~= self:NumLines()) then
                  ST_GameTooltipOnShow();
               end
            elseif (_G["GameTooltipTextLeft1"] and _G["GameTooltipTextLeft1"]:GetText() and (string.find(_G["GameTooltipTextLeft1"]:GetText()," ")==nil)) then
               ST_GameTooltipOnShow();
            end
         elseif ((ST_PM["constantly"] == "1") and (self.updateTooltipTimer > 1)) then
            self.updateTooltipTimer = 2;
         end
      end
   end );
   
end

-------------------------------------------------------------------------------------------------------

function ST_ElvSpellBookTooltipOnShow()
   local E, L, V, P, G = unpack(ElvUI);
   local ElvUISpellBookTooltip = E.SpellBookTooltip;
   local numLines = ElvUISpellBookTooltip:NumLines();

   if (numLines == 1) then   -- ElvUISpellBookTooltip zawiera tylko 1 linijkę opisu i jest to tytuł spella
      return;
   end
   
   if (ST_PM["spell"] == "0") then
      return;
   end
   
   local ST_kodKoloru;
   local ST_leftText, ST_rightText, ST_tlumaczenie, ST_hash, ST_hash2;
   local _font1, _size1, _1;
   
   local ST_prefix = "s";
   if (ElvUISpellBookTooltip.processingInfo and ElvUISpellBookTooltip.processingInfo.tooltipData.id) then
      ST_prefix = ST_prefix..ElvUISpellBookTooltip.processingInfo.tooltipData.id;
   end
   ElvUISpellBookTooltip:HookScript("OnHide", function() ST_MyGameTooltip:Hide(); end);
   ST_MyGameTooltip:SetOwner(WorldFrame, "ANCHOR_NONE" );
   ST_MyGameTooltip:ClearAllPoints();
   ST_MyGameTooltip:SetPoint("TOPLEFT", ElvUISpellBookTooltip, "BOTTOMLEFT", 0, 0);    -- pod przyciskiem od lewej strony
   ST_MyGameTooltip:ClearLines();
   for i = 2, numLines-1, 1 do
      ST_leftText = _G[ElvUISpellBookTooltip:GetName().."TextLeft"..i]:GetText();
      leftColR, leftColG, leftColB = _G[ElvUISpellBookTooltip:GetName().."TextLeft"..i]:GetTextColor();
      ST_kodKoloru = OkreslKodKoloru(leftColR, leftColG, leftColB);
      if (ST_leftText and (string.len(ST_leftText)>15) and ((ST_kodKoloru == "c7") or (ST_kodKoloru == "c4") or (string.len(ST_leftText)>30))) then
         ST_hash = StringHash(ST_UsunZbedneZnaki(ST_leftText));
         if (((ST_kodKoloru == "c7") or (string.len(ST_leftText)>30)) and (not ST_hash2)) then
            ST_hash2 = ST_hash;
         end
         if (ST_TooltipsHS[ST_hash]) then        -- mamy przetłumaczony ten Hash
            ST_tlumaczenie = ST_TooltipsHS[ST_hash];
            ST_tlumaczenie = ST_TranslatePrepare(ST_leftText, ST_tlumaczenie);
            ST_MyGameTooltip:AddLine(QTR_ReverseIfAR(ST_tlumaczenie), leftColR, leftColG, leftColB, true);
            numLines = ST_MyGameTooltip:NumLines();           -- aktualna liczba linii
            _font1, _size1, _1 = _G[ElvUISpellBookTooltip:GetName().."TextLeft"..i]:GetFont();    -- odczytaj aktualną czcionkę i rozmiar    
            _G["ST_MyGameTooltipTextLeft"..numLines]:SetFont(WOWTR_Font2, 11);        -- ustawiamy własną czcionkę 
         end
      end
   end
   
   if (((ST_PM["showID"]=="1") and (string.len(ST_prefix) > 1)) or ((ST_PM["showHS"]=="1") and ST_hash2)) then   -- czy dodawać ID i Hash ?
      numLines = ST_MyGameTooltip:NumLines();           -- aktualna liczba linii
      if (numLines == 0) then
         ST_MyGameTooltip:AddLine(QTR_Messages.missing, 1, 1, 0.5);
         _G["ST_MyGameTooltipTextLeft1"]:SetFont(WOWTR_Font2, 11);      -- ustawiamy czcionkę turecką
      end
      ST_MyGameTooltip:AddLine(" ",0,0,0);           -- dodaj odstęp przed linią z ID
      typName = "Spell";
      ST_ID = string.sub(ST_prefix,2);
      if ((ST_PM["showID"]=="1") and ST_ID) then
         ST_MyGameTooltip:AddLine(typName.." ID: "..tostring(ST_ID),0,1,1);
         numLines = ST_MyGameTooltip:NumLines();                -- Aktualna liczba linii w ST_MyGameTooltip
         _G["ST_MyGameTooltipTextLeft"..numLines]:SetFont(WOWTR_Font2, 10);      -- wielkość 12
      end
      if ((ST_PM["showHS"]=="1") and ST_hash2) then
         ST_MyGameTooltip:AddLine("Hash: "..tostring(ST_hash2),0,1,1);
         numLines = ST_MyGameTooltip:NumLines();                -- Aktualna liczba linii w ST_MyGameTooltip
         _G["ST_MyGameTooltipTextLeft"..numLines]:SetFont(WOWTR_Font2, 10);      -- wielkość 12
      end
   end

   ST_MyGameTooltip:Show();         -- wyświetla ramkę w tłumaczeniem (zrobi także resize)
end

-------------------------------------------------------------------------------------------------------

function ST_BuffOrDebuff()
   if (_G["GameTooltipTextLeft2"] and _G["GameTooltipTextLeft2"]:GetText()) then
      local ST_leftText2 = _G["GameTooltipTextLeft2"]:GetText();
      local ST_hash = StringHash(ST_UsunZbedneZnaki(ST_leftText2));
      if (ST_TooltipsHS[ST_hash]) then        -- mamy przetłumaczony ten Hash
         local ST_tlumaczenie = ST_TooltipsHS[ST_hash];
         ST_tlumaczenie = ST_TranslatePrepare(ST_leftText2, ST_tlumaczenie);
         local leftColR, leftColG, leftColB = _G["GameTooltipTextLeft2"]:GetTextColor();
         
         if not GameTooltip.OnHideHooked then
            GameTooltip:HookScript("OnHide", function() 
               C_Timer.After(0.01, function() 
                  ST_MyGameTooltip:Hide() 
               end)
            end)
            GameTooltip.OnHideHooked = true
         end

         ST_MyGameTooltip:SetOwner(WorldFrame, "ANCHOR_NONE" );
         ST_MyGameTooltip:ClearAllPoints();
         ST_MyGameTooltip:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", 0, 0);    -- pod przyciskiem od prawej strony
         ST_MyGameTooltip:ClearLines();
         if (WoWTR_Localization.lang == 'AR') then
            ST_MyGameTooltip:AddLine(QTR_ExpandUnitInfo(ST_tlumaczenie,false,ST_MyGameTooltip,WOWTR_Font2), leftColR, leftColG, leftColB, true);
         else
            ST_MyGameTooltip:AddLine(QTR_ReverseIfAR(ST_tlumaczenie), leftColR, leftColG, leftColB, true);
         end
         _G["ST_MyGameTooltipTextLeft1"]:SetFont(WOWTR_Font2, 12);      -- wielkość 12
         if (ST_PM["showHS"]=="1") then            -- czy Hash ?
            ST_MyGameTooltip:AddLine(" ",0,0,0);   -- dodaj odstęp przed linią z Hash
            ST_MyGameTooltip:AddLine("Hash: "..tostring(ST_hash),0,1,1);
            _G["ST_MyGameTooltipTextLeft3"]:SetFont(WOWTR_Font2, 12);      -- wielkość 12
         end
         ST_MyGameTooltip:Show();         -- wyświetla ramkę w tłumaczeniem (zrobi także resize)
      elseif ((ST_PM["saveNW"]=="1") and GameTooltip.processingInfo and GameTooltip.processingInfo.tooltipData.id) then
         local ST_prefix = "s"..GameTooltip.processingInfo.tooltipData.id;
         ST_PH[ST_hash]=ST_prefix.."@"..ST_PrzedZapisem(ST_leftText2);
      end
   end
end

-------------------------------------------------------------------------------------------------------

function ST_GameTooltipOnShow()
   if (ST_PM["active"]=="1") then                        -- dodatek aktywny
   
      ST_lastNumLines = 0;

      -- Buff ve Debuff frame'lerinin mouse-over kontrolü
      local ST_BFisOver = BuffFrame and BuffFrame:IsMouseOver();
      local ST_DFisOver = DebuffFrame and DebuffFrame:IsMouseOver();

      -- ElvUI varsa ve Classic için yüklüyse, ek kontrol
      if ElvUIPlayerBuffs and ElvUIPlayerBuffs:IsVisible() and ElvUIPlayerBuffs:IsMouseOver() then
         ST_BFisOver = true;
      end

      if ElvUIPlayerDebuffs and ElvUIPlayerDebuffs:IsVisible() and ElvUIPlayerDebuffs:IsMouseOver() then
         ST_DFisOver = true;
      end

      if ST_BFisOver or ST_DFisOver then
         ST_BuffOrDebuff();
         return;
      end

      GameTooltip.updateTooltipTimer = tonumber(ST_PM["timer"]);   -- X sekund zatrzymania uaktualnienia GameTooltip
      if (_G["GameTooltipTextLeft1"] and _G["GameTooltipTextLeft1"]:GetText()) then
         if (string.find(_G["GameTooltipTextLeft1"]:GetText()," ")) then
             return;
         end
         _G["GameTooltipTextLeft1"]:SetText(QTR_ExpandUnitInfo(_G["GameTooltipTextLeft1"]:GetText(),WOWTR_Font2).." ");   -- znacznik twardej spacji do tytułu
      end
      
      local ST_prefix = "h";
      local itemLink = GameTooltip:GetItem();
      local spellName, spellID = GameTooltip:GetSpell();

      if itemLink then           -- items
         local itemID = GetItemInfoInstant(itemLink);
         if itemID then
            ST_prefix = "i" .. itemID;
            if (ST_PM["item"] == "0") then      -- nie ma zezwolenia tłumaczenia przedmiotów
               return;
            end
         end
      elseif spellID then       -- spell or talent
         if ClassTalentFrame and ClassTalentFrame:IsVisible() and (ClassTalentFrame:GetTab()==2) then     -- otwarta zakładka Talents
            local PTFleft = ClassTalentFrame:GetLeft();
            local PTFright = ClassTalentFrame:GetRight();
            local PTFbootom = ClassTalentFrame:GetBottom();
            local PTFtop = ClassTalentFrame:GetTop();
            local x,y = GetCursorPosition();
            if (x>PTFleft and x<PTFright and y>PTFbootom and y<PTFtop) then
               ST_prefix = "t" .. spellID;
               if (ST_PM["talent"] == "0") then      -- nie ma zezwolenia tłumaczenia talentów
                  return;
               end
            end
         else
            ST_prefix = "s" .. spellID;
            if (ST_PM["spell"] == "0") then      -- nie ma zezwolenia tłumaczenia spelli
               return;
            end
         end
      end

      local numLines = GameTooltip:NumLines();
      if ((numLines == 1) and (ST_prefix ~= "h")) then   -- GameTooltip zawiera tylko 1 linijkę opisu i jest to tytuł itemu lub spella
         return;
      end
      
      local ST_kodKoloru;
      local ST_leftText, ST_rightText, ST_tlumaczenie, ST_hash, ST_hash2, ST_pomoc5, ST_pomoc6, ST_pomoc7;
      local _font1, _size1, _1;
      local ST_odstep = true;
      local ST_orygText = {};
      local ST_nh = 0;   -- nowy Hash ?
      
      -- sprawdź czy są ramki z ceną
      local moneyFrameLineNumber = {};
      local money = {};
      table.insert(moneyFrameLineNumber, 0);
      table.insert(money,0);
      if (GameTooltip.shownMoneyFrames) then        -- są ramki z ceną itemu
         for i = 1, GameTooltip.shownMoneyFrames, 1 do
            local moneyFrameName = GameTooltip:GetName().."MoneyFrame"..i;           -- nazwa obiektu
            _G[moneyFrameName.."PrefixText"]:SetText(QTR_ReverseIfAR(WoWTR_Localization.sellPrice));  -- SELL PRICE
            _font1, _size1, _1 = _G[moneyFrameName.."PrefixText"]:GetFont();  -- odczytaj aktualną czcionkę i rozmiar    
            _G[moneyFrameName.."PrefixText"]:SetFont(WOWTR_Font2, _size1);
            if (ST_PM["sellprice"] == "1") then    -- jest zezwolenie na ukrycie ceny skupu
               _G[moneyFrameName]:Hide();
               ST_odstep = false;
            end
         end
      end

      local ST_fromLine = 2;
      if (ST_prefix == "h") then
         ST_fromLine = 1;
      end
      
      if (ST_TooltipsID and (ST_PM["transtitle"]=="1") and ST_TooltipsID[ST_prefix]) then     -- jest zezwolenie na tłumaczenie tytułu i jest tłumaczenie
         _G["GameTooltipTextLeft1"]:SetText(QTR_ExpandUnitInfo(ST_TooltipsID[ST_prefix],WOWTR_Font2).." ");   -- znacznik twardej spacji do tytułu
         _font1, _size1, _1 = _G["GameTooltipTextLeft1"]:GetFont();           -- odczytaj aktualną czcionkę i rozmiar    
         _G["GameTooltipTextLeft1"]:SetFont(WOWTR_Font2, _size1);
      end

      for i = ST_fromLine, numLines, 1 do
         ST_leftText = _G["GameTooltipTextLeft"..i]:GetText();
         if (ST_leftText and (string.find(ST_leftText," ")==nil)) then                 -- nie jest to nasze tłumaczenie
            leftColR, leftColG, leftColB = _G["GameTooltipTextLeft"..i]:GetTextColor();
            ST_kodKoloru = OkreslKodKoloru(leftColR, leftColG, leftColB);
            if (ST_leftText and (string.len(ST_leftText)>15) and ((ST_kodKoloru == "c7") or (ST_kodKoloru == "c4") or (string.len(ST_leftText)>30))) then
               if (itemLink and (GetItemInfoInstant(itemLink) == 6948)) then   -- wyjątek na Kamień Powrotu
                  ST_pomoc5, _ = string.find(ST_leftText,". Speak");        -- znajdź kropkę kończącą pierwsze zdanie
                  if (ST_pomoc5 and (ST_pomoc5>22)) then
                     ST_miasto = string.sub(ST_leftText,21,ST_pomoc5-1);
                  else
                     ST_miasto = WoWTR_Localization.your_home;
                  end
                  ST_pomoc6, _ = string.find(ST_leftText,' Min Cooldown)');
                  if (ST_pomoc6) then              -- mamy 2 wersję tekstu z Cooldown
                     ST_hash = 1336493626;
                  else                             -- 1 wersja tekstu (bez Cooldown)
                     ST_hash = 3076025968;
                  end
               else
                  ST_hash = StringHash(ST_UsunZbedneZnaki(ST_leftText));
               end
               if (((ST_kodKoloru == "c7") or (string.len(ST_leftText)>30)) and (not ST_hash2)) then
                  ST_hash2 = ST_hash;
               end
               ST_pomoc7, _ = string.find(ST_leftText,"<Made by");    -- znajdź czy jest to tekst typu "|cff00ff00<Made by Platine>|r"
               if (ST_pomoc7) then
                  ST_hash = 1381871427;
               end
               if (ST_TooltipsHS[ST_hash]) then        -- mamy przetłumaczony ten Hash lub jest to <Made by...
                  if (ST_pomoc7) then
                     local endBy = string.find(ST_leftText,">");
                     local nameBy = string.sub(ST_leftText,ST_pomoc7+9,endBy-1);
                     ST_tlumaczenie = ST_TooltipsHS[ST_hash];
                     if (WoWTR_Localization.lang == 'AR') then
                        ST_tlumaczenie = string.gsub(ST_tlumaczenie, "NAMEBY", string.reverse(nameBy));
                        ST_tlumaczenie = string.gsub(ST_tlumaczenie, "{$M}", string.reverse(nameBy));
                     else
                        ST_tlumaczenie = string.gsub(ST_tlumaczenie, "$M", nameBy);
                     end
                  else
                     ST_tlumaczenie = ST_TooltipsHS[ST_hash];
                  end
                  ST_tlumaczenie = ST_TranslatePrepare(ST_leftText, ST_tlumaczenie);
                  _font1, _size1, _1 = _G["GameTooltipTextLeft"..i]:GetFont();    -- odczytaj aktualną czcionkę i rozmiar    
                  _G["GameTooltipTextLeft"..i]:SetFont(WOWTR_Font2, _size1);      -- ustawiamy czcionkę turecką
                  _G["GameTooltipTextLeft"..i]:SetText(QTR_ExpandUnitInfo(ST_tlumaczenie,false,_G["GameTooltipTextLeft"..i],WOWTR_Font2).." ");      -- dodajemy twardą spacje na końcu
                  _G["GameTooltipTextLeft"..i].wrap = true;
                  if (itemLink and (GetItemInfoInstant(itemLink) == 6948)) then   -- wyjątek na Kamień Powrotu
                     break;
                  end
               else
                  ST_nh = 1;              -- nowy Hash
                  table.insert(ST_orygText,ST_leftText);
               end
            end
         end
      end
      

      if (((ST_PM["showID"]=="1") and (string.len(ST_prefix) > 1)) or ((ST_PM["showHS"]=="1") and ST_hash2)) then   -- czy dodawać ID i Hash ?
         numLines = GameTooltip:NumLines();           -- aktualna liczba linii
         if (numLines > 0 and ST_odstep) then
            GameTooltip:AddLine(" ",0,0,0);           -- dodaj odstęp przed linią z ID
         end
         local typName = " ";
         if (string.sub(ST_prefix,1,1) == "i") then
            typName = "Item";
            ST_ID = string.sub(ST_prefix,2);
         elseif (string.sub(ST_prefix,1,1) == "s") then
            typName = "Spell";
            ST_ID = string.sub(ST_prefix,2);
         elseif (string.sub(ST_prefix,1,1) == "t") then
            typName = "Talent";
            ST_ID = string.sub(ST_prefix,2);
         else
            ST_ID = nil;
         end
         if ((ST_PM["showID"]=="1") and ST_ID) then
            GameTooltip:AddLine(typName.." ID: "..tostring(ST_ID),0,1,1);
            numLines = GameTooltip:NumLines();                -- Aktualna liczba linii w GameTooltip
            _G["GameTooltipTextLeft"..numLines]:SetFont(WOWTR_Font2, 12);      -- wielkość 12
            _G["GameTooltipTextRight"..numLines]:SetFont(WOWTR_Font2, 12);     -- wielkość 12
         end
         if ((ST_PM["showHS"]=="1") and ST_hash2) then
            GameTooltip:AddLine("Hash: "..tostring(ST_hash2),0,1,1);
            numLines = GameTooltip:NumLines();                -- Aktualna liczba linii w GameTooltip
            _G["GameTooltipTextLeft"..numLines]:SetFont(WOWTR_Font2, 12);      -- wielkość 12
            _G["GameTooltipTextRight"..numLines]:SetFont(WOWTR_Font2, 12);     -- wielkość 12
         end
      end
      
      if ((ST_PM["constantly"] == "1") and (UnitLevel("player") > 60) and _G["GameTooltipTextLeft1"] and _G["GameTooltipTextLeft1"]:GetText()) then
         _G["GameTooltipTextLeft1"]:SetText(QTR_ExpandUnitInfo(_G["GameTooltipTextLeft1"]:GetText(),WOWTR_Font2).." ");
      end
      GameTooltip:Show();   -- wyświetla ramkę podpowiedzi (zrobi także resize)
      ST_lastNumLines = GameTooltip:NumLines();

      if ((ST_orygText or (ST_nh == 1)) and (ST_PM["saveNW"] == "1")) then
          for _, ST_origin in ipairs(ST_orygText) do
              local ST_hash = StringHash(ST_UsunZbedneZnaki(ST_origin))
              if (string.sub(ST_origin, 1, 11) ~= '|A:raceicon') then
                  local shouldSave = true
                  
                  for _, word in ipairs(ignoreSettings.words) do
                      if string.find(ST_origin, word) then
                          shouldSave = false
                          break
                      end
                  end

                  if shouldSave and string.find(ST_origin, ignoreSettings.pattern) then
                      shouldSave = false
                  end

                  if shouldSave then
                      ST_PH[ST_hash] = ST_prefix .. "@" .. ST_PrzedZapisem(ST_origin)
                  end
              end
          end
      end
   end
end


-------------------------------------------------------------------------------------------------------

function ST_SetText(txt)      -- funkcja wyszukuje tłumaczenie, albo zapisuje test oryginalny
   if (string.find(txt," ")==nil) then    -- nie jest to tekst turecki (nie ma twardej spacji na końcu tłumaczenia)
      local ST_hash = StringHash(ST_UsunZbedneZnaki(txt));
      if (ST_TooltipsHS[ST_hash]) then
         return ST_TooltipsHS[ST_hash].." ";       -- dodajemy twardą spację na końcu tłumaczenia
      elseif (ST_PM["saveNW"]=="1") then           -- jest zezwolenie na zapis oryginalnego tekstu
         ST_PH[ST_hash] = "ui@"..ST_PrzedZapisem(txt);
      end
   end
   return txt;       -- zwracamy oryginalny tekst bez zmiany   
end

-------------------------------------------------------------------------------------------------------

if ((GetLocale()=="enUS") or (GetLocale()=="enGB")) then
   hooksecurefunc("GameTooltip_ShowCompareItem",function(self)
      if (ShoppingTooltip1 and ShoppingTooltip1:IsVisible()) then
         ST_CurrentEquipped(ShoppingTooltip1);
      end
      if (ShoppingTooltip2 and ShoppingTooltip2:IsVisible()) then
         ST_CurrentEquipped(ShoppingTooltip2);
      end
   end );
end

--GameTooltip:HookScript("KeyDown", function() print("key pressed"); end);

-------------------------------------------------------------------------------------------------------

-- Funkcja przegląda wyświetlane itemy Current Equipped w oknie ShoppingTooltip1 lub ShoppingTooltip2
function ST_CurrentEquipped(obj)
   if ((ST_PM["active"]=="1") and (ST_PM["item"] == "1")) then          -- dodatek aktywny i zezwolono na tłumaczenie itemów
      if (obj.processingInfo and obj.processingInfo.tooltipData.id) then
         ST_prefix = "i" .. obj.processingInfo.tooltipData.id;

         local ST_kodKoloru;
         local ST_leftText, ST_rightText, ST_tlumaczenie, ST_hash, ST_hash2;
         local _font1, _size1, _1;
         local ST_odstep = true;
         local ST_orygText = {};
         local ST_nh = 0;   -- nowy Hash ?
         local numLines = obj:NumLines();
         
         -- sprawdź czy są ramki z ceną
         local moneyFrameLineNumber = {};
         local money = {};
         table.insert(moneyFrameLineNumber, 0);
         table.insert(money,0);
         if (obj.shownMoneyFrames) then        -- są ramki z ceną itemu
            for i = 1, obj.shownMoneyFrames, 1 do
               local moneyFrameName = obj:GetName().."MoneyFrame"..i;           -- nazwa obiektu
               _G[moneyFrameName.."PrefixText"]:SetText(QTR_ReverseIfAR(WoWTR_Localization.sellPrice));  -- SELL PRICE
               _font1, _size1, _1 = _G[moneyFrameName.."PrefixText"]:GetFont();  -- odczytaj aktualną czcionkę i rozmiar    
               _G[moneyFrameName.."PrefixText"]:SetFont(WOWTR_Font2, _size1);
               if (ST_PM["sellprice"] == "1") then    -- jest zezwolenie na ukrycie ceny skupu
                  _G[moneyFrameName]:Hide();
                  ST_odstep = false;
               end
            end
         end
         
         -- pierwsza linia z opisem założenia przedmiotu (Currently Equipped lub Equipped With)
         ST_leftText = _G[obj:GetName().."TextLeft1"]:GetText();
         if (ST_leftText) then 
            if (string.find(ST_leftText," ")==nil) then                             -- nie jest to tekst przetłumaczony (twarda spacja na końcu)
               if (ST_leftText=="Currently Equipped") then
                  ST_info = WoWTR_Localization.currentlyEquipped;
               elseif(ST_leftText=="Equipped With") then
                  ST_info = WoWTR_Localization.additionalEquipped;
               else
                  ST_info = ST_leftText;     -- inny wariant tekstu?
               end
               if ((ST_info == ST_leftText) and (string.len(ST_leftText)>2) and (string.sub(ST_leftText,1,2)~="|T")) then  -- nic nie przetłumaczono
               --   ST_PI[ST_info]=leftText[1];        -- zapisz
               else
                  _font1, _size1, _1 = _G[obj:GetName().."TextLeft1"]:GetFont();    -- odczytaj aktualną czcionkę i rozmiar    
                  _G[obj:GetName().."TextLeft1"]:SetText(QTR_ReverseIfAR(ST_info).." ");             -- dodajemy twardą spacje na końcu
                  _G[obj:GetName().."TextLeft1"]:SetFont(WOWTR_Font2, _size1);
               end
            end               
         end
   
         -- druga linia z tytułem przedmiotu
         ST_pomoc0, _ = string.find(_G[obj:GetName().."TextLeft2"]:GetText()," ");   -- szukamy twardej spacji
         if (ST_TooltipID and (ST_pomoc0==nil) and (ST_TooltipsID[ST_prefix..tostring(ST_itemID)]) and (ST_PM["transtitle"]=="1")) then  -- jest tłumaczenie tytułu w bazie
            _G[obj:GetName().."TextLeft2"]:SetText(QTR_ExpandUnitInfo(ST_TooltipsID[ST_prefix..tostring(ST_itemID)]),WOWTR_Font2);
            _font1, _size1, _1 = _G[obj:GetName().."TextLeft2"]:GetFont();  -- odczytaj aktualną czcionkę i rozmiar    
            _G[obj:GetName().."TextLeft2"]:SetFont(WOWTR_Font2, _size1);
         end
   
         for i = 3, numLines, 1 do
            ST_leftText = _G[obj:GetName().."TextLeft"..i]:GetText();
            if (ST_leftText and (string.find(ST_leftText," ")==nil) and not shouldIgnore(ST_leftText)) then                 -- nie jest to nasze tłumaczenie
               leftColR, leftColG, leftColB = _G[obj:GetName().."TextLeft"..i]:GetTextColor();
               ST_kodKoloru = OkreslKodKoloru(leftColR, leftColG, leftColB);
               if (ST_leftText and (string.len(ST_leftText)>15) and ((ST_kodKoloru == "c7") or (ST_kodKoloru == "c4") or (string.len(ST_leftText)>30))) then
--print(ST_kodKoloru,i,ST_leftText);
                  ST_hash = StringHash(ST_UsunZbedneZnaki(ST_leftText));
                  if (((ST_kodKoloru == "c7") or (string.len(ST_leftText)>30)) and (not ST_hash2)) then
                     ST_hash2 = ST_hash;
                  end
                  if (ST_TooltipsHS[ST_hash]) then        -- mamy przetłumaczony ten Hash
                     ST_tlumaczenie = ST_TooltipsHS[ST_hash];
                     ST_tlumaczenie = ST_TranslatePrepare(ST_leftText, ST_tlumaczenie);
                     _font1, _size1, _1 = _G[obj:GetName().."TextLeft"..i]:GetFont();    -- odczytaj aktualną czcionkę i rozmiar    
                     _G[obj:GetName().."TextLeft"..i]:SetFont(WOWTR_Font2, _size1);      -- ustawiamy czcionkę turecką
                     _G[obj:GetName().."TextLeft"..i]:SetText(QTR_ExpandUnitInfo(ST_tlumaczenie,false,_G["GameTooltipTextLeft"..i],WOWTR_Font2).." ");      -- dodajemy twardą spacje na końcu
                  else
                     ST_nh = 1;              -- nowy Hash
                     table.insert(ST_orygText,ST_leftText);
                  end
               end
            end
         end
         
   
         if (((ST_PM["showID"]=="1") and (string.len(ST_prefix) > 1)) or ((ST_PM["showHS"]=="1") and ST_hash2)) then   -- czy dodawać ID i Hash ?
            numLines = obj:NumLines();           -- aktualna liczba linii
            if (numLines > 0 and ST_odstep) then
               obj:AddLine(" ",0,0,0);           -- dodaj odstęp przed linią z ID
            end
            local typName = " ";
            if (string.sub(ST_prefix,1,1) == "i") then
               typName = "Item";
               ST_ID = string.sub(ST_prefix,2);
            elseif (string.sub(ST_prefix,1,1) == "s") then
               typName = "Spell";
               ST_ID = string.sub(ST_prefix,2);
            elseif (string.sub(ST_prefix,1,1) == "t") then
               typName = "Talent";
               ST_ID = string.sub(ST_prefix,2);
            else
               ST_ID = nil;
            end
            if ((ST_PM["showID"]=="1") and ST_ID) then
               obj:AddLine(typName.." ID: "..tostring(ST_ID),0,1,1);
               numLines = obj:NumLines();                -- Aktualna liczba linii w obj
               _G[obj:GetName().."TextLeft"..numLines]:SetFont(WOWTR_Font2, 12);      -- wielkość 12
               _G[obj:GetName().."TextRight"..numLines]:SetFont(WOWTR_Font2, 12);     -- wielkość 12
            end
            if ((ST_PM["showHS"]=="1") and ST_hash2) then
               obj:AddLine("Hash: "..tostring(ST_hash2),0,1,1);
               numLines = obj:NumLines();                -- Aktualna liczba linii w obj
               _G[obj:GetName().."TextLeft"..numLines]:SetFont(WOWTR_Font2, 12);      -- wielkość 12
               _G[obj:GetName().."TextRight"..numLines]:SetFont(WOWTR_Font2, 12);     -- wielkość 12
            end
         end
         
         obj:Show();   -- wyświetla ramkę podpowiedzi (zrobi także resize)
         
         if ((ST_orygText or (ST_nh==1)) and (ST_PM["saveNW"]=="1")) then
            for _, ST_origin in ipairs(ST_orygText) do   
               ST_hash = StringHash(ST_UsunZbedneZnaki(ST_origin));
               if ((not ST_TooltipsHS[ST_hash]) and (string.find(ST_origin," ")==nil)) then    -- i nie jest to tekst tłumaczenia (twarda spacja)
                   local text = ST_PrzedZapisem(ST_origin)
                   if not shouldIgnore(text) then
                   ST_PH[ST_hash]=ST_prefix.."@"..ST_PrzedZapisem(ST_origin);
                   end
               end
            end
         end
      end
         
   end   -- if ST_PM["active"]
   
end
    
-------------------------------------------------------------------------------------------------------

local function CreateToggleButton(parentFrame, settingsTable, settingKey, onText, offText, point, onClick)
    local buttonOFF = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
    local buttonON = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
    
    local function SetupButton(button, text)
        button:SetSize(120, 22)
        if WoWTR_Localization.lang == 'AR' and text == WoWTR_Localization.WoWTR_trDESC then
            button:SetText(QTR_ReverseIfAR(text))
            button:GetFontString():SetFont(WOWTR_Font2, 13)
        else
            button:SetText(text)
            button:GetFontString():SetFont(button:GetFontString():GetFont(), 13)
        end
        button:SetPoint(unpack(point))
        button:SetFrameStrata("TOOLTIP")
    end

    SetupButton(buttonOFF, offText)
    SetupButton(buttonON, onText)

    local function UpdateVisibility()
        if settingsTable[settingKey] == "1" then
            buttonOFF:Show(); buttonON:Hide()
        else
            buttonOFF:Hide(); buttonON:Show()
        end
    end

    buttonOFF:SetScript("OnClick", function()
        settingsTable[settingKey] = "0"
        UpdateVisibility()
        if onClick then onClick() end
    end)

    buttonON:SetScript("OnClick", function()
        settingsTable[settingKey] = "1"
        UpdateVisibility()
        if onClick then onClick() end
    end)

    UpdateVisibility()
    return UpdateVisibility
end

-------------------------------------------------------------------------------------------------------

function ST_UpdateFrameTitle(classTalentFrame)
   local ST_titleText;
   if (classTalentFrame:GetTab() == classTalentFrame.specTabID) then
      titleText = _G["SPECIALIZATION"];
   else -- tabID == self.talentTabID
      titleText = _G["TALENTS"];
   end
   classTalentFrame:SetTitle(ST_SetText(titleText));
   -- local _font, _size, _ = classTalentFrame.TalentsTab.ApplyButton.Text:GetFont();    -- odczytaj aktualną czcionkę i rozmiar
   -- classTalentFrame.TalentsTab.ApplyButton.Text:SetText(QTR_ReverseIfAR(ST_SetText(classTalentFrame.TalentsTab.ApplyButton.Text:GetText())));   -- Apply Changes
   -- classTalentFrame.TalentsTab.ApplyButton.Text:SetFont(WOWTR_Font2, _size);

--   local _font, _size, _ = classTalentFrame:GetTalentsTabButton():GetFont();
   classTalentFrame:GetTalentsTabButton():SetText(ST_SetText(_G["TALENT_FRAME_TAB_LABEL_TALENTS"]));
--   classTalentFrame:GetTalentsTabButton():SetFont(WOWTR_Font2, _size);
--   local _font, _size, _ = classTalentFrame:GetTabButton(classTalentFrame.specTabID):GetFont();
   classTalentFrame:GetTabButton(classTalentFrame.specTabID):SetText(QTR_ReverseIfAR(ST_SetText(_G["TALENT_FRAME_TAB_LABEL_SPEC"])));
--   classTalentFrame:GetTabButton(classTalentFrame.specTabID):SetFont(WOWTR_Font2, _size);
   if ((ST_PM["active"] == "1") and (classTalentFrame:GetTab() ~= classTalentFrame.specTabID)) then
      WOWTR_ToggleButtonT:Show();
   else
      WOWTR_ToggleButtonT:Hide();
   end
end

-------------------------------------------------------------------------------------------------------

function ST_TalentsTab_OnShow(talentsTab)
   local _font, _size, _ = talentsTab.ClassCurrencyDisplay.CurrencyLabel:GetFont();    -- odczytaj aktualną czcionkę i rozmiar
   talentsTab.ClassCurrencyDisplay.CurrencyLabel:SetText(QTR_ReverseIfAR(ST_SetText(talentsTab.ClassCurrencyDisplay.CurrencyLabel:GetText())));   -- Main Class Talent Title
   talentsTab.ClassCurrencyDisplay.CurrencyLabel:SetFont(WOWTR_Font2, _size);
   local _font, _size, _ = talentsTab.SpecCurrencyDisplay.CurrencyLabel:GetFont();
   talentsTab.SpecCurrencyDisplay.CurrencyLabel:SetText(QTR_ReverseIfAR(ST_SetText(talentsTab.SpecCurrencyDisplay.CurrencyLabel:GetText())));     -- Spec Class Talent Title
   talentsTab.SpecCurrencyDisplay.CurrencyLabel:SetFont(WOWTR_Font2, _size);
end

-------------------------------------------------------------------------------------------------------

function ST_TalentsTranslate()
   local talentsFrame = PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame
   if not talentsFrame then return end
   -- Use the predefined function to handle translation and recording
   local lockedLabel1 = talentsFrame.HeroTalentsContainer and talentsFrame.HeroTalentsContainer.LockedLabel1
   ST_CheckAndReplaceTranslationText(lockedLabel1, true, "ui")

   local lockedLabel2 = talentsFrame.HeroTalentsContainer and talentsFrame.HeroTalentsContainer.LockedLabel2
   ST_CheckAndReplaceTranslationText(lockedLabel2, true, "ui")

   local classCurrencyLabel = talentsFrame.ClassCurrencyDisplay and talentsFrame.ClassCurrencyDisplay.CurrencyLabel
   ST_CheckAndReplaceTranslationText(classCurrencyLabel, true, "ui")

   local specCurrencyLabel = talentsFrame.SpecCurrencyDisplay and talentsFrame.SpecCurrencyDisplay.CurrencyLabel
   ST_CheckAndReplaceTranslationText(specCurrencyLabel, true, "ui")

    for i = 1, 3 do
        local tab = PlayerSpellsFrame.TabSystem.tabs[i]
        if tab and tab.Text then
            ST_CheckAndReplaceTranslationText(tab.Text, true, "ui")
        end
    end

   local FrameText01 = PlayerSpellsFrameTitleText
   ST_CheckAndReplaceTranslationText(FrameText01, true, "ui")

   local FrameText02 = PlayerSpellsFrame.TalentsFrame.ApplyButton.Text
   ST_CheckAndReplaceTranslationText(FrameText02, true, "ui")

   local FrameText03 = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame.PagingControls.PageText
   ST_CheckAndReplaceTranslationText(FrameText03, true, "ui")

   local FrameText04 = OverlayPlayerCastingBarFrame.Text
   ST_CheckAndReplaceTranslationText(FrameText04, true, "ui")
end


-------------------------------------------------------------------------------------------------------

function ST_updateSpecContentsHook()
   for specContentFrame in PlayerSpellsFrame.SpecFrame.SpecContentFramePool:EnumerateActive() do
      local _, _, description, _, _, _ = GetSpecializationInfo(specContentFrame.specIndex, false, false, nil, WOWTR_player_sex)
      if description and not description:find(" ") then
         local ST_hash = StringHash(ST_UsunZbedneZnaki(description))
         if ST_TooltipsHS[ST_hash] then
            specContentFrame.Description:SetFont(WOWTR_Font2, select(2, specContentFrame.Description:GetFont()))
            local translatedText = QTR_ExpandUnitInfo(ST_TranslatePrepare(description, ST_TooltipsHS[ST_hash]), false, specContentFrame.Description, WOWTR_Font2)
            specContentFrame.Description:SetText(translatedText)
         elseif ST_PM["saveNW"] == "1" then
            ST_PH[ST_hash] = "SpecTab:" .. WOWTR_player_class .. ":" .. specContentFrame.SpecName:GetText() .. "@" .. ST_PrzedZapisem(description:gsub("(%d),(%d)", "%1%2"):gsub("\r", ""))
         end
      end

      local function updateText(element, key, translationType, alignment)
         local text = element:GetText()
         local hash = StringHash(ST_UsunZbedneZnaki(text))
         if ST_TooltipsHS[hash] then
            local translatedText
            if translationType == 2 then
               translatedText = QTR_ExpandUnitInfo(ST_TranslatePrepare(text, ST_TooltipsHS[hash]), false, element, WOWTR_Font2)
            else
               translatedText = QTR_ReverseIfAR(ST_SetText(text))
            end
            element:SetText(translatedText)
            element:SetFont(WOWTR_Font2, select(2, element:GetFont()))
            
            if alignment then
               element:SetJustifyH(alignment)
            end
         end
      end
      
      updateText(specContentFrame.RoleName, "RoleName", 1)
      updateText(specContentFrame.SampleAbilityText, "SampleAbilityText", 1)
      updateText(specContentFrame.ActivatedText, "ActivatedText", 1)
      updateText(specContentFrame.ActivateButton.Text, "ActivateButton.Text", 1)
      updateText(specContentFrame.Description, "Description", 2)
   end
end

function ST_updateHeroTalentHook()
    if not HeroTalentsSelectionDialog or not HeroTalentsSelectionDialog.SpecContentFramePool then
        --print("HeroTalentsSelectionDialog veya SpecContentFramePool mevcut değil.")
        return
    end

    local activeFrameFunction = HeroTalentsSelectionDialog.SpecContentFramePool:EnumerateActive()
    if activeFrameFunction then
        for frame in activeFrameFunction do
            if frame and frame.Description then
                local description = frame.Description:GetText()
                if description and not description:find(" ") then
                    local ST_hash = StringHash(ST_UsunZbedneZnaki(description))
                    if ST_TooltipsHS[ST_hash] then
                        frame.Description:SetFont(WOWTR_Font2, select(2, frame.Description:GetFont()))
                        local translatedText = QTR_ExpandUnitInfo(ST_TranslatePrepare(description, ST_TooltipsHS[ST_hash]), false, frame.Description, WOWTR_Font2)
                        frame.Description:SetText(translatedText)
                    elseif ST_PM["saveNW"] == "1" then
                        ST_PH[ST_hash] = "SpecTab:" .. WOWTR_player_class .. ":" .. frame.SpecName:GetText() .. "@" .. ST_PrzedZapisem(description:gsub("(%d),(%d)", "%1%2"):gsub("\r", ""))
                    end
                end
            end
         local function updateText(element, key, translationType, alignment)
         local text = element:GetText()
         local hash = StringHash(ST_UsunZbedneZnaki(text))
         if ST_TooltipsHS[hash] then
            local translatedText
            if translationType == 2 then
               translatedText = QTR_ExpandUnitInfo(ST_TranslatePrepare(text, ST_TooltipsHS[hash]), false, element, WOWTR_Font2)
            else
               translatedText = QTR_ReverseIfAR(ST_SetText(text))
            end
            element:SetText(translatedText)
            element:SetFont(WOWTR_Font2, select(2, element:GetFont()))
            
            if alignment then
               element:SetJustifyH(alignment)
            end
         end
      end
      
      updateText(frame.CurrencyFrame.LabelText, "CurrencyFrame.LabelText", 1)
      updateText(frame.ActivatedText, "ActivatedText", 1)
      updateText(frame.ActivateButton.Text, "ActivateButton.Text", 1)
      updateText(frame.Description, "Description", 2)
      
        end
    end
end

-------------------------------------------------------------------------------------------------------

function ST_updateSpellBookFrame()
   if (TT_PS["ui1"] == "1") then --Game Option UI
      local ST_titleTextFontString = SpellBookFrameTitleText;
      if (ST_titleTextFontString and ST_titleTextFontString:GetText()) then
         local str_ID = StringHash(ST_UsunZbedneZnaki(ST_titleTextFontString:GetText()));
         if (ST_TooltipsHS[str_ID]) then
            local text0 = QTR_ReverseIfAR(ST_titleTextFontString:GetText());
            ST_titleTextFontString:SetText(ST_SetText(text0));
         end
      end

      if (SpellBookFrameTabButton1 and SpellBookFrameTabButton1:GetText()) then
         local str_ID = StringHash(ST_UsunZbedneZnaki(SpellBookFrameTabButton1:GetText()));
         if (ST_TooltipsHS[str_ID]) then
            local text1 = QTR_ReverseIfAR(ST_SetText(SpellBookFrameTabButton1:GetText()));
            local fo = SpellBookFrameTabButton1:CreateFontString();
            fo:SetFont(WOWTR_Font2, 11);
            fo:SetText(text1);
            SpellBookFrameTabButton1:SetFontString(fo);
            SpellBookFrameTabButton1:SetText(text1);
         end
      end
      
      if (SpellBookFrameTabButton2 and SpellBookFrameTabButton2:GetText()) then
         local str_ID = StringHash(ST_UsunZbedneZnaki(SpellBookFrameTabButton2:GetText()));
         if (ST_TooltipsHS[str_ID]) then
            local text1 = QTR_ReverseIfAR(ST_SetText(SpellBookFrameTabButton2:GetText()));
            local fo = SpellBookFrameTabButton2:CreateFontString();
            fo:SetFont(WOWTR_Font2, 11);
            fo:SetText(text1);
            SpellBookFrameTabButton2:SetFontString(fo);
            SpellBookFrameTabButton2:SetText(text1);
         end
      end
      
      if (SpellBookFrameTabButton3 and SpellBookFrameTabButton3:GetText()) then
         local str_ID = StringHash(ST_UsunZbedneZnaki(SpellBookFrameTabButton3:GetText()));
         if (ST_TooltipsHS[str_ID]) then
            local text1 = QTR_ReverseIfAR(ST_SetText(SpellBookFrameTabButton3:GetText()));
            local fo = SpellBookFrameTabButton3:CreateFontString();
            fo:SetFont(WOWTR_Font2, 11);
            fo:SetText(text1);
            SpellBookFrameTabButton3:SetFontString(fo);
            SpellBookFrameTabButton3:SetText(text1);
         end
      end

      local SBPageText = SpellBookPageText;
      ST_CheckAndReplaceTranslationText(SBPageText, true, "ui");

      local SBTitleText = SpellBookTitleText;
      ST_CheckAndReplaceTranslationText(SBTitleText, true, "ui");

      local SBallrank = ShowAllSpellRanksCheckboxText;
      ST_CheckAndReplaceTranslationText(SBallrank, true, "ui");

   end
end

-------------------------------------------------------------------------------------------------------

function ST_ProfessionEmptyText()
   if (TT_PS["ui1"] == "1") then --Game Option UI

      -- Handle PrimaryProfession1Missing (Global Frame Name - Seems OK based on error context)
      local PrimaryProfessionText01 = PrimaryProfession1Missing;
      ST_CheckAndReplaceTranslationTextUI(PrimaryProfessionText01, true, "Profession:Other");
      -- Removed the Font/Justify calls for PrimaryProfession1Text here as they were misplaced

      -- Handle PrimaryProfession2Missing (Global Frame Name - Seems OK based on error context)
      local PrimaryProfessionText02 = PrimaryProfession2Missing;
      ST_CheckAndReplaceTranslationTextUI(PrimaryProfessionText02, true, "Profession:Other");
       -- Removed the Font/Justify calls for PrimaryProfession1Text here as they were misplaced


      -- Handle PrimaryProfession1.missingText (Object Property Access - Where the error occurred)
      if PrimaryProfession1 and PrimaryProfession1.missingText then -- ADD THIS CHECK
         local PrimaryProfession1TextElement = PrimaryProfession1.missingText -- Use a different variable name for clarity
         ST_CheckAndReplaceTranslationText(PrimaryProfession1TextElement, true, "Profession:Other", false, false, -15);
         if (WoWTR_Localization.lang == 'AR') then
            PrimaryProfession1TextElement:SetFont(WOWTR_Font2, 11);
            PrimaryProfession1TextElement:SetJustifyH("RIGHT");
         end
      -- else -- Optional: uncomment to see if it's consistently missing
         -- print("DEBUG: PrimaryProfession1.missingText not found or nil")
      end

      -- Handle PrimaryProfession2.missingText (Apply the same check)
      if PrimaryProfession2 and PrimaryProfession2.missingText then -- ADD THIS CHECK
         local PrimaryProfession2TextElement = PrimaryProfession2.missingText
         ST_CheckAndReplaceTranslationText(PrimaryProfession2TextElement, true, "Profession:Other", false, false, -15);
         if (WoWTR_Localization.lang == 'AR') then
            PrimaryProfession2TextElement:SetFont(WOWTR_Font2, 11);
            PrimaryProfession2TextElement:SetJustifyH("RIGHT");
         end
      -- else
         -- print("DEBUG: PrimaryProfession2.missingText not found or nil")
      end

       -- Handle SecondaryProfession1.missingText (Apply the same check)
      if SecondaryProfession1 and SecondaryProfession1.missingText then -- ADD THIS CHECK
         local SecondaryProfession1TextElement = SecondaryProfession1.missingText
         ST_CheckAndReplaceTranslationText(SecondaryProfession1TextElement, true, "Profession:Other", false, false, -15);
         if (WoWTR_Localization.lang == 'AR') then
            SecondaryProfession1TextElement:SetFont(WOWTR_Font2, 10);
            SecondaryProfession1TextElement:SetJustifyH("RIGHT");
         end
      -- else
         -- print("DEBUG: SecondaryProfession1.missingText not found or nil")
      end

      -- Handle SecondaryProfession2.missingText (Apply the same check)
      if SecondaryProfession2 and SecondaryProfession2.missingText then -- ADD THIS CHECK
         local SecondaryProfession2TextElement = SecondaryProfession2.missingText
         ST_CheckAndReplaceTranslationText(SecondaryProfession2TextElement, true, "Profession:Other", false, false, -15);
         if (WoWTR_Localization.lang == 'AR') then
            SecondaryProfession2TextElement:SetFont(WOWTR_Font2, 10);
            SecondaryProfession2TextElement:SetJustifyH("RIGHT");
         end
      -- else
          -- print("DEBUG: SecondaryProfession2.missingText not found or nil")
      end

      -- Handle SecondaryProfession3.missingText (Apply the same check)
      if SecondaryProfession3 and SecondaryProfession3.missingText then -- ADD THIS CHECK
         local SecondaryProfession3TextElement = SecondaryProfession3.missingText
         ST_CheckAndReplaceTranslationText(SecondaryProfession3TextElement, true, "Profession:Other", false, false, -15);
         if (WoWTR_Localization.lang == 'AR') then
            SecondaryProfession3TextElement:SetFont(WOWTR_Font2, 10);
            SecondaryProfession3TextElement:SetJustifyH("RIGHT");
         end
      -- else
         -- print("DEBUG: SecondaryProfession3.missingText not found or nil")
      end

   end
end

-------------------------------------------------------------------------------------------------------

function WOWSTR_onEvent(_, event, addonName)
   --print(addonName);
   --QTR_PS["Test"] = Frame; -- search data

      if (addonName == 'Blizzard_PlayerSpells') then
         ST_Load1 = true;
         PlayerSpellsFrame:HookScript("OnShow", ST_SpellBookTranslateButton);
         PlayerSpellsFrame.SpecFrame:HookScript("OnShow", ST_updateSpecContentsHook);
         PlayerSpellsFrame.TalentsFrame:HookScript("OnShow", function() StartTicker(PlayerSpellsFrame, ST_TalentsTranslate, 0.02) end)
         HeroTalentsSelectionDialog.SpecOptionsContainer:HookScript("OnShow", ST_updateHeroTalentHook);
         
      elseif (addonName == 'Blizzard_EncounterJournal') then
         ST_load2 = true;
         EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription:HookScript("OnShow", ST_clickBosses)
         EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChildDescription:HookScript("OnShow", function() StartTicker(EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChildDescription, ST_ShowAbility, 0.1) end)
         EncounterJournal:HookScript("OnShow", function() StartTicker(EncounterJournal, ST_SuggestTabClick, 0) end)
         EncounterJournal:HookScript("OnShow", ST_AdventureGuidebutton)
         EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont:HookScript("OnShow", ST_showLoreDescription)
         
      elseif (addonName == 'Blizzard_Professions') then
         ST_load3 = true;
         ProfessionsFrame:HookScript("OnShow", function() StartTicker(ProfessionsFrame, ST_showProfessionDescription, 0) end)
         ProfessionsFrame:HookScript("OnShow", ST_ProfDescbutton)
         
      elseif (addonName == 'Blizzard_Collections') then
         ST_load4 = true;
         CollectionsJournalTitleText:HookScript("OnShow", function() StartTicker(CollectionsJournalTitleText, ST_MountJournal, 0.1) end)
         WardrobeCollectionFrame:HookScript("OnShow", function() StartTicker(WardrobeCollectionFrame, ST_HelpPlateTooltip, 0.2) end)
         MountJournalName:HookScript("OnShow", ST_MountJournalbutton)
        
      elseif (addonName == 'Blizzard_GroupFinder_VanillaStyle') then
         ST_load5 = true;
         LFGParentFrame:HookScript("OnShow", function() StartTicker(LFGParentFrame, ST_LFGListingFrame, 0.02) end)
        
      elseif (addonName == 'Blizzard_ChallengesUI') then
         ST_load6 = true;
         ChallengesFrame:HookScript("OnShow", function() StartTicker(ChallengesFrame, ST_GroupMplusFinder, 0) end)
         
      elseif (addonName == 'Blizzard_DelvesDifficultyPicker') then
         ST_load7 = true;
         DelvesDifficultyPickerFrame:HookScript("OnShow", function() StartTicker(DelvesDifficultyPickerFrame, ST_showDelveDifficultFrame, 0.2) end)
         
      elseif (addonName == 'Blizzard_ItemUpgradeUI') then
         ST_load8 = true;
         ItemUpgradeFrame:HookScript("OnShow", function() StartTicker(ItemUpgradeFrame, ST_ItemUpgradeFrm, 0.2) end)
         
      elseif (addonName == 'Blizzard_WeeklyRewards') then
         ST_load9 = true;
         WeeklyRewardsFrame:HookScript("OnShow", function() StartTicker(WeeklyRewardsFrame, ST_WeeklyRewardsFrame, 0.2) end) 
         
      elseif (addonName == 'Blizzard_TrainerUI') then
         ST_load10 = true;
         ClassTrainerFrame:HookScript("OnShow", function() StartTicker(ClassTrainerFrame, ST_ClassTrainerPanel, 0.02) end);
   
      elseif (addonName == 'Blizzard_ProfessionsBook') then
         ST_load11 = true;
         ProfessionsBookFrame:HookScript("OnShow", function() StartTicker(ProfessionsBookFrame, ST_ProfessionEmptyText, 0.02) end)
   
      elseif (addonName == 'Blizzard_MacroUI') then
         --ST_load12 = true;
         MacroFrame:HookScript("OnShow", function() StartTicker(MacroFrame, ST_MacroFrame, 0.02) end)
   
      elseif (addonName == 'Blizzard_AuctionUI') then
         --ST_load12 = true;
         AuctionFrame:HookScript("OnShow", function() StartTicker(AuctionFrame, ST_AuctionHouse, 0.02) end)
      end
   
      if (ST_load1 and ST_load2 and ST_load3 and ST_load4 and ST_load5 and ST_load6 and ST_load7 and ST_load8 and ST_load9 and ST_load10 and ST_load11) then    -- otworzono wszystkie dodatki Blizzarda
         WOWSTR:UnregisterEvent("ADDON_LOADED");      -- wyłącz  nasłuchiwanie
      end
   end

-------------------------------------------------------------------------------------------------------

function ST_SpellBookTranslateButton()
   if (ST_PM["active"] == "1") then
      -- Button to toggle between TR - EN for talents
      WOWTR_ToggleButtonS = CreateFrame("Button", nil, SpellBookFrame, "UIPanelButtonTemplate")
      WOWTR_ToggleButtonS:SetWidth(80)
      WOWTR_ToggleButtonS:SetHeight(13) -- Set the height to 15
      WOWTR_ToggleButtonS:SetFrameStrata("TOOLTIP")

      if (ST_PM["spell"] == "1") then
            if (WoWTR_Localization.lang == 'AR') then
               WOWTR_ToggleButtonS:SetText(QTR_ReverseIfAR(WoWTR_Localization.WoWTR_Spellbook_trDESC))
               WOWTR_ToggleButtonS:GetFontString():SetFont(WOWTR_Font2, 7)
            else
               WOWTR_ToggleButtonS:SetText(WoWTR_Localization.WoWTR_Spellbook_trDESC)
               WOWTR_ToggleButtonS:GetFontString():SetFont(WOWTR_ToggleButtonS:GetFontString():GetFont(), 7)
            end
      else
            WOWTR_ToggleButtonS:SetText(WoWTR_Localization.WoWTR_Spellbook_enDESC)
            WOWTR_ToggleButtonS:GetFontString():SetFont(WOWTR_ToggleButtonS:GetFontString():GetFont(), 7)
      end

      WOWTR_ToggleButtonS:ClearAllPoints()
      WOWTR_ToggleButtonS:SetPoint("TOPLEFT", PlayerSpellsFrame, "TOPRIGHT", -110, 0)
      WOWTR_ToggleButtonS:SetScript("OnClick", STspell_ON_OFF)
      PlayerSpellsFrame:HookScript("OnHide", function() WOWTR_ToggleButtonS:Hide() end)
   end
end
     
-------------------------------------------------------------------------------------------------------
   
function ST_SuggestTabClick()
--print("SuggestTab clicked");
   if (TT_PS["ui5"] == "1") then
      local obj0 = EncounterJournalInstanceSelect.Title;
      ST_CheckAndReplaceTranslationText(obj0, true, "Dungeon&Raid:Suggest:SuggestTittle",false,false);
      
      local obj1 = EncounterJournalSuggestFrame.Suggestion1.centerDisplay.description.text;
      local title1 = EncounterJournalSuggestFrame.Suggestion1.centerDisplay.title.text:GetText() or "?";
      ST_CheckAndReplaceTranslationText(obj1, true, "Dungeon&Raid:Suggest:"..title1);
      
      local obj2 = EncounterJournalSuggestFrame.Suggestion2.centerDisplay.description.text;
      local title2 = EncounterJournalSuggestFrame.Suggestion2.centerDisplay.title.text:GetText() or "?";
      ST_CheckAndReplaceTranslationText(obj2, true, "Dungeon&Raid:Suggest:"..title2);

      local obj3 = EncounterJournalSuggestFrame.Suggestion3.centerDisplay.description.text;
      local title3 = EncounterJournalSuggestFrame.Suggestion3.centerDisplay.title.text:GetText() or "?";
      ST_CheckAndReplaceTranslationText(obj3, true, "Dungeon&Raid:Suggest:"..title3);

      local obj4 = EncounterJournalMonthlyActivitiesFrame.BarComplete.AllRewardsCollectedText; -- https://imgur.com/KE3uW72
      ST_CheckAndReplaceTranslationText(obj4, true, "ui");

      local obj5 = EncounterJournalTitleText;                            -- https://imgur.com/KE3uW72
      ST_CheckAndReplaceTranslationText(obj5, true, "ui");

      local obj6 = EncounterJournalMonthlyActivitiesFrame.HeaderContainer.Month;         -- https://imgur.com/KE3uW72
      ST_CheckAndReplaceTranslationText(obj6, true, "ui");

      local obj7 = EncounterJournalMonthlyActivitiesFrame.HeaderContainer.Title;         -- https://imgur.com/KE3uW72
      ST_CheckAndReplaceTranslationText(obj7, true, "ui");

      local obj8 = EncounterJournalMonthlyActivitiesFrame.HeaderContainer.TimeLeft;      -- https://imgur.com/KE3uW72
      ST_CheckAndReplaceTranslationText(obj8, true, "ui");

      local obj9 = EncounterJournalSuggestFrame.Suggestion1.button.Text;             -- https://imgur.com/kkPedLC
      ST_CheckAndReplaceTranslationText(obj9, true, "ui");

      local obj10 = EncounterJournalSuggestFrame.Suggestion2.centerDisplay.button.Text; -- https://imgur.com/kkPedLC
      ST_CheckAndReplaceTranslationText(obj10, true, "ui");

      local obj11 = EncounterJournalSuggestFrame.Suggestion3.centerDisplay.button.Text; -- https://imgur.com/kkPedLC
      ST_CheckAndReplaceTranslationText(obj11, true, "ui");

      local obj12 = EncounterJournalSuggestFrame.Suggestion1.reward.text;               -- https://imgur.com/kkPedLC
      ST_CheckAndReplaceTranslationText(obj12, true, "ui");
     
      local obj13 = EncounterJournalMonthlyActivitiesFrame.BarComplete.PendingRewardsText;               -- https://imgur.com/kkPedLC
      ST_CheckAndReplaceTranslationText(obj13, true, "ui");

      local obj14 = EncounterJournalMonthlyActivitiesTab.Text;  -- Tab: Traveler's Log
      if (WoWTR_Localization.lang == 'AR') then
         ST_CheckAndReplaceTranslationText(obj14, true, "ui", nil, true);
      else
         ST_CheckAndReplaceTranslationText(obj14, true, "ui");
      end

      local obj15 = EncounterJournalSuggestTab.Text;            -- Tab: Suggested Content
      if (WoWTR_Localization.lang == 'AR') then
         ST_CheckAndReplaceTranslationText(obj15, true, "ui", nil, true);
      else
         ST_CheckAndReplaceTranslationText(obj15, true, "ui");
      end

      local obj16 = EncounterJournalDungeonTab.Text;            -- Tab: Dungeons
      if (WoWTR_Localization.lang == 'AR') then
         ST_CheckAndReplaceTranslationText(obj16, true, "ui", nil, true);
      else
         ST_CheckAndReplaceTranslationText(obj16, true, "ui");
      end

      local obj17 = EncounterJournalRaidTab.Text;               -- Tab: Raids
      if (WoWTR_Localization.lang == 'AR') then
         ST_CheckAndReplaceTranslationText(obj17, true, "ui", nil, true);
      else
         ST_CheckAndReplaceTranslationText(obj17, true, "ui");
      end

      local obj18 = EncounterJournalLootJournalTab.Text;        -- Tab: Item Sets
      if (WoWTR_Localization.lang == 'AR') then
         ST_CheckAndReplaceTranslationText(obj18, true, "ui", nil, true);
      else
         ST_CheckAndReplaceTranslationText(obj18, true, "ui");
      end
   end
end

-------------------------------------------------------------------------------------------------------

function ST_showLoreDescription()
--print("show LoreDescription");
 if (TT_PS["ui5"] == "1") then
   local ST_Dungeon_Raid_zone = EncounterJournalEncounterFrameInstanceFrame.title:GetText() or "?";
   local ST_loreDescription = EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont.ScrollBox.FontStringContainer.FontString;
   ST_CheckAndReplaceTranslationText(ST_loreDescription, true, "Dungeon&Raid:Zone:"..ST_Dungeon_Raid_zone);
   local ST_loreShowmap = EncounterJournalEncounterFrameInstanceFrameMapButtonText;
   ST_CheckAndReplaceTranslationText(ST_loreShowmap, true, "ui");
 end
end

-------------------------------------------------------------------------------------------------------
-- PROFESSION FRAME - Function to work in harmony with the CraftSim plugin.
local professionFrameCheckTimer
local function CheckAndHookProfessionsFrame()
    if ProfessionsFrame and not ProfessionsFrame.hooked then
        ProfessionsFrame:HookScript("OnShow", function() 
            StartTicker(ProfessionsFrame, ST_showProfessionDescription, 0) 
        end)
        ProfessionsFrame:HookScript("OnShow", ST_ProfDescbutton)
        ProfessionsFrame.hooked = true
        return true
    end
    return false
end
local function StartProfessionsFrameCheck()
    professionFrameCheckTimer = C_Timer.NewTicker(1, function()
        if CheckAndHookProfessionsFrame() then
            -- ProfessionsFrame bulundu ve hook'landı, ticker'ı durdurabiliriz
            if professionFrameCheckTimer then
                professionFrameCheckTimer:Cancel()
                professionFrameCheckTimer = nil
            end
        end
    end)
end
StartProfessionsFrameCheck()
-------------------------------------------------------------------------------------------------------

--PROFESSION FRAME, TEXT and OTHER TRANSLATE-----------------------------------------------------------
function ST_showProfessionDescription() 
--print("ST_showProfessionDescription");
   if (TT_PS["ui7"] == "1") then
      local PRobj01 = ProfessionsFrame.CraftingPage.SchematicForm.Description; -- https://imgur.com/BswVlBQ
      local prof_title = ProfessionsFrame.CraftingPage.SchematicForm.OutputText:GetText() or "?";
      local prof_name = ProfessionsFrameTitleText:GetText() or "?";
      ST_CheckAndReplaceTranslationTextUI(PRobj01, true, "Profession:"..ST_RenkKoduSil(prof_name)..":"..ST_RenkKoduSil(prof_title));
      
      local PRobj02 = ProfessionsFrame.SpecPage.TreeView.TreeDescription; -- https://imgur.com/7iBBl30
      ST_CheckAndReplaceTranslationTextUI(PRobj02, false, "");       -- don't save untranslated text
      
      local PRobj03 = ProfessionsFrame.SpecPage.TreePreview.Description; -- https://imgur.com/iwhgxcy
      ST_CheckAndReplaceTranslationTextUI(PRobj03, false, "");    -- don't save untranslated text
      
      local PRobj04 = ProfessionsFrame.SpecPage.TreePreview.Highlight1.Description; -- https://imgur.com/SeLUJey
      ST_CheckAndReplaceTranslationTextUI(PRobj04, true, "Profession:"..ST_RenkKoduSil(prof_name)..":Other");
      
      local PRobj05 = ProfessionsFrame.SpecPage.TreePreview.Highlight2.Description; -- https://imgur.com/sIPdOx6
      ST_CheckAndReplaceTranslationTextUI(PRobj05, true, "Profession:"..ST_RenkKoduSil(prof_name)..":Other");
      
      local PRobj06 = ProfessionsFrame.SpecPage.TreePreview.Highlight3.Description; -- https://imgur.com/7sH7ygf
      ST_CheckAndReplaceTranslationTextUI(PRobj06, true, "Profession:"..ST_RenkKoduSil(prof_name)..":Other");
      
      local PRobj07 = ProfessionsFrame.SpecPage.TreePreview.Highlight4.Description; -- https://imgur.com/ZnJrOjS
      ST_CheckAndReplaceTranslationTextUI(PRobj07, true, "Profession:"..ST_RenkKoduSil(prof_name)..":Other");
      
      local PRobj08 = ProfessionsFrame.CraftingPage.SchematicForm.Details.Label; -- https://imgur.com/piy41yl
      ST_CheckAndReplaceTranslationTextUI(PRobj08, true, "Profession:Other");
      
      local PRobj09 = ProfessionsFrame.SpecPage.TreePreview.HighlightsHeader; -- https://imgur.com/4CrqODj
      ST_CheckAndReplaceTranslationTextUI(PRobj09, true, "Profession:Other");
      
      local PRobj10 = ProfessionsFrame.SpecPage.ViewPreviewButton.Text; -- https://imgur.com/ZhTfjUH
      ST_CheckAndReplaceTranslationTextUI(PRobj10, true, "Profession:Other");
      
      local PRobj11 = ProfessionsFrame.SpecPage.BackToFullTreeButton.Text; -- https://imgur.com/5iEFYpV
      ST_CheckAndReplaceTranslationTextUI(PRobj11, true, "Profession:Other");
      
      local PRobj12 = ProfessionsFrame.SpecPage.DetailedView.SpendPointsButton.Text; -- https://imgur.com/KmjEPCc
      ST_CheckAndReplaceTranslationTextUI(PRobj12, true, "Profession:Other");
      
      local PRobj13 = ProfessionsFrame.SpecPage.DetailedView.UnlockPathButton.Text; -- https://imgur.com/zR0RamH
      ST_CheckAndReplaceTranslationTextUI(PRobj13, true, "Profession:Other");
      
      local PRobj14 = ProfessionsFrame.SpecPage.ApplyButton.Text; -- https://imgur.com/1RqSqU2
      ST_CheckAndReplaceTranslationTextUI(PRobj14, true, "Profession:Other");

      local PRobj15 = ProfessionsFrame.SpecPage.ViewTreeButton.Text; 
      ST_CheckAndReplaceTranslationTextUI(PRobj15, true, "Profession:Other");

      local PRobj16 = ProfessionsFrame.CraftingPage.SchematicForm.Details.CraftingChoicesContainer.FinishingReagentSlotContainer.Label; -- https://imgur.com/PIAUMIB
      ST_CheckAndReplaceTranslationTextUI(PRobj16, true, "Profession:Other");

      -- local PRobj17 = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox.Text; -- https://imgur.com/XDbs3N5
      -- ST_CheckAndReplaceTranslationTextUI(PRobj17, true, "Profession:Other");

      local PRobj18 = ProfessionsFrame.CraftingPage.SchematicForm.FirstCraftBonus.Text; -- https://imgur.com/2N0WWfd
      ST_CheckAndReplaceTranslationTextUI(PRobj18, true, "Profession:Other");
      
      local PRobj19 = ProfessionsFrame.CraftingPage.SchematicForm.RecipeSourceButton.Text; -- https://imgur.com/W3mmU92
      ST_CheckAndReplaceTranslationTextUI(PRobj19, true, "Profession:Other");

      local PRobj20 = ProfessionsFrame.CraftingPage.SchematicForm.Reagents.Label; -- https://imgur.com/3C9smY0
      ST_CheckAndReplaceTranslationTextUI(PRobj20, true, "Profession:Other");

      local PRobj21 = ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents.Label; -- https://imgur.com/oaYzd5v
      ST_CheckAndReplaceTranslationTextUI(PRobj21, true, "Profession:Other");

      -- local PRobj22 = ProfessionsFrame.CraftingPage.SchematicForm.TrackRecipeCheckBox.Text; -- https://imgur.com/jZcvEE9
      -- ST_CheckAndReplaceTranslationTextUI(PRobj22, true, "Profession:Other");

      local PRobj23 = ProfessionsFrame.CraftingPage.SchematicForm.RecraftingDescription; -- https://imgur.com/ihYuF3m
      ST_CheckAndReplaceTranslationTextUI(PRobj23, true, "Profession:Other");
      
      local PRobj24 = ProfessionsFrame.SpecPage.UnlockTabButton.Text; -- https://imgur.com/TSpN8BY
      ST_CheckAndReplaceTranslationTextUI(PRobj24, true, "Profession:Other");

      local PRobj25 = ProfessionsFrame.CraftingPage.RecipeList.FilterDropdown.Text;
      ST_CheckAndReplaceTranslationTextUI(PRobj25, true, "ui");
   end
end

local isProfButtonCreated = false
local ProfupdateVisibility
function ST_ProfDescbutton()
    if not isProfButtonCreated then
        TT_PS = TT_PS or { ui7 = "1" }

    local ProfupdateVisibility = CreateToggleButton(
        ProfessionsFrame,
        TT_PS,
        "ui7",
        WoWTR_Localization.WoWTR_enDESC,
        WoWTR_Localization.WoWTR_trDESC,
        {"TOPLEFT", ProfessionsFrame, "TOPRIGHT", -170, 0},
        function()
            ST_showProfessionDescription()
            if ProfessionsFrame.CraftingPage.SchematicForm then
                ProfessionsFrame.CraftingPage.SchematicForm:Hide()
                ProfessionsFrame.CraftingPage.SchematicForm:Show()
            end
        end
    )
        isProfButtonCreated = true -- Mark that the button has been created to avoid duplication.
    end

    -- Adjust visibility of the existing button
    if ProfupdateVisibility then
        ProfupdateVisibility()
    end
end

-------------------------------------------------------------------------------------------------------

--DelveDifficultFrame, TEXT and OTHER TRANSLATE
function ST_showDelveDifficultFrame() 
--print("show DelveDifficultFrame");
   -- if (TT_PS["ui7"] == "1") then
      local DelveDF01 = DelvesDifficultyPickerFrame.Description; -- https://imgur.com/a/SAyXuiR
      if (WoWTR_Localization.lang == 'AR') then
         ST_CheckAndReplaceTranslationText(DelveDF01, true, "Dungeon&Raid:Zone:DelvesFrame",false,false);       -- save untranslated text
      else
         ST_CheckAndReplaceTranslationTextUI(DelveDF01, true, "Dungeon&Raid:Zone:DelvesFrame");       -- save untranslated text
      end
      
      local DelveDF02 = DelvesDifficultyPickerFrame.EnterDelveButton.Text; -- https://imgur.com/a/SAyXuiR
      ST_CheckAndReplaceTranslationTextUI(DelveDF02, false, "ui");       -- dont save untranslated text

      local DelveDF03 = DelvesDifficultyPickerFrame.DelveRewardsContainerFrame.RewardText; -- https://imgur.com/a/SAyXuiR
      ST_CheckAndReplaceTranslationTextUI(DelveDF03, false, "ui");       -- dont save untranslated text

      local DelveDF04 = DelvesDifficultyPickerFrame.ScenarioLabel; -- https://imgur.com/a/SAyXuiR
      ST_CheckAndReplaceTranslationTextUI(DelveDF04, false, "ui");       -- dont save untranslated text

      local DelveDF05 = DelvesDifficultyPickerFrame.Title; -- https://imgur.com/a/SAyXuiR
      ST_CheckAndReplaceTranslationTextUI(DelveDF05, true, "Dungeon&Raid:Zone:DelvesFrame");       -- dont save untranslated text
   -- end
end

-------------------------------------------------------------------------------------------------------

function ST_UpdateJournalEncounterBossInfo(ST_bossName)
   if not ST_bossName or TT_PS["ui5"] ~= "1" then return end

local function updateElement(element, prefix, ST_corr)
    if not element then return end  -- Element nil ise fonksiyondan çık

    local originalText
    if element.GetText and type(element.GetText) == "function" then
        originalText = element:GetText()
    elseif element.Text and element.Text.GetText and type(element.Text.GetText) == "function" then
        originalText = element.Text:GetText()
    else
        return  -- GetText metodu bulunamadı, fonksiyondan çık
    end

    if not originalText then return end  -- Metin alınamadıysa fonksiyondan çık

    local hash = StringHash(ST_UsunZbedneZnaki(originalText))
    local hasTranslation = ST_TooltipsHS[hash] ~= nil

    ST_CheckAndReplaceTranslationText(element, true, prefix .. ST_bossName, WOWTR_Font2, false, ST_corr)

    local alignment = (hasTranslation and WoWTR_Localization.lang == 'AR') and "RIGHT" or "LEFT"
    
    local function safeSetJustifyH(obj, textType)
        if obj.SetJustifyH then
            pcall(function()
                obj:SetJustifyH(textType, alignment)
            end)
        end
    end

    if element.tooltipFrame and element.tooltipFrame:IsObjectType("GameTooltip") then
        local textTypes = {"p", "h1", "h2", "h3"}
        for _, textType in ipairs(textTypes) do
            safeSetJustifyH(element, textType)
        end
    else
        safeSetJustifyH(element)
    end

    if element.Text then
        local textTypes = {"p", "h1", "h2", "h3"}
        for _, textType in ipairs(textTypes) do
            safeSetJustifyH(element.Text, textType)
        end
    end
end

   local elements = {
       {EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription, "Dungeon&Raid:Boss:", -5},
       {EncounterJournalEncounterFrameInfo.overviewScroll.child.overviewDescription, "Dungeon&Raid:Boss:"},
       {EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChildDescription, "Dungeon&Raid:Boss:"},
       {EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle, "ui"}
   }

   for _, element in ipairs(elements) do
       updateElement(element[1], element[2], element[3])
   end

   local overviewDesc = EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild.overviewDescription
   local descText = overviewDesc.Text
   local originalText = overviewDesc.textString

   if originalText then
       ST_SaveOriginalText(ST_bossName, originalText)

       local hash = StringHash(ST_UsunZbedneZnaki(originalText))
       local hasTranslation = ST_TooltipsHS[hash] ~= nil

       local tempObj = {
           GetText = function() return originalText end,
           SetText = function(self, text) 
               if descText then
                   descText:SetText(text)
                   ST_UpdateBossDescriptionFont(descText)
                   if hasTranslation and WoWTR_Localization.lang == 'AR' then
                       local textTypes = {"p", "h1", "h2", "h3"}
                       for _, textType in ipairs(textTypes) do
                           pcall(function()
                               descText:SetJustifyH(textType, "RIGHT")
                           end)
                       end
                   else
                       local textTypes = {"p", "h1", "h2", "h3"}
                       for _, textType in ipairs(textTypes) do
                           pcall(function()
                               descText:SetJustifyH(textType, "LEFT")
                           end)
                       end
                   end
               end
           end,
           GetWidth = function() return descText and descText:GetWidth() end,
           GetRegions = function() return descText and descText:GetRegions() end
       }
       
       ST_CheckAndReplaceTranslationText(tempObj, true, "Dungeon&Raid:Boss:" .. ST_bossName, WOWTR_Font2, false, -120)
   end

   local rootButton = EncounterJournalEncounterFrameInfoRootButton
   if rootButton then
       rootButton:SetText(WoWTR_Localization.lang == 'AR' and ">" or "<")
   end

   ST_BossHeaderTabText()
end

function ST_SaveOriginalText(bossName, text)
    if not ST_OriginalTexts then
        ST_OriginalTexts = {}
    end
    ST_OriginalTexts[bossName] = text
    -- Here you can save the text permanently, for example, to a file or database
end

function ST_BossHeaderTabText()
    local tabs = {
        EncounterJournalEncounterFrameInfoOverviewTab,
        EncounterJournalEncounterFrameInfoLootTab,
        EncounterJournalEncounterFrameInfoBossTab,
        EncounterJournalEncounterFrameInfoModelTab
    }

    for _, tab in ipairs(tabs) do
        ST_CheckAndReplaceTranslationText(tab, false, "ui", WOWTR_Font2, false, 0)
    end
end

function ST_UpdateBossDescriptionFont(descText)
   if not descText then return end
   
   local textTypes = {"p", "h1", "h2", "h3"}
   for _, textType in ipairs(textTypes) do
       local alignment = (WoWTR_Localization.lang == 'AR') and "RIGHT" or "LEFT"
       if descText.SetJustifyH then
           descText:SetJustifyH(textType, alignment)
       end
       if descText.SetFont then
           descText:SetFont(textType, WOWTR_Font2, 12, "")
       end
       if descText.SetFontObject then
           local fontName = "WOWTRBossDescFont_" .. textType
           local fontObj = CreateFont(fontName)
           fontObj:SetFont(WOWTR_Font2, 12, "")
           fontObj:SetJustifyH(alignment)
           descText:SetFontObject(textType, fontObj)
       end
   end
end

function ST_UpdateBossDescriptionFont(textObject)
    if not textObject then return end
    
    -- Create a custom font object
    local fontName = "WOWTRBossDescFont"
    local font = CreateFont(fontName)
    font:SetFont(WOWTR_Font2, 12, "")
    
    -- Set the font for each text type of the SimpleHTML object
    local textTypes = {"p", "h1", "h2", "h3"}
    for _, textType in ipairs(textTypes) do
        if textObject.SetFont then
            textObject:SetFont(textType, WOWTR_Font2, 12, "")
        end
        if textObject.SetFontObject then
            textObject:SetFontObject(textType, font)
        end
    end
end

function ST_clickBosses()
   local previousText = ""
   local function OnUpdateHandler()
       local currentText = EncounterJournalEncounterFrameInfoEncounterTitle:GetText()
       if currentText and currentText ~= previousText then
           -- Get the boss name from the navigation bar
           local ST_bossName = EncounterJournalNavBarButton3Text:GetText()
           -- Update boss info
           ST_UpdateJournalEncounterBossInfo(ST_bossName)
           -- Update previousText
           previousText = currentText

           -- Add “ ” at the end of the text (only once)
           if not string.find(currentText, " $") then
               local modifiedText = currentText .. " "
               EncounterJournalEncounterFrameInfoEncounterTitle:SetText(modifiedText)
           end
       end
   end

   local frame = CreateFrame("Frame")
   frame:SetScript("OnUpdate", OnUpdateHandler)
end


local isEJournalButtonCreated = false
local EncounterJournalupdateVisibility
function ST_AdventureGuidebutton()
    if not isEJournalButtonCreated then
        TT_PS = TT_PS or { ui5 = "1" }

      EncounterJournalupdateVisibility = CreateToggleButton(
         EncounterJournal,
         TT_PS,
         "ui5",
         WoWTR_Localization.WoWTR_enDESC,
         WoWTR_Localization.WoWTR_trDESC,
         {"TOPLEFT", EncounterJournal, "TOPRIGHT", -170, 0},
         function()
            ST_clickBosses()
            if EncounterJournal then
               EncounterJournal:Hide()
               EncounterJournal:Show()
               -- Butonun temizlenmesi için burada gerekli işlemleri yapabilirsiniz
            end
         end
        )

        isEJournalButtonCreated = true -- Butonlar ilk kez oluşturulunca işaretleyin
    end

    if EncounterJournalupdateVisibility then
       EncounterJournalupdateVisibility()
    end
end
-------------------------------------------------------------------------------------------------------

function ST_ShowAbility()            -- sprawdzanie tekstów Ability
  if (TT_PS["ui5"] == "1") then
   for i = 1, 99, 1 do
      if (_G["EncounterJournalInfoHeader"..i.."Description"]) then
         local obj = _G["EncounterJournalInfoHeader"..i.."Description"];
         local obj1= _G["EncounterJournalInfoHeader"..i];
         local obj2= _G["EncounterJournalInfoHeader"..i.."DescriptionBG"];
         local txt = obj:GetText();

         ST_CheckAndReplaceTranslationText(obj, true, "Dungeon&Raid:Ability:".._G["EncounterJournalInfoHeader"..i.."HeaderButton"].title:GetText());
         local ST_bossDescription2 = EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChildDescription;
         ST_CheckAndReplaceTranslationText(ST_bossDescription2, false);
      end
   end
  end
end

-------------------------------------------------------------------------------------------------------

function ST_BossHeaderTabText()
   if (TT_PS["ui5"] == "1") then
    local ST_bossName = EncounterJournalNavBarButton3Text:GetText()

    local headers = {
        EncounterJournalOverviewInfoHeader1,
        EncounterJournalOverviewInfoHeader2,
        EncounterJournalOverviewInfoHeader3
    }

    for index, header in ipairs(headers) do
        if header then
            local bulletsTable = header.Bullets

            if bulletsTable then
                for _, bulletData in ipairs(bulletsTable) do
                    if bulletData.Text and bulletData.Text.GetTextData then
                        local textData = bulletData.Text:GetTextData()
                        if textData then
                            for text_index, textInfo in ipairs(textData) do
                                if textInfo.text then
                                    local metin = textInfo.text
                                    
                                    -- Create a temporary object to handle text replacement
                                    local tempObj = {
                                        GetText = function() return metin end,
                                        SetText = function(self, text)
                                            bulletData.Text:SetText(text)
                                            -- Update font/style if needed
                                            ST_UpdateBossDescriptionFont(bulletData.Text)
                                        end
                                    }
                                    
                                    local prefix = "Dungeon&Raid:Boss:" .. ST_bossName
                                    ST_CheckAndReplaceTranslationText(tempObj, true, prefix, nil, false, nil)
                                end
                            end
                        end
                    end
                end
            else
                -- Uncomment for debugging: print("Bullets table not found for Header " .. index)
            end
        else
            -- Uncomment for debugging: print("Header " .. index .. " not found.")
        end
    end
      local HeaderTitle1 = EncounterJournalOverviewInfoHeader1HeaderButtonTitle;
      ST_CheckAndReplaceTranslationText(HeaderTitle1, true, "ui");
      local HeaderTitle2 = EncounterJournalOverviewInfoHeader2HeaderButtonTitle;
      ST_CheckAndReplaceTranslationText(HeaderTitle2, true, "ui");
      local HeaderTitle3 = EncounterJournalOverviewInfoHeader3HeaderButtonTitle;
      ST_CheckAndReplaceTranslationText(HeaderTitle3, true, "ui");
   end
end

-------------------------------------------------------------------------------------------------------

--StaticPopup1 and StaticPopup1 WINDOW
function ST_StaticPopup1()
--print(StaticPopup1Text:GetText());
   if (TT_PS["ui1"] == "1") then
      local SPobj01 = StaticPopup1Text;
      ST_CheckAndReplaceTranslationTextUI(SPobj01, true, "h@popuptext-ui"); -- Dodano znacznik "h" do kontroli danych od użytkowników.

      local SPobj02 = StaticPopup1Button1Text;
      ST_CheckAndReplaceTranslationTextUI(SPobj02, true, "h@popupbutton-ui"); -- Dodano znacznik "h" do kontroli danych od użytkowników.

      local SPobj03 = StaticPopup1Button2Text;
      ST_CheckAndReplaceTranslationTextUI(SPobj03, true, "h@popupbutton-ui"); -- Dodano znacznik "h" do kontroli danych od użytkowników.

      local SPobj04 = StaticPopup1Button3Text;
      ST_CheckAndReplaceTranslationTextUI(SPobj04, true, "h@popupbutton-ui"); -- Dodano znacznik "h" do kontroli danych od użytkowników.

      local SPobj05 = StaticPopup1Button4Text;
      ST_CheckAndReplaceTranslationTextUI(SPobj05, true, "h@popupbutton-ui"); -- Dodano znacznik "h" do kontroli danych od użytkowników.
      
      local SPobj06 = StaticPopup2Text;
      ST_CheckAndReplaceTranslationTextUI(SPobj06, true, "h@popuptext-ui"); -- Dodano znacznik "h" do kontroli danych od użytkowników.

      local SPobj07 = StaticPopup2Button1Text;
      ST_CheckAndReplaceTranslationTextUI(SPobj07, true, "h@popupbutton-ui"); -- Dodano znacznik "h" do kontroli danych od użytkowników.

      local SPobj08 = StaticPopup2Button2Text;
      ST_CheckAndReplaceTranslationTextUI(SPobj08, true, "h@popupbutton-ui"); -- Dodano znacznik "h" do kontroli danych od użytkowników.

      local SPobj09 = StaticPopup2Button3Text;
      ST_CheckAndReplaceTranslationTextUI(SPobj09, true, "h@popupbutton-ui"); -- Dodano znacznik "h" do kontroli danych od użytkowników.

      local SPobj10 = StaticPopup2Button4Text;
      ST_CheckAndReplaceTranslationTextUI(SPobj10, true, "h@popupbutton-ui"); -- Dodano znacznik "h" do kontroli danych od użytkowników.
   end
end

-------------------------------------------------------------------------------------------------------

--WORLD MAP TITLE
function ST_WorldMapFunc()
--print("ST_WorldMapFunc");
   local wmframe01 = WorldMapFrameTitleText;
   ST_CheckAndReplaceTranslationText(wmframe01, true, "ui", false, 1);

   local wmframe02 = WorldMapFrameHomeButtonText;
   ST_CheckAndReplaceTranslationText(wmframe02, true, "ui");
end

-------------------------------------------------------------------------------------------------------

--Group Finder Frames
function ST_GroupFinder()
--print("ST_GroupFinder");
-- Dungeons & Raids
   if (TT_PS["ui3"] == "1") then
      local GFobj01 = PVEFrameTitleText;
      ST_CheckAndReplaceTranslationTextUI(GFobj01, true, "ui");

      local GFobj02 = PVEFrameTab1.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj02, true, "ui");

      local GFobj03 = PVEFrameTab2.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj03, true, "ui");

      local GFobj04 = PVEFrameTab3.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj04, true, "ui");

      local GFobj05 = GroupFinderFrameGroupButton1Name;
      ST_CheckAndReplaceTranslationText(GFobj05, true, "ui",false,true);

      local GFobj06 = GroupFinderFrameGroupButton2Name;
      ST_CheckAndReplaceTranslationTextUI(GFobj06, true, "ui");

      local GFobj07 = GroupFinderFrameGroupButton3Name;
      ST_CheckAndReplaceTranslationText(GFobj07, true, "ui",false,true);

      local GFobj08 = LFDQueueFrameTypeDropDownName;
      ST_CheckAndReplaceTranslationTextUI(GFobj08, true, "ui");

      local GFobj09 = LFDQueueFrameRandomScrollFrameChildFrameTitle;
      ST_CheckAndReplaceTranslationTextUI(GFobj09, true, "ui", WOWTR_Font1);

      local GFobj10 = LFDQueueFrameRandomScrollFrameChildFrameDescription;
      ST_CheckAndReplaceTranslationText(GFobj10, true, "ui",false,false);

      local GFobj11 = LFDQueueFrameRandomScrollFrameChildFrameRewardsLabel;
      ST_CheckAndReplaceTranslationTextUI(GFobj11, true, "ui", WOWTR_Font1);

      local GFobj12 = LFDQueueFrameRandomScrollFrameChildFrameRewardsDescription;
      ST_CheckAndReplaceTranslationText(GFobj12, true, "ui",false,false,-10);

      local GFobj13 = LFDQueueFrameFindGroupButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj13, true, "ui");

      local GFobj14 = RaidFinderQueueFrameScrollFrameChildFrameDescription;
      ST_CheckAndReplaceTranslationTextUI(GFobj14, true, "ui");

      local GFobj15 = RaidFinderQueueFrameScrollFrameChildFrameRewardsLabel;
      ST_CheckAndReplaceTranslationTextUI(GFobj15, true, "ui", WOWTR_Font1);

      local GFobj16 = RaidFinderQueueFrameScrollFrameChildFrameRewardsDescription;
      ST_CheckAndReplaceTranslationTextUI(GFobj16, true, "ui");

      local GFobj17 = RaidFinderFrameFindRaidButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj17, true, "ui");

      local GFobj18 = LFGListFrame.CategorySelection.StartGroupButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj18, true, "ui");

      local GFobj19 = LFGListFrame.CategorySelection.FindGroupButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj19, true, "ui");

      local GFobj20 = LFGListFrame.CategorySelection.Label;
      ST_CheckAndReplaceTranslationTextUI(GFobj20, true, "ui", WOWTR_Font1);

      local GFobj21 = LFGListApplicationDialog.Label; -- Choose your Roles
      ST_CheckAndReplaceTranslationTextUI(GFobj21, true, "ui");

      local GFobj22 = LFGListApplicationDialog.SignUpButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj22, true, "ui");

      local GFobj23 = LFGListApplicationDialog.CancelButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj23, true, "ui");

      local GFobj24 = LFGListFrame.SearchPanel.SignUpButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj24, true, "ui");

      local GFobj25 = LFGListFrame.SearchPanel.BackButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj25, true, "ui");

      local GFobj26 = LFGListFrame.SearchPanel.CategoryName;
      ST_CheckAndReplaceTranslationTextUI(GFobj26, true, "ui");

      local GFobj27 = LFGListFrame.EntryCreation.NameLabel;
      ST_CheckAndReplaceTranslationTextUI(GFobj27, true, "ui");

      local GFobj28 = LFGListFrame.EntryCreation.DescriptionLabel;
      ST_CheckAndReplaceTranslationTextUI(GFobj28, true, "ui");

      local GFobj29 = LFGListFrame.EntryCreation.Label;
      ST_CheckAndReplaceTranslationTextUI(GFobj29, true, "ui", WOWTR_Font1);

      local GFobj30 = LFGListInviteDialog.Label;
      ST_CheckAndReplaceTranslationTextUI(GFobj30, true, "ui");

      local GFobj31 = LFGListInviteDialog.RoleDescription;
      ST_CheckAndReplaceTranslationTextUI(GFobj31, true, "ui");

      local GFobj32 = LFGListInviteDialog.AcceptButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj32, true, "ui");

      local GFobj33 = LFGListInviteDialog.DeclineButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj33, true, "ui");

      local GFobj34 = LFGListInviteDialog.AcknowledgeButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj34, true, "ui");

      local GFobj35 = LFDQueueFrameFollowerTitle;
      ST_CheckAndReplaceTranslationTextUI(GFobj35, true, "ui", WOWTR_Font1);

      local GFobj36 = LFDQueueFrameFollowerDescription;
      ST_CheckAndReplaceTranslationTextUI(GFobj36, true, "ui");

      local GFobj37 = LFGListFrame.EntryCreation.ListGroupButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj37, true, "ui");

      local GFobj38 = LFGListFrame.SearchPanel.ScrollBox.StartGroupButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj38, true, "ui");

      local GFobj39 = LFGListFrame.SearchPanel.SearchBox.Instructions;
      ST_CheckAndReplaceTranslationTextUI(GFobj39, true, "ui");

      local GFobj40 = LFGListFrame.SearchPanel.ScrollBox.NoResultsFound;
      ST_CheckAndReplaceTranslationTextUI(GFobj40, true, "ui");

      local GFobj41 = LFGListFrame.EntryCreation.PlayStyleLabel;
      ST_CheckAndReplaceTranslationTextUI(GFobj41, true, "ui");

      local GFobj42 = LFGListCreationDescription.EditBox.Instructions;
      ST_CheckAndReplaceTranslationTextUI(GFobj42, true, "ui");

      local GFobj43 = LFGListFrame.EntryCreation.MythicPlusRating.Label;
      ST_CheckAndReplaceTranslationTextUI(GFobj43, true, "ui");

      local GFobj44 = LFGListFrame.EntryCreation.ItemLevel.Label;
      ST_CheckAndReplaceTranslationTextUI(GFobj44, true, "ui");

      local GFobj45 = LFGListFrame.EntryCreation.VoiceChat.Label;
      ST_CheckAndReplaceTranslationTextUI(GFobj45, true, "ui");

      local GFobj46 = LFGListFrame.EntryCreation.PrivateGroup.Label;
      ST_CheckAndReplaceTranslationTextUI(GFobj46, true, "ui");

      local GFobj47 = LFGListFrame.EntryCreation.CrossFactionGroup.Label;
      ST_CheckAndReplaceTranslationTextUI(GFobj47, true, "ui");

      local GFobj48 = LFGListFrame.EntryCreation.Name.Instructions;
      ST_CheckAndReplaceTranslationTextUI(GFobj48, true, "ui");

      local GFobj49 = LFGListFrame.EntryCreation.ItemLevel.EditBox.Instructions;
      ST_CheckAndReplaceTranslationTextUI(GFobj49, true, "ui");

      local GFobj50 = LFGListFrame.EntryCreation.VoiceChat.EditBox.Instructions;
      ST_CheckAndReplaceTranslationTextUI(GFobj50, true, "ui");

      local GFobj51 = LFGListFrame.EntryCreation.CancelButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj51, true, "ui");

      local GFobj52 = LFGListApplicationDialogDescription.EditBox.Instructions;
      ST_CheckAndReplaceTranslationTextUI(GFobj52, true, "ui");

      local GFobj53 = LFGListFrame.ApplicationViewer.ScrollBox.NoApplicants;
      ST_CheckAndReplaceTranslationTextUI(GFobj53, true, "ui");

      local GFobj54 = LFGListFrame.ApplicationViewer.BrowseGroupsButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj54, true, "ui");

      local GFobj55 = LFGListFrame.ApplicationViewer.RemoveEntryButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj55, true, "ui");

      local GFobj56 = LFGListFrame.ApplicationViewer.EditButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj56, true, "ui");

      local GFobj57 = LFGListFrame.SearchPanel.BackToGroupButton.Text;
      ST_CheckAndReplaceTranslationTextUI(GFobj57, true, "ui");

      local GFobj58 = LFGListFrame.ApplicationViewer.NameColumnHeader.Label;
      ST_CheckAndReplaceTranslationTextUI(GFobj58, true, "ui");

      local GFobj59 = LFGListFrame.ApplicationViewer.RoleColumnHeader.Label;
      ST_CheckAndReplaceTranslationTextUI(GFobj59, true, "ui");

      local GFobj60 = LFGListFrame.SearchPanel.SearchingSpinner.Label;
      ST_CheckAndReplaceTranslationTextUI(GFobj60, true, "ui");

      -- Utility function for applying translations to UI elements with custom font
      local function ApplyTranslationToElement(element, alignment)
         -- Check if the element is valid and has the necessary text methods
         if element and element.GetText and element.SetText then
               local originalText = element:GetText()  -- Get the current text
      
               if originalText then
                  -- --- START: Debug code to print font information ---
                  if element.GetFont then -- Check if the element supports getting font info
                     local fontFile, fontHeight, fontFlags = element:GetFont()
                     local elementName = element:GetName() -- Try to get the element's name for context
                     local parentName = element:GetParent() and element:GetParent():GetName() -- Get parent name too
      
                     --print("--- ApplyTranslationToElement Debug ---")
                     if elementName then
                           --print("Element Name:", elementName)
                     end
                     if parentName then
                           --print("Parent Name:", parentName)
                     end
                     -- If no name, maybe show the first few chars of text for context
                     if not elementName then
                           --print("Element (no name): Text starts with ->", string.sub(originalText, 1, 30))
                     end
                     --print("Original Font File:", fontFile or "N/A")
                     --print("Original Font Size:", fontHeight or "N/A")
                     -- print("Original Font Flags:", fontFlags or "N/A") -- Optional: Uncomment if you need flags
                     --print("---------------------------------------")
                  else
                        -- Optionally print if GetFont isn't supported
                        local elementName = element:GetName()
                        --print("ApplyTranslationToElement:", elementName or "Unnamed Element", "does not support GetFont()")
                  end
                  -- --- END: Debug code ---
      
                  local hash = StringHash(ST_UsunZbedneZnaki(originalText))  -- Calculate the hash
      
                  -- If a translation exists, update the text and font
                  if ST_TooltipsHS[hash] then
                     local translatedText = QTR_ReverseIfAR(ST_TooltipsHS[hash])
                     element:SetText(translatedText)  -- Set the translated text
      
                     if element.SetFont then
                           -- Use select(2,...) which is safer if GetFont returns nil
                           element:SetFont(WOWTR_Font2, select(2, element:GetFont()))
                     end
                  -- else -- No translation found
                     -- Ensure original font remains if needed (usually not necessary unless something else modified it)
                     -- if element.SetFont and fontFile and fontHeight then
                     --    element:SetFont(fontFile, fontHeight, fontFlags)
                     -- end
                  end
      
                  -- Adjust text alignment if specified
                  if alignment and element.SetJustifyH then
                     element:SetJustifyH(alignment)
                  end
               end
         end
      end

      -- Iterate through the category buttons and apply translations
      local categoryButtons = {
         LFGListFrame.CategorySelection.CategoryButtons[1],
         LFGListFrame.CategorySelection.CategoryButtons[2],
         LFGListFrame.CategorySelection.CategoryButtons[3],
         LFGListFrame.CategorySelection.CategoryButtons[4],
         LFGListFrame.CategorySelection.CategoryButtons[5],
         LFGListFrame.CategorySelection.CategoryButtons[6]
      }

      for _, button in ipairs(categoryButtons) do
         -- MODIFICATION: Check for the .Label child and pass THAT to the function
         if button and button.Label then
             -- Pass the actual Label element which holds the text and font info
             ApplyTranslationToElement(button.Label)
         elseif button then
             -- Fallback: If no Label child, try applying to the button itself (might not work for font)
             --print("Warning: Button", button:GetName(), "does not have a .Label child. Applying to button itself.")
             ApplyTranslationToElement(button)
         end
     end
   end
end

-------------------------------------------------------------------------------------------------------

function ST_LFGListingFrame()
    if (TT_PS["ui1"] == "1") then
        local function processRegion(frame)
            ST_CheckAndReplaceTranslationTextUI(frame, true, "ui")
        end

        -- Alt öğeleri işlemek için bir fonksiyon tanımlayalım
        local function processChildren(parent, childKey, startIndex, endIndex)
            local children = {parent:GetChildren()}
            for i = startIndex, endIndex do
                local child = children[i]
                if child and child[childKey] then
                    local text = child[childKey]:GetText()
                    if text then
                        -- print(childKey .. " " .. i .. " text: " .. text)
                        ST_CheckAndReplaceTranslationTextUI(child[childKey], true, "ui")
                    end
                end
            end
        end

        -- LFGListingFrameCategoryView ve LFGListingComment'ın alt öğelerini işle
        processChildren(LFGListingFrameCategoryView, "Label", 2, 5)
        processChildren(LFGListingComment, "Instructions", 2, 2)

        -- Global strings and buttons
        processRegion(LFGListingFrameFrameTitle)
        processRegion(LFGListingFrameBackButtonText)
        processRegion(LFGListingFramePostButtonText)
        processRegion(LFGParentFrameTab1Text)
        processRegion(LFGParentFrameTab2Text)
        processRegion(LFGBrowseFrameFrameTitle)
        processRegion(LFGBrowseFrameSendMessageButtonText)
        processRegion(LFGBrowseFrameGroupInviteButtonText)
        processRegion(LFGBrowseFrameCategoryDropDownText)
    end
end




-------------------------------------------------------------------------------------------------------

function ST_GroupMplusFinder()
   if TT_PS["ui3"] == "1" then
     local elements = {
       {ChallengesFrame.SeasonChangeNoticeFrame.NewSeason, "ui"},
       {ChallengesFrame.SeasonChangeNoticeFrame.SeasonDescription, "ui"},
       {ChallengesFrame.SeasonChangeNoticeFrame.SeasonDescription2, "ui"},
       {ChallengesFrame.WeeklyInfo.Child.Description, "ui"},
       {ChallengesFrame.WeeklyInfo.Child.SeasonBest, "ui"},
       {ChallengesFrame.WeeklyInfo.Child.ThisWeekLabel, "ui"},
       {ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus, "ui"},
       {ChallengesFrame.WeeklyInfo.Child.DungeonScoreInfo.Title, "ui"},
     };
 
     for _, elementData in ipairs(elements) do
       local element, prefix = unpack(elementData);
       if WoWTR_Localization.lang == 'AR' then
         ST_CheckAndReplaceTranslationText(element, true, prefix, false, false, -10);
       else
         ST_CheckAndReplaceTranslationTextUI(element, true, prefix);
       end
     end
   end
 end

-------------------------------------------------------------------------------------------------------

--MERCHANT FRAME
function ST_MerchantFrame()
--print("ST_MerchantFrame");
   if (TT_PS["ui1"] == "1") then

            local merchantFrameTexts = {
                MerchantFrameTab1Text,
                MerchantFrameTab2Text,
                MerchantPageText,
                MerchantRepairText,
            }
            for _, text in ipairs(merchantFrameTexts) do
                ST_CheckAndReplaceTranslationTextUI(text, true, "ui")
            end


            local function ProcessRegion(frame)
                ST_CheckAndReplaceTranslationTextUI(frame, true, "ui")
            end

            local regions = {
                { MerchantPrevPageButton, 1 },
                { MerchantNextPageButton, 1 }
            }
            for _, region in ipairs(regions) do
                local frame = region[1]
                for i = 2, #region do
                    ProcessRegion(select(region[i], frame:GetRegions()))
                end
            end

   end
end

-------------------------------------------------------------------------------------------------------

--GAME MENU
function ST_GameMenuTranslate()
   if (TT_PS["ui1"] == "1") then

       local gameMenuFrame = GameMenuFrame
       if gameMenuFrame then
           -- children elemanları işle
           local children = {gameMenuFrame:GetChildren()}
           for _, child in ipairs(children) do
               local fontString = child:GetFontString()
               if fontString then
                   local text = fontString:GetText()
                   ST_CheckAndReplaceTranslationTextUI(fontString, true, "ui")
               end
           end

           -- Başlık metnini işle
           local titleRegion = select(2, gameMenuFrame:GetRegions())
           if titleRegion and titleRegion:GetObjectType() == "FontString" then
               local titleText = titleRegion:GetText()
               ST_CheckAndReplaceTranslationTextUI(titleRegion, true, "ui")
           end
       end
   end
end

-------------------------------------------------------------------------------------------------------

--Collections Journal & Toys
function ST_MountJournal()
--print(ST_MountJournal);
   if (TT_PS["ui4"] == "1") then
      local CJobj01 = MountJournalLore;
      local ST_MountName = MountJournalName:GetText();
      if (WoWTR_Localization.lang == 'AR') then
         ST_CheckAndReplaceTranslationText(CJobj01, true, "Collections:Mount:"..(ST_MountName or ''),false,false,-10);
      else
         ST_CheckAndReplaceTranslationTextUI(CJobj01, true, "Collections:Mount:"..(ST_MountName or ''));  -- https://imgur.com/7INQmHh
      end

      local CJobj02 = MountJournalSummonRandomFavoriteButtonSpellName;
      ST_CheckAndReplaceTranslationText(CJobj02, false, "ui",false,false);

      local CJobj03 = MountJournal.BottomLeftInset.SlotLabel;
      ST_CheckAndReplaceTranslationTextUI(CJobj03, false, "ui");

      local CJobj04 = MountJournal.MountDisplay.ModelScene.TogglePlayer.TogglePlayerText;
      ST_CheckAndReplaceTranslationTextUI(CJobj04, false, "ui");

      local CJobj05 = MountJournal.MountCount.Label;
      ST_CheckAndReplaceTranslationTextUI(CJobj05, false, "ui");

      local CJobj06 = CollectionsJournalTitleText;
      ST_CheckAndReplaceTranslationTextUI(CJobj06, false, "ui");

      local CJobj07 = MountJournalMountButton.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj07, false, "ui");

      local CJobj13 = WardrobeCollectionFrameTab1.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj13, false, "ui");

      local CJobj14 = WardrobeCollectionFrameTab2.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj14, false, "ui");

      local CJobj15 = MountJournalSearchBox.Instructions;
      ST_CheckAndReplaceTranslationTextUI(CJobj15, false, "ui");

      local CJobj16 = PetJournalSearchBox.Instructions;
      ST_CheckAndReplaceTranslationTextUI(CJobj16, false, "ui");

      local CJobj17 = PetJournal.PetCount.Label;
      ST_CheckAndReplaceTranslationTextUI(CJobj17, false, "ui");

      local CJobj18 = PetJournalSummonButton.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj18, false, "ui");

      local CJobj19 = PetJournalFindBattle.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj19, false, "ui");

      local CJobj20 = PetJournalSummonRandomFavoritePetButtonSpellName;
      if (WoWTR_Localization.lang == 'AR') then
         ST_CheckAndReplaceTranslationText(CJobj20, false, "ui",false,false);
      else
         ST_CheckAndReplaceTranslationTextUI(CJobj20, false, "ui");
      end

      local CJobj21 = PetJournalHealPetButtonSpellName;
      if (WoWTR_Localization.lang == 'AR') then
         ST_CheckAndReplaceTranslationText(CJobj21, false, "ui",false,false);
      else
         ST_CheckAndReplaceTranslationTextUI(CJobj21, false, "ui");
      end

      local CJobj22 = MountJournal.FilterDropdown.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj22, false, "ui");

      local CJobj23 = PetJournal.FilterDropdown.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj23, false, "ui");

      local CJobj24 = ToyBox.searchBox.Instructions;
      ST_CheckAndReplaceTranslationTextUI(CJobj24, false, "ui");

      local CJobj25 = ToyBox.FilterDropdown.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj25, false, "ui");

      local CJobj26 = ToyBox.PagingFrame.PageText;
      ST_CheckAndReplaceTranslationTextUI(CJobj26, false, "ui");

      local CJobj27 = HeirloomsJournalSearchBox.Instructions;
      ST_CheckAndReplaceTranslationTextUI(CJobj27, false, "ui");

      local CJobj28 = HeirloomsJournal.FilterDropdown.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj28, false, "ui");

      local CJobj29 = HeirloomsJournal.PagingFrame.PageText;
      ST_CheckAndReplaceTranslationTextUI(CJobj29, false, "ui");

      local CJobj30 = WardrobeCollectionFrameSearchBox.Instructions;
      ST_CheckAndReplaceTranslationTextUI(CJobj30, false, "ui");

      local CJobj31 = WardrobeCollectionFrame.FilterButton.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj31, false, "ui");

      local CJobj32 = WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame.PageText;
      ST_CheckAndReplaceTranslationTextUI(CJobj32, false, "ui");

      -- for i = 1, 18 do
         -- local CJToys = ToyBox.iconsFrame["spellButton"..i].name;
         -- ST_CheckAndReplaceTranslationTextUI(CJToys, true, "toyname");
      -- end
   end
   
   if (TT_PS["ui5"] == "1") then
      local CJobj08 = CollectionsJournalTab1.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj08, false, "ui");

      local CJobj09 = CollectionsJournalTab2.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj09, false, "ui");

      local CJobj10 = CollectionsJournalTab3.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj10, false, "ui");

      local CJobj11 = CollectionsJournalTab4.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj11, false, "ui");

      local CJobj12 = CollectionsJournalTab5.Text;
      ST_CheckAndReplaceTranslationTextUI(CJobj12, false, "ui");
   end
end

local isMountButtonCreated = false
local mountUpdateVisibility

function ST_MountJournalbutton()
    if not isMountButtonCreated then
        TT_PS = TT_PS or { ui4 = "1" }

        mountUpdateVisibility = CreateToggleButton(
            MountJournal,
            TT_PS,
            "ui4",
            WoWTR_Localization.WoWTR_enDESC,
            WoWTR_Localization.WoWTR_trDESC,
            {"TOPLEFT", MountJournal, "TOPRIGHT", -170, 0},
            function()
                ST_MountJournal()
                -- You can add any necessary refresh logic here for the mount journal.
            end
        )

        isMountButtonCreated = true -- Mark that the button has been created to avoid duplication.
    end

    -- Adjust visibility of the existing button
    if mountUpdateVisibility then
        mountUpdateVisibility()
    end
end

-------------------------------------------------------------------------------------------------------

--CHARACTER FRAME
function ST_CharacterFrame() -- https://imgur.com/FV5MXvb
--print("ST_CharacterFrame");
   if (TT_PS["ui2"] == "1") then
      -- local ChFrame1 = CharacterStatsPane.ItemLevelCategory.Title;    -- Item Level
      -- ST_CheckAndReplaceTranslationTextUI(ChFrame1, true, "ui");

      -- local ChFrame2 = CharacterStatsPane.AttributesCategory.Title;   -- Attributes
      -- ST_CheckAndReplaceTranslationTextUI(ChFrame2, true, "ui");

      local ChFrame3 = SkillFrameCancelButtonText; -- Enhancements
      ST_CheckAndReplaceTranslationTextUI(ChFrame3, true, "ui");

      local ChFrame4 = CharacterFrameTab1Text;                       -- Character Tab
      ST_CheckAndReplaceTranslationTextUI(ChFrame4, true, "ui");

      local ChFrame5 = CharacterFrameTab2Text;                       -- Reputation Tab
      ST_CheckAndReplaceTranslationTextUI(ChFrame5, true, "ui");

      local ChFrame6 = CharacterFrameTab3Text;                       -- Currency Tab
      ST_CheckAndReplaceTranslationTextUI(ChFrame6, true, "ui");

      local ChFrame7 = ReputationDetailFactionDescription;
      local RDFactionName = ReputationDetailFactionName:GetText(); -- Get the Faction Name
      ST_CheckAndReplaceTranslationTextUI(ChFrame7, true, "Factions:" .. ST_RenkKoduSil(RDFactionName));
      
      local ChFrame8 = ReputationDetailAtWarCheckboxText;             -- Check Box Text - At War
      ST_CheckAndReplaceTranslationTextUI(ChFrame8, true, "ui");

      local ChFrame9 = ReputationDetailInactiveCheckboxText;          -- Check Box Text - Move to Inactive
      ST_CheckAndReplaceTranslationTextUI(ChFrame9, true, "ui");

      local ChFrame10 = ReputationDetailMainScreenCheckboxText;       -- Check Box Text - Show as Experience Bar
      ST_CheckAndReplaceTranslationTextUI(ChFrame10, true, "ui");

      local function processButtonText(button)
         if button and button:IsObjectType("Button") then
            local fontString = button:GetFontString()
            if fontString then
                  ST_CheckAndReplaceTranslationTextUI(fontString, true, "ui")
            else
                  -- Eğer fontString bulunamazsa, SetText metodunu kullanarak mevcut metni alıp işleyebiliriz
                  local currentText = button:GetText()
                  if currentText then
                     local newText = ST_CheckAndReplaceTranslationTextUI(currentText, true, "ui")
                     button:SetText(newText)
                  end
            end
         end
      end

      -- local ChFrame11 = ReputationFrame.ReputationDetailFrame.ViewRenownButton
      -- processButtonText(ChFrame11)

      local ChFrame12 = ReputationFrameFactionLabel;
      ST_CheckAndReplaceTranslationTextUI(ChFrame12, true, "ui");

      local ChFrame13 = ReputationFrameStandingLabel;       -- TokenFramePopup Unused Text
      ST_CheckAndReplaceTranslationTextUI(ChFrame13, true, "ui");

      -- local ChFrame14 = TokenFramePopup.BackpackCheckbox.Text;       -- TokenFramePopup Show on Backpack Text
      -- ST_CheckAndReplaceTranslationTextUI(ChFrame14, true, "ui");
   end

end

-------------------------------------------------------------------------------------------------------

--FRIENDS FRAME
function ST_FriendsFrame()
--print("ST_FriendsFrame");
   if (TT_PS["ui6"] == "1") then
      local Friendsobj01 = FriendsFrameTitleText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj01, false, "ui");

      local Friendsobj02 = FriendsTabHeaderTab1.Text;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj02, false, "ui");

      local Friendsobj03 = FriendsTabHeaderTab2.Text;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj03, false, "ui");

      -- local Friendsobj04 = FriendsTabHeaderTab3.Text;
      -- ST_CheckAndReplaceTranslationTextUI(Friendsobj04, false, "ui");

      local Friendsobj05 = FriendsFrameTab1Text;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj05, false, "ui");

      local Friendsobj06 = FriendsFrameTab2Text;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj06, false, "ui");

      local Friendsobj07 = FriendsFrameTab3Text;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj07, false, "ui");

      local Friendsobj08 = FriendsFrameTab4Text;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj08, false, "ui");

      local Friendsobj09 = FriendsFrameAddFriendButtonText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj09, false, "ui");

      local Friendsobj10 = FriendsFrameSendMessageButtonText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj10, false, "ui");

      local Friendsobj11 = FriendsFrameIgnorePlayerButtonText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj11, false, "ui");

      local Friendsobj12 = FriendsFrameUnsquelchButtonText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj12, false, "ui");

      local Friendsobj13 = WhoFrameWhoButtonText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj13, false, "ui");

      local Friendsobj14 = WhoFrameAddFriendButtonText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj14, false, "ui");

      local Friendsobj15 = WhoFrameGroupInviteButtonText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj15, false, "ui");

      local Friendsobj16 = WhoFrameTotals;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj16, false, "ui");

      local Friendsobj17 = RaidFrameConvertToRaidButtonText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj17, false, "ui");

      local Friendsobj18 = RaidFrameRaidInfoButtonText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj18, false, "ui");

      local Friendsobj19 = RaidFrameRaidDescription;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj19, false, "ui");

      -- local Friendsobj20 = RecruitAFriendRecruitmentFrame.Title;
      -- ST_CheckAndReplaceTranslationTextUI(Friendsobj20, false, "ui");
      
      -- local Friendsobj21 = RecruitAFriendRecruitmentFrame.Description;
      -- ST_CheckAndReplaceTranslationTextUI(Friendsobj21, false, "ui");

      -- local Friendsobj22 = RecruitAFriendRecruitmentFrame.FactionAndRealm;
      -- ST_CheckAndReplaceTranslationTextUI(Friendsobj22, false, "ui");

      -- local Friendsobj23 = RecruitAFriendFrame.RecruitList.Header.RecruitedFriends;
      -- ST_CheckAndReplaceTranslationTextUI(Friendsobj23, false, "ui");

      -- local Friendsobj24 = RecruitAFriendFrame.RecruitmentButton.Text;
      -- ST_CheckAndReplaceTranslationTextUI(Friendsobj24, false, "ui");



      -- local Friendsobj26 = RecruitAFriendFrame.RewardClaiming.MonthCount.Text;
      -- ST_CheckAndReplaceTranslationTextUI(Friendsobj26, false, "ui");

      local Friendsobj27 = RecruitAFriendFrameText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj27, false, "ui");

      -- local Friendsobj28 = RecruitAFriendRecruitmentFrame.EditBox.Instructions;
      -- ST_CheckAndReplaceTranslationTextUI(Friendsobj28, false, "ui");

      local Friendsobj29 = RecruitAFriendRecruitmentFrameText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj29, false, "ui");

      -- local Friendsobj30 = RecruitAFriendRecruitmentFrame.InfoText1;
      -- ST_CheckAndReplaceTranslationTextUI(Friendsobj30, false, "ui");

      -- local Friendsobj31 = RecruitAFriendRecruitmentFrame.InfoText2;
      -- ST_CheckAndReplaceTranslationTextUI(Friendsobj31, false, "ui");

      -- local Friendsobj32 = RecruitAFriendFrame.RewardClaiming.EarnInfo;
      -- ST_CheckAndReplaceTranslationTextUI(Friendsobj32, false, "ui");

      local Friendsobj33 = AddFriendEntryFrameTopTitle;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj33, true, "ui");

      local Friendsobj34 = AddFriendEntryFrameAcceptButtonText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj34, true, "ui");

      local Friendsobj35 = AddFriendEntryFrameCancelButtonText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj35, true, "ui");

      local Friendsobj36 = select(7, AddFriendInfoFrame:GetRegions());
      ST_CheckAndReplaceTranslationTextUI(Friendsobj36, true, "ui");

      local Friendsobj37 = AddFriendInfoFrameContinueButtonText;
      ST_CheckAndReplaceTranslationTextUI(Friendsobj37, true, "ui");

      local Friendsobj38 = select(8, AddFriendInfoFrame:GetRegions());
      ST_CheckAndReplaceTranslationTextUI(Friendsobj38, true, "ui");

      local Friendsobj39 = select(6, AddFriendEntryFrame:GetRegions());
      ST_CheckAndReplaceTranslationTextUI(Friendsobj39, true, "ui");

      local Friendsobj40 = select(10, AddFriendEntryFrame:GetRegions())
      ST_CheckAndReplaceTranslationTextUI(Friendsobj40, true, "ui");

        local function processRegion(frame)
            ST_CheckAndReplaceTranslationTextUI(frame, true, "ui")
        end

        -- CommunitiesFrame
        processRegion(select(4, WhoFrameColumnHeader1:GetRegions()))
        processRegion(select(4, WhoFrameColumnHeader2:GetRegions()))
        processRegion(select(4, WhoFrameColumnHeader3:GetRegions()))
        processRegion(select(4, WhoFrameColumnHeader4:GetRegions()))


        -- Global strings and buttons
        processRegion(WhoFrameDropdown.Text)

   end
end

-------------------------------------------------------------------------------------------------------

--HELP FRAME TOOLTIP
function ST_HelpPlateTooltip()   -- https://imgur.com/MkPVoFr
--print("ST_HelpPlateTooltip");
   if (TT_PS["active"] == "1") then
      local HPT01 = HelpPlateTooltip.Text;
      ST_CheckAndReplaceTranslationTextUI(HPT01, true, "ui");
   end
end

-------------------------------------------------------------------------------------------------------

--SPLASH FRAME (What's New)
function ST_SplashFrame()   -- https://imgur.com/80WLNbC       You can use FontFile: Original_Font1, Original_Font2
--print("ST_SplashFrame");
   if (TT_PS["active"] == "1") then
      local SplashF01 = SplashFrame.Header;
      ST_CheckAndReplaceTranslationTextUI(SplashF01, true, "ui");

      local SplashF02 = SplashFrame.Label;
      ST_CheckAndReplaceTranslationTextUI(SplashF02, true, "ui");

      local SplashF03 = SplashFrame.TopLeftFeature.Description;
      if (WoWTR_Localization.lang == 'AR') then
      ST_CheckAndReplaceTranslationText(SplashF03, true, "ui",false,false,-10);
      SplashF03:SetJustifyH("RIGHT");
      else
      ST_CheckAndReplaceTranslationTextUI(SplashF03, true, "ui");
      end

      local SplashF04 = SplashFrame.BottomLeftFeature.Description;
      if (WoWTR_Localization.lang == 'AR') then
      ST_CheckAndReplaceTranslationText(SplashF04, true, "ui",false,false,-15);
      SplashF04:SetJustifyH("RIGHT");
      else
      ST_CheckAndReplaceTranslationTextUI(SplashF04, true, "ui");
      end

      local SplashF05 = SplashFrame.RightFeature.Description;
      if (WoWTR_Localization.lang == 'AR') then
      ST_CheckAndReplaceTranslationText(SplashF05, true, "ui",false,false,-10);
      else
      ST_CheckAndReplaceTranslationTextUI(SplashF05, true, "ui");
      end

      local SplashF06 = SplashFrame.BottomCloseButton.Text;
      ST_CheckAndReplaceTranslationTextUI(SplashF06, true, "ui");

      local SplashF07 = SplashFrame.TopLeftFeature.Title;
      ST_CheckAndReplaceTranslationTextUI(SplashF07, true, "ui");

      local SplashF08 = SplashFrame.BottomLeftFeature.Title;
      ST_CheckAndReplaceTranslationTextUI(SplashF08, true, "ui");

      local SplashF09 = SplashFrame.RightFeature.Title;
      ST_CheckAndReplaceTranslationTextUI(SplashF09, true, "ui");
   end
end

-------------------------------------------------------------------------------------------------------

--PING TUTORIAL FRAME
function ST_PingSystemTutorial()   -- https://imgur.com/tv61op7      You can use FontFile: Original_Font1, Original_Font2
--print("ST_PingSystemTutorial");
   if (TT_PS["active"] == "1") then
      local PST01 = PingSystemTutorialTitleText;
      ST_CheckAndReplaceTranslationTextUI(PST01, true, "ui");

      local PST02 = PingSystemTutorial.Tutorial1.TutorialHeader;
      ST_CheckAndReplaceTranslationTextUI(PST02, true, "ui");

      local PST03 = PingSystemTutorial.Tutorial2.TutorialHeader;
      ST_CheckAndReplaceTranslationTextUI(PST03, true, "ui");

      local PST04 = PingSystemTutorial.Tutorial3.TutorialHeader;
      ST_CheckAndReplaceTranslationTextUI(PST04, true, "ui");

      local PST05 = PingSystemTutorial.Tutorial4.TutorialHeader;
      ST_CheckAndReplaceTranslationTextUI(PST05, true, "ui");

      local PST06 = PingSystemTutorial.Tutorial4.ImageBounds.TutorialBody1;
      ST_CheckAndReplaceTranslationTextUI(PST06, true, "ui");

      local PST07 = PingSystemTutorial.Tutorial4.ImageBounds.TutorialBody2;
      ST_CheckAndReplaceTranslationTextUI(PST07, true, "ui");

      local PST08 = PingSystemTutorial.Tutorial4.ImageBounds.TutorialBody3;
      ST_CheckAndReplaceTranslationTextUI(PST08, true, "ui");
   end
end

-------------------------------------------------------------------------------------------------------

--BANK FRAME (Bank, Reagent, Warband Bank)
function ST_WarbandBankFrm()
--print("ST_WarbandBankFrm")
   if (TT_PS["active"] == "1") then

        local function processRegion(frame)
            ST_CheckAndReplaceTranslationTextUI(frame, true, "ui")
        end

        -- CommunitiesFrame
        processRegion(select(4, BankFrame:GetRegions()))
        processRegion(select(5, BankFrame:GetRegions()))
        processRegion(select(1, BankFramePurchaseInfo:GetRegions()))


        -- Global strings and buttons
        processRegion(BankFramePurchaseButtonText)
        processRegion(BankFrameSlotCost)
   end
end

-------------------------------------------------------------------------------------------------------

--TOOLTIPS FRAME (click on chat frame) 
local ignoreList = {}  -- The texts in the list will not be translated.
if WoWTR_Localization.lang == 'TR' then
    ignoreList = {
        "Head", "Neck", "Shoulder", "Back", "Chest", "Tabard", "Wrist", "Hands", "Waist", "Legs", "Feet", "Finger", "Trinket"
    }
else
    -- For other languages, the ignore list empty.
end

function ST_ItemRefTooltip()         -- https://imgur.com/a/5Ooqnb2
    for i = 2, 30 do
        local itemRefLeft = _G["ItemRefTooltipTextLeft" .. i]
        if itemRefLeft and itemRefLeft:GetText() then
            local text = itemRefLeft:GetText()
            ST_CheckAndReplaceTranslationTextUI(itemRefLeft, true, "other")
        end

        local itemRefRight = _G["ItemRefTooltipTextRight" .. i]
        if itemRefRight and itemRefRight:GetText() then
            local text = itemRefRight:GetText()
            ST_CheckAndReplaceTranslationTextUI(itemRefRight, true, "other")
        end
    end
end

-------------------------------------------------------------------------------------------------------

--ITEM UPGRADE FRAME
function ST_ItemUpgradeFrm()         -- https://imgur.com/a/Vy6wNjO
   if (TT_PS["ui1"] == "1") then
   local ItemUpFrm01 = ItemUpgradeFrameTitleText;
   ST_CheckAndReplaceTranslationTextUI(ItemUpFrm01, false, "ui");
   local ItemUpFrm02 = ItemUpgradeFrame.ItemInfo.MissingItemText;
   ST_CheckAndReplaceTranslationTextUI(ItemUpFrm02, false, "ui");
   local ItemUpFrm03 = ItemUpgradeFrame.MissingDescription;
   ST_CheckAndReplaceTranslationTextUI(ItemUpFrm03, false, "ui");
   local ItemUpFrm04 = ItemUpgradeFrame.UpgradeButton.Text;
   ST_CheckAndReplaceTranslationTextUI(ItemUpFrm04, false, "ui");
   local ItemUpFrm05 = ItemUpgradeFrame.UpgradeCostFrame.Label;
   ST_CheckAndReplaceTranslationTextUI(ItemUpFrm05, false, "ui");
   local ItemUpFrm06 = ItemUpgradeFrame.ItemInfo.UpgradeTo;
   ST_CheckAndReplaceTranslationTextUI(ItemUpFrm06, false, "ui");
   local ItemUpFrm07 = ItemUpgradeFrameLeftItemPreviewFrameTextLeft1;
   ST_CheckAndReplaceTranslationTextUI(ItemUpFrm07, false, "ui");
   local ItemUpFrm08 = ItemUpgradeFrameRightItemPreviewFrameTextLeft1;
   ST_CheckAndReplaceTranslationTextUI(ItemUpFrm08, false, "ui");
   end
end

-------------------------------------------------------------------------------------------------------

--WEEKLY REWARDS - GREAT VAULT FRAME
function ST_WeeklyRewardsFrame()
   if (TT_PS["ui1"] == "1") then
    local WeeklyRFrm01 = WeeklyRewardsFrame.HeaderFrame.Text
    ST_CheckAndReplaceTranslationTextUI(WeeklyRFrm01, false, "ui")
    local WeeklyRFrm02 = WeeklyRewardsFrame.RaidFrame.Name
    ST_CheckAndReplaceTranslationTextUI(WeeklyRFrm02, false, "ui")
    local WeeklyRFrm03 = WeeklyRewardsFrame.MythicFrame.Name
    ST_CheckAndReplaceTranslationTextUI(WeeklyRFrm03, false, "ui")
    local WeeklyRFrm04 = WeeklyRewardsFrame.WorldFrame.Name
    ST_CheckAndReplaceTranslationTextUI(WeeklyRFrm04, false, "ui")
    if WeeklyRewardsFrame.Overlay and WeeklyRewardsFrame.Overlay.Title then
        local WeeklyRFrm05 = WeeklyRewardsFrame.Overlay.Title
        ST_CheckAndReplaceTranslationTextUI(WeeklyRFrm05, true, "ui")
    end
    if WeeklyRewardsFrame.Overlay and WeeklyRewardsFrame.Overlay.Text then
        local WeeklyRFrm06 = WeeklyRewardsFrame.Overlay.Text
        ST_CheckAndReplaceTranslationTextUI(WeeklyRFrm06, true, "ui")
    end
   end
end

-------------------------------------------------------------------------------------------------------

-- EVENT UNLOCKED TEXT FRAME
function ST_EventToastManagerFrame()
   if (TT_PS["ui1"] == "1") then
      local toast = EventToastManagerFrame.currentDisplayingToast
      if toast then
         local EventTextScreen01 = toast.Title
         ST_CheckAndReplaceTranslationTextUI(EventTextScreen01, true, "Collections:TextEvent", WOWTR_Font1)
         
         local EventTextScreen02 = toast.SubTitle
         ST_CheckAndReplaceTranslationTextUI(EventTextScreen02, true, "Collections:TextEvent")
         
         local EventTextScreen03 = toast.Description
         ST_CheckAndReplaceTranslationTextUI(EventTextScreen03, true, "Collections:TextEvent")
         
         if toast.Contents then
            local EventTextScreen04 = toast.Contents.Title
            ST_CheckAndReplaceTranslationTextUI(EventTextScreen04, true, "Collections:TextEvent", WOWTR_Font1)
            
            local EventTextScreen05 = toast.Contents.SubTitle
            ST_CheckAndReplaceTranslationTextUI(EventTextScreen05, true, "Collections:TextEvent")
            
            local EventTextScreen06 = toast.Contents.Description
            ST_CheckAndReplaceTranslationTextUI(EventTextScreen06, true, "Collections:TextEvent")
         end
      end
   end
end

-------------------------------------------------------------------------------------------------------

-- RAID BOSS EMOTE FRAME
function ST_RaidBossEmoteFrame()
   if (TT_PS["ui1"] == "1") then
   local RBossEmoteFrm04 = RaidBossEmoteFrame.slot1Text
    ST_CheckAndReplaceTranslationTextUI(RBossEmoteFrm04, false, "Collections:Emote")
    local RBossEmoteFrm05 = RaidBossEmoteFrame.slot2Text
    ST_CheckAndReplaceTranslationTextUI(RBossEmoteFrm05, false, "Collections:Emote")
    local RBossEmoteFrm06 = RaidBossEmoteFrame.slot3Text
    ST_CheckAndReplaceTranslationTextUI(RBossEmoteFrm06, false, "Collections:Emote")
    local RBossEmoteFrm01 = RaidBossEmoteFrame.slot1
    ST_CheckAndReplaceTranslationTextUI(RBossEmoteFrm01, true, "Collections:Emote")
    local RBossEmoteFrm02 = RaidBossEmoteFrame.slot2
    ST_CheckAndReplaceTranslationTextUI(RBossEmoteFrm02, true, "Collections:Emote")
    local RBossEmoteFrm03 = RaidBossEmoteFrame.slot3
    ST_CheckAndReplaceTranslationTextUI(RBossEmoteFrm03, true, "Collections:Emote")
   end
end

-------------------------------------------------------------------------------------------------------
-- MACRO FRAME

function ST_MacroFrame()
   if (TT_PS["ui1"] == "1") then
    local MacroFrame01 = MacroFrameTab1.Text
    ST_CheckAndReplaceTranslationTextUI(MacroFrame01, true, "ui")
    local MacroFrame02 = MacroFrameTab2.Text
    ST_CheckAndReplaceTranslationTextUI(MacroFrame02, true, "ui")
    local MacroFrame03 = MacroEditButtonText
    ST_CheckAndReplaceTranslationTextUI(MacroFrame03, true, "ui")
    local MacroFrame04 = MacroCancelButtonText
    ST_CheckAndReplaceTranslationTextUI(MacroFrame04, true, "ui")
    local MacroFrame05 = MacroSaveButtonText
    ST_CheckAndReplaceTranslationTextUI(MacroFrame05, true, "ui")
    local MacroFrame06 = MacroDeleteButtonText
    ST_CheckAndReplaceTranslationTextUI(MacroFrame06, true, "ui")
    local MacroFrame07 = MacroNewButtonText
    ST_CheckAndReplaceTranslationTextUI(MacroFrame07, true, "ui")
    local MacroFrame08 = MacroExitButtonText
    ST_CheckAndReplaceTranslationTextUI(MacroFrame08, true, "ui")
    local MacroFrame09 = MacroFrameEnterMacroText
    ST_CheckAndReplaceTranslationTextUI(MacroFrame09, true, "ui")
    local MacroFrame10 = MacroFrameCharLimitText
    ST_CheckAndReplaceTranslationTextUI(MacroFrame10, true, "ui")
    local MacroFrame11 = MacroPopupFrame.BorderBox.EditBoxHeaderText
    ST_CheckAndReplaceTranslationTextUI(MacroFrame11, true, "ui")
    local MacroFrame12 = MacroPopupFrameText
    ST_CheckAndReplaceTranslationTextUI(MacroFrame12, true, "ui")
    local MacroFrame13 = MacroPopupFrame.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconHeader
    ST_CheckAndReplaceTranslationTextUI(MacroFrame13, true, "ui")
    local MacroFrame14 = MacroPopupFrame.BorderBox.IconSelectionText
    ST_CheckAndReplaceTranslationTextUI(MacroFrame14, true, "ui")
    local MacroFrame15 = MacroPopupFrame.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription
    ST_CheckAndReplaceTranslationTextUI(MacroFrame15, true, "ui")
    local MacroFrame16 = MacroPopupFrame.BorderBox.OkayButton.Text
    ST_CheckAndReplaceTranslationTextUI(MacroFrame16, true, "ui")
    local MacroFrame17 = MacroPopupFrame.BorderBox.CancelButton.Text
    ST_CheckAndReplaceTranslationTextUI(MacroFrame17, true, "ui")



        -- for _, region in ipairs({MacroFrame:GetRegions()}) do
            -- if region:GetObjectType() == "FontString" and region:GetText() == "Create Macros" then
                -- local MacroFrame14 = region
                -- ST_CheckAndReplaceTranslationTextUI(MacroFrame14, true, "ui")
                -- break -- İstediğimiz metni bulduk ve değiştirdik, döngüden çıkabiliriz
            -- end
        -- end

   end
end

-------------------------------------------------------------------------------------------------------
-- ADDON LIST

function ST_AddonListFrame()
    if (TT_PS["ui1"] == "1") then
        -- shouldIgnore fonksiyonunu geçici olarak devre dışı bırak
        local oldShouldIgnore = shouldIgnore
        shouldIgnore = function() return false end
        local buttonInfoList = {
            { button = AddonList.EnableAllButton, name = "EnableAllButton" },
            { button = AddonList.DisableAllButton, name = "DisableAllButton" },
            { button = AddonList.CancelButton, name = "CancelButton" },
            { button = AddonList.OkayButton, name = "OkayButton" },
        }

        for _, buttonInfo in ipairs(buttonInfoList) do
            local fontString = buttonInfo.button:GetFontString()

            if fontString then
                ST_CheckAndReplaceTranslationTextUI(fontString, true, "ui")
            else
                --print("Uyarı: " .. buttonInfo.name .. " butonu için FontString bulunamadı.")
            end
        end

        -- local AddonListFrame04 = AddonList.Performance.Header
        -- ST_CheckAndReplaceTranslationTextUI(AddonListFrame04, true, "ui")
        local AddonListFrame05 = AddonList.TitleContainer.TitleText
        ST_CheckAndReplaceTranslationTextUI(AddonListFrame05, true, "ui")

        for _, region in ipairs({ AddonListForceLoad:GetRegions() }) do
            if region:GetObjectType() == "FontString" and region:GetText() == "Load out of date AddOns" then
                local AddonListFrame14 = region
                ST_CheckAndReplaceTranslationTextUI(AddonListFrame14, true, "ui")
                break -- İstediğimiz metni bulduk ve değiştirdik, döngüden çıkabiliriz
            end
        end

        for _, region in ipairs({ AddonList:GetRegions() }) do
            if region:GetObjectType() == "FontString" and region:GetText() == "AddOn List" then
                local AddonListFrame15 = region
                ST_CheckAndReplaceTranslationTextUI(AddonListFrame15, true, "ui")
                break -- İstediğimiz metni bulduk ve değiştirdik, döngüden çıkabiliriz
            end
        end


        local i = 1
        local reloadEntry = _G["AddonListEntry" .. i .. "Reload"]
        local statusEntry = _G["AddonListEntry" .. i .. "Status"]

        while reloadEntry and statusEntry do
            local reloadText = (reloadEntry and reloadEntry:GetText()) or ""
            local statusText = (statusEntry and statusEntry:GetText()) or ""

            ST_CheckAndReplaceTranslationTextUI(reloadEntry, true, "ui")
            ST_CheckAndReplaceTranslationTextUI(statusEntry, true, "ui")

            i = i + 1
            reloadEntry = _G["AddonListEntry" .. i .. "Reload"]
            statusEntry = _G["AddonListEntry" .. i .. "Status"]
        end

        shouldIgnore = oldShouldIgnore
    end
end

-------------------------------------------------------------------------------------------------------
-- Guild Frame
function ST_GuildFrame()
    if (TT_PS["ui1"] == "1") then
        local function processRegion(frame)
            ST_CheckAndReplaceTranslationTextUI(frame, true, "ui")
        end

        -- CommunitiesFrame
        processRegion(select(4, GuildFrameColumnHeader1:GetRegions()))
        processRegion(select(4, GuildFrameColumnHeader2:GetRegions()))
        processRegion(select(4, GuildFrameColumnHeader3:GetRegions()))
        processRegion(select(4, GuildFrameColumnHeader4:GetRegions()))
        processRegion(select(4, GuildFrameGuildStatusColumnHeader1:GetRegions()))
        processRegion(select(4, GuildFrameGuildStatusColumnHeader2:GetRegions()))
        processRegion(select(4, GuildFrameGuildStatusColumnHeader3:GetRegions()))
        processRegion(select(4, GuildFrameGuildStatusColumnHeader4:GetRegions()))


        -- Global strings and buttons
        processRegion(GuildFrameLFGButtonText)
        processRegion(GuildFrameTotals)
        processRegion(GuildFrameOnlineTotals)
        processRegion(GuildFrameGuildInformationButtonText)
        processRegion(GuildFrameAddMemberButtonText)
        processRegion(GuildFrameControlButtonText)
        processRegion(GuildInfoTitle)
        processRegion(GuildInfoGuildEventButtonText)
        processRegion(GuildInfoSaveButtonText)
        processRegion(GuildInfoCancelButtonText)


        -- -- CommunitiesFrame.MemberList.ColumnDisplay children işle
        -- local columnDisplay = CommunitiesFrame.MemberList.ColumnDisplay
        -- if columnDisplay then
            -- local children = {columnDisplay:GetChildren()}
            -- for _, child in ipairs(children) do
                -- if child:IsObjectType("Button") then
                    -- local fontString = child:GetFontString()
                    -- if fontString then
                        -- ST_CheckAndReplaceTranslationTextUI(fontString, true, "ui")
                    -- end
                -- end
            -- end
        -- end

    end
end

-------------------------------------------------------------------------------------------------------
-- MAILBOX
function ST_MailFrame()
    if (TT_PS["ui1"] == "1") then
        local Mailobj01 = MailFrameTab1Text;
        ST_CheckAndReplaceTranslationTextUI(Mailobj01, true, "ui");

        local Mailobj02 = MailFrameTab2Text;
        ST_CheckAndReplaceTranslationTextUI(Mailobj02, true, "ui");

        local Mailobj03 = OpenAllMailText;
        ST_CheckAndReplaceTranslationTextUI(Mailobj03, true, "ui");

        local Mailobj04 = SendMailMailButtonText;
        ST_CheckAndReplaceTranslationTextUI(Mailobj04, true, "ui");

        local Mailobj05 = SendMailCancelButtonText;
        ST_CheckAndReplaceTranslationTextUI(Mailobj05, true, "ui");

        local Mailobj06 = SendMailSendMoneyButtonText;
        ST_CheckAndReplaceTranslationTextUI(Mailobj06, true, "ui");

        local Mailobj07 = select(3, SendMailNameEditBox:GetRegions());
        ST_CheckAndReplaceTranslationTextUI(Mailobj07, true, "ui");

        local Mailobj08 = select(3, SendMailSubjectEditBox:GetRegions());
        ST_CheckAndReplaceTranslationTextUI(Mailobj08, true, "ui");

        local Mailobj09 = select(1, SendMailCostMoneyFrame:GetRegions());
        ST_CheckAndReplaceTranslationTextUI(Mailobj09, true, "ui");

        local Mailobj11 = select(3, OpenMailInvoiceFrame:GetRegions());
        ST_CheckAndReplaceTranslationTextUI(Mailobj11, true, "ui");

        local Mailobj12 = select(4, OpenMailInvoiceFrame:GetRegions());
        ST_CheckAndReplaceTranslationTextUI(Mailobj12, true, "ui");

        local Mailobj13 = select(5, OpenMailInvoiceFrame:GetRegions());
        ST_CheckAndReplaceTranslationTextUI(Mailobj13, true, "ui");

        local Mailobj14 = select(7, OpenMailInvoiceFrame:GetRegions());
        ST_CheckAndReplaceTranslationTextUI(Mailobj14, true, "ui");

        local Mailobj15 = OpenMailDeleteButtonText;
        ST_CheckAndReplaceTranslationTextUI(Mailobj15, true, "ui");

        local Mailobj16 = OpenMailReplyButtonText;
        ST_CheckAndReplaceTranslationTextUI(Mailobj16, true, "ui");

        local Mailobj17 = OpenMailCancelButtonText;
        ST_CheckAndReplaceTranslationTextUI(Mailobj17, true, "ui");

        local Mailobj18 = select(4, OpenMailFrame:GetRegions());
        ST_CheckAndReplaceTranslationTextUI(Mailobj18, true, "ui");

        local Mailobj19 = select(5, OpenMailFrame:GetRegions());
        ST_CheckAndReplaceTranslationTextUI(Mailobj19, true, "ui");

        local Mailobj20 = select(6, OpenMailFrame:GetRegions());
        ST_CheckAndReplaceTranslationTextUI(Mailobj20, true, "ui");

        local Mailobj21 = InboxTitleText
        ST_CheckAndReplaceTranslationTextUI(Mailobj21, true, "ui");

        local Mailobj22 = SendMailMoneyText
        ST_CheckAndReplaceTranslationTextUI(Mailobj22, true, "ui");

        local Mailobj23 = select(1, InboxNextPageButton:GetRegions());
        ST_CheckAndReplaceTranslationTextUI(Mailobj23, true, "ui");

        local Mailobj24 = select(1, InboxPrevPageButton:GetRegions());
        ST_CheckAndReplaceTranslationTextUI(Mailobj24, true, "ui");

        local Mailobj25 = OpenMailFrameTitleText
        ST_CheckAndReplaceTranslationTextUI(Mailobj25, true, "ui");
    end
end

-------------------------------------------------------------------------------------------------------
-- Settings Panel
function ST_SettingsPanel()
    if (TT_PS["ui1"] == "1") then
        local SetFrame01 = SettingsPanel.NineSlice.Text;
        ST_CheckAndReplaceTranslationTextUI(SetFrame01, true, "ui");

        local SetFrame02 = SettingsPanel.GameTab.Text;
        ST_CheckAndReplaceTranslationTextUI(SetFrame02, true, "ui");

        local SetFrame03 = SettingsPanel.AddOnsTab.Text;
        ST_CheckAndReplaceTranslationTextUI(SetFrame03, true, "ui");

        local SetFrame04 = SettingsPanel.CloseButton.Text;
        ST_CheckAndReplaceTranslationTextUI(SetFrame04, true, "ui");

        local SetFrame05 = SettingsPanel.ApplyButton.Text;
        ST_CheckAndReplaceTranslationTextUI(SetFrame05, true, "ui");

        local SetFrame06 = SettingsPanel.Container.SettingsList.Header.DefaultsButton.Text;
        ST_CheckAndReplaceTranslationTextUI(SetFrame06, true, "ui");

        local scrollBox = SettingsPanel and SettingsPanel.CategoryList and SettingsPanel.CategoryList.ScrollBox
        if scrollBox and scrollBox:HasDataProvider() then
            scrollBox:ForEachFrame(function(frame)
                if frame.Label and frame.Label:GetText() then
                    local SetFrame08 = frame.Label;
                    ST_CheckAndReplaceTranslationTextUI(SetFrame08, false, "ui");
                end
            end)
        end

        local scrollBox = SettingsPanel.Container.SettingsList.ScrollBox
        if scrollBox and scrollBox:HasDataProvider() then
            scrollBox:ForEachFrame(function(frame)
                if frame.Label and frame.Label:GetText() then
                    local SetFrame10 = frame.Label;
                    ST_CheckAndReplaceTranslationTextUI(SetFrame10, false, "ui");
                elseif frame.Title and frame.Title:GetText() then
                    local SetFrame12 = frame.Title;
                    ST_CheckAndReplaceTranslationTextUI(SetFrame12, false, "ui");
                end
            end)
        end

        local scrollBox = SettingsPanel and SettingsPanel.Container and SettingsPanel.Container.SettingsList and SettingsPanel.Container.SettingsList.ScrollBox
        if scrollBox and scrollBox:HasDataProvider() then
            scrollBox:ForEachFrame(function(frame)
                if frame.Text and frame.Text:GetText() then
                    local SetFrame09 = frame.Text;
                    ST_CheckAndReplaceTranslationTextUI(SetFrame09, false, "ui");
                end
            end)
        end

        local SetFrame07 = SettingsPanel.SearchBox.Instructions;
        ST_CheckAndReplaceTranslationTextUI(SetFrame07, false, "ui");

        local SetFrame11 = SettingsPanel.Container.SettingsList.Header.Title;
        ST_CheckAndReplaceTranslationTextUI(SetFrame11, false, "ui");


    end
end

-------------------------------------------------------------------------------------------------------
-- Auction House
function ST_AuctionHouse()
    if (TT_PS["ui1"] == "1") then
        -- local function CheckAndReplaceHeaderContainerTexts(headerContainers)
            -- for _, headerContainer in ipairs(headerContainers) do
                -- local children = {headerContainer:GetChildren()}
                -- for _, child in ipairs(children) do
                    -- if child:IsObjectType("Button") then
                        -- local Text = child:GetFontString()
                        -- if Text then
                            -- ST_CheckAndReplaceTranslationTextUI(Text, false, "ui")
                        -- end
                    -- end
                -- end
            -- end
        -- end

            -- local containers = {
                -- -- AuctionHouseFrameAuctionsFrame.BidsList.HeaderContainer,
                -- -- AuctionHouseFrameAuctionsFrame.AllAuctionsList.HeaderContainer,
                -- -- AuctionHouseFrame.ItemSellList.HeaderContainer,
                -- -- AuctionHouseFrame.BrowseResultsFrame.ItemList.HeaderContainer,
                -- -- AuctionHouseFrame.CommoditiesSellList.HeaderContainer
            -- }
            -- for _, container in ipairs(containers) do
                -- if container then
                    -- CheckAndReplaceHeaderContainerTexts({container})
                -- end
            -- end

            local auctionFrameTexts = {
                AuctionFrameTab1Text,
                AuctionFrameTab2Text,
                AuctionFrameTab3Text,
                BrowseBidButtonText,
                BrowseTitle,
                BrowseNameText,
                BrowseLevelText,
                BrowseDropdownName,
                IsUsableCheckButtonText,
                ShowOnPlayerCheckButtonText,
                BrowseSearchButtonText,
                BrowseResetButtonText,
                BrowseBuyoutButtonText,
                BrowseCloseButtonText,
                BrowseQualitySortText,
                BrowseLevelSortText,
                BrowseDurationSortText,
                BrowseNoResultsText,
                BrowseHighBidderSortText,
                BrowseCurrentBidSortText,
                BidTitle,
                BidQualitySortText,
                BidLevelSortText,
                BidDurationSortText,
                BidBuyoutSortText,
                BidStatusSortText,
                BidBidSortText,
                BidBidText,
                BidBidButtonText,
                BidBuyoutButtonText,
                BidCloseButtonText,
                AuctionsTitle,
                AuctionsTabText,
                AuctionsQualitySortText,
                AuctionsDurationSortText,
                AuctionsHighBidderSortText,
                AuctionsBidSortText,
                AuctionsItemText,
                AuctionsDurationText,
                AuctionsShortAuctionButtonText,
                AuctionsMediumAuctionButtonText,
                AuctionsLongAuctionButtonText,
                AuctionsBuyoutText,
                AuctionsDepositText,
                AuctionsCreateAuctionButtonText,
                AuctionsCancelAuctionButtonText,
                AuctionsCloseButtonText
            }
            for _, text in ipairs(auctionFrameTexts) do
                ST_CheckAndReplaceTranslationTextUI(text, true, "ui")
            end


            -- local scrollBox = AuctionHouseFrameAuctionsFrame.SummaryList.ScrollBox
            -- if scrollBox and scrollBox:HasDataProvider() then
                -- scrollBox:ForEachFrame(function(frame)
                    -- if frame.Text and frame.Text:GetText() then
                        -- ST_CheckAndReplaceTranslationTextUI(frame.Text, false, "ui")
                    -- end
                -- end)
            -- end

            local function ProcessRegion(frame)
                ST_CheckAndReplaceTranslationTextUI(frame, true, "ui")
            end

            local regions = {
                { BrowsePrevPageButton, 1 },
                { BrowseNextPageButton, 1 },
                { StartPrice, 1 }
            }
            for _, region in ipairs(regions) do
                local frame = region[1]
                for i = 2, #region do
                    ProcessRegion(select(region[i], frame:GetRegions()))
                end
            end

    end
end

-------------------------------------------------------------------------------------------------------
-- Hata ve uyarılar "UI_ERROR_MESSAGE"
local err = CreateFrame("Frame")
err:RegisterEvent("UI_ERROR_MESSAGE")
err:RegisterEvent("UI_INFO_MESSAGE")

err:SetScript("OnEvent", function(self, event, message, messageType)
    local eventHash = StringHash(messageType) 
    local function ProcessRegion(region)
        local textToSave = ""

        if region and region:IsObjectType("FontString") then
            textToSave = region:GetText() or ""
        end

        if textToSave == "" then
            return
        end
        
        local lowerTextToSave = textToSave:lower()
        local shouldSkipFinal = string.find(lowerTextToSave, "%d") or
                                string.find(lowerTextToSave, "completed") or
                                string.find(lowerTextToSave, "discovered:") or
                                string.find(lowerTextToSave, "missing reagent:")

        if shouldSkipFinal then
            --print("SKIP (Final Filter) >> Metin atlandı: " .. textToSave)
        else
            --print("KAYDEDİLDİ >> Hash: " .. eventHash .. " | ID: " .. message .. " | Metin: " .. textToSave)
            ST_CheckAndReplaceTranslationTextUI(region, true, "Collections:XErrorText")
        end
    end

    if UIErrorsFrame then
        local regions = { UIErrorsFrame:GetRegions() }

        C_Timer.After(0.02, function()
            for _, region in ipairs(regions) do
                ProcessRegion(region)
            end
        end)
    end
end)
-------------------------------------------------------------------------------------------------------
--Quest Log Frame
function QTR_QuestLogFrameUI()
   if (TT_PS["ui1"] == "1") then

            local QuestLogFrameTexts = {
                QuestLogTitleText,
                QuestLogTrackTitle,
                QuestLogQuestCount,
                QuestLogFrameAbandonButtonText,
                QuestFramePushQuestButtonText,
                QuestFrameExitButtonText,
                QuestLogItemReceiveText,
                QuestLogNoQuestsText
            }
            for _, text in ipairs(QuestLogFrameTexts) do
                ST_CheckAndReplaceTranslationTextUI(text, true, "ui")
            end

        -- local QuestLogFrameText01 = QuestLogQuestCount;
        -- ST_CheckAndReplaceTranslationTextUI(QuestLogFrameText01, false, "ui");
   end
end
-------------------------------------------------------------------------------------------------------
-- Class Trainer Frame

function ST_ClassTrainerPanel()
   if (TT_PS["ui1"] == "1") then

            local ClassTrainerFrameTexts = {
                ClassTrainerGreetingText,
                ClassTrainerTrainButtonText,
                ClassTrainerCancelButtonText,
                ClassTrainerCostLabel,
                ClassTrainerFrame.FilterDropdown.Text,
                ClassTrainerCollapseAllButtonText,
                ClassTrainerSkillDescription
                
            }
            for _, text in ipairs(ClassTrainerFrameTexts) do
                ST_CheckAndReplaceTranslationTextUI(text, false, "ui")
            end

   end
end

-------------------------------------------------------------------------------------------------------
-- Stable Frame

function ST_PetStableFrame()
   if (TT_PS["ui1"] == "1") then

            local PetStableFrameTexts = {
                PetStableTitleLabel,
                PetStableSlotText,
                PetStablePurchaseButtonText,
                PetStableCostLabel
                
            }
            for _, text in ipairs(PetStableFrameTexts) do
                ST_CheckAndReplaceTranslationTextUI(text, true, "ui")
            end

            local function processRegion(frame)
                ST_CheckAndReplaceTranslationTextUI(frame, true, "ui")
            end

            processRegion(select(7, PetStableCurrentPet:GetRegions()))
            processRegion(select(7, PetStableStabledPet1:GetRegions()))
   end
end

-------------------------------------------------------------------------------------------------------

if ((GetLocale()=="enUS") or (GetLocale()=="enGB")) then
-- Własne okno Tooltips - do wyświetlenia tłumaczenia Buff lub Debudd
   ST_MyGameTooltip = CreateFrame( "GameTooltip", "ST_MyGameTooltip", UIParent, "GameTooltipTemplate" );
   ST_MyGameTooltip:SetOwner(WorldFrame, "ANCHOR_NONE" );

-------------------------------------------------------------------------------------------------------

   WOWSTR = CreateFrame("Frame");               -- ramka czekająca na załadowanie modułu ClassTalentFrame
   WOWSTR:SetScript("OnEvent", WOWSTR_onEvent);
   WOWSTR:RegisterEvent("ADDON_LOADED");

-------------------------------------------------------------------------------------------------------

   if SpellBookFrame_Update then
      hooksecurefunc("SpellBookFrame_Update", ST_updateSpellBookFrame);
   end

end
