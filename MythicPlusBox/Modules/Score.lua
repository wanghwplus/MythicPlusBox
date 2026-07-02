local addonName, ns = ...

local M = {}
ns:RegisterModule("score", M)

local function GetLevelColor(best, overtime)
    local colors = ns.db.profile.colors.levelColors
    if overtime then return "ffa3a3a3" end
    local add = best >= 15 and 1 or 0
    local levelIndex = math.min(math.floor((math.max(best or 0, 2) - 2) / 2), 5) + add
    return colors[levelIndex] or colors[0]
end

local function GetScoreColor(score)
    local colors = ns.db.profile.colors.levelColors
    if not score or score == 0 then return colors[0] end
    for _, range in ipairs(ns.db.profile.colors.scoreColorRanges) do
        if score >= range.minScore then
            return colors[range.index] or colors[0]
        end
    end
    return colors[0]
end

local function FormatDungeonInfo(mapID)
    local inTime, overtime = C_MythicPlus.GetSeasonBestForMap(mapID)
    local best, score, ot = 0, 0, false
    if inTime or overtime then
        local choose = (inTime and overtime and inTime.dungeonScore > overtime.dungeonScore)
                    or (inTime and not overtime)
        best = choose and inTime.level or overtime.level
        score = choose and inTime.dungeonScore or overtime.dungeonScore
        ot = not choose
    end
    local totalScore = select(2, C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)) or 0
    local name = ns:GetDungeonName(mapID, ns.db.profile.score.useAbbreviation)
    return name, best, score, totalScore, ot
end

local function CreateOrGetLine(icon, lineKey)
    icon._MPBoxLines = icon._MPBoxLines or {}
    local existing = icon._MPBoxLines[lineKey]
    if existing then return existing end
    local t = icon:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    t:SetJustifyH("CENTER")
    t:SetJustifyV("MIDDLE")
    icon._MPBoxLines[lineKey] = t
    return t
end

local function ApplyLineStyle(text, cfg)
    local path, size, outline = ns:GetFont({
        name    = cfg.font or ns.db.profile.font.name,
        size    = cfg.size,
        outline = ns.db.profile.font.outline,
    })
    text:SetFont(path, size, outline)
    text:ClearAllPoints()
    text:SetPoint("CENTER", text:GetParent(), "CENTER", cfg.x or 0, cfg.y or 0)
    text:SetShown(cfg.shown ~= false)
end

local function HideBuiltInLevel(icon)
    if icon.HighestLevel and icon.HighestLevel.Hide then icon.HighestLevel:Hide() end
end

local function IsCurrentSeason(mapID)
    return ns.CurrentSeasonMapIDSet and ns.CurrentSeasonMapIDSet[mapID]
end

local function RefreshIcon(icon)
    HideBuiltInLevel(icon)
    if not icon.mapID or not IsCurrentSeason(icon.mapID) then return end
    if not ns.db.profile.score.enabled then
        if icon._MPBoxLines then
            for _, t in pairs(icon._MPBoxLines) do t:Hide() end
        end
        return
    end

    local overlay = ns.db.profile.score.overlay
    local name, best, _score, totalScore, ot = FormatDungeonInfo(icon.mapID)

    local nameLine  = CreateOrGetLine(icon, "name")
    local levelLine = CreateOrGetLine(icon, "level")
    local scoreLine = CreateOrGetLine(icon, "score")

    ApplyLineStyle(nameLine,  overlay.name)
    ApplyLineStyle(levelLine, overlay.level)
    ApplyLineStyle(scoreLine, overlay.score)

    nameLine:SetText("|cffffd700" .. name .. "|r")
    levelLine:SetText("|c" .. GetLevelColor(best, ot) .. (best or 0) .. "|r")
    scoreLine:SetText("|c" .. GetScoreColor(totalScore) .. (totalScore or 0) .. "|r")
end

local function HookIcon(icon)
    if icon._MPBoxHooked then return end
    icon._MPBoxHooked = true
    if type(icon.SetUp) == "function" then
        hooksecurefunc(icon, "SetUp", RefreshIcon)
    end
    icon:HookScript("OnShow", RefreshIcon)
    RefreshIcon(icon)
end

local function HookAllIcons()
    if not ChallengesFrame or not ChallengesFrame.DungeonIcons then return end
    for _, icon in ipairs(ChallengesFrame.DungeonIcons) do HookIcon(icon) end
end

local function TryInit()
    if not _G.ChallengesFrame then
        C_AddOns.LoadAddOn("Blizzard_ChallengesUI")
    end
    if not _G.ChallengesFrame then return end
    HookAllIcons()
    if not M._challengesHooked then
        M._challengesHooked = true
        if type(ChallengesFrame.Update) == "function" then
            hooksecurefunc(ChallengesFrame, "Update", HookAllIcons)
        end
        ChallengesFrame:HookScript("OnShow", HookAllIcons)
    end
end

function M:OnPlayerLogin()
    TryInit()
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(_, _, arg)
        if arg == "Blizzard_ChallengesUI" then TryInit() end
    end)
end

function M:Refresh()
    if ChallengesFrame and ChallengesFrame.DungeonIcons then
        for _, icon in ipairs(ChallengesFrame.DungeonIcons) do
            RefreshIcon(icon)
        end
    end
end
