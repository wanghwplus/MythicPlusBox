local addonName, ns = ...

local M = {}
ns:RegisterModule("centerBanner", M)

local REFRESH_INTERVAL = 3.0
local ROW_HEIGHT_PAD   = 6
local FRAME_PAD        = 10

M.rows = {}

local function GetLibOpenRaid()
    return _G.LibStub and _G.LibStub("LibOpenRaid-1.0", true)
end

local function ClassColor(classID)
    if not classID then return { r = 1, g = 1, b = 1 } end
    local classFile = select(2, GetClassInfo(classID))
    return classFile and RAID_CLASS_COLORS[classFile] or { r = 1, g = 1, b = 1 }
end

local function LevelColor(level)
    local colors = ns.db.profile.colors.levelColors
    if not level or level <= 0 then return colors[0] end
    local add = level >= 15 and 1 or 0
    local idx = math.min(math.floor((math.max(level, 2) - 2) / 2), 5) + add
    return colors[idx] or colors[0]
end

local function CurrentFont()
    local cfg = ns.db.profile.centerBanner
    return ns:GetFont({
        name    = cfg.font.name,
        size    = cfg.font.size,
        outline = ns.db.profile.font.outline,
    })
end

local function EnsureFrame()
    if M.frame then return M.frame end
    local f = CreateFrame("Frame", "MythicPlusBoxCenterBannerFrame", UIParent, "BackdropTemplate")
    f:SetSize(260, 80)
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
        if ns.RefreshOptionsUI then ns:RefreshOptionsUI() end
    end)

    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    f:SetBackdropColor(0, 0, 0, 0.5)
    f:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("TOPLEFT",  f, "TOPLEFT",  FRAME_PAD, -FRAME_PAD)
    f.title:SetPoint("TOPRIGHT", f, "TOPRIGHT", -FRAME_PAD, -FRAME_PAD)
    f.title:SetJustifyH("CENTER")
    f.title:SetFont(CurrentFont())

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

local function GetRow(index)
    if M.rows[index] then return M.rows[index] end
    local row = CreateFrame("Frame", nil, M.frame)
    row:SetHeight(20)

    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.text:SetAllPoints(row)
    row.text:SetJustifyH("CENTER")
    row.text:SetJustifyV("MIDDLE")
    row.text:SetFont(CurrentFont())

    M.rows[index] = row
    return row
end

local function HideExtraRows(fromIndex)
    for i = fromIndex, #M.rows do
        if M.rows[i] then M.rows[i]:Hide() end
    end
end

local function PartyUnitIDs()
    local ids = { "player" }
    if IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInRaid() then
        for i = 1, GetNumSubgroupMembers() do
            local unit = "party" .. i
            if UnitExists(unit) then table.insert(ids, unit) end
        end
    end
    return ids
end

local function KeystoneForUnit(lib, unitId)
    if unitId == "player" then
        local _, _, classID = UnitClass("player")
        return {
            level          = C_MythicPlus.GetOwnedKeystoneLevel() or 0,
            challengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID() or 0,
            classID        = classID,
        }
    end
    if lib and lib.GetKeystoneInfo then
        local info = lib.GetKeystoneInfo(unitId)
        if info then
            return {
                level          = info.level or 0,
                challengeMapID = info.challengeMapID or info.mapID or 0,
                classID        = info.classID,
            }
        end
    end
    local _, _, classID = UnitClass(unitId)
    return { level = 0, challengeMapID = 0, classID = classID }
end

local function ActiveMapID()
    if C_ChallengeMode and C_ChallengeMode.GetActiveChallengeMapID then
        return C_ChallengeMode.GetActiveChallengeMapID() or 0
    end
    return 0
end

-- Collect the list of party members whose keystone matches the currently
-- active dungeon. Unlocked-preview mode always yields the player themselves
-- (regardless of whether the key matches, or even exists), so the anchor
-- has something to render outside a live run.
local function CollectHolders(unlocked)
    local list = {}
    local lib  = GetLibOpenRaid()

    if unlocked then
        local info = KeystoneForUnit(lib, "player")
        table.insert(list, {
            unitName = UnitName("player") or "player",
            level    = info.level,
            classID  = info.classID,
        })
        return list
    end

    local activeMap = ActiveMapID()
    if activeMap == 0 then return list end

    for _, unitId in ipairs(PartyUnitIDs()) do
        local info = KeystoneForUnit(lib, unitId)
        if info.level > 0 and info.challengeMapID == activeMap then
            table.insert(list, {
                unitName = UnitName(unitId) or unitId,
                level    = info.level,
                classID  = info.classID,
            })
        end
    end
    table.sort(list, function(a, b)
        if a.level ~= b.level then return a.level > b.level end
        return (a.unitName or "") < (b.unitName or "")
    end)
    return list
end

local function ShouldShow(cfg)
    if not cfg.enabled then return false end
    if not cfg.locked then return true end
    return ActiveMapID() ~= 0
end

local function LayoutRows()
    local L = ns.L
    local cfg = ns.db.profile.centerBanner
    local path, size, outline = ns:GetFont({ name = cfg.font.name, size = cfg.font.size, outline = ns.db.profile.font.outline })
    local rowH   = size + ROW_HEIGHT_PAD
    local gap    = cfg.rowSpacing or 4
    local titleH = size + 6
    local afterTitleGap = gap + 4

    M.frame.title:SetFont(path, size, outline)
    M.frame.title:SetText("|cffffd700" .. (L["OPT_CENTER_BANNER"] or "Keystone owners") .. "|r")

    local list = CollectHolders(not cfg.locked)
    if #list == 0 then
        HideExtraRows(1)
        M.frame:SetHeight(FRAME_PAD * 2 + titleH)
        return
    end

    for i, entry in ipairs(list) do
        local row = GetRow(i)
        row:ClearAllPoints()
        if i == 1 then
            row:SetPoint("TOPLEFT",  M.frame.title, "BOTTOMLEFT",  0, -afterTitleGap)
            row:SetPoint("TOPRIGHT", M.frame.title, "BOTTOMRIGHT", 0, -afterTitleGap)
        else
            row:SetPoint("TOPLEFT",  M.rows[i - 1], "BOTTOMLEFT",  0, -gap)
            row:SetPoint("TOPRIGHT", M.rows[i - 1], "BOTTOMRIGHT", 0, -gap)
        end
        row:SetHeight(rowH)
        row:Show()
        row.text:SetFont(path, size, outline)

        local c = ClassColor(entry.classID)
        local nameStr = string.format("|cff%02x%02x%02x%s|r",
            c.r * 255, c.g * 255, c.b * 255,
            Ambiguate(entry.unitName or "?", "short"))
        local levelStr
        if entry.level > 0 then
            levelStr = "|c" .. LevelColor(entry.level) .. "+" .. entry.level .. "|r"
        else
            levelStr = "|cff9d9d9d-|r"
        end
        row.text:SetText(nameStr .. "        " .. levelStr)
    end

    HideExtraRows(#list + 1)
    M.frame:SetHeight(FRAME_PAD * 2 + titleH + afterTitleGap
        + rowH * #list + gap * math.max(#list - 1, 0))
end

function M:Refresh()
    if not self.frame then return end
    local cfg = ns.db.profile.centerBanner
    if not ShouldShow(cfg) then self.frame:Hide(); return end
    self:ApplyAnchor()
    self.frame:EnableMouse(not cfg.locked)
    self.frame:Show()
    LayoutRows()
end

function M:OnPlayerLogin()
    EnsureFrame()

    local lib = GetLibOpenRaid()
    if lib and lib.RequestKeystoneDataFromParty then
        lib.RequestKeystoneDataFromParty()
    end
    if lib and lib.RegisterCallback then
        lib.RegisterCallback(M, "KeystoneUpdate", "OnKeystoneUpdate")
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("CHALLENGE_MODE_START")
    f:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    f:RegisterEvent("CHALLENGE_MODE_RESET")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("GROUP_ROSTER_UPDATE")
    f:SetScript("OnEvent", function(_, event)
        if event == "GROUP_ROSTER_UPDATE" then
            C_Timer.After(1, function()
                local l = GetLibOpenRaid()
                if l and l.RequestKeystoneDataFromParty then
                    l.RequestKeystoneDataFromParty()
                end
                M:Refresh()
            end)
        else
            C_Timer.After(1, function() M:Refresh() end)
        end
    end)

    local accum = 0
    self.frame:SetScript("OnUpdate", function(_, elapsed)
        accum = accum + elapsed
        if accum >= REFRESH_INTERVAL then
            accum = 0
            M:Refresh()
        end
    end)

    M:Refresh()
end

function M:OnKeystoneUpdate()
    M:Refresh()
end
