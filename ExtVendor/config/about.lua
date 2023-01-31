local L = LibStub("AceLocale-3.0"):GetLocale("ExtVendor", true);

local ABOUT = {
    author = "Ascension Version: Anch - Area-52 \n(Original Author: Alex Ellison (Germbread - Deathwing-US)",
    hosts = {
        "https://discord.gg/nEqQmp9UMf",
    },
};

local CONFIG_SHOWN = false;

--========================================
-- Setting up the config frame
--========================================
function ExtVendorConfig_About_OnLoad(self)
    self.name = L["ABOUT"];
    self.parent = L["ADDON_TITLE"];
    self.okay = function(self) ExtVendorConfig_About_OnClose(); end;
    self.cancel = function(self) ExtVendorConfig_About_OnClose(); end;
    self.refresh = function(self) ExtVendorConfig_About_OnRefresh(); end;
    InterfaceOptions_AddCategory(self);

    ExtVendorConfigAboutTitle:SetText(string.format(L["VERSION_TEXT"], "|cffffffffv" .. EXTVENDOR_VERSION));
    ExtVendorConfigAboutAuthor:SetText(L["LABEL_AUTHOR"] .. ": |cffffffff" .. ABOUT.author);
    ExtVendorConfigAboutAuthor:SetJustifyH("LEFT")
    ExtVendorConfigAboutURLs:SetText(L["LABEL_HOSTS"] .. ":");
end

--========================================
-- Refresh
--========================================
function ExtVendorConfig_About_OnRefresh()
    if (CONFIG_SHOWN) then return; end

    for i, v in ipairs(ABOUT.hosts) do
        local button = _G["ExtVendorConfigAbout_SiteList_Button"..i];
        local fontString = _G["ExtVendorConfigAbout_SiteList" .. i];
        if not button then
            button = CreateFrame("button", "ExtVendorConfigAbout_SiteList_Button"..i,ExtVendorConfigAbout)
        end
        if (not fontString) then
            fontString = ExtVendorConfigAbout:CreateFontString("ExtVendorConfigAbout_SiteList" .. i, "ARTWORK", "GameFontHighlight");
        end

        button:ClearAllPoints();
        button:SetPoint("TOPLEFT", ExtVendorConfigAbout, "TOPLEFT", 40, -(105 + (i * 20)));
        button:SetScript("OnClick", function()
            Internal_CopyToClipboard(v)
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFFLink copyed to clipboard")
        end)
        button:SetHeight(20)
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT",-13,-50)
            GameTooltip:AddLine("Click to copy link to clipboard")
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        fontString:ClearAllPoints();
        fontString:SetPoint("TOPLEFT", _G["ExtVendorConfigAbout_SiteList_Button"..i], 0, 0);
        fontString:SetJustifyH("LEFT")
        fontString:SetText("|cff9999ff"..v);
        button:SetWidth(fontString:GetStringWidth() + 10)
    end

    CONFIG_SHOWN = true;
end

--========================================
-- Closing the window
--========================================
function ExtVendorConfig_About_OnClose()
    CONFIG_SHOWN = false;
end
