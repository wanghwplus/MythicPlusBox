local addonName, ns = ...

-- ============================================================================
-- Current-season dungeon mapIDs (Midnight S1 as of ship date)
-- Weekly panel and Score overlay iterate over this list.
-- ============================================================================
ns.CurrentSeasonMapIDs = {
    239, 556, 161, 402, 557, 558, 560, 559,
}

ns.CurrentSeasonMapIDSet = {}
for _, mid in ipairs(ns.CurrentSeasonMapIDs) do
    ns.CurrentSeasonMapIDSet[mid] = true
end

-- ============================================================================
-- Weekly-vault ilvl per keystone level (index 1..10)
-- ============================================================================
ns.VaultItemLevels = { 256, 259, 259, 263, 263, 266, 269, 269, 269, 272 }

-- ============================================================================
-- Evergreen teleport-spell catalog (mapID -> array of spellIDs; first learned wins)
-- All expansions kept — teleport spells only accumulate over time.
-- ============================================================================
ns.DungeonTeleport = {
    -- Midnight
    [239] = {1254551}, [556] = {1254555}, [161] = {1254557}, [557] = {1254400},
    [558] = {1254572}, [560] = {1254559}, [559] = {1254563},
    -- Cataclysm
    [438] = {410080}, [456] = {424142}, [507] = {445424},
    -- Pandaria
    [2]={131204},[56]={131205},[57]={131225},[58]={131206},[59]={131228},
    [60]={131222},[76]={131232},[77]={131231},[78]={131229},
    -- Draenor
    [163]={159895},[164]={159897},[165]={159899},
    [166]={159900},[167]={159902},[168]={159901},[169]={159896},
    -- Legion
    [198]={424163},[199]={424153},[200]={393764},[206]={410078},
    [210]={393766},[227]={373262},[234]={373262},
    -- BfA
    [244]={424187},[245]={410071},[247]={467553,467555},
    [248]={424167},[251]={410074},[353]={445418,464256},[369]={373274},[370]={373274},
    -- Shadowlands
    [375]={354464},[376]={354462},[377]={354468},[378]={354465},
    [379]={354463},[380]={354469},[381]={354466},[382]={354467},
    [391]={367416},[392]={367416},
    -- Dragonflight
    [399]={393256},[400]={393262},[401]={393279},[402]={393273},
    [403]={393222},[404]={393276},[405]={393267},[406]={393283},
    [463]={424197},[464]={424197},
    -- The War Within
    [499]={445444},[500]={445443},[501]={445269},[502]={445416},
    [503]={445417},[504]={445441},[505]={445414},[506]={445440},
    [525]={1216786},[542]={1237215},
}

-- ============================================================================
-- Score-color tiers (used by Score overlay)
-- ============================================================================
ns.ScoreColorRanges = {
    { minScore = 455, index = 6 },
    { minScore = 410, index = 5 },
    { minScore = 380, index = 4 },
    { minScore = 320, index = 3 },
    { minScore = 230, index = 2 },
    { minScore = 155, index = 1 },
    { minScore = 0,   index = 0 },
}

-- ============================================================================
-- Dungeon-name helper: returns short abbreviation when useAbbreviation is on,
-- otherwise the localized full name from Blizzard's ChallengeMode API.
-- ============================================================================
function ns:GetDungeonName(mapID, useAbbreviation)
    local L = self.L
    if useAbbreviation and L then
        local key = "ABBR_" .. tostring(mapID)
        -- AceLocale returns the key itself when missing (with silent=true),
        -- so we test for a real translation by comparing lengths.
        local abbr = L[key]
        if abbr and abbr ~= key then return abbr end
    end
    if C_ChallengeMode and C_ChallengeMode.GetMapUIInfo then
        local name = C_ChallengeMode.GetMapUIInfo(mapID)
        if name then return name end
    end
    return (L and L["UNKNOWN"]) or "Unknown"
end
