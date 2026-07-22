local WOWTR_ACCENT = { r = 0.85, g = 0.68, b = 0.22 }
local WOWTR_PANEL = { r = 0.035, g = 0.031, b = 0.024 }
local WOWTR_PANEL_SOFT = { r = 0.059, g = 0.051, b = 0.043 }
local WOWTR_BORDER = { r = 0.42, g = 0.35, b = 0.24 }
local WOWTR_TEXT = { r = 0.92, g = 0.90, b = 0.86 }
local WOWTR_TEXT_DIM = { r = 0.63, g = 0.59, b = 0.52 }
local WOWTR_UI_FONT = "Interface\\AddOns\\WoWTR\\Fonts\\Expressway.ttf"
local WOWTR_UI_FONT_BOLD = "Interface\\AddOns\\WoWTR\\Fonts\\Expressway.ttf"


local function WOWTR_SetTextureColor(texture, color, alpha)
    if texture then
        texture:SetColorTexture(color.r, color.g, color.b, alpha or 1)
    end
end

function WOWTR_CreateModernLine(parent, layer, alpha)
    local line = parent:CreateTexture(nil, layer or "ARTWORK")
    WOWTR_SetTextureColor(line, WOWTR_BORDER, alpha or 0.45)
    return line
end

function WOWTR_StyleModernButton(button, accent)
    if not button or button.WOWTRModernStyled then return end
    button.WOWTRModernStyled = true

    if button.SetNormalTexture then
        button:SetNormalTexture("")
        button:SetHighlightTexture("")
        button:SetPushedTexture("")
    end

    button.Bg = button:CreateTexture(nil, "BACKGROUND")
    button.Bg:SetAllPoints()
    WOWTR_SetTextureColor(button.Bg, WOWTR_PANEL_SOFT, 0.82)

    button.BorderTop = WOWTR_CreateModernLine(button, "ARTWORK", accent and 0.80 or 0.35)
    button.BorderTop:SetPoint("TOPLEFT")
    button.BorderTop:SetPoint("TOPRIGHT")
    button.BorderTop:SetHeight(1)

    button.BorderBottom = WOWTR_CreateModernLine(button, "ARTWORK", 0.28)
    button.BorderBottom:SetPoint("BOTTOMLEFT")
    button.BorderBottom:SetPoint("BOTTOMRIGHT")
    button.BorderBottom:SetHeight(1)

    button:HookScript("OnEnter", function(self)
        WOWTR_SetTextureColor(self.Bg, accent and WOWTR_ACCENT or WOWTR_PANEL_SOFT, accent and 0.16 or 1)
    end)
    button:HookScript("OnLeave", function(self)
        WOWTR_SetTextureColor(self.Bg, WOWTR_PANEL_SOFT, 0.82)
    end)
end

-- Creates a WoWTR-owned button without Blizzard's red UIPanelButtonTemplate
-- textures. This keeps its appearance consistent across Retail, Era and TBC.
function WOWTR_CreateModernButton(name, parent, accent)
    local button = CreateFrame("Button", name, parent, "BackdropTemplate")
    local label = button:CreateFontString(nil, "OVERLAY")
    label:SetAllPoints(button)
    label:SetJustifyH("CENTER")
    label:SetJustifyV("MIDDLE")
    label:SetFont(WOWTR_UI_FONT, 13, "")
    label:SetTextColor(WOWTR_TEXT.r, WOWTR_TEXT.g, WOWTR_TEXT.b, 1)
    button:SetFontString(label)
    WOWTR_StyleModernButton(button, accent == true)
    return button
end

function WOWTR_SkinOptionsFrame(frame)
    frame.WOWTRModernSkinned = true

    frame:HookScript("OnShow", function(self)
        if WOWTR_PolishOptionsFrame then
            WOWTR_PolishOptionsFrame(self)
        end
    end)

    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:SetBackdropColor(WOWTR_PANEL.r, WOWTR_PANEL.g, WOWTR_PANEL.b, 0.96)
    frame:SetBackdropBorderColor(WOWTR_BORDER.r, WOWTR_BORDER.g, WOWTR_BORDER.b, 0.55)



    frame.HeaderShade = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    frame.HeaderShade:SetPoint("TOPLEFT", 1, -1)
    frame.HeaderShade:SetPoint("TOPRIGHT", -1, -1)
    frame.HeaderShade:SetHeight(86)
    WOWTR_SetTextureColor(frame.HeaderShade, WOWTR_PANEL_SOFT, 0.94)





    frame.SideShade = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    frame.SideShade:SetPoint("TOPLEFT", 1, -1)
    frame.SideShade:SetPoint("BOTTOMLEFT", 1, 1)
    frame.SideShade:SetWidth(204)
    WOWTR_SetTextureColor(frame.SideShade, { r = 0.025, g = 0.034, b = 0.040 }, 0.98)


    frame.ContentShade = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    frame.ContentShade:SetPoint("TOPLEFT", 205, -86)
    frame.ContentShade:SetPoint("BOTTOMRIGHT", -1, 52)
    WOWTR_SetTextureColor(frame.ContentShade, { r = 0.030, g = 0.037, b = 0.043 }, 0.72)

    frame.FooterShade = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    frame.FooterShade:SetPoint("BOTTOMLEFT", 1, 1)
    frame.FooterShade:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.FooterShade:SetHeight(52)
    WOWTR_SetTextureColor(frame.FooterShade, WOWTR_PANEL_SOFT, 0.86)

    frame.AccentLine = frame:CreateTexture(nil, "ARTWORK", nil, 7)
    frame.AccentLine:SetPoint("TOPLEFT", 205, -85)
    frame.AccentLine:SetPoint("TOPRIGHT", -56, -85)
    frame.AccentLine:SetHeight(2)
    WOWTR_SetTextureColor(frame.AccentLine, WOWTR_ACCENT, 0.75)

    frame.TopLine = WOWTR_CreateModernLine(frame, "ARTWORK", 0.36)
    frame.TopLine:SetPoint("TOPLEFT", 1, -86)
    frame.TopLine:SetPoint("TOPRIGHT", -1, -86)
    frame.TopLine:SetHeight(1)

    frame.FooterLine = WOWTR_CreateModernLine(frame, "ARTWORK", 0.28)
    frame.FooterLine:SetPoint("BOTTOMLEFT", 1, 53)
    frame.FooterLine:SetPoint("BOTTOMRIGHT", -1, 53)
    frame.FooterLine:SetHeight(1)


end

-- Changes only the options window background layers. Interactive controls and
-- text stay fully opaque so the interface remains readable at low values.
function WOWTR_SetOptionsOpacity(frame, opacity)
    if not frame then return end

    opacity = tonumber(opacity) or 1
    opacity = math.max(0.30, math.min(1, opacity))

    if frame.SetBackdropColor then
        frame:SetBackdropColor(WOWTR_PANEL.r, WOWTR_PANEL.g, WOWTR_PANEL.b, 0.96 * opacity)
    end

    local shades = {
        frame.HeaderShade,
        frame.SideShade,
        frame.ContentShade,
        frame.FooterShade,
    }
    for _, texture in ipairs(shades) do
        if texture then
            texture:SetAlpha(opacity)
        end
    end
end

-- Forces a real redraw across separate rendered frames. This is needed after
-- showing a tab because Retail can otherwise leave some child regions hidden
-- until the user moves the resize grip manually.
function WOWTR_ForceOptionsRedraw(frame)
    if not frame then return end

    local savedScale = tonumber(QTR_PS and QTR_PS["scale"]) or frame:GetScale() or 1
    frame:SetScale(savedScale)
    frame.WOWTRRedrawToken = (frame.WOWTRRedrawToken or 0) + 1
    local redrawToken = frame.WOWTRRedrawToken

    C_Timer.After(0.02, function()
        if frame:IsShown() and frame.WOWTRRedrawToken == redrawToken then
            frame:SetScale(savedScale + 0.001)
        end
    end)
    C_Timer.After(0.04, function()
        if frame:IsShown() and frame.WOWTRRedrawToken == redrawToken then
            frame:SetScale(savedScale)
        end
    end)
end

local function WOWTR_GetFontSize(fontString, fallback)
    local _, size = fontString:GetFont()
    size = tonumber(size)
    if not size or size ~= size or size <= 0 or size > 200 then
        return fallback or 13
    end
    return size
end

local function WOWTR_PolishFontString(fontString)
    if not fontString or fontString.WOWTRFontPolished then return end
    if fontString.WOWTRKeepFont then return end
    fontString.WOWTRFontPolished = true

    local size = WOWTR_GetFontSize(fontString, 13)
    local text = fontString:GetText() or ""
    local font = size >= 17 and WOWTR_UI_FONT_BOLD or WOWTR_UI_FONT
    fontString:SetFont(font, size, "")
    fontString:SetShadowColor(0, 0, 0, 0.85)
    fontString:SetShadowOffset(1, -1)

    if text == "" then
        fontString:SetTextColor(WOWTR_TEXT.r, WOWTR_TEXT.g, WOWTR_TEXT.b, 1)
    end
end

local function WOWTR_PolishTexture(texture)
    if not texture or texture.WOWTRTexturePolished then return end
    local source = texture.GetTexture and texture:GetTexture()
    if type(source) == "string" and source:find("_mini%.jpg") then
        texture.WOWTRTexturePolished = true
        texture:SetDesaturated(true)
        texture:SetVertexColor(0.78, 0.92, 0.88, 1)
        texture:SetAlpha(0.18)
        texture:SetSize(245, 245)
    end
end

local function WOWTR_PolishFrameTree(frame)
    if not frame then return end

    local regions = { frame:GetRegions() }
    for _, region in ipairs(regions) do
        local objectType = region:GetObjectType()
        if objectType == "FontString" then
            WOWTR_PolishFontString(region)
        elseif objectType == "Texture" then
            WOWTR_PolishTexture(region)
        end
    end

    local children = { frame:GetChildren() }
    for _, child in ipairs(children) do
        local childName = child.GetName and child:GetName() or ""
        if child:GetObjectType() == "Button"
            and not child.WOWTRCheckBg
            and not child.WOWTRModernStyled
            and not childName:find("WOWTR_Tab")
            and not childName:find("Close")
            and child:GetWidth() >= 50
            and child:GetHeight() >= 18 then
            WOWTR_StyleModernButton(child, false)
        end
        WOWTR_PolishFrameTree(child)
    end
end

function WOWTR_PolishOptionsFrame(frame)
    WOWTR_PolishFrameTree(frame)
end

-- Helper for creating modern UI tabs
function WOWTR_CreateModernTab(parent, id, text, iconPath, onClickFunc)
    local button = CreateFrame("Button", "WOWTR_Tab"..id.."TitleA", parent, "BackdropTemplate");
    button:SetSize(205, 36); -- Full width of sidebar
    
    -- Background (Default: Transparent/Dark)
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = nil,
        tile = false, tileSize = 0, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    });
    button:SetBackdropColor(0, 0, 0, 0); -- Transparent initially

    -- Highlight Texture (On Hover)
    local highlight = button:CreateTexture(nil, "HIGHLIGHT");
    highlight:SetAllPoints(button);
    highlight:SetColorTexture(1, 1, 1, 0.05); -- Very subtle white overlay

    -- Selected Indicator (Left Bar)
    button.SelectedBar = button:CreateTexture(nil, "OVERLAY");
    button.SelectedBar:SetSize(3, 36);
    button.SelectedBar:SetPoint("LEFT", button, "LEFT", 0, 0);
    WOWTR_SetTextureColor(button.SelectedBar, WOWTR_ACCENT, 1)
    button.SelectedBar:Hide();

    button.SelectedBg = button:CreateTexture(nil, "BACKGROUND", nil, 2)
    button.SelectedBg:SetAllPoints()
    WOWTR_SetTextureColor(button.SelectedBg, WOWTR_ACCENT, 0.13)
    button.SelectedBg:Hide()

    -- Icon
    if iconPath then
        button.Icon = button:CreateTexture(nil, "ARTWORK");
        button.Icon:SetSize(19, 19);
        button.Icon:SetPoint("LEFT", button, "LEFT", 28, 0); -- Padding left
        button.Icon:SetTexture(iconPath);
        button.Icon:SetVertexColor(0.72, 0.76, 0.76, 1)
    end

    -- Text
    button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    button.Text:SetPoint("LEFT", button, "LEFT", 62, 0); -- Right of icon
    button.Text:SetPoint("RIGHT", button, "RIGHT", -10, 0);
    button.Text:SetJustifyH("LEFT")
    button.Text:SetWordWrap(false)
    button.Text:SetText(text);
    button.Text:SetFont(WOWTR_UI_FONT_BOLD, 14, "");
    button.Text:SetTextColor(WOWTR_TEXT_DIM.r, WOWTR_TEXT_DIM.g, WOWTR_TEXT_DIM.b); -- Light Gray
    button.Text.WOWTRKeepFont = true

    -- OnClick Wrapper
    button:SetScript("OnClick", function(self)
        -- Reset all tabs logic (Will be handled by usage)
        -- Call original logic
        if onClickFunc then onClickFunc(self) end
        
        -- Update Visuals for All Tabs
        WOWTR_UpdateTabVisuals(id);
    end);
    
    button:SetScript("OnEnter", function(self)
        self.Text:SetTextColor(1, 1, 1); -- White on hover
        if self.Icon then self.Icon:SetVertexColor(1, 1, 1, 1) end
    end);

    button:SetScript("OnLeave", function(self)
        if not self.SelectedBar:IsShown() then
            self.Text:SetTextColor(WOWTR_TEXT_DIM.r, WOWTR_TEXT_DIM.g, WOWTR_TEXT_DIM.b); -- Back to gray if not selected
            if self.Icon then self.Icon:SetVertexColor(0.72, 0.76, 0.76, 1) end
        end
    end);

    return button;
end

-- Function to manage tab visual states
function WOWTR_UpdateTabVisuals(selectedId)
    -- List of known tab IDs
    local tabIds = {1, 2, 3, 6, 9, 4, 5, 12}; -- Add all IDs here (Quests, Chat, Books, Movies, etc.)
    
    for _, id in ipairs(tabIds) do
        local btn = _G["WOWTR_Tab"..id.."TitleA"];
        if btn then
            if id == selectedId then
                -- Selected State
                btn.SelectedBar:Show();
                if btn.SelectedBg then btn.SelectedBg:Show() end
                btn:SetBackdropColor(1, 1, 1, 0.02); -- Slight background
                btn.Text:SetTextColor(1, 1, 1, 1); -- White Text
                btn.Text:Show()
                if btn.Icon then btn.Icon:SetVertexColor(1, 1, 1, 1) end
            else
                -- Unselected State
                btn.SelectedBar:Hide();
                if btn.SelectedBg then btn.SelectedBg:Hide() end
                btn:SetBackdropColor(0, 0, 0, 0);
                btn.Text:SetTextColor(WOWTR_TEXT_DIM.r, WOWTR_TEXT_DIM.g, WOWTR_TEXT_DIM.b, 1);
                btn.Text:Show()
                if btn.Icon then btn.Icon:SetVertexColor(0.72, 0.76, 0.76, 1) end
            end
        end
    end
end

-- Main function to switch tabs
function WOWTR_SelectTab(id)
    -- 1. Update Buttons Visuals
    WOWTR_UpdateTabVisuals(id);

    -- 2. Hide All Panels
    local panels = {1, 2, 3, 4, 5, 6, 9, 12};
    for _, pID in ipairs(panels) do
        local panel = _G["WOWTR_OptionPanel"..pID];
        if panel then
            panel:Hide();
        end
    end

    -- 3. Show Selected Panel
    local selectedPanel = _G["WOWTR_OptionPanel"..id];
    if selectedPanel then
        selectedPanel:SetAlpha(1);
        selectedPanel:Show();
        WOWTR_ForceOptionsRedraw(selectedPanel:GetParent());
    end
end

local function WOWTR_RefreshModernCheckbox(cb)
    local checked = cb:GetChecked()
    
    -- Ensure the default Blizzard checked texture is completely hidden
    local checkedTexture = cb:GetCheckedTexture()
    if checkedTexture then
        checkedTexture:SetTexture(nil)
        checkedTexture:SetAlpha(0)
    end
    
    if cb.WOWTRCheckMark then
        if checked then
            cb.WOWTRCheckMark:Show()
        else
            cb.WOWTRCheckMark:Hide()
        end
    end
    
    if cb.WOWTRCheckBorder then
        if checked then
            WOWTR_SetTextureColor(cb.WOWTRCheckBorder, WOWTR_ACCENT, 0.90)
        else
            WOWTR_SetTextureColor(cb.WOWTRCheckBorder, WOWTR_BORDER, 0.55)
        end
    end

    if cb.WOWTRCheckBg then
        WOWTR_SetTextureColor(cb.WOWTRCheckBg, WOWTR_PANEL, 1.0)
    end
end

-- Helper for creating modern checkboxes
function WOWTR_CreateModernCheckbox(name, parent, text, onClickFunc)
    local cb = CreateFrame("CheckButton", name, parent);
    cb:SetSize(24, 24);

    local checkedTexture = cb:GetCheckedTexture()
    if checkedTexture then
        checkedTexture:SetTexture(nil)
        checkedTexture:SetAlpha(0)
    end

    cb.WOWTRCheckBg = cb:CreateTexture(nil, "BACKGROUND")
    cb.WOWTRCheckBg:SetPoint("CENTER")
    cb.WOWTRCheckBg:SetSize(18, 18)
    WOWTR_SetTextureColor(cb.WOWTRCheckBg, WOWTR_PANEL, 1.0)

    cb.WOWTRCheckBorder = cb:CreateTexture(nil, "BORDER")
    cb.WOWTRCheckBorder:SetPoint("CENTER")
    cb.WOWTRCheckBorder:SetSize(20, 20)
    WOWTR_SetTextureColor(cb.WOWTRCheckBorder, WOWTR_BORDER, 0.55)

    -- A clean, modern cyan checkmark instead of a blocky solid fill
    cb.WOWTRCheckMark = cb:CreateTexture(nil, "OVERLAY")
    cb.WOWTRCheckMark:SetPoint("CENTER")
    cb.WOWTRCheckMark:SetSize(18, 18)
    cb.WOWTRCheckMark:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    cb.WOWTRCheckMark:SetVertexColor(WOWTR_ACCENT.r, WOWTR_ACCENT.g, WOWTR_ACCENT.b, 1.0)
    cb.WOWTRCheckMark:Hide()

    -- Keep the old .Text access pattern used throughout WoW_Config.lua.
    if not cb.Text then
        cb.Text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    end
    
    cb.Text:SetPoint("LEFT", cb, "RIGHT", 8, 0);
    cb.Text:SetText(text);
    cb.Text:SetFont(WOWTR_UI_FONT, 14, "")
    cb.Text:SetTextColor(WOWTR_TEXT.r, WOWTR_TEXT.g, WOWTR_TEXT.b, 1); -- White text
    cb.Text:SetJustifyH("LEFT")
    cb.Text:SetWordWrap(false)
    cb.Text:SetWidth(520)
    cb.Text.WOWTRKeepFont = true

    local nativeTextSetFont = cb.Text.SetFont
    cb.Text.SetFont = function(self, font, size, flags)
        nativeTextSetFont(self, WOWTR_UI_FONT, size or 14, flags or "")
        self:SetTextColor(WOWTR_TEXT.r, WOWTR_TEXT.g, WOWTR_TEXT.b, 1)
        self:Show()
    end

    local nativeTextSetText = cb.Text.SetText
    cb.Text.SetText = function(self, value)
        nativeTextSetText(self, value or "")
        self:SetTextColor(WOWTR_TEXT.r, WOWTR_TEXT.g, WOWTR_TEXT.b, 1)
        self:Show()
    end

    local nativeSetScript = cb.SetScript
    cb.SetScript = function(self, scriptType, handler)
        if scriptType == "OnClick" and handler then
            nativeSetScript(self, scriptType, function(frame, ...)
                handler(frame, ...)
                WOWTR_RefreshModernCheckbox(frame)
            end)
        else
            nativeSetScript(self, scriptType, handler)
        end
    end

    cb:SetScript("OnClick", function(self)
        if onClickFunc then onClickFunc(self) end
    end);

    cb:HookScript("OnShow", function(self) WOWTR_RefreshModernCheckbox(self) end)
    cb:HookScript("OnEnter", function(self)
        if self.Text then self.Text:SetTextColor(1, 1, 1) end
        WOWTR_RefreshModernCheckbox(self)
    end)
    cb:HookScript("OnLeave", function(self)
        if self.Text then self.Text:SetTextColor(WOWTR_TEXT.r, WOWTR_TEXT.g, WOWTR_TEXT.b) end
        WOWTR_RefreshModernCheckbox(self)
    end)

    local nativeSetChecked = cb.SetChecked
    cb.SetChecked = function(self, checked)
        nativeSetChecked(self, checked)
        WOWTR_RefreshModernCheckbox(self)
    end
    WOWTR_RefreshModernCheckbox(cb)
    
    return cb;
end

-- Helper for creating modern sliders
function WOWTR_CreateModernSlider(name, parent, text, minVal, maxVal, step, onValueChangedFunc)
    local slider = CreateFrame("Slider", name, parent, "BackdropTemplate");
    slider:SetOrientation("HORIZONTAL");
    slider:SetHeight(5);
    slider:SetWidth(155);

    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = nil,
        tile = false, tileSize = 0, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    });
    slider:SetBackdropColor(0.12, 0.14, 0.16, 0.85); -- Darker track

    -- Progress Fill
    slider.Progress = slider:CreateTexture(nil, "BORDER");
    slider.Progress:SetHeight(5);
    slider.Progress:SetPoint("LEFT", slider, "LEFT", 0, 0);
    WOWTR_SetTextureColor(slider.Progress, WOWTR_ACCENT, 1.0)

    -- Thumb
    local thumb = slider:CreateTexture(nil, "OVERLAY");
    WOWTR_SetTextureColor(thumb, WOWTR_ACCENT, 1)
    thumb:SetSize(12, 17);
    slider:SetThumbTexture(thumb);

    -- Text (Header)
    local label = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    label:SetPoint("BOTTOM", slider, "TOP", 0, 8); -- Moved slightly higher
    label:SetText(text);
    label:SetFont(WOWTR_UI_FONT, 12)
    label:SetTextColor(WOWTR_TEXT.r, WOWTR_TEXT.g, WOWTR_TEXT.b);
    slider.Text = label;

    -- Low/High Text (Compatibility with OptionsSliderTemplate)
    slider.Low = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
    slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -3);
    
    slider.High = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
    slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -3);

    -- Value Text (Moved to RIGHT of the Label/Header to avoid overlap)
    local valText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    valText:SetPoint("LEFT", label, "RIGHT", 5, 0); -- Next to header
    valText:SetText("");
    valText:SetTextColor(WOWTR_ACCENT.r, WOWTR_ACCENT.g, WOWTR_ACCENT.b); -- Accent color for value
    slider.ValText = valText;

    slider:SetMinMaxValues(minVal, maxVal);
    slider:SetValueStep(step);
    slider:SetObeyStepOnDrag(true);

    slider:SetScript("OnValueChanged", function(self, value)
        -- Update value text
        local rounded = math.floor(value * 10 + 0.5) / 10; -- Round to 1 decimal
        if step == 1 then rounded = math.floor(value) end
        self.ValText:SetText(rounded);

        -- Update progress fill
        local minV, maxV = self:GetMinMaxValues();
        local range = maxV - minV;
        local percent = range > 0 and (value - minV) / range or 0;
        self.Progress:SetWidth(math.max(1, self:GetWidth() * percent));
        
        if onValueChangedFunc then onValueChangedFunc(self, value) end
    end);

    return slider;
end
