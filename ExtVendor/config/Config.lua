local L = LibStub("AceLocale-3.0"):GetLocale("ExtVendor", true);

-- ********** variables for storing previous values **********
local OLD_LOADMESSAGE = false;
local OLD_QUICKVENDOR_ENABLEBUTTON = false;
local OLD_AUTOQUICKVENDOR = false;
local OLD_QUICKVENDOR_ALREADYKNOWN = false;
local OLD_QUICKVENDOR_ALREADYKNOWNBOERECIPES = false;
local OLD_QUICKVENDOR_WHITEGEAR = false;
local OLD_MOUSEWHEEL_PAGING = false;
local OLD_SCALE = 1;
local OLD_DEFAULT_VENDOR_AUTO_SELL = false;

-- ***********************************************************

local CONFIG_SHOWN = false;

--========================================
-- Setting up the config frame
--========================================
function ExtVendorConfig_OnLoad(self)
    self.name = L["ADDON_TITLE"];
    self.okay = function(self) ExtVendorConfig_Close(); end;
    self.cancel = function(self) ExtVendorConfig_Cancel(); end;
    self.refresh = function(self) ExtVendorConfig_Refresh(); end;
    self.default = function(self) ExtVendorConfig_SetDefaults(); end;
    InterfaceOptions_AddCategory(self);

    ExtVendorConfigTitle:SetText(string.format(L["VERSION_TEXT"], "|cffffffffv" .. EXTVENDOR_VERSION));

    -- ********** General Options **********

    ExtVendorConfig_GeneralContainerTitle:SetText(L["CONFIG_HEADING_GENERAL"]);

	ExtVendorConfig_GeneralContainer_ShowLoadMsgText:SetText(L["OPTION_STARTUP_MESSAGE"]);
	ExtVendorConfig_GeneralContainer_ShowLoadMsg.tooltip = L["OPTION_STARTUP_MESSAGE_TOOLTIP"];

	ExtVendorConfig_GeneralContainer_MouseWheelText:SetText(L["OPTION_MOUSEWHEEL_PAGING"]);
	ExtVendorConfig_GeneralContainer_MouseWheel.tooltip = L["OPTION_MOUSEWHEEL_PAGING_TOOLTIP"];

    ExtVendorConfig_GeneralContainer_Scale.tooltip = L["OPTION_SCALE_TOOLTIP"];

    -- ********** Quick-Vendor Options **********

    ExtVendorConfig_QuickVendorContainerTitle:SetText(L["CONFIG_HEADING_QUICKVENDOR"]);

	ExtVendorConfig_QuickVendorContainer_EnableButtonText:SetText(L["OPTION_QUICKVENDOR_ENABLEBUTTON"]);
	ExtVendorConfig_QuickVendorContainer_EnableButton.tooltip = L["OPTION_QUICKVENDOR_ENABLEBUTTON_TOOLTIP"];

    ExtVendorConfig_QuickVendorContainer_AutoQuickVendorText:SetText(L["OPTION_ENABLE_QUICKVENDOR_AUTO_BUTTON"]);
	ExtVendorConfig_QuickVendorContainer_AutoQuickVendor.tooltip = L["OPTION_ENABLE_QUICKVENDOR_AUTO_BUTTON_TOOLTIP"];
    
	ExtVendorConfig_QuickVendorContainer_AlreadyKnownText:SetText(L["OPTION_QUICKVENDOR_ALREADYKNOWN"]);
	ExtVendorConfig_QuickVendorContainer_AlreadyKnown.tooltip = L["OPTION_QUICKVENDOR_ALREADYKNOWN_TOOLTIP"] .. "\n\n|cff00ff00" .. L["QUICKVENDOR_SOULBOUND"];

    ExtVendorConfig_QuickVendorContainer_AlreadyKnownBoeRecipeText:SetText(L["OPTION_QUICKVENDOR_ALREADYKNOWNBOERECIPE"]);
	ExtVendorConfig_QuickVendorContainer_AlreadyKnownBoeRecipe.tooltip = L["OPTION_QUICKVENDOR_ALREADYKNOWNBOERECIPE_TOOLTIP"] .. "\n\n|cff00ff00" .. L["QUICKVENDOR_SOULBOUND"];

	ExtVendorConfig_QuickVendorContainer_WhiteGearText:SetText(L["OPTION_QUICKVENDOR_WHITEGEAR"]);
	ExtVendorConfig_QuickVendorContainer_WhiteGear.tooltip = L["OPTION_QUICKVENDOR_WHITEGEAR_TOOLTIP"];

    ExtVendorConfig_QuickVendorContainer_AutoVendorCheckText:SetText(L["OPTION_DEFAULT_AUTO_CHECK"]);
	ExtVendorConfig_QuickVendorContainer_AutoVendorCheck.tooltip = L["OPTION_DEFAULT_AUTO_CHECK_TOOLTIP"];
end

--==================================================
-- Handle when the configuration is opened
--==================================================
function ExtVendorConfig_OnShow()
    if (CONFIG_SHOWN) then return; end
    ExtVendorConfig_StoreCurrentSettings();
    CONFIG_SHOWN = true;
end

--========================================
-- Sets the values of the controls to
-- reflect currently loaded settings
--========================================
function ExtVendorConfig_Refresh()
    ExtVendorConfig_OnShow();
	ExtVendorConfig_GeneralContainer_ShowLoadMsg:SetChecked(EXTVENDOR_DATA['config']['show_load_message']);
    ExtVendorConfig_GeneralContainer_MouseWheel:SetChecked(EXTVENDOR_DATA['config']['mousewheel_paging']);
    ExtVendorConfig_GeneralContainer_Scale:SetValue((EXTVENDOR_DATA['config']['scale'] * 20) - 15);

    ExtVendorConfig_QuickVendorContainer_EnableButton:SetChecked(EXTVENDOR_DATA['config']['enable_quickvendor']);
    ExtVendorConfig_QuickVendorContainer_AutoQuickVendor:SetChecked(EXTVENDOR_DATA['config']['enable_quickvendor_auto']);
    ExtVendorConfig_QuickVendorContainer_AlreadyKnown:SetChecked(EXTVENDOR_DATA['config']['quickvendor_alreadyknown']);
    ExtVendorConfig_QuickVendorContainer_AlreadyKnownBoeRecipe:SetChecked(EXTVENDOR_DATA['config']['quickvendor_alreadyknownBoeRecipes']);
    ExtVendorConfig_QuickVendorContainer_WhiteGear:SetChecked(EXTVENDOR_DATA['config']['quickvendor_whitegear']);
    ExtVendorConfig_QuickVendorContainer_AutoVendorCheck:SetChecked(EXTVENDOR_DATA['config']['hide_default_vendor_auto_sell']);
end

--==================================================
-- Store current settings to restore if the user
-- presses cancel
--==================================================
function ExtVendorConfig_StoreCurrentSettings()
    OLD_LOADMESSAGE = EXTVENDOR_DATA['config']['show_load_message'];
    OLD_MOUSEWHEEL_PAGING = EXTVENDOR_DATA['config']['mousewheel_paging'];
    OLD_SCALE = EXTVENDOR_DATA['config']['scale'];
    OLD_QUICKVENDOR_ENABLEBUTTON = EXTVENDOR_DATA['config']['enable_quickvendor'];
    OLD_AUTOQUICKVENDOR = EXTVENDOR_DATA['config']['enable_quickvendor_auto'];
    OLD_QUICKVENDOR_ALREADYKNOWN = EXTVENDOR_DATA['config']['quickvendor_alreadyknown'];
    OLD_QUICKVENDOR_ALREADYKNOWNBOERECIPES = EXTVENDOR_DATA['config']['quickvendor_alreadyknownBoeRecipes'];
    OLD_QUICKVENDOR_WHITEGEAR = EXTVENDOR_DATA['config']['quickvendor_whitegear'];
    OLD_DEFAULT_VENDOR_AUTO_SELL = EXTVENDOR_DATA['config']['hide_default_vendor_auto_sell'];

end

--========================================
-- Closing the config window
--========================================
function ExtVendorConfig_Close()
    if EXTVENDOR_DATA['config']['hide_default_vendor_auto_sell'] then
        MerchantFrameSellJunkFrameAutoSellCheck:Hide()
    else
        MerchantFrameSellJunkFrameAutoSellCheck:Show()
    end
    CONFIG_SHOWN = false;
end

--==================================================
-- Handle clicking the Cancel button; restore
-- all settings to their previous values
--==================================================
function ExtVendorConfig_Cancel()
    EXTVENDOR_DATA['config']['show_load_message'] = OLD_LOADMESSAGE;
    EXTVENDOR_DATA['config']['scale'] = OLD_SCALE;
    EXTVENDOR_DATA['config']['enable_quickvendor_auto'] = OLD_AUTOQUICKVENDOR;
    EXTVENDOR_DATA['config']['enable_quickvendor'] = OLD_QUICKVENDOR_ENABLEBUTTON;
    EXTVENDOR_DATA['config']['quickvendor_alreadyknown'] = OLD_QUICKVENDOR_ALREADYKNOWN;
    EXTVENDOR_DATA['config']['quickvendor_alreadyknownBoeRecipes'] = OLD_QUICKVENDOR_ALREADYKNOWNBOERECIPES;
    EXTVENDOR_DATA['config']['quickvendor_whitegear'] = OLD_QUICKVENDOR_WHITEGEAR;
    EXTVENDOR_DATA['config']['hide_default_vendor_auto_sell'] = OLD_DEFAULT_VENDOR_AUTO_SELL;
    EXTVENDOR_DATA['config']['mousewheel_paging'] = OLD_MOUSEWHEEL_PAGING;
    ExtVendor_UpdateMouseScrolling();
    ExtVendor_UpdateQuickVendorButtonVisibility();
    ExtVendor_UpdateDisplay();
    ExtVendorConfig_Close();
end

--========================================
-- Handler for checking/unchecking
-- checkbox(es)
--========================================
function ExtVendorConfig_CheckBox_OnClick(self, id)
	if (id == 1) then
		if (self:GetChecked()) then
		    EXTVENDOR_DATA['config']['show_load_message'] = true;
		else
		    EXTVENDOR_DATA['config']['show_load_message'] = false;
		end
    elseif (id == 2) then
		if (self:GetChecked()) then
		    EXTVENDOR_DATA['config']['mousewheel_paging'] = true;
		else
		    EXTVENDOR_DATA['config']['mousewheel_paging'] = false;
		end
        ExtVendor_UpdateMouseScrolling();

    -- ********** Quick-Vendor Options **********

    elseif (id == 20) then
        if (self:GetChecked()) then
            EXTVENDOR_DATA['config']['enable_quickvendor'] = true;
        else
            EXTVENDOR_DATA['config']['enable_quickvendor'] = false;
        end
        ExtVendor_UpdateQuickVendorButtonVisibility();
    elseif (id == 21) then
        if (self:GetChecked()) then
            EXTVENDOR_DATA['config']['enable_quickvendor_auto'] = true;
        else
            EXTVENDOR_DATA['config']['enable_quickvendor_auto'] = false;
        end
    elseif (id == 22) then
		if (self:GetChecked()) then
		    EXTVENDOR_DATA['config']['quickvendor_alreadyknown'] = true;
		else
		    EXTVENDOR_DATA['config']['quickvendor_alreadyknown'] = false;
		end
    elseif (id == 23) then
		if (self:GetChecked()) then
		    EXTVENDOR_DATA['config']['quickvendor_alreadyknownBoeRecipes'] = true;
		else
		    EXTVENDOR_DATA['config']['quickvendor_alreadyknownBoeRecipes'] = false;
		end
    elseif (id == 24) then
		if (self:GetChecked()) then
		    EXTVENDOR_DATA['config']['quickvendor_whitegear'] = true;
		else
		    EXTVENDOR_DATA['config']['quickvendor_whitegear'] = false;
		end
    elseif (id == 25) then
        if (self:GetChecked()) then
            EXTVENDOR_DATA['config']['hide_default_vendor_auto_sell'] = true;
        else
            EXTVENDOR_DATA['config']['hide_default_vendor_auto_sell'] = false;
        end
	end
end

--========================================
-- Handler for mousing over options
-- on the config window
--========================================
function ExtVendorConfig_Option_OnEnter(self)
	if (self.tooltip) then
        GameTooltip:SetOwner(self, "ANCHOR_NONE");
		GameTooltip:SetPoint("TOPLEFT", self:GetName(), "BOTTOMLEFT", -10, -4);
        GameTooltip:SetText(self.tooltip, 1, 1, 1);
        GameTooltip:Show();
	end
end

--========================================
-- Moving the mouse away from config
-- options
--========================================
function ExtVendorConfig_Option_OnLeave(self)
	GameTooltip:Hide();
end

--========================================
-- Handler for changing slider(s)
--========================================
function ExtVendorConfig_Slider_OnValueChanged(self, id)

    if (id == 1) then
        local newScale = (self:GetValue() * 5) + 75;
        EXTVENDOR_DATA['config']['scale'] = newScale * 0.01;
        ExtVendor_UpdateScale();
        ExtVendorConfig_Slider_UpdateText(self, string.format(L["OPTION_SCALE"], newScale .. "%"));
    end

end

--========================================
-- Slider text update for value changes
--========================================
function ExtVendorConfig_Slider_UpdateText(slider, text)
    _G[slider:GetName() .. "Text1"]:SetText(text);
end
