local addonName, ns = ...

local defaults = {
    profile = {
        font = {
            name    = nil,
            size    = 14,
            outline = "OUTLINE",
        },
        score = {
            enabled         = true,
            useAbbreviation = true,
            overlay = {
                name  = { shown = true, x = 0, y = 22,  size = 16, font = nil },
                level = { shown = true, x = 0, y = 0,   size = 20, font = nil },
                score = { shown = true, x = 0, y = -22, size = 20, font = nil },
            },
        },
        weekly = {
            enabled        = true,
            useModifierKey = true,
            font = { name = nil, size = 14, rowSpacing = 4 },
            anchor = { point = "TOPLEFT", relativeTo = "PVEFrame", relativePoint = "TOPRIGHT", x = 3, y = -1 },
        },
        teleport = {
            enabled          = true,
            announceTemplate = nil,
        },
        keystoneList = {
            enabled     = true,
            locked      = true,
            rowSpacing  = 4,
            font        = { name = nil, size = 12 },
            anchor      = { point = "LEFT", relativeTo = "UIParent", relativePoint = "LEFT", x = 10, y = 200 },
        },
        centerBanner = {
            enabled    = true,
            locked     = true,
            rowSpacing = 6,
            font       = { name = nil, size = 18 },
            anchor     = { point = "TOP", relativeTo = "UIParent", relativePoint = "TOP", x = 0, y = -200 },
        },
        colors = {
            levelColors = {
                [0] = "ffffffff",
                [1] = "ff1eff00",
                [2] = "ff0070dd",
                [3] = "ffa335ee",
                [4] = "ffff8000",
                [5] = "ffe6cc80",
                [6] = "fff46fc8",
            },
            scoreColorRanges = {
                { minScore = 455, index = 6 },
                { minScore = 410, index = 5 },
                { minScore = 380, index = 4 },
                { minScore = 320, index = 3 },
                { minScore = 230, index = 2 },
                { minScore = 155, index = 1 },
                { minScore = 0,   index = 0 },
            },
        },
    },
    global = {
        minimap      = { hide = false },
        seenOptions  = false,
    },
}

function ns:InitializeDB()
    local AceDB = LibStub("AceDB-3.0")
    self.db = AceDB:New("MythicPlusBoxDB", defaults, true)

    self.db.RegisterCallback(self, "OnProfileChanged", function() self:RefreshAll() end)
    self.db.RegisterCallback(self, "OnProfileCopied",  function() self:RefreshAll() end)
    self.db.RegisterCallback(self, "OnProfileReset",   function() self:RefreshAll() end)

    local L = self.L
    if L then
        local tp = self.db.profile.teleport
        if tp.announceTemplate == nil then
            tp.announceTemplate = L["TELEPORT_TEMPLATE_DEFAULT"]
        elseif type(tp.announceTemplate) == "string" then
            -- One-shot migration: strip legacy "[MPBox] " prefix from saved templates.
            local cleaned = tp.announceTemplate:gsub("^%s*%[MPBox%]%s*", "")
            if cleaned ~= tp.announceTemplate then
                tp.announceTemplate = cleaned
            end
            -- One-shot migration: older defaults used %s placeholders that the
            -- runtime substitutor ({spell}/{dungeon}) never fills in. If the
            -- saved template still carries %s, replace it with the new default.
            if tp.announceTemplate:find("%%s") then
                tp.announceTemplate = L["TELEPORT_TEMPLATE_DEFAULT"]
            end
        end
    end

    -- One-shot migration: the bundled "MythicPlusBox" font has been removed.
    -- Clear it from any saved font.name field so LSM falls back cleanly.
    local prof = self.db.profile
    if prof.font and prof.font.name == "MythicPlusBox" then prof.font.name = nil end
    if prof.weekly and prof.weekly.font and prof.weekly.font.name == "MythicPlusBox" then
        prof.weekly.font.name = nil
    end
    if prof.keystoneList and prof.keystoneList.font and prof.keystoneList.font.name == "MythicPlusBox" then
        prof.keystoneList.font.name = nil
    end
    if prof.centerBanner and prof.centerBanner.font and prof.centerBanner.font.name == "MythicPlusBox" then
        prof.centerBanner.font.name = nil
    end
    if prof.score and prof.score.overlay then
        for _, sub in pairs(prof.score.overlay) do
            if sub.font == "MythicPlusBox" then sub.font = nil end
        end
    end
end

ns.defaults = defaults
