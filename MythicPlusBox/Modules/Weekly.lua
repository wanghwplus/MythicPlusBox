local addonName, ns = ...

local M = {}
ns:RegisterModule("weekly", M)

M.rows = {}

local function ColorClass(text)
    local _, class = UnitClass("player")
    local c = RAID_CLASS_COLORS[class] or { r = 1, g = 1, b = 1 }
    return string.format("|cff%02x%02x%02x%s|r", c.r * 255, c.g * 255, c.b * 255, text)
end

local function ColorCompleted(completed, level)
    return (completed and "|cff00ff00" or "|cffff0000") .. (level or "") .. "|r"
end

local function DungeonName(mapID)
    return ns:GetDungeonName(mapID, ns.db.profile.score and ns.db.profile.score.useAbbreviation)
end

local function LevelColor(level)
    local colors = ns.db.profile.colors.levelColors
    local add = level >= 15 and 1 or 0
    local idx = math.min(math.floor((math.max(level or 0, 2) - 2) / 2), 5) + add
    return colors[idx] or colors[0]
end

local function CurrentFont()
    local weekly = ns.db.profile.weekly
    return ns:GetFont({
        name    = weekly.font.name,
        size    = weekly.font.size,
        outline = ns.db.profile.font.outline,
    })
end

local function GetRow(index)
    if M.rows[index] then return M.rows[index] end
    local fs = M.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetJustifyH("LEFT")
    -- Belt-and-suspenders: guarantee the FontString has a valid font before
    -- any SetText can run, even if the template lookup silently returned no
    -- font. Prevents "SetText(): Font not set" from ClearRows/EmitRow.
    fs:SetFont(CurrentFont())
    M.rows[index] = fs
    return fs
end

local function ClearRows()
    for _, fs in ipairs(M.rows) do
        fs:SetText("")
        fs:Hide()
        fs:ClearAllPoints()
    end
end

local function LayoutRow(row, index, extraTop)
    local weekly = ns.db.profile.weekly
    row:SetFont(CurrentFont())
    row:Show()
    if index == 1 then
        row:SetPoint("TOPLEFT", M.frame, "TOPLEFT", 0, 0)
    else
        local gap = (weekly.font.rowSpacing or 4) + (extraTop or 0)
        row:SetPoint("TOPLEFT", M.rows[index - 1], "BOTTOMLEFT", 0, -gap)
    end
end

local function EmitRow(index, text, extraTop)
    local row = GetRow(index)
    LayoutRow(row, index, extraTop)
    row:SetText(text)
    return index + 1
end

local function EnsureFrame()
    if M.frame then return M.frame end
    if not PVEFrame then return nil end
    local weekly = ns.db.profile.weekly
    -- Parent to UIParent (not PVEFrame) to avoid tainting a secure frame's
    -- descendant tree from addon code. Follow PVEFrame's visibility via
    -- HookScript instead.
    local f = CreateFrame("Frame", "MythicPlusBoxWeeklyFrame", UIParent)
    f:SetSize(330, 220)
    local a = weekly.anchor
    local relTo = _G[a.relativeTo] or PVEFrame
    f:SetPoint(a.point, relTo, a.relativePoint, a.x, a.y)
    if not PVEFrame:IsShown() then f:Hide() end
    -- Read config through ns.db at call time: a captured `weekly` table goes
    -- stale after a profile switch (AceDB swaps the profile table).
    PVEFrame:HookScript("OnShow", function()
        if ns.db.profile.weekly.enabled then f:Show(); M:Update() end
    end)
    PVEFrame:HookScript("OnHide", function() f:Hide() end)
    M.frame = f
    return f
end

local function BuildDungeonStatsRows(runHistory, startIndex)
    local L = ns.L
    local index = startIndex
    local byDungeon, order = {}, {}
    for _, run in ipairs(runHistory) do
        local id = run.mapChallengeModeID
        if not byDungeon[id] then
            byDungeon[id] = { runs = {} }
            table.insert(order, id)
        end
        table.insert(byDungeon[id].runs, run)
    end
    table.sort(order)

    index = EmitRow(index, ColorClass(L["COMPLETION_COUNT_LABEL"]) .. "|cffff8f00" .. #runHistory .. "|r", 10)

    for _, id in ipairs(order) do
        local d = byDungeon[id]
        local text = DungeonName(id) .. "  |CFF9385ffx|R|CFF0ffff2" .. #d.runs .. "|r - "
        for i, run in ipairs(d.runs) do
            text = text .. ColorCompleted(run.completed, run.level)
            if i < #d.runs then text = text .. "|cff9d9d9d·|r" end
        end
        index = EmitRow(index, text)
    end
    return index
end

local function BuildWeeklyRows(runHistory)
    local L = ns.L
    ClearRows()
    if not runHistory or #runHistory == 0 then
        EmitRow(1, L["NO_WEEKLY_RECORD"])
        return
    end
    table.sort(runHistory, function(a, b)
        if a.level == b.level then return a.mapChallengeModeID < b.mapChallengeModeID end
        return a.level > b.level
    end)
    local index = 1
    index = EmitRow(index, ColorClass(L["WEEKLY_BEST_HEADER"]))
    for i, run in ipairs(runHistory) do
        if i > 8 then break end
        local text = ColorCompleted(run.completed, run.level)
            .. " " .. DungeonName(run.mapChallengeModeID)
        if i == 1 or i == 4 or i == 8 then
            text = text .. " |cffa335ee[" .. (ns.VaultItemLevels[math.min(run.level, 10)] or "?") .. " " .. L["ITEM_LEVEL"] .. "]|r"
        end
        index = EmitRow(index, text)
    end
    BuildDungeonStatsRows(runHistory, index)
end

local function BuildSeasonRows(runHistory)
    local L = ns.L
    ClearRows()
    if not runHistory or #runHistory == 0 then
        EmitRow(1, L["NO_SEASON_RECORD"])
        return
    end
    local bestByDungeon = {}
    for _, run in ipairs(runHistory) do
        if run.completed then
            local id = run.mapChallengeModeID
            if not bestByDungeon[id] or run.level > bestByDungeon[id].level then
                bestByDungeon[id] = run
            end
        end
    end
    local bestList = {}
    for _, run in pairs(bestByDungeon) do table.insert(bestList, run) end
    table.sort(bestList, function(a, b)
        if a.level == b.level then return a.mapChallengeModeID < b.mapChallengeModeID end
        return a.level > b.level
    end)
    local index = 1
    index = EmitRow(index, ColorClass(L["SEASON_RECORD_HEADER"]))
    for i, run in ipairs(bestList) do
        if i > 8 then break end
        local text = "|c" .. LevelColor(run.level) .. run.level .. "|r "
                  .. DungeonName(run.mapChallengeModeID)
        index = EmitRow(index, text)
    end
    BuildDungeonStatsRows(runHistory, index)
end

function M:Update()
    local weekly = ns.db.profile.weekly
    local f = EnsureFrame()
    if not f then return end
    if not weekly.enabled then f:Hide(); return end
    if not (PVEFrame and PVEFrame:IsShown()) then f:Hide(); return end
    f:Show()

    local showSeasonData = false
    if weekly.useModifierKey then
        showSeasonData = IsShiftKeyDown()
    end

    -- Anchor may have changed via Options — reapply.
    local a = weekly.anchor
    local relTo = _G[a.relativeTo] or PVEFrame
    f:ClearAllPoints()
    f:SetPoint(a.point, relTo, a.relativePoint, a.x, a.y)

    if showSeasonData then
        BuildSeasonRows(C_MythicPlus.GetRunHistory(true, true) or {})
    else
        BuildWeeklyRows(C_MythicPlus.GetRunHistory(false, true) or {})
    end
end

function M:OnPlayerLogin()
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    f:RegisterEvent("MODIFIER_STATE_CHANGED")
    f:SetScript("OnEvent", function(_, event)
        if event == "MODIFIER_STATE_CHANGED" then
            local w = ns.db.profile.weekly
            if w.enabled and w.useModifierKey and PVEFrame and PVEFrame:IsShown() then
                M:Update()
            end
        else
            C_Timer.After(1, function() M:Update() end)
        end
    end)
    C_Timer.After(2, function() M:Update() end)
end

function M:Refresh()
    self:Update()
end
