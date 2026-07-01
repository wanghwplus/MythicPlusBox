local addonName, ns = ...

local M = {}
ns:RegisterModule("centerBanner", M)

local function GetLibOpenRaid()
    return _G.LibStub and _G.LibStub("LibOpenRaid-1.0", true)
end

local function EnsureFrame()
    if M.frame then return M.frame end
    local f = CreateFrame("Frame", "MythicPlusBoxCenterBannerFrame", UIParent)
    f:SetSize(500, 60)
    f:SetFrameStrata("HIGH")
    f:SetMovable(true)
    f:EnableMouse(false)
    f:RegisterForDrag("LeftButton")
    f:Hide()

    f:SetScript("OnDragStart", function(self)
        if ns.db.profile.centerBanner.locked then return end
        self:StartMoving()
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        local anchor = ns.db.profile.centerBanner.anchor
        anchor.point         = point
        anchor.relativeTo    = "UIParent"
        anchor.relativePoint = relativePoint
        anchor.x             = x
        anchor.y             = y
    end)

    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.text:SetAllPoints(f)
    f.text:SetJustifyH("CENTER")
    f.text:SetJustifyV("MIDDLE")

    M.frame = f
    M:ApplyAnchor()
    return f
end

function M:ApplyAnchor()
    if not self.frame then return end
    local a = ns.db.profile.centerBanner.anchor
    local relTo = _G[a.relativeTo] or UIParent
    self.frame:ClearAllPoints()
    self.frame:SetPoint(a.point, relTo, a.relativePoint, a.x, a.y)
end

local function ResolveHolderAndKey()
    -- Returns holderName, mapID, level when we can figure out the current run's key.
    local level, _, _, _, _, mapID
    if C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo then
        level = C_ChallengeMode.GetActiveKeystoneInfo()
    end
    if C_ChallengeMode and C_ChallengeMode.GetActiveChallengeMapID then
        mapID = C_ChallengeMode.GetActiveChallengeMapID()
    end
    if not mapID or not level or level == 0 then return nil end

    -- Match holder by comparing everyone's keystone level+challenge map to the active key.
    local lib = GetLibOpenRaid()
    if lib and lib.GetAllKeystonesInfo then
        for unitName, info in pairs(lib.GetAllKeystonesInfo() or {}) do
            if info and info.level == level and (info.challengeMapID == mapID or info.mapID == mapID) then
                return unitName, mapID, level
            end
        end
    end
    -- Fallback: assume local player.
    if (C_MythicPlus.GetOwnedKeystoneLevel() or 0) == level
       and (C_MythicPlus.GetOwnedKeystoneChallengeMapID() or 0) == mapID then
        return UnitName("player"), mapID, level
    end
    return nil, mapID, level
end

function M:Show()
    if not ns.db.profile.centerBanner.enabled then return end
    local f = EnsureFrame()
    local L = ns.L
    local cfg = ns.db.profile.centerBanner
    local path, size, outline = ns:GetFont({ name = cfg.font.name, size = cfg.font.size, outline = ns.db.profile.font.outline })
    f.text:SetFont(path, size, outline)

    local holder, mapID, level = ResolveHolderAndKey()
    local dungeonName = ns:GetDungeonName(mapID, false)
    local holderName  = Ambiguate(holder or L["UNKNOWN"], "short")
    f.text:SetText(string.format(L["KEYSTONE_BANNER_FORMAT"], holderName, dungeonName, level or 0))

    self:ApplyAnchor()
    f:EnableMouse(not cfg.locked)
    f:Show()
    f:SetAlpha(0)
    if _G.UIFrameFadeIn then UIFrameFadeIn(f, 0.5, 0, 1) else f:SetAlpha(1) end

    if self._hideTimer then self._hideTimer:Cancel() end
    self._hideTimer = C_Timer.NewTimer(cfg.duration, function() M:Hide() end)
end

function M:Hide()
    if not self.frame then return end
    if _G.UIFrameFadeOut then
        UIFrameFadeOut(self.frame, 0.4, self.frame:GetAlpha(), 0)
        C_Timer.After(0.5, function() if self.frame then self.frame:Hide() end end)
    else
        self.frame:Hide()
    end
end

function M:Refresh()
    if not self.frame then return end
    local cfg = ns.db.profile.centerBanner
    self:ApplyAnchor()
    self.frame:EnableMouse(not cfg.locked)
    if not cfg.enabled then self.frame:Hide() end
    -- If the frame is currently shown (banner active or user unlocked to drag), reapply text style.
    if self.frame:IsShown() then
        local path, size, outline = ns:GetFont({ name = cfg.font.name, size = cfg.font.size, outline = ns.db.profile.font.outline })
        self.frame.text:SetFont(path, size, outline)
    end
end

function M:OnPlayerLogin()
    EnsureFrame()
    local f = CreateFrame("Frame")
    f:RegisterEvent("CHALLENGE_MODE_START")
    f:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    f:RegisterEvent("CHALLENGE_MODE_RESET")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function(_, event)
        if event == "CHALLENGE_MODE_START" then
            C_Timer.After(1, function() M:Show() end)
        elseif event == "CHALLENGE_MODE_COMPLETED" or event == "CHALLENGE_MODE_RESET" then
            M:Hide()
        elseif event == "PLAYER_ENTERING_WORLD" then
            -- Re-show if we're already inside a live challenge (e.g. /reload mid-run).
            local _, instanceType, _, _, _, _, _, _, _ = GetInstanceInfo()
            if instanceType == "party" and C_ChallengeMode
               and C_ChallengeMode.GetActiveKeystoneInfo and (C_ChallengeMode.GetActiveKeystoneInfo() or 0) > 0 then
                C_Timer.After(1, function() M:Show() end)
            end
        end
    end)
end
