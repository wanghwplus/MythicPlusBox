local addonName, ns = ...
_G.MythicPlusBox = ns

ns.name    = addonName
ns.version = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addonName, "Version"))
          or (GetAddOnMetadata and GetAddOnMetadata(addonName, "Version"))
          or "0.0.0"
ns.modules = {}
ns.L       = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

local LSM = LibStub("LibSharedMedia-3.0")
local BUNDLED_FONT_NAME = "MythicPlusBox"
LSM:Register("font", BUNDLED_FONT_NAME, [[Interface\AddOns\MythicPlusBox\Media\font.ttf]],
    LSM.LOCALE_BIT_western + LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_koKR + LSM.LOCALE_BIT_zhCN + LSM.LOCALE_BIT_zhTW)
ns.BUNDLED_FONT_NAME = BUNDLED_FONT_NAME

function ns:GetFont(fontDesc)
    local fontName = (fontDesc and fontDesc.name) or self.db.profile.font.name
    local size     = (fontDesc and fontDesc.size) or self.db.profile.font.size
    local outline  = (fontDesc and fontDesc.outline) or self.db.profile.font.outline
    local path = LSM:Fetch("font", fontName) or LSM:Fetch("font", BUNDLED_FONT_NAME)
    return path, size, outline
end

function ns:RegisterModule(id, mod)
    self.modules[id] = mod
end

function ns:RefreshAll()
    for _, mod in pairs(self.modules) do
        if type(mod.Refresh) == "function" then
            mod:Refresh()
        end
    end
end

local bootstrap = CreateFrame("Frame")
bootstrap:RegisterEvent("ADDON_LOADED")
bootstrap:RegisterEvent("PLAYER_LOGIN")
bootstrap:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        ns:InitializeDB()
        for _, mod in pairs(ns.modules) do
            if type(mod.OnDBReady) == "function" then mod:OnDBReady() end
        end
    elseif event == "PLAYER_LOGIN" then
        for _, mod in pairs(ns.modules) do
            if type(mod.OnPlayerLogin) == "function" then mod:OnPlayerLogin() end
        end
        if ns.db.global.seenOptions == false and ns.OpenOptions then
            ns.db.global.seenOptions = true
            ns:OpenOptions()
        end
    end
end)

SLASH_MYTHICPLUSBOX1 = "/mpb"
SLASH_MYTHICPLUSBOX2 = "/mpbox"
SlashCmdList["MYTHICPLUSBOX"] = function(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if msg == "reset" then
        ns.db:ResetProfile()
        ns:RefreshAll()
        print("|cff5CE1E6MythicPlusBox|r: profile reset")
    elseif msg == "unlock" then
        ns.db.profile.keystoneList.locked = false
        ns.db.profile.centerBanner.locked = false
        ns:RefreshAll()
        print("|cff5CE1E6MythicPlusBox|r: frames unlocked (drag to move)")
    elseif msg == "lock" then
        ns.db.profile.keystoneList.locked = true
        ns.db.profile.centerBanner.locked = true
        ns:RefreshAll()
        print("|cff5CE1E6MythicPlusBox|r: frames locked")
    else
        if ns.OpenOptions then ns:OpenOptions() end
    end
end
