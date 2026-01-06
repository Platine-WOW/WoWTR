-- Helper for creating modern UI tabs
function WOWTR_CreateModernTab(parent, id, text, iconPath, onClickFunc)
    local button = CreateFrame("Button", "WOWTR_Tab"..id.."TitleA", parent, "BackdropTemplate");
    button:SetSize(185, 30); -- Full width of sidebar
    
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
    button.SelectedBar:SetSize(4, 30);
    button.SelectedBar:SetPoint("LEFT", button, "LEFT", 0, 0);
    button.SelectedBar:SetColorTexture(0, 0.7, 1, 1); -- Cyan/Blue Bar
    button.SelectedBar:Hide();

    -- Icon
    if iconPath then
        button.Icon = button:CreateTexture(nil, "ARTWORK");
        button.Icon:SetSize(18, 18);
        button.Icon:SetPoint("LEFT", button, "LEFT", 15, 0); -- Padding left
        button.Icon:SetTexture(iconPath);
    end

    -- Text
    button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    button.Text:SetPoint("LEFT", button, "LEFT", 45, 0); -- Right of icon
    button.Text:SetText(text);
    button.Text:SetFont(WOWTR_Font2, 14);
    button.Text:SetTextColor(0.8, 0.8, 0.8); -- Light Gray

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
    end);

    button:SetScript("OnLeave", function(self)
        if not self.SelectedBar:IsShown() then
            self.Text:SetTextColor(0.8, 0.8, 0.8); -- Back to gray if not selected
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
                btn:SetBackdropColor(1, 1, 1, 0.05); -- Slight background
                btn.Text:SetTextColor(1, 1, 1); -- White Text (User requested no blue)
            else
                -- Unselected State
                btn.SelectedBar:Hide();
                btn:SetBackdropColor(0, 0, 0, 0);
                btn.Text:SetTextColor(0.8, 0.8, 0.8);
            end
        end
    end
end

-- Main function to switch tabs
function WOWTR_SelectTab(id)
    -- 1. Update Buttons Visuals
    WOWTR_UpdateTabVisuals(id);

    -- 2. Hide All Panels
    local panels = {1, 2, 3, 4, 5, 6, 9};
    for _, pID in ipairs(panels) do
        local panel = _G["WOWTR_OptionPanel"..pID];
        if panel then
            panel:Hide();
        end
    end

    -- 3. Show Selected Panel
    local selectedPanel = _G["WOWTR_OptionPanel"..id];
    if selectedPanel then
        selectedPanel:Show();
        -- Animation: Fade In
        if UIFrameFadeIn then
            UIFrameFadeIn(selectedPanel, 0.2, 0, 1);
        end
    end
end


-- Helper for creating modern checkboxes (Reverted to standard style locally as per user request)
function WOWTR_CreateModernCheckbox(name, parent, text, onClickFunc)
    local cb = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate");
    cb:SetSize(26, 26); -- Standard size, slightly larger than 20 for better visibility

    -- 4. Label Text
    -- UICheckButtonTemplate creates a region named name.."Text" automatically or we can access it via key if it's not named?
    -- Actually standard template adds a FontString named $parentText or similar if inherited, let's just use our own reference for safety or set the existing one.
    
    -- The template usually creates a 'Text' region if using the name convention, but let's be explicit to match previous API
    if not cb.Text then
        cb.Text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    end
    
    cb.Text:SetPoint("LEFT", cb, "RIGHT", 5, 0);
    cb.Text:SetText(text);
    if WOWTR_Font2 then cb.Text:SetFont(WOWTR_Font2, 13) end;
    cb.Text:SetTextColor(1, 1, 1); -- White text

    cb:SetScript("OnClick", function(self)
        if onClickFunc then onClickFunc(self) end
    end);
    
    return cb;
end

-- Helper for creating modern sliders
function WOWTR_CreateModernSlider(name, parent, text, minVal, maxVal, step, onValueChangedFunc)
    local slider = CreateFrame("Slider", name, parent, "BackdropTemplate");
    slider:SetOrientation("HORIZONTAL");
    slider:SetHeight(8);
    slider:SetWidth(150);

    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = nil,
        tile = false, tileSize = 0, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    });
    slider:SetBackdropColor(0.2, 0.2, 0.2, 1); -- Main track color

    -- Thumb
    local thumb = slider:CreateTexture(nil, "OVERLAY");
    thumb:SetColorTexture(0, 0.7, 1); -- Blue Thumb
    thumb:SetSize(8, 14);
    slider:SetThumbTexture(thumb);

    -- Text (Header)
    local label = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    label:SetPoint("BOTTOM", slider, "TOP", 0, 8); -- Moved slightly higher
    label:SetText(text);
    if WOWTR_Font2 then label:SetFont(WOWTR_Font2, 12) end;
    label:SetTextColor(0.9, 0.9, 0.9);
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
    valText:SetTextColor(0, 0.7, 1); -- Blue color for value
    slider.ValText = valText;

    slider:SetMinMaxValues(minVal, maxVal);
    slider:SetValueStep(step);
    slider:SetObeyStepOnDrag(true);

    slider:SetScript("OnValueChanged", function(self, value)
        -- Update value text
        local rounded = math.floor(value * 10 + 0.5) / 10; -- Round to 1 decimal
        if step == 1 then rounded = math.floor(value) end
        self.ValText:SetText(rounded);
        
        if onValueChangedFunc then onValueChangedFunc(self, value) end
    end);

    return slider;
end
