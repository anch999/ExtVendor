local L = LibStub("AceLocale-3.0"):GetLocale("ExtVendor", true);

local CLASS_PROFICIENCIES = {
    ["DEATHKNIGHT"] = {
        weapons = { "1H_AXE", "1H_MACE", "1H_SWORD", "2H_AXE", "2H_MACE", "2H_SWORD", "POLEARM" },
    },
    ["DRUID"]       = {
        weapons = { "1H_MACE", "2H_MACE", "POLEARM", "STAFF", "DAGGER", "FIST" },
    },
    ["HUNTER"]      = {
        weapons = { "1H_AXE", "1H_SWORD", "2H_AXE", "2H_SWORD", "POLEARM", "STAFF", "DAGGER", "FIST", "BOW", "GUN", "CROSSBOW" },
    },
    ["MAGE"]        = {
        weapons = { "1H_SWORD", "STAFF", "DAGGER", "WAND" },
    },
    ["MONK"]        = {
        weapons = { "1H_AXE", "1H_MACE", "1H_SWORD", "POLEARM", "STAFF", "FIST" },
    },
    ["PALADIN"]     = {
        weapons = { "1H_AXE", "1H_MACE", "1H_SWORD", "2H_AXE", "2H_MACE", "2H_SWORD", "POLEARM" },
        canUseShields = true,
    },
    ["PRIEST"]      = {
        weapons = { "1H_MACE", "DAGGER", "STAFF", "WAND" },
    },
    ["ROGUE"]       = {
        weapons = { "1H_AXE", "1H_MACE", "1H_SWORD", "DAGGER", "FIST" },
    },
    ["SHAMAN"]      = {
        weapons = { "1H_AXE", "1H_MACE", "2H_AXE", "2H_MACE", "DAGGER", "FIST", "STAFF" },
        canUseShields = true,
    },
    ["WARLOCK"]     = {
        weapons = { "1H_SWORD", "DAGGER", "STAFF", "WAND" },
    },
    ["WARRIOR"]     = {
        weapons = { "1H_AXE", "1H_MACE", "1H_SWORD", "2H_AXE", "2H_MACE", "2H_SWORD", "DAGGER", "FIST", "POLEARM", "STAFF" },
        canUseShields = true,
    },
};

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

                -- check for "Classes: xxx"
                local checkClasses = ExtVendor_GetRequiredClasses(checkLine);
                if (checkClasses) then
                    classes = checkClasses;
                end

            end
        end

    end

    ExtVendorHiddenTooltip:Hide();

    return isBoP, isKnown, classes;
end

--========================================
-- Returns an item's ID from the given
-- link
--========================================
function ExtVendor_GetItemID(link)
    if (link) then
        local w;
        for w in string.gmatch(link, "item:(%d+):") do
            return tonumber(w);
        end
    end
    return nil;
end

--========================================
-- Returns a list of required classes
-- based on the "Classes:" line of an
-- item tooltip
--========================================
function ExtVendor_GetRequiredClasses(tooltipString)
    if (string.find(tooltipString, L["CLASSES"])) then
        local out = {};
        local i;
        local className = "";
        for i = string.len(L["CLASSES"]) + 1, string.len(tooltipString), 1 do
            local chr = string.sub(tooltipString, i, i);
            local skipChar = false;
            local finishName = false;
            if (chr == ",") then
                finishName = true;
                skipChar = true;
            elseif (i == string.len(tooltipString)) then
                finishName = true;
            end
            if (not skipChar) then
                className = className .. chr;
            end
            if (finishName) then
                table.insert(out, string.trim(className));
                className = "";
            end
        end

        return out;
    end
    return nil;
end

--========================================
-- Returns whether or not the specified
-- class is in the given list of classes
--========================================
function ExtVendor_ClassIsAllowed(class, classes)
    if (table.maxn(classes) > 0) then
        for index, name in pairs(classes) do
            if (class == name) then
                return true;
            end
        end
        return false;
    end
    return true;
end

--========================================
-- Returns whether or not the character's
-- class can EVER wear armor of the given
-- type (e.g. mages can NEVER wear
-- leather or higher, shamans can NEVER
-- wear plate, etc.)
--========================================
function ExtVendor_IsUsableArmorType(type, subType, slot)
    local maxArmor = select(2, ExtVendor_GetOptimalArmorType());

    if ((type == L["ARMOR"]) and (slot ~= "INVTYPE_CLOAK")) then
        if ((subType == L["ARMOR_CLOTH"]) or (subType == L["ARMOR_LEATHER"]) or (subType == L["ARMOR_MAIL"]) or (subType == L["ARMOR_PLATE"])) then
            if (EXTVENDOR_ARMOR_RANKS[subType] > EXTVENDOR_ARMOR_RANKS[maxArmor]) then
                return false;
            end
        elseif (subType == L["ARMOR_SHIELD"]) then
            local EXTVENDOR_DUMMY, cls = UnitClass("player");
            if (CLASS_PROFICIENCIES[cls].canUseShields) then
                return true;
            end
            return false;
        end
    end
    return true;
end

--========================================
-- Returns whether or not the character's
-- class can use the given weapon type
-- based on class proficiencies
--========================================
function ExtVendor_IsUsableWeaponType(type, subType, slot)
    if (type == L["WEAPON"]) then
        if ((subType == L["WEAPON_1H_AXE"]) or (subType == L["WEAPON_1H_MACE"]) or (subType == L["WEAPON_1H_SWORD"]) or (subType == L["WEAPON_2H_AXE"])
        or (subType == L["WEAPON_2H_MACE"]) or (subType == L["WEAPON_2H_SWORD"]) or (subType == L["WEAPON_POLEARM"]) or (subType == L["WEAPON_DAGGER"])
        or (subType == L["WEAPON_FIST"]) or (subType == L["WEAPON_STAFF"]) or (subType == L["WEAPON_WAND"]) or (subType == L["WEAPON_BOW"])
        or (subType == L["WEAPON_GUN"]) or (subType == L["WEAPON_CROSSBOW"])) then
            local EXTVENDOR_DUMMY, cls = UnitClass("player");
            for index, wt in pairs(CLASS_PROFICIENCIES[cls].weapons) do
                if (L["WEAPON_" .. wt] == subType) then
                    return true;
                end
            end
            return false;
        end
    end
    return true;
end
