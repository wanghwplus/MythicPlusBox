local addonName, ns = ...
_G.MythicPlusBox = ns

ns.name    = addonName
ns.version = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addonName, "Version"))
          or (GetAddOnMetadata and GetAddOnMetadata(addonName, "Version"))
          or "0.0.0"
ns.modules = {}
ns.L       = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

local LSM = LibStub("LibSharedMedia-3.0")

function ns:GetFont(fontDesc)
    local fontName = (fontDesc and fontDesc.name) or self.db.profile.font.name
    local size     = (fontDesc and fontDesc.size) or self.db.profile.font.size
    local outline  = (fontDesc and fontDesc.outline) or self.db.profile.font.outline
    local path = (fontName and LSM:Fetch("font", fontName))
              or LSM:Fetch("font", LSM:GetDefault("font"))
              or STANDARD_TEXT_FONT
    return path, size or 12, outline or ""
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

function ns:SetupMinimapIcon()
    if self._minimapReady then return end
    local LDB   = LibStub("LibDataBroker-1.1", true)
    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    if not LDB or not LDBIcon then return end
    local launcher = LDB:NewDataObject(addonName, {
        type = "launcher",
        icon = [[Interface\AddOns\MythicPlusBox\Media\icon]],
        label = self.L and self.L["ADDON_TITLE"] or addonName,
        OnClick = function(_, button)
            if button == "RightButton" then
                self.db.profile.keystoneList.locked = not self.db.profile.keystoneList.locked
                self.db.profile.centerBanner.locked = self.db.profile.keystoneList.locked
                self:RefreshAll()
            else
                if self.OpenOptions then self:OpenOptions() end
            end
        end,
        OnTooltipShow = function(tip)
            tip:AddLine(self.L and self.L["ADDON_TITLE"] or addonName)
            tip:AddLine("|cff9d9d9d/mpb|r")
        end,
    })
    LDBIcon:Register(addonName, launcher, self.db.global.minimap)
    self._minimapReady = true
end

local bootstrap = CreateFrame("Frame")
bootstrap:RegisterEvent("ADDON_LOADED")
bootstrap:RegisterEvent("PLAYER_LOGIN")
bootstrap:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        ns:InitializeDB()
        ns:SetupMinimapIcon()
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
