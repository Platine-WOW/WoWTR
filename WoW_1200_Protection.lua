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

-- Checks if the tooltip is safe to process
function WOWTR_IsSafeToProcess(tooltip)
    return true
end

-- Fallback Shim for older versions (though file is 12.0 protected)
if not WOWTR_Is1200OrNewer then
    WOWTR_IsSafeToProcess = function() return true end
end
