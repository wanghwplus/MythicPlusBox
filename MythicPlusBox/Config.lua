local addonName, ns = ...

-- Every string here was, at some point, a locale's default teleport announce
-- template. If we see one of them saved in the profile we treat it as "user
-- never customised it" and drop it back to nil, so the runtime falls through
-- to the current locale's L["TELEPORT_TEMPLATE_DEFAULT"]. Add every new
-- locale's default string here, and never remove old entries.
ns.KNOWN_DEFAULT_TELEPORT_TEMPLATES = {
    ["Casting: {spell}, teleporting to: {dungeon}"] = true,   -- enUS
    ["正在施放: {spell},传送到: {dungeon}"]         = true,   -- zhCN
    ["正在施放: {spell},傳送到: {dungeon}"]         = true,   -- zhTW
}

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

    -- The teleport announce template stays nil in DB when the user hasn't
    -- customised it; Teleport.lua / Options.lua fall back to the current
    -- locale's L["TELEPORT_TEMPLATE_DEFAULT"] at read time. This is what
    -- lets the default text follow the WoW client language, instead of
    -- freezing whichever locale first initialised the profile.
    local tp = self.db.profile.teleport
    if type(tp.announceTemplate) == "string" then
        -- Strip legacy "[MPBox] " prefix.
        local cleaned = tp.announceTemplate:gsub("^%s*%[MPBox%]%s*", "")
        if cleaned ~= tp.announceTemplate then
            tp.announceTemplate = cleaned
        end
        -- Any historical default template (including old %s placeholders
        -- that the {spell}/{dungeon} substitutor never fills in) resets to
        -- nil so the locale fallback wins.
        if tp.announceTemplate:find("%%s") or ns.KNOWN_DEFAULT_TELEPORT_TEMPLATES[tp.announceTemplate] then
            tp.announceTemplate = nil
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
