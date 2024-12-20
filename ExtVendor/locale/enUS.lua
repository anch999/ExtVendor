local L = LibStub("AceLocale-3.0"):NewLocale("ExtVendor", "enUS", true)

if L then

L["LOADED_MESSAGE"] = "Version %s loaded. Type |cffffff00/evui|r to configure.";
L["ADDON_TITLE"] = "Extended Vendor UI";
L["VERSION_TEXT"] = "Extended Vendor UI Ascension %s";

L["QUICKVENDOR_BUTTON_TOOLTIP"] = "Sell all unwanted items";

L["CONFIRM_SELL_JUNK"] = "Do you want to sell the following items:";
L["TOTAL_SALE_PRICE"] = "Total sale price";
L["ITEMS_BLACKLISTED"] = "%s item(s) blacklisted";

L["SOLD"] = "Sold:";
L["JUNK_MONEY_EARNED"] = "Money earned from junk items: %s";

L["HIDE_FILTERED"] = "Hide Filtered";
L["HIDE_KNOWN_RECIPES"] = "Unlearned Recipes Only";
L["HIDE_KNOWN_ASCENSION_COLLECTION_ITEMS"] = "Filter Known Skill Cards/Vanity Items";
L["FILTER_RECIPES"] = "Recipe Filtering";
L["FILTER_ALREADY_KNOWN"] = "Hide Already Known";
L["FILTER_PURCHASED"] = "Hide Already Purchased";
L["FILTER_SLOT"] = "Slot";
L["FILTER_STAT"] = "Stats";
L["FILTER_ARMOR"] = "Armor";
L["QUALITY_FILTER_MINIMUM"] = "Quality (Minimum)";
L["QUALITY_FILTER_SPECIFIC"] = "Quality (Specific)";
L["SINGLE_ITEM_HIDDEN"] = "%d item hidden";
L["MULTI_ITEMS_HIDDEN"] = "%d items hidden";
L["CONFIGURE_QUICKVENDOR"] = "Configure Quick-Vendor";
L["MAIN_OPTIONS"] = "Options";


L["SLOT_CAT_ARMOR"] = "Armor";
L["SLOT_HEAD"] = "Head";
L["SLOT_SHOULDER"] = "Shoulder";
L["SLOT_BACK"] = "Back";
L["SLOT_CHEST"] = "Chest";
L["SLOT_WRIST"] = "Wrist";
L["SLOT_HANDS"] = "Hands";
L["SLOT_WAIST"] = "Waist";
L["SLOT_LEGS"] = "Legs";
L["SLOT_FEET"] = "Feet";

L["SLOT_CAT_ACCESSORIES"] = "Accessories";
L["SLOT_NECK"] = "Neck";
L["SLOT_SHIRT"] = "Shirt";
L["SLOT_TABARD"] = "Tabard";
L["SLOT_FINGER"] = "Finger";
L["SLOT_TRINKET"] = "Trinket";

L["SLOT_CAT_WEAPONS"] = "Weapons";
L["SLOT_WEAPON2H"] = "Two-Handed";
L["SLOT_WEAPON1H"] = "One-Handed / Main Hand";
L["SLOT_WEAPONOH"] = "Off Hand";
L["SLOT_RANGED"] = "Ranged";

L["SLOT_CAT_OFFHAND"] = "Off Hand";
L["SLOT_OFFHAND"] = "Held in Off-hand";
L["SLOT_SHIELD"] = "Shields";

L["STAT_PRIMARY"] = "Primary Stats";
L["STAT_SECONDARY"] = "Secondary Stats";
L["STAT_DEFENSIVE"] = "Defensive Stats";

L["STAT_STRENGTH"] = "Strength";
L["STAT_AGILITY"] = "Agility";
L["STAT_INTELLECT"] = "Intellect";
L["STAT_SPIRIT"] = "Spirit";
L["STAT_STAMINA"] = "Stamina";

L["STAT_ATTACT_POWER"] = "Attack Power";
L["STAT_SPELL_POWER"] = "Spell Power";
L["STAT_CRIT"] = "Crit";
L["STAT_HIT"] = "Hit";
L["STAT_HASTE"] = "Haste";
L["STAT_EXPERTISE"] = "Expertise";
L["STAT_ARMOR_PEN"] = "Armor Penetration";
L["STAT_SPELL_PEN"] = "Spell Penetration";

L["DEFENSE"] = "Defense";
L["DODGE"] = "Dodge";
L["PARRY"] = "Parry";
L["BLOCK"] = "Block";
L["BLOCK_VALUE"] = "Block Value";
L["RESILIENCE"] = "Resilience";

-- The following strings are used to match against text found on item tooltips or itemType/itemSubType returns of GetItemInfo(); if they don't match, things will break.
L["ARMOR"] = "Armor";
L["ARMOR_CLOTH"] = "Cloth";
L["ARMOR_LEATHER"] = "Leather";
L["ARMOR_MAIL"] = "Mail";
L["ARMOR_PLATE"] = "Plate";
L["ARMOR_SHIELD"] = "Shields";

L["WEAPON"] = "Weapon";
L["WEAPON_1H_AXE"] = "One-Handed Axes";
L["WEAPON_1H_MACE"] = "One-Handed Maces";
L["WEAPON_1H_SWORD"] = "One-Handed Swords";
L["WEAPON_2H_AXE"] = "Two-Handed Axes";
L["WEAPON_2H_MACE"] = "Two-Handed Maces";
L["WEAPON_2H_SWORD"] = "Two-Handed Swords";
L["WEAPON_STAFF"] = "Staves";
L["WEAPON_POLEARM"] = "Polearms";
L["WEAPON_WAND"] = "Wands";
L["WEAPON_BOW"] = "Bows";
L["WEAPON_GUN"] = "Guns";
L["WEAPON_CROSSBOW"] = "Crossbows";
L["WEAPON_DAGGER"] = "Daggers";
L["WEAPON_FIST"] = "Fist Weapons";

L["CLASSES"] = "Classes:";

L["ITEMTYPE_RECIPE"] = "Recipe";

-- used for checking darkmoon faire replica items
L["REPLICA"] = "Replica";

L["CONFIG_HEADING_GENERAL"] = "General Settings";
L["OPTION_STARTUP_MESSAGE"] = "Show loading message";
L["OPTION_STARTUP_MESSAGE_TOOLTIP"] = "If enabled, a message indicating when Extended Vendor UI is\nloaded will be displayed on the chat frame when logging in.";
L["OPTION_MOUSEWHEEL_PAGING"] = "Mouse Wheel Paging";
L["OPTION_MOUSEWHEEL_PAGING_TOOLTIP"] = "If enabled, the mouse wheel can be used to\nscroll through vendor pages.";
L["OPTION_SCALE"] = "Scale: %s";
L["OPTION_SCALE_TOOLTIP"] = "Sets the scale of the main vendor interface.";
L["CONFIG_HEADING_QUICKVENDOR"] = "Quick-Vendor Settings";
L["OPTION_QUICKVENDOR_ENABLEBUTTON"] = "Show the Quick-Vendor button";
L["OPTION_QUICKVENDOR_ENABLEBUTTON_TOOLTIP"] = "Shows or hides the Quick-Vendor button on the merchant frame.";
L["OPTION_ENABLE_QUICKVENDOR_AUTO_BUTTON"] = "Auto Quick Vendor";
L["OPTION_ENABLE_QUICKVENDOR_AUTO_BUTTON_TOOLTIP"] = "Auto Quick Vendor when you talk to a merchant";
L["OPTION_QUICKVENDOR_ALREADYKNOWN"] = "Aready Known items (BoP only)";
L["OPTION_QUICKVENDOR_ALREADYKNOWNBOERECIPE"] = "Aready Known items (BoE)";
L["OPTION_QUICKVENDOR_ALREADYKNOWN_TOOLTIP"] = "If enabled, items that are |cffff0000Already Known|r (such as profession\nrecipes) will be included in the quick-vendor feature.";
L["OPTION_QUICKVENDOR_ALREADYKNOWNBOERECIPE_TOOLTIP"] = "If enabled, items that are |cffff0000Already Known|r (such as profession\nrecipes) will be included in the quick-vendor feature.";
L["OPTION_QUICKVENDOR_WHITEGEAR"] = "Common quality (|cffffffffWhite|r) weapons and armor";
L["OPTION_QUICKVENDOR_WHITEGEAR_TOOLTIP"] = "If enabled, all white weapons and armor (not equipped)\nwill be included in the quick-vendor feature.";
L["OPTION_DEFAULT_AUTO_CHECK"] = "Hide default auto vendor gray checkbox";
L["OPTION_DEFAULT_AUTO_CHECK_TOOLTIP"] = "Hides the auto vendor grays checkbox added by Ascension.";
L["NOTE"] = "NOTE";
L["QUICKVENDOR_SOULBOUND"] = "This option only affects Bind on Pickup (BoP) items.";

L["QUICKVENDOR_REASON_POORQUALITY"] = "Poor quality";
L["QUICKVENDOR_REASON_WHITEGEAR"] = "White quality equipment";
L["QUICKVENDOR_REASON_ALREADYKNOWN"] = "Already known";
L["QUICKVENDOR_REASON_WHITELISTED"] = "Whitelisted";

L["QUICKVENDOR_CONFIG_HEADER"] = "Quick-Vendor Configuration";
L["CUSTOMIZE_BLACKLIST"] = "Customize Blacklist";
L["CUSTOMIZE_BLACKLIST_TEXT"] = "Items in this list will NEVER be vendored by the Quick-Vendor feature.";
L["CUSTOMIZE_WHITELIST"] = "Customize Whitelists";
L["CUSTOMIZE_WHITELIST_TEXT"] = "Items in these lists will ALWAYS be vendored by the Quick-Vendor feature.";
L["ITEMLIST_GLOBAL_TEXT"] = "This list applies to all characters on this account.";
L["ITEMLIST_LOCAL_TEXT"] = "This list only applies to the character you are currently playing.";
L["DROP_ITEM_BLACKLIST"] = "Drop an item from your bags onto this button to add it to the blacklist.";
L["DROP_ITEM_WHITELIST"] = "Drop an item from your bags onto this button to add it to the whitelist.";
L["CANNOT_BLACKLIST"] = "Cannot add {$item} to the blacklist: {$reason}";
L["CANNOT_WHITELIST"] = "Cannot add {$item} to the whitelist: {$reason}";
L["REASON_NO_SELL_PRICE"] = "No vendor price";
L["REASON_ALREADY_BLACKLISTED"] = "Item is already blacklisted";
L["REASON_ALREADY_WHITELISTED"] = "Item is already whitelisted";
L["ITEM_ADDED_TO_BLACKLIST"] = "%s has been added to the Quick-Vendor blacklist.";
L["ITEM_ADDED_TO_GLOBAL_WHITELIST"] = "%s has been added to the Quick-Vendor whitelist for all characters.";
L["ITEM_ADDED_TO_LOCAL_WHITELIST"] = "%s has been added to the Quick-Vendor whitelist for the current character only.";
L["DELETE_SELECTED"] = "Delete selected";
L["RESET_TO_DEFAULT"] = "Reset to default";
L["CLEAR_ALL"] = "Clear all";
L["CONFIRM_RESET_BLACKLIST"] = "Do you want to reset the Quick-Vendor blacklist to default values?";
L["CONFIRM_CLEAR_GLOBAL_WHITELIST"] = "Do you want to clear the account-wide Quick-Vendor whitelist?";
L["CONFIRM_CLEAR_LOCAL_WHITELIST"] = "Do you want to clear the Quick-Vendor whitelist for this character?";
L["UNKNOWN_ITEM"] = "Unknown Item";
L["BASIC_SETTINGS"] = "Basic Settings";

-- ***** About page strings *****
L["ABOUT"] = "About";
L["LABEL_AUTHOR"] = "Author";
L["LABEL_EMAIL"] = "Email";
L["LABEL_HOSTS"] = "Discord";

L["COPYRIGHT"] = "�2012, All rights reserved.";

end
