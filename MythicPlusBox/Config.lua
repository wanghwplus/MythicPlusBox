local addonName, ns = ...

local defaults = {
    profile = {
        font = {
            name    = "MythicPlusBox",
            size    = 14,
            outline = "OUTLINE",
        },
        score = {
            enabled         = true,
            useAbbreviation = true,
            overlay = {
                name  = { shown = true, x = 0, y = 22,  size = 12 },
                level = { shown = true, x = 0, y = 0,   size = 20 },
                score = { shown = true, x = 0, y = -22, size = 12 },
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
            announceEnabled  = false,
            announceTemplate = nil,
        },
        keystoneList = {
            enabled     = true,
            locked      = true,
            showOffline = false,
            rowSpacing  = 4,
            font        = { name = nil, size = 12 },
            anchor      = { point = "LEFT", relativeTo = "UIParent", relativePoint = "LEFT", x = 20, y = 0 },
        },
        centerBanner = {
            enabled  = true,
            locked   = true,
            duration = 8,
            font     = { name = nil, size = 22 },
            anchor   = { point = "CENTER", relativeTo = "UIParent", relativePoint = "CENTER", x = 0, y = 200 },
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

    local LibDualSpec = LibStub("LibDualSpec-1.0", true)
    if LibDualSpec then LibDualSpec:EnhanceDatabase(self.db, addonName) end

    self.db.RegisterCallback(self, "OnProfileChanged", function() self:RefreshAll() end)
    self.db.RegisterCallback(self, "OnProfileCopied",  function() self:RefreshAll() end)
    self.db.RegisterCallback(self, "OnProfileReset",   function() self:RefreshAll() end)

    local L = self.L
    if L then
        if self.db.profile.teleport.announceTemplate == nil then
            self.db.profile.teleport.announceTemplate = L["TELEPORT_TEMPLATE_DEFAULT"]
        end
    end
end

ns.defaults = defaults
