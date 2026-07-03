local addonName, ns = ...

local M = {}
ns:RegisterModule("teleport", M)

local SpellToMap

local function BuildSpellToMap()
    SpellToMap = {}
    for mapID, spellIDs in pairs(ns.DungeonTeleport or {}) do
        for _, spellID in ipairs(spellIDs) do
            SpellToMap[spellID] = mapID
        end
    end
end

local function SelectBestSpellID(spellIDs)
    for _, spellID in ipairs(spellIDs) do
        if IsSpellKnown(spellID) then return spellID end
    end
    return spellIDs[1]
end

local function UpdateTooltip(parent, spellID, initialize)
    if M.isLoadingScreen then return end
    local L = ns.L
    if not initialize and not GameTooltip:IsOwned(parent) then return end
    local onEnter = parent:GetScript("OnEnter")
    if onEnter then onEnter(parent) end

    local name = C_Spell.GetSpellName(spellID)
    GameTooltip:AddLine(" ")

    if IsSpellKnown(spellID) then
        GameTooltip:AddLine(name or L["TELEPORT_TOOLTIP_TITLE"])
        local cd = C_Spell.GetSpellCooldown(spellID)
        if not cd or not cd.startTime or not cd.duration then
            GameTooltip:AddLine(L["TELEPORT_UNKNOWN_COOLDOWN"], 1, 0, 0)
        elseif cd.duration == 0 then
            GameTooltip:AddLine(L["TELEPORT_READY"], 0, 1, 0)
        else
            GameTooltip:AddLine(SecondsToTime(math.ceil(cd.startTime + cd.duration - GetTime())), 1, 0, 0)
        end
    else
        GameTooltip:AddLine(name or L["TELEPORT_TOOLTIP_TITLE"])
        GameTooltip:AddLine(L["TELEPORT_NOT_LEARNED"], 1, 0, 0)
    end
    GameTooltip:Show()

    C_Timer.After(1, function() UpdateTooltip(parent, spellID) end)
end

local function CreateDungeonButton(icon, spellIDs)
    if not spellIDs then return end
    if InCombatLockdown() then return end
    local spellID = SelectBestSpellID(spellIDs)
    if not spellID then return end

    local button = icon.__MPBoxTeleport
    if not button then
        button = CreateFrame("Button", nil, icon, "InsecureActionButtonTemplate")
        button:SetAllPoints(icon)
        button:RegisterForClicks("AnyDown", "AnyUp")
        icon.__MPBoxTeleport = button
    end
    button:SetAttribute("type", "spell")
    button:SetAttribute("spell", spellID)
    button:SetScript("OnEnter", function() UpdateTooltip(icon, spellID, true) end)
    button:SetScript("OnLeave", function()
        if GameTooltip:IsOwned(icon) then GameTooltip:Hide() end
    end)
end

local function CreateAll()
    if InCombatLockdown() then return end
    if not ChallengesFrame or not ChallengesFrame.DungeonIcons then return end
    if not ns.db.profile.teleport.enabled then return end
    for _, dungeonIcon in ipairs(ChallengesFrame.DungeonIcons) do
        CreateDungeonButton(dungeonIcon, ns.DungeonTeleport[dungeonIcon.mapID])
    end
end

local function TryInit()
    if not _G.ChallengesFrame then
        C_AddOns.LoadAddOn("Blizzard_ChallengesUI")
    end
    if not _G.ChallengesFrame then return end
    if M._hooked then return end
    M._hooked = true
    if type(ChallengesFrame.Update) == "function" then
        hooksecurefunc(ChallengesFrame, "Update", CreateAll)
    end
    CreateAll()
end

local function SafeSendChatMessage(msg, chatType)
    if not msg or msg == "" then return end
    msg = msg:gsub("\n", " "):gsub("[%z\1-\31\127]", ""):sub(1, 255)
    SendChatMessage(msg, chatType)
end

local function ShouldAnnounce()
    return IsInGroup() or IsInInstance()
end

function M:GenerateMessage(spellID)
    local mapID = SpellToMap and SpellToMap[spellID]
    if not mapID then return end
    local L = ns.L
    local link = C_Spell.GetSpellLink(spellID)
              or ("|cff71d5ff[" .. (C_Spell.GetSpellName(spellID) or "?") .. "]|r")
    local dungeonName = ns:GetDungeonName(mapID, false)
    local template = ns.db.profile.teleport.announceTemplate or L["TELEPORT_TEMPLATE_DEFAULT"]
    return (template:gsub("{spell}", link):gsub("{dungeon}", dungeonName))
end

function M:OnSpellCast(unit, spellID, castGUID)
    if unit ~= "player" then return end
    if not ns.db.profile.teleport.enabled then return end
    if not ShouldAnnounce() then return end
    -- Same cast can fire UNIT_SPELLCAST_START more than once (loading-screen
    -- edge cases, self-cast frame refreshes). Dedup by castGUID so a single
    -- cast only broadcasts once.
    if castGUID and castGUID == self._lastCastGUID then return end
    local msg = self:GenerateMessage(spellID)
    if not msg then return end
    self._lastCastGUID = castGUID
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SafeSendChatMessage(msg, "INSTANCE_CHAT")
    elseif IsInGroup() then
        SafeSendChatMessage(msg, "PARTY")
    end
end

function M:OnDBReady()
    BuildSpellToMap()
end

function M:OnPlayerLogin()
    TryInit()
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:RegisterEvent("LOADING_SCREEN_ENABLED")
    f:RegisterEvent("LOADING_SCREEN_DISABLED")
    f:RegisterEvent("UNIT_SPELLCAST_START")
    f:SetScript("OnEvent", function(_, event, arg1, castGUID, spellID)
        if event == "ADDON_LOADED" and arg1 == "Blizzard_ChallengesUI" then
            TryInit()
        elseif event == "LOADING_SCREEN_ENABLED" then
            M.isLoadingScreen = true
        elseif event == "LOADING_SCREEN_DISABLED" then
            M.isLoadingScreen = nil
        elseif event == "UNIT_SPELLCAST_START" then
            M:OnSpellCast(arg1, spellID, castGUID)
        end
    end)
end

function M:Refresh()
    CreateAll()
end
