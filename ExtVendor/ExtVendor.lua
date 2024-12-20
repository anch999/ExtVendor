local EV = LibStub("AceAddon-3.0"):NewAddon("ExtVendor", "AceTimer-3.0")

EXTVENDOR_VERSION = GetAddOnMetadata("ExtVendor", "Version");
EXTVENDOR_VERSION_ID = 10502;
EXTVENDOR_ITEMS_PER_SUBPAGE = MERCHANT_ITEMS_PER_PAGE;  -- transfer original page size to become "sub-pages"
EXTVENDOR_SUBPAGES_PER_PAGE = 2;                        -- number of sub-pages per page
MERCHANT_ITEMS_PER_PAGE = 20;                           -- overrides default value of base ui, default functions will handle page display accordingly
EXTVENDOR_HOOKS = {};
EXTVENDOR_DATA = {};
EXTVENDOR_PROFILE = "";
EXTVENDOR_SELECTED_QUALITY = 0;
EXTVENDOR_SPECIFIC_QUALITY = false;

local L = LibStub("AceLocale-3.0"):GetLocale("ExtVendor", true);

local EXTVENDOR_NUM_PAGES = 1;
local SLOT_FILTER_INDEX = 0;
local STAT_FILTER_INDEX = 0;

local SLOT_FILTERS = {
    [1] = {"INVTYPE_HEAD", "INVTYPE_SHOULDER", "INVTYPE_CLOAK", "INVTYPE_CHEST", "INVTYPE_ROBE", "INVTYPE_WRIST", "INVTYPE_HAND", "INVTYPE_WAIST", "INVTYPE_LEGS", "INVTYPE_FEET"},
    [2] = {"INVTYPE_HEAD"},
    [3] = {"INVTYPE_SHOULDER"},
    [4] = {"INVTYPE_CLOAK"},
    [5] = {"INVTYPE_CHEST", "INVTYPE_ROBE"},
    [6] = {"INVTYPE_WRIST"},
    [7] = {"INVTYPE_HAND"},
    [8] = {"INVTYPE_WAIST"},
    [9] = {"INVTYPE_LEGS"},
    [10] = {"INVTYPE_FEET"},

    [20] = {"INVTYPE_NECK", "INVTYPE_BODY", "INVTYPE_TABARD", "INVTYPE_FINGER", "INVTYPE_TRINKET"},
    [21] = {"INVTYPE_NECK"},
    [22] = {"INVTYPE_BODY"},
    [23] = {"INVTYPE_TABARD"},
    [24] = {"INVTYPE_FINGER"},
    [25] = {"INVTYPE_TRINKET"},

    [30] = {"INVTYPE_WEAPON", "INVTYPE_WEAPONMAINHAND", "INVTYPE_2HWEAPON", "INVTYPE_WEAPONOFFHAND", "INVTYPE_RANGED", "INVTYPE_RANGEDRIGHT"},
    [31] = {"INVTYPE_WEAPON", "INVTYPE_WEAPONMAINHAND"},
    [32] = {"INVTYPE_2HWEAPON"},
    [33] = {"INVTYPE_WEAPONOFFHAND"},
    [34] = {"INVTYPE_RANGED", "INVTYPE_RANGEDRIGHT"},

    [40] = {"INVTYPE_HOLDABLE", "INVTYPE_SHIELD"},
    [41] = {"INVTYPE_HOLDABLE"},
    [42] = {"INVTYPE_SHIELD"},
};

local STAT_FILTERS = {
    [1] = {"ITEM_MOD_STRENGTH_SHORT", "ITEM_MOD_STRENGTH_SHORT", "ITEM_MOD_AGILITY_SHORT", "ITEM_MOD_INTELLECT_SHORT", "ITEM_MOD_SPIRIT_SHORT", "ITEM_MOD_STAMINA_SHORT"},
    [2] = {"ITEM_MOD_STRENGTH_SHORT"},
    [3] = {"ITEM_MOD_AGILITY_SHORT"},
    [4] = {"ITEM_MOD_INTELLECT_SHORT"},
    [5] = {"ITEM_MOD_SPIRIT_SHORT"},
    [6] = {"ITEM_MOD_STAMINA_SHORT"},

    [6] = {"ITEM_MOD_ATTACK_POWER_SHORT", "ITEM_MOD_SPELL_POWER_SHORT", "ITEM_MOD_CRIT_RATING_SHORT", "ITEM_MOD_HIT_RATING_SHORT", "ITEM_MOD_HASTE_RATING_SHORT", "ITEM_MOD_EXPERTISE_RATING_SHORT", "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT", "ITEM_MOD_SPELL_PENETRATION_SHORT"},
    [7] = {"ITEM_MOD_ATTACK_POWER_SHORT"},
    [8] = {"ITEM_MOD_SPELL_POWER_SHORT"},
    [9] = {"ITEM_MOD_CRIT_RATING_SHORT"},
    [10] = {"ITEM_MOD_HIT_RATING_SHORT"},
    [11] = {"ITEM_MOD_HASTE_RATING_SHORT"},
    [12] = {"ITEM_MOD_EXPERTISE_RATING_SHORT"},
    [13] = {"ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT"},
    [14] = {"ITEM_MOD_SPELL_PENETRATION_SHORT"},

    [15] = {"ITEM_MOD_DEFENSE_SKILL_RATING_SHORT", "ITEM_MOD_DODGE_RATING_SHORT", "ITEM_MOD_PARRY_RATING_SHORT", "ITEM_MOD_BLOCK_RATING_SHORT", "ITEM_MOD_BLOCK_VALUE_SHORT", "ITEM_MOD_RESILIENCE_RATING"},
    [16] = {"ITEM_MOD_DEFENSE_SKILL_RATING_SHORT"},
    [17] = {"ITEM_MOD_DODGE_RATING_SHORT"},
    [18] = {"ITEM_MOD_PARRY_RATING_SHORT"},
    [19] = {"ITEM_MOD_BLOCK_RATING_SHORT"},
    [20] = {"ITEM_MOD_BLOCK_VALUE_SHORT"},
    [21] = {"ITEM_MOD_RESILIENCE_RATING"}
}
--========================================
-- Initial load routine
--========================================
function ExtVendor_OnLoad(self)

    ExtVendor_RebuildMerchantFrame()

    ExtVendor_UpdateButtonPositions()

    EXTVENDOR_HOOKS["MerchantFrame_UpdateMerchantInfo"] = MerchantFrame_UpdateMerchantInfo
    MerchantFrame_UpdateMerchantInfo = ExtVendor_UpdateMerchantInfo
    EXTVENDOR_HOOKS["MerchantFrame_UpdateBuybackInfo"] = MerchantFrame_UpdateBuybackInfo
    MerchantFrame_UpdateBuybackInfo = ExtVendor_UpdateBuybackInfo

    MerchantFrame:HookScript("OnShow", ExtVendor_OnShow)
    MerchantFrame:HookScript("OnHide", ExtVendor_OnHide)

    self:RegisterEvent("ADDON_LOADED")

    SLASH_EXTVENDOR1 = "/evui"
    SlashCmdList["EXTVENDOR"] = ExtVendor_CommandHandler

end

local function ExtVendor_AutoSell_Junk()
    if EXTVENDOR_DATA.config.enable_quickvendor_auto then
        ExtVendor_ConfirmQuickVendor()
    end
end

--========================================
-- Hooked merchant frame OnShow
--========================================
function ExtVendor_OnShow(self)
    if EXTVENDOR_DATA['config']['hide_default_vendor_auto_sell'] then
        MerchantFrameSellJunkFrameAutoSellCheck:Hide()
    else
        MerchantFrameSellJunkFrameAutoSellCheck:Show()
    end
    if not EXTVENDOR_DATA['config']['armor_filter'] then
        EXTVENDOR_DATA['config']['armor_filter'] = {
            All = true,
            Cloth = false,
            Leather = false,
            Mail = false,
            Plate = false
        }
    end

    MerchantFrameSearchBox:SetText("")

    ExtVendor_SetMinimumQuality(0)
    ExtVendor_SetSlotFilter(0)
    ExtVendor_AutoSell_Junk()
end

--========================================
-- Hooked merchant frame OnHide
--========================================
function ExtVendor_OnHide(self)

    CloseDropDownMenus();

end

--========================================
-- Event handler
--========================================
function ExtVendor_OnEvent(self, event, ...)
    
    if (event == "ADDON_LOADED") then
        local arg1 = ...;
        if (arg1 == "ExtVendor") then
            ExtVendor_Setup()
        end
    end

end

--========================================
-- Post-load setup
--========================================
function ExtVendor_Setup()

    EXTVENDOR_PROFILE = GetRealmName() .. "." .. UnitName("player");

    local version = ExtVendor_CheckSetting("version", EXTVENDOR_VERSION_ID);

    EXTVENDOR_DATA['config']['version'] = EXTVENDOR_VERSION_ID;

    ExtVendor_CheckSetting("hide_filtered", false);
    ExtVendor_CheckSetting("hide_known_recipes", false);
    ExtVendor_CheckSetting("hide_known_ascension_collection_items", false);
    ExtVendor_CheckSetting("stockfilter_defall", false);
    ExtVendor_CheckSetting("show_load_message", false);
    ExtVendor_CheckSetting("mousewheel_paging", true);
    ExtVendor_CheckSetting("enable_quickvendor", true);
    ExtVendor_CheckSetting("enable_quickvendor_auto", true);
    ExtVendor_CheckSetting("scale", 1);
    ExtVendor_CheckSetting("filter_purchased_recipes", true);

    ExtVendor_CheckSetting("quickvendor_alreadyknown", false);
    ExtVendor_CheckSetting("quickvendor_alreadyknownBoeRecipes", false);
    ExtVendor_CheckSetting("quickvendor_whitegear", false);

    if (EXTVENDOR_DATA['config']['show_load_message']) then
        ExtVendor_Message(string.format(L["LOADED_MESSAGE"], EXTVENDOR_VERSION));
    end

    -- initialize the customizable blacklist
    if (not EXTVENDOR_DATA['quickvendor_blacklist']) then
        EXTVENDOR_DATA['quickvendor_blacklist'] = EXTVENDOR_QUICKVENDOR_DEFAULT_BLACKLIST;
    end
    -- initialize global whitelist
    if (not EXTVENDOR_DATA['quickvendor_whitelist']) then
        EXTVENDOR_DATA['quickvendor_whitelist'] = {};
    end

    if (not EXTVENDOR_DATA[EXTVENDOR_PROFILE]) then
        EXTVENDOR_DATA[EXTVENDOR_PROFILE] = {};
    end

    -- initialize per-character whitelist
    if (not EXTVENDOR_DATA[EXTVENDOR_PROFILE]['quickvendor_whitelist']) then
        EXTVENDOR_DATA[EXTVENDOR_PROFILE]['quickvendor_whitelist'] = {};
    end

    ExtVendor_UpdateMouseScrolling();
    ExtVendor_UpdateQuickVendorButtonVisibility();

end

--========================================
-- Check configuration setting, and
-- initialize with default value if not
-- present
--========================================
function ExtVendor_CheckSetting(field, default)

    if (not EXTVENDOR_DATA['config']) then
        EXTVENDOR_DATA['config'] = {};
    end
    if (EXTVENDOR_DATA['config'][field] == nil) then
        EXTVENDOR_DATA['config'][field] = default;
    end
    return EXTVENDOR_DATA['config'][field];
end

--========================================
-- Rearrange item slot positions
--========================================
function ExtVendor_UpdateButtonPositions(isBuyBack)

    local btn;
    local vertSpacing, horizSpacing;

    if (isBuyBack) then
        vertSpacing = -30;
        horizSpacing = 50;
    else
        vertSpacing = -16;
        horizSpacing = 12;
    end
    for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
        btn = _G["MerchantItem" .. i];
        if (isBuyBack) then
            if (i > BUYBACK_ITEMS_PER_PAGE) then
                btn:Hide();
            else
                if (i == 1) then
                    btn:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 64, -105);
                else
                    if ((i % 3) == 1) then
                        btn:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 3)], "BOTTOMLEFT", 0, vertSpacing);
                    else
                        btn:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", horizSpacing, 0);
                    end
                end
            end
        else
            btn:Show();
            if ((i % EXTVENDOR_ITEMS_PER_SUBPAGE) == 1) then
                if (i == 1) then
                    btn:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 34, -82);
                else
                    btn:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - (EXTVENDOR_ITEMS_PER_SUBPAGE - 1))], "TOPRIGHT", 12, 0);
                end
            else
                if ((i % 2) == 1) then
                    btn:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 2)], "BOTTOMLEFT", 0, vertSpacing);
                else
                    btn:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", horizSpacing, 0);
                end
            end
        end
    end

end
local numButtons = 0
--========================================
-- Show merchant page
--========================================
function ExtVendor_UpdateMerchantInfo()
    EXTVENDOR_HOOKS["MerchantFrame_UpdateMerchantInfo"]();
    ExtVendor_UpdateButtonPositions();

    -- set title and portrait
	MerchantNameText:SetText(UnitName("NPC"));
	SetPortraitTexture(MerchantFramePortrait, "NPC");

    -- locals
    local totalMerchantItems = GetMerchantNumItems();
    local visibleMerchantItems = 0;
    local indexes = {};
    local search = string.trim(MerchantFrameSearchBox:GetText());
	local name, texture, price, quantity, numAvailable, isUsable, extendedCost, r, g, b, notOptimal;
    local link, quality, itemType, itemSubType, itemId, itemEquipLoc;
    local isFiltered = false;
    local isBoP = false;
    local isKnown = false;
    local isCollectionItemKnow = false;

    -- **************************************************
    --  Pre-check filtering if hiding filtered items
    -- **************************************************
    if (EXTVENDOR_DATA['config']['hide_filtered']) then
        visibleMerchantItems = 0;
        for i = 1, totalMerchantItems, 1 do
		    name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(i);
            if (name) then
                isFiltered = false;
                link = GetMerchantItemLink(i);
                quality = 1;
                isKnown = false;
                isBoP = false;
                isCollectionItemKnow = false;

                -- get info from item link
                if (link) then
                    isBoP, isKnown = ExtVendor_GetExtendedItemInfo(link);
                    itemId = ExtVendor_GetItemID(link);
                    isCollectionItemKnow = C_VanityCollection.IsCollectionItemOwned(itemId);
                    _, _, quality, _, _, itemType, itemSubType, _, itemEquipLoc, _, _ = GetItemInfo(link);
                end
                -- filter known recipes
                if (EXTVENDOR_DATA['config']['hide_known_recipes'] and isKnown) then
                    isFiltered = true;
                end
                -- filter known skill cards
                if (EXTVENDOR_DATA['config']['hide_known_ascension_collection_items'] and isCollectionItemKnow) then
                    isFiltered = true;
                end
                -- filter purchased recipes
                if (EXTVENDOR_DATA['config']['filter_purchased_recipes']) then
                    if (itemType == L["ITEMTYPE_RECIPE"]) then
                        if (ExtVendor_HasItemInBags(itemId) > 0) then
                            isFiltered = true;
                        end
                    end
                end
                -- check search filter
                if (string.len(search) > 0) then
                    if (not string.find(string.lower(name), string.lower(search), 1, true)) then
                        isFiltered = true;
                    end
                end
                -- check quality filter
                if (EXTVENDOR_SELECTED_QUALITY > 0) then
                    if ((quality < EXTVENDOR_SELECTED_QUALITY) or ((quality > EXTVENDOR_SELECTED_QUALITY) and EXTVENDOR_SPECIFIC_QUALITY)) then
                        isFiltered = true;
                    end
                end
                -- check armor filter
                if EXTVENDOR_DATA['config']['armor_filter'] and not EXTVENDOR_DATA['config']['armor_filter']["All"] and itemType == "Armor" then
                    for i, v in pairs(EXTVENDOR_DATA['config']['armor_filter']) do
                        if i == itemSubType and not v then
                            isFiltered = true
                        end
                    end   
                end
                -- check slot filter
                if (SLOT_FILTER_INDEX > 0) then
                    if (SLOT_FILTERS[SLOT_FILTER_INDEX]) then
                        local validSlot = false;
                        for _, slot in pairs(SLOT_FILTERS[SLOT_FILTER_INDEX]) do
                            if (slot == itemEquipLoc) then
                                validSlot = true;
                            end
                        end
                        if (not validSlot) then
                            isFiltered = true;
                        end
                    end
                end
                
                -- check stat filter
                if (STAT_FILTER_INDEX > 0) then
                    if (STAT_FILTERS[STAT_FILTER_INDEX]) and link then
                        local ItemStats = {};
                        GetItemStats(link, ItemStats);
                        local validSlot = false;
                        for _, slot in pairs(STAT_FILTERS[STAT_FILTER_INDEX]) do
                            if (ItemStats[slot]) then
                                validSlot = true;
                            end
                        end
                        if (not validSlot) then
                            isFiltered = true;
                        end
                    end
                end

                -- ***** add item to list if not filtered *****
                if (not isFiltered) then
                    table.insert(indexes, i);
                    visibleMerchantItems = visibleMerchantItems + 1;
                end
            end
        end
    else
        -- no item hiding, add all items to list
        visibleMerchantItems = totalMerchantItems;
        for i = 1, totalMerchantItems, 1 do
            table.insert(indexes, i);
        end
    end

    -- validate current page shown
    if (MerchantFrame.page > math.max(1, math.ceil(visibleMerchantItems / MERCHANT_ITEMS_PER_PAGE))) then
        MerchantFrame.page = math.max(1, math.ceil(visibleMerchantItems / MERCHANT_ITEMS_PER_PAGE));
    end

    -- Show correct page count based on number of items shown
	MerchantPageText:SetFormattedText(MERCHANT_PAGE_NUMBER, MerchantFrame.page, math.ceil(visibleMerchantItems / MERCHANT_ITEMS_PER_PAGE));

    -- **************************************************
    --  Display items on merchant page
    -- **************************************************
    local isAltCurrency = {}
    
    if numButtons then
        for i = 1, numButtons, 1 do
            _G["MerchantFrame_AltCurrency"..i]:Hide()
            _G["MerchantFrame_AltCurrency_Icon"..i]:Hide()
        end
    end

    for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
        local index = ((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i;
		local itemButton = _G["MerchantItem" .. i .. "ItemButton"];
        itemButton.link = nil;
		local merchantButton = _G["MerchantItem" .. i];
		local merchantMoney = _G["MerchantItem" .. i .. "MoneyFrame"];
		local merchantAltCurrency = _G["MerchantItem" .. i .. "AltCurrencyFrame"];

        if (index <= visibleMerchantItems) then
			name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(indexes[index]);
            if (name ~= nil) then
			    _G["MerchantItem"..i.."Name"]:SetText(name);
			    SetItemButtonCount(itemButton, quantity);
			    SetItemButtonStock(itemButton, numAvailable);
			    SetItemButtonTexture(itemButton, texture);
                local honorPoints, arenaPoints = GetMerchantItemCostInfo(i);
                -- update item's currency info
			    if ( extendedCost and (price <= 0) ) then
				    itemButton.price = nil;
				    itemButton.extendedCost = true;
				    itemButton.link = GetMerchantItemLink(indexes[index]);
				    itemButton.texture = texture;
				    MerchantFrame_UpdateAltCurrency(indexes[index], i);
				    merchantAltCurrency:ClearAllPoints();
				    merchantAltCurrency:SetPoint("BOTTOMLEFT", "MerchantItem"..i.."NameFrame", "BOTTOMLEFT", 0, 31);
				    merchantMoney:Hide();
				    merchantAltCurrency:Show();
                    if honorPoints > 0 then
                        isAltCurrency.honor = {"honor", true, "honor"}
                    elseif arenaPoints > 0 then
                        isAltCurrency.arena = {"arena", true, "arena"}
                    elseif _G["MerchantItem" .. i .. "AltCurrencyFrameItem1"].itemLink then 
                        local _, id = strsplit(":", _G["MerchantItem" .. i .. "AltCurrencyFrameItem1"].itemLink)
                        isAltCurrency[id] = {id}
                    end
			    elseif ( extendedCost and (price > 0) ) then
				    itemButton.price = price;
				    itemButton.extendedCost = true;
				    itemButton.link = GetMerchantItemLink(indexes[index]);
				    itemButton.texture = texture;
				    MerchantFrame_UpdateAltCurrency(indexes[index], i);
				    MoneyFrame_Update(merchantMoney:GetName(), price);
				    merchantAltCurrency:ClearAllPoints();
				    merchantAltCurrency:SetPoint("LEFT", merchantMoney:GetName(), "RIGHT", -14, 0);
				    merchantAltCurrency:Show();
				    merchantMoney:Show();
                    if honorPoints > 0 then
                        isAltCurrency.honor = {"honor", true, "honor"}
                    elseif arenaPoints > 0 then
                        isAltCurrency.arena = {"arena", true, "arena"}
                    elseif _G["MerchantItem" .. i .. "AltCurrencyFrameItem1"].itemLink then  
                        local _, id = strsplit(":", _G["MerchantItem" .. i .. "AltCurrencyFrameItem1"].itemLink)
                        isAltCurrency[id] = {id}
                    end
			    else
				    itemButton.price = price;
				    itemButton.extendedCost = nil;
				    itemButton.link = GetMerchantItemLink(indexes[index]);
				    itemButton.texture = texture;
				    MoneyFrame_Update(merchantMoney:GetName(), price);
				    merchantAltCurrency:Hide();
				    merchantMoney:Show();
			    end

                isBoP = false;
                isKnown = false;
                isFiltered = false;
                isCollectionItemKnow = false;

                quality = 1;
                if (itemButton.link) then
                    isBoP, isKnown = ExtVendor_GetExtendedItemInfo(itemButton.link);
                    itemId = ExtVendor_GetItemID(itemButton.link);
                    isCollectionItemKnow = C_VanityCollection.IsCollectionItemOwned(itemId);
                    _, _, quality, _, _, itemType, itemSubType, _, itemEquipLoc, _, _ = GetItemInfo(itemButton.link);
                end

                -- set color
                r, g, b = GetItemQualityColor(quality);
                _G["MerchantItem" .. i .. "Name"]:SetTextColor(r, g, b);

                -- check filtering
                if (not EXTVENDOR_DATA['config']['hide_filtered']) then
                    -- check search filter
                    if (string.len(search) > 0) then
                        if (not string.find(string.lower(name), string.lower(search), 1, true)) then
                            isFiltered = true;
                        end
                    end
                    -- check quality filter
                    if (EXTVENDOR_SELECTED_QUALITY > 0) then
                        if ((quality < EXTVENDOR_SELECTED_QUALITY) or ((quality > EXTVENDOR_SELECTED_QUALITY) and EXTVENDOR_SPECIFIC_QUALITY)) then
                            isFiltered = true;
                        end
                    end
                    -- filter known recipes
                    if (EXTVENDOR_DATA['config']['hide_known_recipes'] and isKnown) then
                        isFiltered = true;
                    end
                    -- filter known skill cards
                    if (EXTVENDOR_DATA['config']['hide_known_ascension_collection_items'] and isCollectionItemKnow) then
                        isFiltered = true;
                    end
                    -- filter purchased recipes
                    if (EXTVENDOR_DATA['config']['filter_purchased_recipes']) then
                        if (itemType == L["ITEMTYPE_RECIPE"]) then
                            if (ExtVendor_HasItemInBags(itemId) > 0) then
                                isFiltered = true;
                            end
                        end
                    end
                    -- check armor filter
                    if EXTVENDOR_DATA['config']['armor_filter'] and not EXTVENDOR_DATA['config']['armor_filter']["All"] and itemType == "Armor" then
                        for i, v in pairs(EXTVENDOR_DATA['config']['armor_filter']) do
                            if i == itemSubType and not v then
                                isFiltered = true
                            end
                        end   
                    end
                    -- check slot filter
                    if (SLOT_FILTER_INDEX > 0) then
                        if (SLOT_FILTERS[SLOT_FILTER_INDEX]) then
                            local validSlot = false;
                            for _, slot in pairs(SLOT_FILTERS[SLOT_FILTER_INDEX]) do
                                if (slot == itemEquipLoc) then
                                    validSlot = true;
                                end
                            end
                            if (not validSlot) then
                                isFiltered = true;
                            end
                        end
                    end

                    -- check stat filter
                    if (STAT_FILTER_INDEX > 0) then
                        if (STAT_FILTERS[STAT_FILTER_INDEX]) and itemButton.link then
                            local ItemStats = {};
                            GetItemStats(itemButton.link, ItemStats);
                            local validSlot = false;
                            for _, slot in pairs(STAT_FILTERS[STAT_FILTER_INDEX]) do
                                if (ItemStats[slot]) then
                                    validSlot = true;
                                end
                            end
                            if (not validSlot) then
                                isFiltered = true;
                            end
                        end
                    end
                end

                ExtVendor_SearchDimItem(_G["MerchantItem" .. i], isFiltered);

			    itemButton.hasItem = true;
			    itemButton:SetID(indexes[index]);
			    itemButton:Show();
                local colorMult = 1.0;
                local detailColor = {};
                local slotColor = {};
                -- unavailable items (limited stock, bought out) are darkened
			    if ( numAvailable == 0 ) then
                    colorMult = 0.5;
                end
			    if ( not isUsable ) then
                    slotColor = {r = 1.0, g = 0, b = 0};
                    detailColor = {r = 1.0, g = 0, b = 0};
			    else
                    if (notOptimal) then
                        slotColor = {r = 0.25, g = 0.25, b = 0.25};
                        detailColor = {r = 0.5, g = 0, b = 0};
                    else
                        slotColor = {r = 1.0, g = 1.0, b = 1.0};
                        detailColor = {r = 0.5, g = 0.5, b = 0.5};
                    end
			    end
			    SetItemButtonNameFrameVertexColor(merchantButton, detailColor.r * colorMult, detailColor.g * colorMult, detailColor.b * colorMult);
			    SetItemButtonSlotVertexColor(merchantButton, slotColor.r * colorMult, slotColor.g * colorMult, slotColor.b * colorMult);
			    SetItemButtonTextureVertexColor(itemButton, slotColor.r * colorMult, slotColor.g * colorMult, slotColor.b * colorMult);
			    SetItemButtonNormalTextureVertexColor(itemButton, slotColor.r * colorMult, slotColor.g * colorMult, slotColor.b * colorMult);
            end
        else
			itemButton.price = nil;
			itemButton.hasItem = nil;
			itemButton:Hide();
			SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5);
			SetItemButtonSlotVertexColor(merchantButton,0.4, 0.4, 0.4);
			_G["MerchantItem"..i.."Name"]:SetText("");
			_G["MerchantItem"..i.."MoneyFrame"]:Hide();
			_G["MerchantItem"..i.."AltCurrencyFrame"]:Hide();
            ExtVendor_SearchDimItem(_G["MerchantItem" .. i], false);
        end
    end

    if isAltCurrency then
        ExtVendor_UpdateAltCurrency(isAltCurrency)
    end
	MerchantFrame_UpdateRepairButtons();

	-- Handle vendor buy back item
	local buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable = GetBuybackItemInfo(GetNumBuybackItems());
	if ( buybackName ) then
		MerchantBuyBackItemName:SetText(buybackName);
		SetItemButtonCount(MerchantBuyBackItemItemButton, buybackQuantity);
		SetItemButtonStock(MerchantBuyBackItemItemButton, buybackNumAvailable);
		SetItemButtonTexture(MerchantBuyBackItemItemButton, buybackTexture);
		MerchantBuyBackItemMoneyFrame:Show();
		MoneyFrame_Update("MerchantBuyBackItemMoneyFrame", buybackPrice);
		MerchantBuyBackItem:Show();
	else
		MerchantBuyBackItemName:SetText("");
		MerchantBuyBackItemMoneyFrame:Hide();
		SetItemButtonTexture(MerchantBuyBackItemItemButton, "");
		SetItemButtonCount(MerchantBuyBackItemItemButton, 0);
		-- Hide the tooltip upon sale
		if ( GameTooltip:IsOwned(MerchantBuyBackItemItemButton) ) then
			GameTooltip:Hide();
		end
	end

	-- Handle paging buttons
	if ( visibleMerchantItems > MERCHANT_ITEMS_PER_PAGE ) then
		if ( MerchantFrame.page == 1 ) then
			MerchantPrevPageButton:Disable();
		else
			MerchantPrevPageButton:Enable();
		end
		if ( MerchantFrame.page == ceil(visibleMerchantItems / MERCHANT_ITEMS_PER_PAGE) or visibleMerchantItems == 0) then
			MerchantNextPageButton:Disable();
		else
			MerchantNextPageButton:Enable();
		end
        EXTVENDOR_NUM_PAGES = ceil(visibleMerchantItems / MERCHANT_ITEMS_PER_PAGE);
		MerchantPageText:Show();
		MerchantPrevPageButton:Show();
		MerchantNextPageButton:Show();
	else
        EXTVENDOR_NUM_PAGES = 1;
		MerchantPageText:Hide();
		MerchantPrevPageButton:Hide();
		MerchantNextPageButton:Hide();
	end

	-- Show all merchant related items
	MerchantBuyBackItem:Show();
	MerchantFrameBottomLeftBorder:Show();
	MerchantFrameBottomRightBorder:Show();

	-- Hide buyback related items
    for i = 13, MERCHANT_ITEMS_PER_PAGE, 1 do
	    _G["MerchantItem" .. i]:Show();
    end

    local numHiddenItems = math.max(0, totalMerchantItems - visibleMerchantItems);
    local hstring = (numHiddenItems == 1) and L["SINGLE_ITEM_HIDDEN"] or L["MULTI_ITEMS_HIDDEN"];
    MerchantFrameHiddenText:SetText(string.format(hstring, numHiddenItems));

    -- update text color for buyback slot
    local link = GetBuybackItemLink(GetNumBuybackItems());
    if (link) then
        local _, _, quality = GetItemInfo(link);
        local r, g, b = GetItemQualityColor(quality);
        MerchantBuyBackItemName:SetTextColor(r, g, b);
    end

    if (ExtVendor_GetQuickVendorList()) then
        ExtVendor_SetJunkButtonState(true);
    else
        ExtVendor_SetJunkButtonState(false);
    end
end

--========================================
-- Show buyback page
--========================================
function ExtVendor_UpdateBuybackInfo()
    EXTVENDOR_HOOKS["MerchantFrame_UpdateBuybackInfo"]();
    ExtVendor_UpdateButtonPositions(true);
    -- apply coloring
    local btn, link, quality, r, g, b;
    for i = 1, BUYBACK_ITEMS_PER_PAGE, 1 do
        btn = _G["MerchantItem" .. i];
        if (btn) then
            link = GetBuybackItemLink(i);
            if (link) then
                _, _, quality = GetItemInfo(link);
                r, g, b = GetItemQualityColor(quality);
                _G["MerchantItem" .. i .. "Name"]:SetTextColor(r, g, b);
            end
            ExtVendor_SearchDimItem(btn, false);
        end
    end
end

function ExtVendor_PairsByKeys(t)
    local a = {}
    for n in pairs(t) do
      table.insert(a, n)
    end
    table.sort(a)
  
    local i = 0
    local iter = function()
      i = i + 1
      if a[i] == nil then
        return nil
      else
        return a[i], t[a[i]]
      end
    end
    return iter
end

local function createAtlCurrencys(num)
    if _G["MerchantFrame_AltCurrency"..num] then return _G["MerchantFrame_AltCurrency"..num] end
    local altCurrencyFrame = "MerchantFrame_AltCurrency"..num
    local altCurrencyFrameIcon = "MerchantFrame_AltCurrency_Icon"..num
    local button = CreateFrame("Button", altCurrencyFrame, MerchantFrame)
    button:SetSize(100,15)
    button.icon = button:CreateTexture(altCurrencyFrameIcon,"ARTWORK");
    button.icon:SetSize(13,13);
    button.icon:SetPoint("RIGHT", altCurrencyFrame,0,0);
	button.Lable = button:CreateFontString(nil, "BORDER", "GameFontNormal");
    button.Lable:SetPoint("RIGHT", altCurrencyFrameIcon, -15, 1);
	button.Lable:SetJustifyH("RIGHT");
    button:SetScript("OnLeave", function () GameTooltip:Hide() end)
    button:Hide()
    numButtons = numButtons + 1
    return _G[altCurrencyFrame]
end

local function setTooltip(button)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -13, -50)
        if tonumber(button.itemID) then
        GameTooltip:SetHyperlink(select(2,GetItemInfo(button.itemID)));
        else
            GameTooltip:AddLine(button.itemID)
        end
        GameTooltip:Show()
    end)
end

local function updateCurrency(text, button)
    if text == "arena" then
        button.Lable:SetText("Arena Points: |cffffffff"..GetArenaCurrency())
    else
        button.Lable:SetText("Honor Points: |cffffffff"..GetHonorCurrency())
    end
end

local fac = UnitFactionGroup("player")

function ExtVendor_UpdateAltCurrency(currencyTable)
    local i = 1
    local sorted = {}
    for id, v in pairs(currencyTable) do
        if id == "honor" or id == "arena" then
            sorted[id] = v
        else
            sorted[GetItemInfo(v[1])] = v
        end
    end
    table.sort(sorted)
    for _,currency in ExtVendor_PairsByKeys(sorted) do
        if currency[1] then
            local button = createAtlCurrencys(i)
            if currency[2] and currency[3] == "honor" then
                button.itemID = "Honor Points"
                button.icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..fac);
                button.Lable:SetText("Honor Points: |cffffffff"..GetHonorCurrency())
                button.icon:SetSize(16,16);
                EV:ScheduleTimer(updateCurrency, .2, "honor", button)
            elseif currency[2] and currency[3] == "arena" then
                button.itemID = "Arena Points"
                button.icon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon");
                button.Lable:SetText("Arena Points: |cffffffff"..GetArenaCurrency())
                button.icon:SetSize(16,16);
                EV:ScheduleTimer(updateCurrency, .2, "arena", button)
            else
                button.itemID = currency[1]
                button.icon:SetTexture(GetItemIcon(currency[1]));
                button.Lable:SetText("|cffffffff"..GetItemCount(currency[1]))
                button.icon:SetSize(13,13);
            end
            setTooltip(button)
            if i == 1 then
                button:ClearAllPoints()
                button:SetPoint("RIGHT","MerchantMoneyFrameGoldButton", (- MerchantMoneyFrameGoldButtonText:GetStringWidth()) - 20,-1);
            else
                local lastFrame = i - 1
                button:ClearAllPoints()
                button:SetPoint("RIGHT",_G["MerchantFrame_AltCurrency"..lastFrame], (- button.Lable:GetStringWidth()) - 20,0);
            end
            button:SetWidth(button.Lable:GetStringWidth() + 15)
            button:Show()
            button.icon:Show()
            i = i + 1
        end
    end
end
--========================================
-- Rebuilds the merchant frame into
-- the extended design
--========================================
function ExtVendor_RebuildMerchantFrame()

    -- set the new width of the frame
    if ExtVendor_LastPos then
    MerchantFrame:SetPoint(ExtVendor_LastPos);
    end

    MerchantFrame:SetWidth(736);
    MerchantFrame:RegisterForDrag("LeftButton");
    MerchantFrame:SetScript("OnDragStart", function ()
        MerchantFrame:StartMoving();
        MerchantFrame.isMoving = true;
    end)
    MerchantFrame:SetMovable(true);
    MerchantFrame:SetScript("OnDragStop", function ()
        MerchantFrame:StopMovingOrSizing();
        ExtVendor_LastPos = MerchantFrame:GetPoint();
        MerchantFrame.isMoving = false;
    end)
    MerchantRepairSettingsButton:SetPoint("BottomLeft",MerchantFrame,152,111);
    -- create new item buttons as needed
    for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
        if (not _G["MerchantItem" .. i]) then
            CreateFrame("Frame", "MerchantItem" .. i, MerchantFrame, "MerchantItemTemplate");
        end
    end

    -- Thank you Blizzard for making the frame dynamically resizable for me. :D

    -- retexture the border element around the repair/buyback spots on the merchant tab
    MerchantFrameBottomLeftBorder:SetTexture("Interface\\AddOns\\ExtVendor\\textures\\bottomborder");
    MerchantFrameBottomRightBorder:SetTexture("Interface\\AddOns\\ExtVendor\\textures\\bottomborder");

    local topmiddleleft = MerchantFrame:CreateTexture("ExtFrameTop", "BACKGROUND");
    topmiddleleft:SetPoint("TOP", MerchantFrame,85, 0);
    topmiddleleft:SetTexture("Interface\\AddOns\\ExtVendor\\textures\\UI-Merchant-TopRight","MIRROR","MIRROR");
    topmiddleleft:SetHorizTile(true);
    topmiddleleft:SetWidth(400);

    local botmiddleleft = MerchantFrame:CreateTexture("ExtFrameBot", "BACKGROUND");
    botmiddleleft:SetPoint("BOTTOM", MerchantFrame, 100, 0);
    botmiddleleft:SetTexture("Interface\\AddOns\\ExtVendor\\textures\\UI-MERCHANT-BOTRIGHT","MIRROR","MIRROR");
    botmiddleleft:SetHorizTile(true);
    botmiddleleft:SetWidth(450);

    -- alter the position of the buyback item slot on the merchant tab
    MerchantBuyBackItem:ClearAllPoints();
    MerchantBuyBackItem:SetPoint("TOPLEFT", MerchantItem10, "BOTTOMLEFT", -11, -18.5);

    -- move the next/previous page buttons
    MerchantPrevPageButton:ClearAllPoints();
    MerchantPrevPageButton:SetPoint("CENTER", MerchantFrame, "BOTTOM", 30, 110);
    MerchantPageText:ClearAllPoints();
    MerchantPageText:SetPoint("BOTTOM", MerchantFrame, "BOTTOM", 160, 105);
    MerchantNextPageButton:ClearAllPoints();
    MerchantNextPageButton:SetPoint("CENTER", MerchantFrame, "BOTTOM", 290, 110);
    -- currency insets
    -- MerchantFrameAltCurrencyFrame:ClearAllPoints();
    -- MerchantFrameAltCurrencyFrame:SetPoint("BOTTOMRIGHT", "MerchantItem"..i.."NameFrame", "BOTTOMLEFT", 0, 0);
    --merchantAltCurrency:Show();

    --[[ MerchantExtraCurrencyBg:ClearAllPoints();
    MerchantExtraCurrencyBg:SetPoint("TOPLEFT", MerchantExtraCurrencyInset, "TOPLEFT", 3, -2);
    MerchantExtraCurrencyBg:SetPoint("BOTTOMRIGHT", MerchantExtraCurrencyInset, "BOTTOMRIGHT", -3, 2); ]]
    -- add the search box
    local editbox = CreateFrame("EditBox", "MerchantFrameSearchBox", MerchantFrame, "EV_SearchBoxTemplate");
    editbox:SetWidth(200);
    editbox:SetHeight(24);
    editbox:SetPoint("TOPRIGHT", MerchantFrame, "TOPRIGHT", -55, -42);
    editbox:SetAutoFocus(false);
    editbox:SetScript("OnTextChanged", ExtVendor_UpdateDisplay);
    editbox:SetMaxLetters(30);

    -- add quick-vendor button
    local junkBtn = CreateFrame("Button", "MerchantFrameSellJunkButton", MerchantFrame);
    junkBtn:SetWidth(32);
    junkBtn:SetHeight(32);
    junkBtn:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 80, -38);
    junkBtn.tooltip = L["QUICKVENDOR_BUTTON_TOOLTIP"];
    junkBtn:SetScript("OnClick", ExtVendor_StartQuickVendor);
    junkBtn:SetScript("OnEnter", ExtVendor_ShowButtonTooltip);
    junkBtn:SetScript("OnLeave", ExtVendor_HideButtonTooltip);
    junkBtn:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
    junkBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");
    junkBtn.junkBtnIcon = junkBtn:CreateTexture("MerchantFrameSellJunkButtonIcon", "BORDER");
    junkBtn.junkBtnIcon:SetTexture("Interface\\Icons\\inv_misc_bag_10");
    junkBtn.junkBtnIcon:SetPoint("TOPLEFT", junkBtn, "TOPLEFT", 0, 0);
    junkBtn.junkBtnIcon:SetPoint("BOTTOMRIGHT", junkBtn, "BOTTOMRIGHT", 0, 0);

    -- filter button
   local filterBtn = CreateFrame("Button", "MerchantFrameFilterButton", MerchantFrame, "ExtVendor_UIButtonStretchTemplate");
    filterBtn:SetText(FILTER);
    filterBtn:SetPoint("RIGHT", MerchantFrameSearchBox, "LEFT", -30, 0);
    filterBtn:SetWidth(80);
    filterBtn:SetHeight(22);
    filterBtn:SetScript("OnClick", ExtVendor_DisplayFilterDropDown);
    MerchantFrameFilterButtonRightArrow:Show();

    -- create text for showing number of hidden items
    local hiddenText = MerchantFrame:CreateFontString("MerchantFrameHiddenText", "ARTWORK", "GameFontNormal");
    hiddenText:SetPoint("RIGHT", MerchantFrameFilterButton, "LEFT", -10, 0);
    hiddenText:SetJustifyH("RIGHT");
    hiddenText:SetText("0 item(s) hidden");

    -- hide the new stock filter dropdown
    --MerchantFrameLootFilter:Hide();

    -- filter options dropdown
    local filterDropdown = CreateFrame("Frame", "MerchantFrameFilterDropDown", UIParent, "UIDropDownMenuTemplate");

    -- create a new tooltip object for handling item tooltips in the background
    evTooltip = CreateFrame("GameTooltip", "ExtVendorHiddenTooltip", UIParent, "GameTooltipTemplate");

    function MerchantItemButton_OnModifiedClick(self, button)
        if ( MerchantFrame.selectedTab == 1 ) then
            -- Is merchant frame
            if ( HandleModifiedItemClick(GetMerchantItemLink(self:GetID())) ) then
                return;
            end
                if IsAltKeyDown() then
                    local maxStack = GetMerchantItemMaxStack(self:GetID());
                    if ( self.extendedCost ) then
                        MerchantFrame_ConfirmExtendedItemCost(self);
                    elseif ( self.price and self.price >= MERCHANT_HIGH_PRICE_COST ) then
                        MerchantFrame_ConfirmHighCostItem(self);
                    else
                        BuyMerchantItem(self:GetID(),maxStack);
                    end
                elseif ( IsModifiedClick("SPLITSTACK") ) then
                    local maxStack = GetMerchantItemMaxStack(self:GetID());
                    if ( self.price and (self.price > 0) ) then
                        local canAfford = floor(GetMoney() / self.price);
                        if ( canAfford < maxStack ) then
                            maxStack = canAfford;
                        end
                    end
                    OpenStackSplitFrame(1000, self, "BOTTOMLEFT", "TOPLEFT");
                    return;
            end
        else
            HandleModifiedItemClick(GetBuybackItemLink(self:GetID()));
        end
    end
end

--========================================
-- Performs additional updates to main
-- display - fades items for searching
-- and applies quality colors to names
--========================================
function ExtVendor_UpdateDisplay()

    if (MerchantFrame.selectedTab == 1) then
        ExtVendor_UpdateMerchantInfo();
    elseif (MerchantFrame.selectedTab == 2) then
        ExtVendor_UpdateBuybackInfo();
    end

    CloseDropDownMenus();

end

--========================================
-- Dims or shows an item frame
--========================================
function ExtVendor_SearchDimItem(itemFrame, isDimmed)

    if (not itemFrame) then return; end

    local alpha;

    if (isDimmed) then
        alpha = 0.2;
    else
        alpha = 1;
    end
    itemFrame:SetAlpha(alpha);

    local btn = _G[itemFrame:GetName() .. "ItemButton"];
    if (isDimmed) then
        btn:Disable();
    else
        btn:Enable();
    end

end

--========================================
-- Show button tooltips
--========================================
function ExtVendor_ShowButtonTooltip(self)

    if (self.tooltip) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText(self.tooltip);
        GameTooltip:Show();
    end

end

--========================================
-- Hide button tooltips
--========================================
function ExtVendor_HideButtonTooltip(self)

    if (GameTooltip:GetOwner() == self) then
        GameTooltip:Hide();
    end

end

--========================================
-- Enable/disable the sell junk button
--========================================
function ExtVendor_SetJunkButtonState(state)
    if (state) then
        MerchantFrameSellJunkButton:Enable();
        MerchantFrameSellJunkButtonIcon:SetDesaturated(false);
    else
        MerchantFrameSellJunkButton:Disable();
        MerchantFrameSellJunkButtonIcon:SetDesaturated(true);
    end
end

--========================================
-- Gold/silver/copper money formatting
--========================================
function ExtVendor_FormatMoneyString(value, trailing)

    value = tonumber(value) or 0;

    local gold = math.floor(value / 10000);
    local silver = math.floor(value / 100) % 100;
    local copper = value % 100;

    local disp = "";

    if (gold > 0) then
        disp = disp .. format(GOLD_AMOUNT_TEXTURE, gold, 0, 0) .. " ";
    end
    if ((silver > 0) or (trailing and (gold > 0))) then
        disp = disp .. format(SILVER_AMOUNT_TEXTURE, silver, 0, 0) .. " ";
    end
    if ((copper > 0) or (trailing and ((gold > 0) or (silver > 0)))) then
        disp = disp .. format(COPPER_AMOUNT_TEXTURE, copper, 0, 0);
    end

    return disp;

end

--========================================
-- Initialize the item quality dropdown
--========================================
function ExtVendor_InitQualityFilter()

    local info = {};
    local color;
    for i = 0, 7, 1 do
        -- skip common, legendary and artifact qualities for now
        if ((i ~= 1) and (i ~= 5) and (i ~= 6)) then
            if (i == 0) then
                info.text = ALL;
            else
                color = select(4,GetItemQualityColor(i));
                info.text = color .. _G["ITEM_QUALITY" .. i .. "_DESC"];
            end
            info.value = i;
            info.checked = nil;
            info.func = ExtVendor_SelectFilterQuality;
            ExtVendor_UIDropDownMenu_AddButton(info);
        end
    end

end

--========================================
-- Handler for selecting an item quality
--========================================
function ExtVendor_SelectFilterQuality(self)
    ExtVendor_UIDropDownMenu_SetSelectedValue(MerchantFrameQualityFilter, self.value);
    EXTVENDOR_SELECTED_QUALITY = self.value;

    ExtVendor_UpdateDisplay();
end

--========================================
-- Show the filter options dropdown menu
--========================================
function ExtVendor_DisplayFilterDropDown(self)
    local menu = {
        { text = L["HIDE_FILTERED"], checked = EXTVENDOR_DATA['config']['hide_filtered'], func = function() ExtVendor_ToggleSetting("hide_filtered"); ExtVendor_UpdateDisplay(); end },
        { text = L["HIDE_KNOWN_RECIPES"], checked = EXTVENDOR_DATA['config']['hide_known_recipes'], func = function() ExtVendor_ToggleSetting("hide_known_recipes"); ExtVendor_UpdateDisplay(); end },
        { text = L["HIDE_KNOWN_ASCENSION_COLLECTION_ITEMS"], checked = EXTVENDOR_DATA['config']['hide_known_ascension_collection_items'], func = function() ExtVendor_ToggleSetting("hide_known_ascension_collection_items"); ExtVendor_UpdateDisplay(); end },
        { text = L["FILTER_RECIPES"], hasArrow = true, notCheckable = true,
            menuList = {
                { text = L["FILTER_ALREADY_KNOWN"], checked = EXTVENDOR_DATA['config']['hide_known_recipes'], func = function() ExtVendor_ToggleSetting("hide_known_recipes"); ExtVendor_UpdateDisplay(); end },
                { text = L["FILTER_PURCHASED"], checked = EXTVENDOR_DATA['config']['filter_purchased_recipes'], func = function() ExtVendor_ToggleSetting("filter_purchased_recipes"); ExtVendor_UpdateDisplay(); end },
            },
        },
        { text = L["FILTER_ARMOR"], hasArrow = true, notCheckable = true,
                menuList = {
                    { text = ALL, checked = (EXTVENDOR_DATA['config']['armor_filter']["All"]), func = function() ExtVendor_SetArmorFilter("All") end },
                    { text = L["ARMOR_CLOTH"], checked = (EXTVENDOR_DATA['config']['armor_filter']["Cloth"]), func = function() ExtVendor_SetArmorFilter("Cloth") end },
                    { text = L["ARMOR_LEATHER"], checked = (EXTVENDOR_DATA['config']['armor_filter']["Leather"]), func = function() ExtVendor_SetArmorFilter("Leather") end },
                    { text = L["ARMOR_MAIL"], checked = (EXTVENDOR_DATA['config']['armor_filter']["Mail"]), func = function() ExtVendor_SetArmorFilter("Mail") end },
                    { text = L["ARMOR_PLATE"], checked = (EXTVENDOR_DATA['config']['armor_filter']["Plate"]), func = function() ExtVendor_SetArmorFilter("Plate") end },      
                },
        },
        { text = L["FILTER_STAT"], hasArrow = true, notCheckable = true,
            menuList = {
                { text = ALL,                   checked = (STAT_FILTER_INDEX == 0),  func = function() ExtVendor_SetSlotFilter(0, true); end },
                { text = L["STAT_PRIMARY"], hasArrow = true, notCheckable = true,
                    menuList = {
                        { text = ALL,                   checked = (STAT_FILTER_INDEX == 1),  func = function() ExtVendor_SetSlotFilter(1, true); end },
                        { text = L["STAT_STRENGTH"],        checked = (STAT_FILTER_INDEX == 2), func = function() ExtVendor_SetSlotFilter(2, true); end },
                        { text = L["STAT_AGILITY"],       checked = (STAT_FILTER_INDEX == 3), func = function() ExtVendor_SetSlotFilter(3, true); end },
                        { text = L["STAT_INTELLECT"],      checked = (STAT_FILTER_INDEX == 4), func = function() ExtVendor_SetSlotFilter(4, true); end },
                        { text = L["STAT_SPIRIT"],      checked = (STAT_FILTER_INDEX == 5), func = function() ExtVendor_SetSlotFilter(5, true); end },
                        { text = L["STAT_STAMINA"],      checked = (STAT_FILTER_INDEX == 6), func = function() ExtVendor_SetSlotFilter(6, true); end },

                    },
                },
                { text = L["STAT_SECONDARY"], hasArrow = true, notCheckable = true,
                    menuList = {
                        { text = ALL,                   checked = (STAT_FILTER_INDEX == 6), func = function() ExtVendor_SetSlotFilter(6, true); end },
                        { text = L["STAT_ATTACT_POWER"],        checked = (STAT_FILTER_INDEX == 7), func = function() ExtVendor_SetSlotFilter(7, true); end },
                        { text = L["STAT_SPELL_POWER"],       checked = (STAT_FILTER_INDEX == 8), func = function() ExtVendor_SetSlotFilter(8, true); end },
                        { text = L["STAT_CRIT"],      checked = (STAT_FILTER_INDEX == 9), func = function() ExtVendor_SetSlotFilter(9, true); end },
                        { text = L["STAT_HIT"],      checked = (STAT_FILTER_INDEX == 10), func = function() ExtVendor_SetSlotFilter(10, true); end },
                        { text = L["STAT_HASTE"],      checked = (STAT_FILTER_INDEX == 11), func = function() ExtVendor_SetSlotFilter(11, true); end },
                        { text = L["STAT_EXPERTISE"],      checked = (STAT_FILTER_INDEX == 12), func = function() ExtVendor_SetSlotFilter(12, true); end },
                        { text = L["STAT_ARMOR_PEN"],      checked = (STAT_FILTER_INDEX == 13), func = function() ExtVendor_SetSlotFilter(13, true); end },
                        { text = L["STAT_SPELL_PEN"],      checked = (STAT_FILTER_INDEX == 14), func = function() ExtVendor_SetSlotFilter(14, true); end },
                    },
                },
                { text = L["STAT_DEFENSIVE"], hasArrow = true, notCheckable = true,
                    menuList = {
                        { text = ALL,                   checked = (STAT_FILTER_INDEX == 15), func = function() ExtVendor_SetSlotFilter(15, true); end },
                        { text = L["DEFENSE"],    checked = (STAT_FILTER_INDEX == 16), func = function() ExtVendor_SetSlotFilter(16, true); end },
                        { text = L["DODGE"],    checked = (STAT_FILTER_INDEX == 17), func = function() ExtVendor_SetSlotFilter(17, true); end },
                        { text = L["PARRY"],    checked = (STAT_FILTER_INDEX == 18), func = function() ExtVendor_SetSlotFilter(18, true); end },
                        { text = L["BLOCK"],      checked = (STAT_FILTER_INDEX == 19), func = function() ExtVendor_SetSlotFilter(19, true); end },
                        { text = L["BLOCK_VALUE"],      checked = (STAT_FILTER_INDEX == 20), func = function() ExtVendor_SetSlotFilter(20, true); end },
                        { text = L["RESILIENCE"],      checked = (STAT_FILTER_INDEX == 21), func = function() ExtVendor_SetSlotFilter(21, true); end },
                    },
                },
            },
        },
        { text = L["FILTER_SLOT"], hasArrow = true, notCheckable = true,
            menuList = {
                { text = ALL,                   checked = (SLOT_FILTER_INDEX == 0),  func = function() ExtVendor_SetSlotFilter(0); end },
                { text = L["SLOT_CAT_ARMOR"], hasArrow = true, notCheckable = true,
                    menuList = {
                        { text = ALL,                   checked = (SLOT_FILTER_INDEX == 1),  func = function() ExtVendor_SetSlotFilter(1); end },
                        { text = L["SLOT_HEAD"],        checked = (SLOT_FILTER_INDEX == 2),  func = function() ExtVendor_SetSlotFilter(2); end },
                        { text = L["SLOT_SHOULDER"],    checked = (SLOT_FILTER_INDEX == 3),  func = function() ExtVendor_SetSlotFilter(3); end },
                        { text = L["SLOT_BACK"],        checked = (SLOT_FILTER_INDEX == 4),  func = function() ExtVendor_SetSlotFilter(4); end },
                        { text = L["SLOT_CHEST"],       checked = (SLOT_FILTER_INDEX == 5),  func = function() ExtVendor_SetSlotFilter(5); end },
                        { text = L["SLOT_WRIST"],       checked = (SLOT_FILTER_INDEX == 6),  func = function() ExtVendor_SetSlotFilter(6); end },
                        { text = L["SLOT_HANDS"],       checked = (SLOT_FILTER_INDEX == 7),  func = function() ExtVendor_SetSlotFilter(7); end },
                        { text = L["SLOT_WAIST"],       checked = (SLOT_FILTER_INDEX == 8),  func = function() ExtVendor_SetSlotFilter(8); end },
                        { text = L["SLOT_LEGS"],        checked = (SLOT_FILTER_INDEX == 9),  func = function() ExtVendor_SetSlotFilter(9); end },
                        { text = L["SLOT_FEET"],        checked = (SLOT_FILTER_INDEX == 10), func = function() ExtVendor_SetSlotFilter(10); end },
                    },
                },
                { text = L["SLOT_CAT_ACCESSORIES"], hasArrow = true, notCheckable = true,
                    menuList = {
                        { text = ALL,                   checked = (SLOT_FILTER_INDEX == 20), func = function() ExtVendor_SetSlotFilter(20); end },
                        { text = L["SLOT_NECK"],        checked = (SLOT_FILTER_INDEX == 21), func = function() ExtVendor_SetSlotFilter(21); end },
                        { text = L["SLOT_SHIRT"],       checked = (SLOT_FILTER_INDEX == 22), func = function() ExtVendor_SetSlotFilter(22); end },
                        { text = L["SLOT_TABARD"],      checked = (SLOT_FILTER_INDEX == 23), func = function() ExtVendor_SetSlotFilter(23); end },
                        { text = L["SLOT_FINGER"],      checked = (SLOT_FILTER_INDEX == 24), func = function() ExtVendor_SetSlotFilter(24); end },
                        { text = L["SLOT_TRINKET"],     checked = (SLOT_FILTER_INDEX == 25), func = function() ExtVendor_SetSlotFilter(25); end },
                    },
                },
                { text = L["SLOT_CAT_WEAPONS"], hasArrow = true, notCheckable = true,
                    menuList = {
                        { text = ALL,                   checked = (SLOT_FILTER_INDEX == 30), func = function() ExtVendor_SetSlotFilter(30); end },
                        { text = L["SLOT_WEAPON1H"],    checked = (SLOT_FILTER_INDEX == 31), func = function() ExtVendor_SetSlotFilter(31); end },
                        { text = L["SLOT_WEAPON2H"],    checked = (SLOT_FILTER_INDEX == 32), func = function() ExtVendor_SetSlotFilter(32); end },
                        { text = L["SLOT_WEAPONOH"],    checked = (SLOT_FILTER_INDEX == 33), func = function() ExtVendor_SetSlotFilter(33); end },
                        { text = L["SLOT_RANGED"],      checked = (SLOT_FILTER_INDEX == 34), func = function() ExtVendor_SetSlotFilter(34); end },
                    },
                },
                { text = L["SLOT_CAT_OFFHAND"], hasArrow = true, notCheckable = true,
                    menuList = {
                        { text = ALL,                   checked = (SLOT_FILTER_INDEX == 40), func = function() ExtVendor_SetSlotFilter(40); end },
                        { text = L["SLOT_OFFHAND"],     checked = (SLOT_FILTER_INDEX == 41), func = function() ExtVendor_SetSlotFilter(41); end },
                        { text = L["SLOT_SHIELD"],      checked = (SLOT_FILTER_INDEX == 42), func = function() ExtVendor_SetSlotFilter(42); end },
                    },
                },
            },
        },
        { text = L["QUALITY_FILTER_MINIMUM"], hasArrow = true, notCheckable = true,
            menuList = {
                { text = ALL, checked = (EXTVENDOR_SELECTED_QUALITY == 0), func = function() ExtVendor_SetMinimumQuality(0); end },
                { text = ITEM_QUALITY_COLORS[2].hex .. ITEM_QUALITY2_DESC, checked = (EXTVENDOR_SELECTED_QUALITY == 2), func = function() ExtVendor_SetMinimumQuality(2); end },
                { text = ITEM_QUALITY_COLORS[3].hex .. ITEM_QUALITY3_DESC, checked = (EXTVENDOR_SELECTED_QUALITY == 3), func = function() ExtVendor_SetMinimumQuality(3); end },
                { text = ITEM_QUALITY_COLORS[4].hex .. ITEM_QUALITY4_DESC, checked = (EXTVENDOR_SELECTED_QUALITY == 4), func = function() ExtVendor_SetMinimumQuality(4); end },
                { text = ITEM_QUALITY_COLORS[7].hex .. ITEM_QUALITY7_DESC, checked = (EXTVENDOR_SELECTED_QUALITY == 7), func = function() ExtVendor_SetMinimumQuality(7); end },
            },
        },
        { text = L["QUALITY_FILTER_SPECIFIC"], hasArrow = true, notCheckable = true,
            menuList = {
                { text = ALL, checked = (EXTVENDOR_SELECTED_QUALITY == 0), func = function() ExtVendor_SetMinimumQuality(0); end },
                { text = ITEM_QUALITY_COLORS[1].hex .. ITEM_QUALITY1_DESC, checked = (EXTVENDOR_SELECTED_QUALITY == 1), func = function() ExtVendor_SetSpecificQuality(1); end },
                { text = ITEM_QUALITY_COLORS[2].hex .. ITEM_QUALITY2_DESC, checked = (EXTVENDOR_SELECTED_QUALITY == 2), func = function() ExtVendor_SetSpecificQuality(2); end },
                { text = ITEM_QUALITY_COLORS[3].hex .. ITEM_QUALITY3_DESC, checked = (EXTVENDOR_SELECTED_QUALITY == 3), func = function() ExtVendor_SetSpecificQuality(3); end },
                { text = ITEM_QUALITY_COLORS[4].hex .. ITEM_QUALITY4_DESC, checked = (EXTVENDOR_SELECTED_QUALITY == 4), func = function() ExtVendor_SetSpecificQuality(4); end },
                { text = ITEM_QUALITY_COLORS[7].hex .. ITEM_QUALITY7_DESC, checked = (EXTVENDOR_SELECTED_QUALITY == 7), func = function() ExtVendor_SetSpecificQuality(7); end },
            },
        },
        { text = L["CONFIGURE_QUICKVENDOR"], notCheckable = true, func = function() ExtVendor_QVConfigFrame:Show(); end },
        { text = L["MAIN_OPTIONS"], notCheckable = true, func = function() InterfaceOptionsFrame_OpenToCategory(ExtVendorConfigContainer); end },
    };
    EasyMenu(menu, MerchantFrameFilterDropDown, self, 0, 0, "MENU", 1);
end

--========================================
-- Toggles a boolean config setting
--========================================
function ExtVendor_ToggleSetting(name)
    if (EXTVENDOR_DATA['config'][name]) then
        EXTVENDOR_DATA['config'][name] = false;
    else
        EXTVENDOR_DATA['config'][name] = true;
    end
end

--========================================
-- Sets the minimum quality filter
--========================================
function ExtVendor_SetMinimumQuality(quality)
    EXTVENDOR_SELECTED_QUALITY = math.max(0, math.min(7, quality));
    EXTVENDOR_SPECIFIC_QUALITY = false;
    ExtVendor_UpdateDisplay();
end

--========================================
-- Sets the specific quality filter
--========================================
function ExtVendor_SetSpecificQuality(quality)
    EXTVENDOR_SELECTED_QUALITY = math.max(0, math.min(7, quality));
    EXTVENDOR_SPECIFIC_QUALITY = true;
    ExtVendor_UpdateDisplay();
end

--========================================
-- Output message to chat frame
--========================================
function ExtVendor_Message(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00<" .. L["ADDON_TITLE"] .. ">|r " .. msg);
end

--========================================
-- Slash command handler
--========================================
function ExtVendor_CommandHandler(cmd)
    if cmd == "wlistchar" then
            local _, link = GameTooltip:GetItem()
        if GameTooltip:IsShown() and link then
            local type = {}
            type.isWhitelist = true
            type.isLocal = true
            ExtVendor_QVConfig_OnItemDrop(type, link)
        end
    elseif cmd == "wlist" then
            local _, link = GameTooltip:GetItem()
        if GameTooltip:IsShown() and link then
            local type = {}
            type.isWhitelist = true
            type.isLocal = false
            ExtVendor_QVConfig_OnItemDrop(type, link)
        end
    elseif cmd == "blist" then
            local _, link = GameTooltip:GetItem()
        if GameTooltip:IsShown() and link then
            local type = {}
            type.isWhitelist = false
            type.isLocal = false
            ExtVendor_QVConfig_OnItemDrop(type, link)
        end
    else
        InterfaceOptionsFrame_OpenToCategory(ExtVendorConfigContainer);
    end
end

function ExtVendor_AddToVendorList(list)
    local _, link = GameTooltip:GetItem()
    if GameTooltip:IsShown() and link then
        local type = {}
        if list == "wlistchar" then        
            type.isWhitelist = true
            type.isLocal = true
        elseif list == "wlist" then
            type.isWhitelist = true
            type.isLocal = false
        elseif list == "blist" then
            type.isWhitelist = false
            type.isLocal = false
        end
        ExtVendor_QVConfig_OnItemDrop(type, link)
    end
end

_G["BINDING_HEADER_EXTENDEDVENDORUI"] = "ExtendedVendorUI"
_G["BINDING_NAME_EXTENDEDVENDORBIND1"] = "Add to global white list"
_G["BINDING_NAME_EXTENDEDVENDORBIND2"] = "Add to character white list "
_G["BINDING_NAME_EXTENDEDVENDORBIND3"] = "Add to black list"


--========================================
-- Called with pcall to safely catch
-- errors (fixes battle pet error)
--========================================
function ExtVendor_SetHiddenTooltip(link)
    ExtVendorHiddenTooltip:SetHyperlink(link);
end

--========================================
-- Mouse wheel handler
--========================================
function ExtVendor_OnMouseWheel(self, delta)
    if (delta > 0) then
        if ((MerchantFrame.page > 1) and (MerchantPrevPageButton:IsEnabled()) and (MerchantPrevPageButton:IsVisible())) then
            MerchantPrevPageButton:Click();
        end
    else
        if ((MerchantFrame.page < EXTVENDOR_NUM_PAGES) and (MerchantNextPageButton:IsEnabled()) and (MerchantNextPageButton:IsVisible())) then
            MerchantNextPageButton:Click();
        end
    end
end

--========================================
-- Enables/disables the mouse wheel
-- handler depending on config
--========================================
function ExtVendor_UpdateMouseScrolling(state)
    if (EXTVENDOR_DATA['config']['mousewheel_paging']) then
        MerchantFrame:EnableMouseWheel();
        MerchantFrame:SetScript("OnMouseWheel", ExtVendor_OnMouseWheel);
    else
        MerchantFrame:SetScript("OnMouseWheel", nil);
    end
end

--========================================
-- Changes the armor filter
--========================================
function ExtVendor_SetArmorFilter(type)
    if type == "All" then
        for i, v in pairs(EXTVENDOR_DATA['config']['armor_filter']) do
            EXTVENDOR_DATA["config"]["armor_filter"][i] = false
        end
        EXTVENDOR_DATA["config"]["armor_filter"]["All"] = true
    else
        EXTVENDOR_DATA['config']['armor_filter'][type] = not EXTVENDOR_DATA['config']['armor_filter'][type]
        EXTVENDOR_DATA["config"]["armor_filter"]["All"] = false
    end
   
    ExtVendor_UpdateDisplay()
end

--========================================
-- Changes the equipment slot filter
--========================================
function ExtVendor_SetSlotFilter(index, stat)
    if stat then
        STAT_FILTER_INDEX = index;
    else
        SLOT_FILTER_INDEX = index;
    end
    ExtVendor_UpdateDisplay();
end

--========================================
-- Sets the scale of the vendor frame to
-- the configured scale
--========================================
function ExtVendor_UpdateScale()
    MerchantFrame:SetScale(EXTVENDOR_DATA['config']['scale']);
end

--========================================
-- Returns how many of an item of the
-- specified ID is in the player's bags
--========================================
function ExtVendor_HasItemInBags(itemId)
    local count = 0;
    for bag = 0, 4, 1 do
        if (GetContainerNumSlots(bag)) then
            for slot = 1, GetContainerNumSlots(bag), 1 do
                local id = GetContainerItemID(bag, slot);
                if (id == itemId) then
                    count = count + 1;
                end
            end
        end
    end
    return count;
end
