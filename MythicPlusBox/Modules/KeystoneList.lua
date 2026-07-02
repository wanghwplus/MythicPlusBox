local addonName, ns = ...

local M = {}
ns:RegisterModule("keystoneList", M)

local REFRESH_INTERVAL = 3.0
local ICON_SIZE        = 64
local ICON_TEXT_GAP    = 10
local FALLBACK_ICON    = [[Interface\Icons\INV_Misc_Key_14]]

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

local function EnsureFrame()
    if M.frame then return M.frame end
    local f = CreateFrame("Frame", "MythicPlusBoxKeystoneListFrame", UIParent, "BackdropTemplate")
    f:SetSize(320, 200)
    f:SetFrameStrata("MEDIUM")
    f:SetMovable(true)
    f:EnableMouse(false)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        if ns.db.profile.keystoneList.locked then return end
        self:StartMoving()
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        local anchor = ns.db.profile.keystoneList.anchor
        anchor.point         = point
        anchor.relativeTo    = "UIParent"
        anchor.relativePoint = relativePoint
        anchor.x             = x
        anchor.y             = y
    end)

    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    f:SetBackdropColor(0, 0, 0, 0.5)
    f:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -8)
    f.title:SetJustifyH("LEFT")

    M.frame = f
    M:ApplyAnchor()
    return f
end

function M:ApplyAnchor()
    if not self.frame then return end
    local a = ns.db.profile.keystoneList.anchor
    local relTo = _G[a.relativeTo] or UIParent
    self.frame:ClearAllPoints()
    self.frame:SetPoint(a.point, relTo, a.relativePoint, a.x, a.y)
end

local function CurrentFont()
    local cfg = ns.db.profile.keystoneList
    return ns:GetFont({
        name    = cfg.font.name,
        size    = cfg.font.size,
        outline = ns.db.profile.font.outline,
    })
end

local function GetRow(index)
    if M.rows[index] then return M.rows[index] end
    local row = CreateFrame("Frame", nil, M.frame)
    row:SetHeight(ICON_SIZE)

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(ICON_SIZE, ICON_SIZE)
    row.icon:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    row.iconBorder = row:CreateTexture(nil, "BORDER")
    row.iconBorder:SetColorTexture(0, 0, 0, 0.6)
    row.iconBorder:SetPoint("TOPLEFT",     row.icon, "TOPLEFT",     -1, 1)
    row.iconBorder:SetPoint("BOTTOMRIGHT", row.icon, "BOTTOMRIGHT",  1, -1)

    row.level = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.level:SetPoint("CENTER", row.icon, "CENTER", 0, 0)
    row.level:SetJustifyH("CENTER")
    row.level:SetFont(CurrentFont())

    row.dungeon = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.dungeon:SetPoint("TOPLEFT",  row.icon, "TOPRIGHT", ICON_TEXT_GAP, -4)
    row.dungeon:SetPoint("RIGHT",    row,      "RIGHT",    -6, 0)
    row.dungeon:SetJustifyH("LEFT")
    row.dungeon:SetFont(CurrentFont())

    row.holder = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.holder:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", ICON_TEXT_GAP, 4)
    row.holder:SetPoint("RIGHT",      row,      "RIGHT",       -6, 0)
    row.holder:SetJustifyH("LEFT")
    row.holder:SetFont(CurrentFont())

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
                rating         = info.rating,
            }
        end
    end
    local _, _, classID = UnitClass(unitId)
    return { level = 0, challengeMapID = 0, classID = classID }
end

local function CollectPartyKeystones()
    local result = {}
    local lib = GetLibOpenRaid()
    local cfg = ns.db.profile.keystoneList
    -- In unlocked-preview mode always keep the player in the list so the frame
    -- has something to render while the user is dragging it into place.
    local includeEmpty = cfg.showOffline or not cfg.locked
    for _, unitId in ipairs(PartyUnitIDs()) do
        local info = KeystoneForUnit(lib, unitId)
        local isPlayer = (unitId == "player")
        if info.level > 0 or includeEmpty or (not cfg.locked and isPlayer) then
            table.insert(result, {
                unitName       = UnitName(unitId) or unitId,
                level          = info.level,
                challengeMapID = info.challengeMapID,
                classID        = info.classID,
                rating         = info.rating,
                isPlayer       = isPlayer,
            })
        end
    end
    table.sort(result, function(a, b)
        if a.level ~= b.level then return a.level > b.level end
        return (a.unitName or "") < (b.unitName or "")
    end)
    return result
end

local function DungeonIconTexture(mapID)
    if not mapID or mapID == 0 then return FALLBACK_ICON end
    if C_ChallengeMode and C_ChallengeMode.GetMapUIInfo then
        local _, _, _, tex = C_ChallengeMode.GetMapUIInfo(mapID)
        if tex and tex ~= 0 then return tex end
    end
    return FALLBACK_ICON
end

local function LayoutRows()
    local L = ns.L
    local cfg = ns.db.profile.keystoneList
    local path, size, outline = ns:GetFont({ name = cfg.font.name, size = cfg.font.size, outline = ns.db.profile.font.outline })
    M.frame.title:SetFont(path, size, outline)
    M.frame.title:SetText("|cffffd700" .. L["KEYSTONE_LIST_HEADER"] .. "|r")

    local list = CollectPartyKeystones()
    local titleH = size + 12
    local rowH   = ICON_SIZE
    local gap    = math.max(cfg.rowSpacing or 4, 4)

    if #list == 0 then
        local row = GetRow(1)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", M.frame.title, "BOTTOMLEFT", 0, -gap)
        row:SetPoint("RIGHT",   M.frame, "RIGHT", -8, 0)
        row:SetHeight(rowH)
        row:Show()
        row.icon:SetTexture(FALLBACK_ICON)
        row.iconBorder:Show()
        row.level:SetFont(path, math.max(size + 4, 14), outline)
        row.level:SetText("")
        row.dungeon:SetFont(path, size, outline)
        row.holder:SetFont(path, size, outline)
        row.dungeon:SetText("|cff9d9d9d" ..
            (IsInGroup() and L["KEYSTONE_NONE"] or L["KEYSTONE_NO_PARTY"]) .. "|r")
        row.holder:SetText("")
        HideExtraRows(2)
        M.frame:SetHeight(titleH + rowH + gap + 12)
        return
    end

    local levelSize = math.max(size + 6, 18)
    for i, entry in ipairs(list) do
        local row = GetRow(i)
        row:ClearAllPoints()
        if i == 1 then
            row:SetPoint("TOPLEFT", M.frame.title, "BOTTOMLEFT", 0, -gap)
        else
            row:SetPoint("TOPLEFT", M.rows[i - 1], "BOTTOMLEFT", 0, -gap)
        end
        row:SetPoint("RIGHT", M.frame, "RIGHT", -8, 0)
        row:SetHeight(rowH)
        row:Show()

        row.icon:SetTexture(DungeonIconTexture(entry.challengeMapID))
        row.iconBorder:Show()

        row.level:SetFont(path, levelSize, "THICKOUTLINE")
        row.dungeon:SetFont(path, size, outline)
        row.holder:SetFont(path, size, outline)

        if entry.level > 0 then
            row.level:SetText("|c" .. LevelColor(entry.level) .. "+" .. entry.level .. "|r")
            row.dungeon:SetText(ns:GetDungeonName(entry.challengeMapID, false))
        else
            row.level:SetText("|cff9d9d9d-|r")
            row.dungeon:SetText("|cff9d9d9d" .. L["KEYSTONE_NONE"] .. "|r")
        end

        local c = ClassColor(entry.classID)
        row.holder:SetText(string.format("|cff%02x%02x%02x%s|r",
            c.r * 255, c.g * 255, c.b * 255,
            Ambiguate(entry.unitName or "?", "short")))
    end

    HideExtraRows(#list + 1)
    M.frame:SetHeight(titleH + (rowH + gap) * #list + 8)
end

local function ShouldShow(cfg)
    if not cfg.enabled then return false end
    -- Unlocked: keep the frame on screen so the user can drag it into place,
    -- even outside a party or dungeon (a "self keystone" preview row is shown).
    if not cfg.locked then return true end
    if not IsInGroup(LE_PARTY_CATEGORY_HOME) then return false end
    if IsInRaid() then return false end
    if M.inActiveRun then return false end
    return true
end

function M:Refresh()
    if not self.frame then return end
    local cfg = ns.db.profile.keystoneList
    if not ShouldShow(cfg) then self.frame:Hide(); return end
    self.frame:Show()
    self.frame:EnableMouse(not cfg.locked)
    self:ApplyAnchor()
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
    f:RegisterEvent("GROUP_ROSTER_UPDATE")
    f:RegisterEvent("BAG_UPDATE_DELAYED")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("CHALLENGE_MODE_START")
    f:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    f:RegisterEvent("CHALLENGE_MODE_RESET")
    f:SetScript("OnEvent", function(_, event)
        if event == "CHALLENGE_MODE_START" then
            M.inActiveRun = true
            M:Refresh()
        elseif event == "CHALLENGE_MODE_COMPLETED" or event == "CHALLENGE_MODE_RESET" then
            M.inActiveRun = false
            M:Refresh()
        elseif event == "GROUP_ROSTER_UPDATE" then
            C_Timer.After(1, function()
                local l = GetLibOpenRaid()
                if l and l.RequestKeystoneDataFromParty then
                    l.RequestKeystoneDataFromParty()
                end
                M:Refresh()
            end)
        elseif event == "PLAYER_ENTERING_WORLD" then
            local _, instanceType = GetInstanceInfo()
            local activeLevel = C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo
                                and C_ChallengeMode.GetActiveKeystoneInfo() or 0
            M.inActiveRun = (instanceType == "party" and activeLevel > 0) or false
            M:Refresh()
        else
            M:Refresh()
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
