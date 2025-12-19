-- WoWTR 12.0.0+ (Midnight?) Compatibility & Protection Layer
-- Description: Handles API changes and provides safe wrappers for Beta/PTR
-- Author: Hakan YILMAZ

local _, _, _, uiVersion = GetBuildInfo()
-- Global variable to check for 12.0.0+
WOWTR_Is1200OrNewer = uiVersion and uiVersion >= 120000

-- If we are NOT on 12.0.0+, we can stop here or define empty placeholders if needed.
-- But since this file is for protection logic specifically for new version, 
-- we mostly want to expose the flag and maybe some utility functions.

if not WOWTR_Is1200OrNewer then
    return
end

-- ----------------------------------------------------------------------------
-- Protection Functions for 12.0.0+
-- ----------------------------------------------------------------------------

-- Safe wrapper for GameTooltip access that might trigger "restricted execution" or "secret" errors
function WOWTR_ProtectedTooltipCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        -- Suppress "secret" value errors which are common in 12.0.0+ restricted environments
        if result and string.find(tostring(result), "secret") then
            return nil
        end
        -- Allow other errors to bubble up or log them only in verbose mode
        -- print("WoWTR Protection Error:", result) 
    end
    return success, result
end

-- Add any other 12.0.0 specific shims or protections here

-- Global Taint Protection Flag (Whitelist Strategy)
WOWTR_TooltipAllowed = false

-- Initialize Whitelist Protection
if WOWTR_Is1200OrNewer then
    -- Reset allow flag when tooltip is cleared/hidden
    -- We can safely hook GameTooltip here as this file loads early
    GameTooltip:HookScript("OnTooltipCleared", function() WOWTR_TooltipAllowed = false end)
    GameTooltip:HookScript("OnHide", function() WOWTR_TooltipAllowed = false end)
    
    -- Helper to authorize tooltip processing
    local function AllowTooltip() WOWTR_TooltipAllowed = true end

    -- Hook standard events to whitelist safe types via TooltipDataProcessor (10.0+)
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, AllowTooltip)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, AllowTooltip)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, AllowTooltip)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, AllowTooltip)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, AllowTooltip)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, AllowTooltip)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Achievement, AllowTooltip)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, AllowTooltip)
    else
        -- Traditional Fallback for older clients (if Is1200OrNewer is true significantly in future)
        GameTooltip:HookScript("OnTooltipSetItem", AllowTooltip)
        GameTooltip:HookScript("OnTooltipSetSpell", AllowTooltip)
        GameTooltip:HookScript("OnTooltipSetUnit", AllowTooltip)
        if GameTooltip.OnTooltipSetAction then
           GameTooltip:HookScript("OnTooltipSetAction", AllowTooltip) 
        end
    end
else
    -- Pre-12.0.0 (Retail/Classic): Always allow processing, legacy logic applies
    WOWTR_TooltipAllowed = true
end
