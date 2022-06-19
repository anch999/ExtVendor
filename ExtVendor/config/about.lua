local L = LibStub("AceLocale-3.0"):GetLocale("ExtVendor", true);

local ABOUT = {
    author = "Alex Ellison (Germbread - Deathwing-US)",
    email = GetAddOnMetadata("ExtVendor", "X-Email"),
    hosts = {
        "http://www.wowinterface.com/",
        "http://www.curse.com/",
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
    ExtVendorConfigAboutEmail:SetText(L["LABEL_EMAIL"] .. ": |cffffffff" .. ABOUT.email);
    ExtVendorConfigAboutURLs:SetText(L["LABEL_HOSTS"] .. ":");
end

--========================================
-- Refresh
--========================================
function ExtVendorConfig_About_OnRefresh()
    if (CONFIG_SHOWN) then return; end

    for i = 1, table.maxn(ABOUT.hosts), 1 do
        local fontString = _G["ExtVendorConfigAbout_SiteList" .. i];
        if (not fontString) then
            fontString = ExtVendorConfigAbout:CreateFontString("ExtVendorConfigAbout_SiteList" .. i, "ARTWORK", "GameFontHighlight");
        end
        fontString:ClearAllPoints();
        fontString:SetPoint("TOPLEFT", ExtVendorConfigAbout, "TOPLEFT", 60, -(145 + (i * 20)));
        fontString:SetText(ABOUT.hosts[i]);
    end

    CONFIG_SHOWN = true;
end

--========================================
-- Closing the window
--========================================
function ExtVendorConfig_About_OnClose()
    CONFIG_SHOWN = false;
end
