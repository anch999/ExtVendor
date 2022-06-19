local L = LibStub("AceLocale-3.0"):GetLocale("ExtVendor", true);

local EXTVENDOR_DUMMY;

--========================================
-- Gets a list of junk items in the
-- player's bags
--========================================
function ExtVendor_GetQuickVendorList()

    local junk = {};
    local count, name, quality, price, maxStack;
    local isBoP, isKnown, reqClasses;
    local numBlacklisted = 0;

    for bag = 0, 4, 1 do
        if (GetContainerNumSlots(bag)) then
            for slot = 1, GetContainerNumSlots(bag), 1 do
                local isJunk = false;
                EXTVENDOR_DUMMY, count = GetContainerItemInfo(bag, slot);
                link = GetContainerItemLink(bag, slot);
                if (link and count) then
                    isBoP, isKnown, reqClasses = ExtVendor_GetExtendedItemInfo(link);
                    name, EXTVENDOR_DUMMY, quality, EXTVENDOR_DUMMY, EXTVENDOR_DUMMY, itemType, itemSubType, maxStack, itemEquipLoc, EXTVENDOR_DUMMY, price = GetItemInfo(link);

                    -- make sure the item has a vendor price
                    if ((price or 0) > 0) then

                        local isJunk, reason = ExtVendor_IsItemQuickVendor(link, quality, isBoP, isKnown, itemType, itemSubType, itemEquipLoc, reqClasses);

                        if ((not isJunk) and (reason == 100)) then
                            numBlacklisted = numBlacklisted + 1;
                        end

                        -- if the item meets requirements, add it to the list
                        if (isJunk) then
                            table.insert(junk, {name = name, quality = quality, count = count, maxStack = maxStack, stackPrice = count * price, reason = reason});
                        end
                    end
                end
            end
        end
    end

    table.sort(junk, function(a, b) return (a.stackPrice < b.stackPrice); end);

    if (table.maxn(junk) > 0) then
        return junk, numBlacklisted;
    end
    return nil;

end

--========================================
-- Show confirmation for selling all
-- junk items
--========================================
function ExtVendor_StartQuickVendor(self)

    local junk, numBlacklisted = ExtVendor_GetQuickVendorList();

    if (junk) then
        ExtVendor_ShowJunkPopup(junk, numBlacklisted);
    end

end

--========================================
-- Returns whether an item should
-- quick-vendor based on quality, type,
-- if it is already known, soulbound
--========================================
function ExtVendor_IsItemQuickVendor(link, quality, isSoulbound, alreadyKnown, type, subType, equipSlot, requiredClasses)
    local itemID = ExtVendor_GetItemID(link);
    -- don't vendor blacklisted items
    if (ExtVendor_IsBlacklisted(itemID)) then
        return false, 100;
    end
    -- always vendor whitelisted items
    if (ExtVendor_IsWhitelisted(itemID)) then
        return true, L["QUICKVENDOR_REASON_WHITELISTED"];
    end
    -- NEVER quick-vendor legendary or heirloom items. EVER. Ever. ever.
    if (quality > 4) then
        return false;
    end
    -- *** Poor (grey) items ***
    if (quality == 0) then
        return true, L["QUICKVENDOR_REASON_POORQUALITY"];
    end
    -- *** Common (white) gear ***
    if (EXTVENDOR_DATA['config']['quickvendor_whitegear']) then
        if (quality == 1) then
            if (type == "Armor") then
                if ((subType == L["ARMOR_CLOTH"]) or (subType == L["ARMOR_LEATHER"]) or (subType == L["ARMOR_MAIL"]) or (subType == L["ARMOR_PLATE"])) then
                    if ((equipSlot ~= "INVTYPE_TABARD") and (equipSlot ~= "INVTYPE_SHIRT")) then
                        return true, L["QUICKVENDOR_REASON_WHITEGEAR"];
                    end
                end
            elseif (type == "Weapon") then
                if ((subType == L["WEAPON_1H_AXE"]) or (subType == L["WEAPON_1H_MACE"]) or (subType == L["WEAPON_1H_SWORD"]) or (subType == L["WEAPON_2H_AXE"])
                or (subType == L["WEAPON_2H_MACE"]) or (subType == L["WEAPON_2H_SWORD"]) or (subType == L["WEAPON_POLEARM"]) or (subType == L["WEAPON_DAGGER"])
                or (subType == L["WEAPON_FIST"]) or (subType == L["WEAPON_STAFF"]) or (subType == L["WEAPON_WAND"]) or (subType == L["WEAPON_BOW"])
                or (subType == L["WEAPON_GUN"]) or (subType == L["WEAPON_CROSSBOW"])) then
                    return true, L["QUICKVENDOR_REASON_WHITEGEAR"];
                end
            end
        end
    end
    -- Soulbound stuff
    if (isSoulbound) then
        -- *** "Already Known" ***
        if (EXTVENDOR_DATA['config']['quickvendor_alreadyknown']) then
            if (alreadyKnown) then
                return true, L["QUICKVENDOR_REASON_ALREADYKNOWN"];
            end
        end
        -- *** Unusable (class-restricted, unusable armor/weapon types) ***
        if (EXTVENDOR_DATA['config']['quickvendor_unusable']) then
            if (not ExtVendor_ClassIsAllowed(UnitClass("player"), requiredClasses)) then
                return true, L["QUICKVENDOR_REASON_CLASSRESTRICTED"];
            end
            if (not ExtVendor_IsUsableArmorType(type, subType, equipSlot)) then
                return true, L["QUICKVENDOR_REASON_UNUSABLEARMOR"];
            end
            if (not ExtVendor_IsUsableWeaponType(type, subType, equipSlot)) then
                return true, L["QUICKVENDOR_REASON_UNUSABLEWEAPON"];
            end
        end
        -- *** Sub-optimal armor ***
        if (EXTVENDOR_DATA['config']['quickvendor_suboptimal']) then
            if (not ExtVendor_IsOptimalArmor(type, subType, equipSlot)) then
                return true, L["QUICKVENDOR_REASON_SUBOPTIMAL"];
            end
        end
    end
    -- nothing matched = do not quickvendor
    return false;
end

--========================================
-- Performs quick-vendor
--========================================
function ExtVendor_ConfirmQuickVendor()
    local link, count, name, color, quality, price, maxStack, quantity;
    local totalPrice = 0;
    local itemsOnLine = 0;
    local numItemsSold = 0;
    local itemsSold = "";
    local soldPref = L["SOLD"];

    if (not MerchantFrame:IsShown()) then return; end

    for bag = 0, 4, 1 do
        if (GetContainerNumSlots(bag)) then
            for slot = 1, GetContainerNumSlots(bag), 1 do
                EXTVENDOR_DUMMY, count = GetContainerItemInfo(bag, slot);
                link = GetContainerItemLink(bag, slot);
                if (link and count) then
                    name, EXTVENDOR_DUMMY, quality, EXTVENDOR_DUMMY, EXTVENDOR_DUMMY, itemType, itemSubType, maxStack, itemEquipLoc, EXTVENDOR_DUMMY, price = GetItemInfo(link);
                    local isBoP, isKnown, reqClasses = ExtVendor_GetExtendedItemInfo(link);

                    if ((price or 0) > 0) then
                        if (ExtVendor_IsItemQuickVendor(link, quality, isBoP, isKnown, itemType, itemSubType, itemEquipLoc, reqClasses)) then
                            PickupContainerItem(bag, slot);
                            PickupMerchantItem(0);
                            EXTVENDOR_DUMMY, EXTVENDOR_DUMMY, EXTVENDOR_DUMMY, color = GetItemQualityColor(quality);
                            if (itemsOnLine > 0) then
                                itemsSold = itemsSold .. ", ";
                            end
                            if (maxStack > 1) then
                                quantity = "x" .. count;
                            else
                                quantity = "";
                            end
                            itemsSold = itemsSold .. "|c" .. color .. "[" .. name .. "]|r" .. quantity;
                            itemsOnLine = itemsOnLine + 1;
                            if (itemsOnLine == 12) then
                                DEFAULT_CHAT_FRAME:AddMessage(soldPref .. " " .. itemsSold, ChatTypeInfo["SYSTEM"].r, ChatTypeInfo["SYSTEM"].g, ChatTypeInfo["SYSTEM"].b, GetChatTypeIndex("SYSTEM"));
                                soldPref = "    ";
                                itemsSold = "";
                                itemsOnLine = 0;
                            end
                            totalPrice = totalPrice + (price * count);
                            numItemsSold = numItemsSold + 1;
                        end
                    end
                end
            end
        end
    end

    if (itemsOnLine > 0) then
        DEFAULT_CHAT_FRAME:AddMessage(soldPref .. " " .. itemsSold, ChatTypeInfo["SYSTEM"].r, ChatTypeInfo["SYSTEM"].g, ChatTypeInfo["SYSTEM"].b, GetChatTypeIndex("SYSTEM"));
    end
    if (numItemsSold > 0) then
        DEFAULT_CHAT_FRAME:AddMessage(string.format(L["JUNK_MONEY_EARNED"], "|cffffffff" .. ExtVendor_FormatMoneyString(totalPrice)), ChatTypeInfo["SYSTEM"].r, ChatTypeInfo["SYSTEM"].g, ChatTypeInfo["SYSTEM"].b, GetChatTypeIndex("SYSTEM"));
    end
end

--========================================
-- Returns whether or not the specified
-- item ID is blacklisted
--========================================
function ExtVendor_IsBlacklisted(itemId)

    for idx, id in pairs(EXTVENDOR_DATA['quickvendor_blacklist']) do
        if (id == itemId) then
            return true;
        end
    end

    return false;

end

--========================================
-- Returns whether or not the specified
-- item ID is whitelisted
--========================================
function ExtVendor_IsWhitelisted(itemId, globalOnly)
    for idx, id in pairs(EXTVENDOR_DATA['quickvendor_whitelist']) do
        if (id == itemId) then
            return true;
        end
    end
    if (not globalOnly) then
        for idx, id in pairs(EXTVENDOR_DATA[EXTVENDOR_PROFILE]['quickvendor_whitelist']) do
            if (id == itemId) then
                return true;
            end
        end
    end
    return false;
end

--========================================
-- Shows or hides the quick vendor button
-- depending on configuration
--========================================
function ExtVendor_UpdateQuickVendorButtonVisibility()
    if (EXTVENDOR_DATA['config']['enable_quickvendor']) then
        MerchantFrameSellJunkButton:Show();
    else
        MerchantFrameSellJunkButton:Hide();
    end
end
