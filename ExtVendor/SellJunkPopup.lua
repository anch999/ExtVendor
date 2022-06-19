local L = LibStub("AceLocale-3.0"):GetLocale("ExtVendor", true);

local EXTVENDOR_DUMMY;

--========================================
-- Popup load
--========================================
function ExtVendor_SellJunkPopup_OnLoad(self)

    ExtVendor_SellJunkPopupMessage:SetText(L["CONFIRM_SELL_JUNK"]);

    hooksecurefunc("StaticPopup_OnShow", ExtVendor_Hook_StaticPopup_OnShow);
    hooksecurefunc("StaticPopup_OnHide", ExtVendor_Hook_StaticPopup_OnHide);

    tinsert(UISpecialFrames, "ExtVendor_SellJunkPopup");

end

--========================================
-- Show the custom sell junk popup
--========================================
function ExtVendor_ShowJunkPopup(junkList, numBlacklisted)

    if (ExtVendor_SellJunkPopup:IsShown() or (not junkList)) then return; end

    ExtVendor_SellJunkPopup_UpdatePosition();

    ExtVendor_SellJunkPopup_BuildJunkList(junkList, numBlacklisted);

    ExtVendor_SellJunkPopup:Show();

end

--========================================
-- Update popup position based on the
-- state of the original static popups
--========================================
function ExtVendor_SellJunkPopup_UpdatePosition()

    local anchorTo = 0;

    for i = 1, 4, 1 do
        local popup = _G["StaticPopup" .. i];
        if (popup) then
            if (popup:IsShown()) then
                anchorTo = i;
            end
        end
    end

    ExtVendor_SellJunkPopup:ClearAllPoints();
    if (anchorTo > 0) then
        ExtVendor_SellJunkPopup:SetPoint("TOP", _G["StaticPopup" .. anchorTo], "BOTTOM", 0, 0);
    else
        ExtVendor_SellJunkPopup:SetPoint("TOP", UIParent, "TOP", 0, -135);
    end

end

--========================================
-- Build the list of junk items to sell
--========================================
function ExtVendor_SellJunkPopup_BuildJunkList(junkList, numBlacklisted)

    local line = 1;
    local leftText, midText, rightText, quantity;
    local topOfList = 25 + ExtVendor_SellJunkPopupMessage:GetStringHeight() + 15;
    local totalHeight = 0;
    local totalPrice = 0;

    for i = 1, 100, 1 do
        leftText = _G["ExtVendor_SellJunkPopupLeft" .. i];
        midText = _G["ExtVendor_SellJunkPopupMid" .. i];
        rightText = _G["ExtVendor_SellJunkPopupRight" .. i];
        if (leftText) then leftText:Hide(); end
        if (midText) then midText:Hide(); end
        if (rightText) then rightText:Hide(); end
    end

    if (table.maxn(junkList) > 0) then
        for index, data in pairs(junkList) do
            leftText = _G["ExtVendor_SellJunkPopupLeft" .. line];
            midText = _G["ExtVendor_SellJunkPopupMid" .. line];
            rightText = _G["ExtVendor_SellJunkPopupRight" .. line];
            if (not leftText) then
                leftText = ExtVendor_SellJunkPopup:CreateFontString("ExtVendor_SellJunkPopupLeft" .. line, "ARTWORK", "GameFontHighlightSmall");
                if (line == 1) then
                    leftText:SetPoint("TOPLEFT", ExtVendor_SellJunkPopup, "TOPLEFT", 25, -topOfList);
                else
                    leftText:SetPoint("TOPLEFT", _G["ExtVendor_SellJunkPopupLeft" .. (line - 1)], "BOTTOMLEFT", 0, -2);
                end
            else
                leftText:Show();
            end
            if (not midText) then
                midText = ExtVendor_SellJunkPopup:CreateFontString("ExtVendor_SellJunkPopupMid" .. line, "ARTWORK", "GameFontHighlightSmall");
                if (line == 1) then
                    midText:SetPoint("TOP", ExtVendor_SellJunkPopup, "TOP", 50, -topOfList);
                else
                    midText:SetPoint("TOP", _G["ExtVendor_SellJunkPopupMid" .. (line - 1)], "BOTTOM", 0, -2);
                end
            else
                midText:Show();
            end
            if (not rightText) then
                rightText = ExtVendor_SellJunkPopup:CreateFontString("ExtVendor_SellJunkPopupRight" .. line, "ARTWORK", "GameFontHighlightSmall");
                rightText:SetJustifyH("RIGHT");
                if (line == 1) then
                    rightText:SetPoint("TOPRIGHT", ExtVendor_SellJunkPopup, "TOPRIGHT", -25, -topOfList);
                else
                    rightText:SetPoint("TOPRIGHT", _G["ExtVendor_SellJunkPopupRight" .. (line - 1)], "BOTTOMRIGHT", 0, -2);
                end
            else
                rightText:Show();
            end
            if (data.maxStack > 1) then
                quantity = "x" .. data.count;
            else
                quantity = "";
            end
            EXTVENDOR_DUMMY, EXTVENDOR_DUMMY, EXTVENDOR_DUMMY, color = GetItemQualityColor(data.quality);
            leftText:SetText("|c" .. color .. "[" .. data.name .. "]|r" .. quantity);
            midText:SetText(data.reason);
            rightText:SetText(string.trim(ExtVendor_FormatMoneyString(data.stackPrice, true)));
            if (line == 1) then
                totalHeight = topOfList + leftText:GetStringHeight();
            else
                totalHeight = totalHeight + 2 + leftText:GetStringHeight();
            end
            line = line + 1;
            totalPrice = totalPrice + data.stackPrice;
        end
    end

    local tsOffset = 0;

    totalHeight = totalHeight + 15;

    local totalLeft = ExtVendor_SellJunkPopupTotalLeft or ExtVendor_SellJunkPopup:CreateFontString("ExtVendor_SellJunkPopupTotalLeft", "ARTWORK", "GameFontHighlight");
    local totalRight = ExtVendor_SellJunkPopupTotalRight or ExtVendor_SellJunkPopup:CreateFontString("ExtVendor_SellJunkPopupTotalRight", "ARTWORK", "GameFontHighlight");
    totalLeft:ClearAllPoints();
    totalLeft:SetPoint("TOPLEFT", _G["ExtVendor_SellJunkPopupLeft" .. (line - 1)], "BOTTOMLEFT", 0, -(15 + tsOffset));
    totalLeft:SetText(L["TOTAL_SALE_PRICE"]);

    totalRight:ClearAllPoints();
    totalRight:SetPoint("TOPRIGHT", _G["ExtVendor_SellJunkPopupRight" .. (line - 1)], "BOTTOMRIGHT", 0, -(15 + tsOffset));
    totalRight:SetText(ExtVendor_FormatMoneyString(totalPrice));

    totalHeight = totalHeight + totalLeft:GetStringHeight() + 15;

    -- blacklist message
    local blText;
    blText = _G["ExtVendor_SellJunkPopupBlacklist"];
    if ((numBlacklisted or 0) > 0) then
        if (not blText) then
            blText = ExtVendor_SellJunkPopup:CreateFontString("ExtVendor_SellJunkPopupBlacklist", "ARTWORK", "GameFontHighlight");
        end
        blText:ClearAllPoints();
        blText:SetPoint("TOP", ExtVendor_SellJunkPopup, "TOP", 0, -(totalHeight - 10));
        blText:SetText(string.format(L["ITEMS_BLACKLISTED"], numBlacklisted));
        blText:Show();
        totalHeight = totalHeight + 5 + blText:GetStringHeight();
    else
        if (blText) then
            blText:Hide();
        end
    end

    ExtVendor_SellJunkPopupYesButton:SetPoint("TOPRIGHT", ExtVendor_SellJunkPopup, "TOP", -5, -totalHeight);

    totalHeight = totalHeight + ExtVendor_SellJunkPopupYesButton:GetHeight() + 25;

    ExtVendor_SellJunkPopup:SetHeight(totalHeight);

end

--========================================
-- Hook for static popup OnShow
--========================================
function ExtVendor_Hook_StaticPopup_OnShow(self)

    ExtVendor_SellJunkPopup_UpdatePosition();

end

--========================================
-- Hook for static popup OnHide
--========================================
function ExtVendor_Hook_StaticPopup_OnHide(self)

    ExtVendor_SellJunkPopup_UpdatePosition();

end
