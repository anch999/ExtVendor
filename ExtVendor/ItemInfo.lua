local L = LibStub("AceLocale-3.0"):GetLocale("ExtVendor", true);

--========================================
-- Retrieve additional item info via the
-- item's tooltip
--========================================
function ExtVendor_GetExtendedItemInfo(link)
    -- set up return values
    local isBoP = false
    local isKnown = false;
    local classes = {};

    -- generate item tooltip in hidden tooltip object
    ExtVendorHiddenTooltip:SetOwner(UIParent, "ANCHOR_LEFT");

    local ok = pcall(ExtVendor_SetHiddenTooltip, link);
    if (ok) then

        for cl = 2, ExtVendorHiddenTooltip:NumLines(), 1 do
            local checkLine = _G["ExtVendorHiddenTooltipTextLeft" .. cl]:GetText();
            if (checkLine) then

                -- check if item binds when picked up
                if (cl <= 3) then
                    if (checkLine == ITEM_BIND_ON_PICKUP) then
                        isBoP = true;
                    end
                end

                -- check for "Already Known"
                if (checkLine == ITEM_SPELL_KNOWN) then
                    isKnown = true;
                end
            end
        end

    end

    ExtVendorHiddenTooltip:Hide();

    return isBoP, isKnown;
end

--========================================
-- Returns an item's ID from the given
-- link
--========================================
function ExtVendor_GetItemID(link)
    if (link) then
        for w in string.gmatch(link, "item:(%d+):") do
            return tonumber(w);
        end
    end
    return nil;
end