local L = LibStub("AceLocale-3.0"):GetLocale("ExtVendor", true);

-- ********** variables for storing previous values **********
local OLD_LOADMESSAGE = false;
local OLD_SUBARMOR_SHOW = false;
local OLD_STOCK_DEFALL = false;
local OLD_QUICKVENDOR_ENABLEBUTTON = false;
local OLD_QUICKVENDOR_SUBOPTIMAL = false;
local OLD_QUICKVENDOR_ALREADYKNOWN = false;
local OLD_QUICKVENDOR_UNUSABLEEQUIP = false;
local OLD_QUICKVENDOR_WHITEGEAR = false;
local OLD_MOUSEWHEEL_PAGING = false;
local OLD_SCALE = 1;
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

    -- ********** Filter Options **********

    ExtVendorConfig_FilterContainerTitle:SetText(L["CONFIG_HEADING_FILTER"]);

	ExtVendorConfig_FilterContainer_ShowSuboptimalArmorText:SetText(L["OPTION_FILTER_SUBARMOR_SHOW"]);
	ExtVendorConfig_FilterContainer_ShowSuboptimalArmor.tooltip = L["OPTION_FILTER_SUBARMOR_SHOW_TOOLTIP"];

	ExtVendorConfig_FilterContainer_StockDefaultAllText:SetText(L["OPTION_STOCKFILTER_DEFAULTALL"]);
	ExtVendorConfig_FilterContainer_StockDefaultAll.tooltip = L["OPTION_STOCKFILTER_DEFAULTALL_TOOLTIP"];

    -- ********** Quick-Vendor Options **********

    ExtVendorConfig_QuickVendorContainerTitle:SetText(L["CONFIG_HEADING_QUICKVENDOR"]);

	ExtVendorConfig_QuickVendorContainer_EnableButtonText:SetText(L["OPTION_QUICKVENDOR_ENABLEBUTTON"]);
	ExtVendorConfig_QuickVendorContainer_EnableButton.tooltip = L["OPTION_QUICKVENDOR_ENABLEBUTTON_TOOLTIP"];

	ExtVendorConfig_QuickVendorContainer_SuboptimalArmorText:SetText(L["OPTION_QUICKVENDOR_SUBARMOR"]);
	ExtVendorConfig_QuickVendorContainer_SuboptimalArmor.tooltip = L["OPTION_QUICKVENDOR_SUBARMOR_TOOLTIP"] .. "\n\n|cff00ff00" .. L["QUICKVENDOR_SOULBOUND"];

	ExtVendorConfig_QuickVendorContainer_AlreadyKnownText:SetText(L["OPTION_QUICKVENDOR_ALREADYKNOWN"]);
	ExtVendorConfig_QuickVendorContainer_AlreadyKnown.tooltip = L["OPTION_QUICKVENDOR_ALREADYKNOWN_TOOLTIP"] .. "\n\n|cff00ff00" .. L["QUICKVENDOR_SOULBOUND"];

	ExtVendorConfig_QuickVendorContainer_UnusableEquipText:SetText(L["OPTION_QUICKVENDOR_UNUSABLE"]);
	ExtVendorConfig_QuickVendorContainer_UnusableEquip.tooltip = L["OPTION_QUICKVENDOR_UNUSABLE_TOOLTIP"] .. "\n\n|cff00ff00" .. L["QUICKVENDOR_SOULBOUND"];

	ExtVendorConfig_QuickVendorContainer_WhiteGearText:SetText(L["OPTION_QUICKVENDOR_WHITEGEAR"]);
	ExtVendorConfig_QuickVendorContainer_WhiteGear.tooltip = L["OPTION_QUICKVENDOR_WHITEGEAR_TOOLTIP"];

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

	ExtVendorConfig_FilterContainer_ShowSuboptimalArmor:SetChecked(EXTVENDOR_DATA['config']['show_suboptimal_armor']);
	ExtVendorConfig_FilterContainer_StockDefaultAll:SetChecked(EXTVENDOR_DATA['config']['stockfilter_defall']);

    ExtVendorConfig_QuickVendorContainer_EnableButton:SetChecked(EXTVENDOR_DATA['config']['enable_quickvendor']);
    ExtVendorConfig_QuickVendorContainer_SuboptimalArmor:SetChecked(EXTVENDOR_DATA['config']['quickvendor_suboptimal']);
    ExtVendorConfig_QuickVendorContainer_AlreadyKnown:SetChecked(EXTVENDOR_DATA['config']['quickvendor_alreadyknown']);
    ExtVendorConfig_QuickVendorContainer_UnusableEquip:SetChecked(EXTVENDOR_DATA['config']['quickvendor_unusable']);
    ExtVendorConfig_QuickVendorContainer_WhiteGear:SetChecked(EXTVENDOR_DATA['config']['quickvendor_whitegear']);
end

--==================================================
-- Store current settings to restore if the user
-- presses cancel
--==================================================
function ExtVendorConfig_StoreCurrentSettings()
    OLD_LOADMESSAGE = EXTVENDOR_DATA['config']['show_load_message'];
    OLD_MOUSEWHEEL_PAGING = EXTVENDOR_DATA['config']['mousewheel_paging'];
    OLD_SCALE = EXTVENDOR_DATA['config']['scale'];
    OLD_SUBARMOR_SHOW = EXTVENDOR_DATA['config']['show_suboptimal_armor'];
    OLD_STOCK_DEFALL = EXTVENDOR_DATA['config']['stockfilter_defall'];
    OLD_QUICKVENDOR_ENABLEBUTTON = EXTVENDOR_DATA['config']['enable_quickvendor'];
    OLD_QUICKVENDOR_SUBOPTIMAL = EXTVENDOR_DATA['config']['quickvendor_suboptimal'];
    OLD_QUICKVENDOR_ALREADYKNOWN = EXTVENDOR_DATA['config']['quickvendor_alreadyknown'];
    OLD_QUICKVENDOR_UNUSABLEEQUIP = EXTVENDOR_DATA['config']['quickvendor_unusable'];
    OLD_QUICKVENDOR_WHITEGEAR = EXTVENDOR_DATA['config']['quickvendor_whitegear'];
end

--========================================
-- Closing the config window
--========================================
function ExtVendorConfig_Close()
    CONFIG_SHOWN = false;
end

--==================================================
-- Handle clicking the Cancel button; restore
-- all settings to their previous values
--==================================================
function ExtVendorConfig_Cancel()
    EXTVENDOR_DATA['config']['show_load_message'] = OLD_LOADMESSAGE;
    EXTVENDOR_DATA['config']['scale'] = OLD_SCALE;
    EXTVENDOR_DATA['config']['show_suboptimal_armor'] = OLD_SUBARMOR_SHOW;
    EXTVENDOR_DATA['config']['stockfilter_defall'] = OLD_STOCK_DEFALL;
    EXTVENDOR_DATA['config']['enable_quickvendor'] = OLD_QUICKVENDOR_ENABLEBUTTON;
    EXTVENDOR_DATA['config']['quickvendor_suboptimal'] = OLD_QUICKVENDOR_SUBOPTIMAL;
    EXTVENDOR_DATA['config']['quickvendor_alreadyknown'] = OLD_QUICKVENDOR_ALREADYKNOWN;
    EXTVENDOR_DATA['config']['quickvendor_unusable'] = OLD_QUICKVENDOR_UNUSABLEEQUIP;
    EXTVENDOR_DATA['config']['quickvendor_whitegear'] = OLD_QUICKVENDOR_WHITEGEAR;
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

    -- ********** Filter Options **********

    elseif (id == 10) then
		if (self:GetChecked()) then
		    EXTVENDOR_DATA['config']['show_suboptimal_armor'] = true;
		else
		    EXTVENDOR_DATA['config']['show_suboptimal_armor'] = false;
		end
        ExtVendor_UpdateDisplay();
    elseif (id == 11) then
		if (self:GetChecked()) then
		    EXTVENDOR_DATA['config']['stockfilter_defall'] = true;
		else
		    EXTVENDOR_DATA['config']['stockfilter_defall'] = false;
		end

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
		    EXTVENDOR_DATA['config']['quickvendor_suboptimal'] = true;
		else
		    EXTVENDOR_DATA['config']['quickvendor_suboptimal'] = false;
		end
    elseif (id == 22) then
		if (self:GetChecked()) then
		    EXTVENDOR_DATA['config']['quickvendor_alreadyknown'] = true;
		else
		    EXTVENDOR_DATA['config']['quickvendor_alreadyknown'] = false;
		end
    elseif (id == 23) then
		if (self:GetChecked()) then
		    EXTVENDOR_DATA['config']['quickvendor_unusable'] = true;
		else
		    EXTVENDOR_DATA['config']['quickvendor_unusable'] = false;
		end
    elseif (id == 24) then
		if (self:GetChecked()) then
		    EXTVENDOR_DATA['config']['quickvendor_whitegear'] = true;
		else
		    EXTVENDOR_DATA['config']['quickvendor_whitegear'] = false;
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
