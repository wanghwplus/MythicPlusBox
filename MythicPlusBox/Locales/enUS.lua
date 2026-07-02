local L = LibStub("AceLocale-3.0"):NewLocale("MythicPlusBox", "enUS", true, true)
if not L then return end

-- ============================================================================
-- UI (settings panel)
-- ============================================================================
L["ADDON_TITLE"]              = "MythicPlusBox"
L["TAB_GENERAL"]              = "General"
L["TAB_SCORE"]                = "Score Overlay"
L["TAB_WEEKLY"]               = "Stats Panel"
L["TAB_TELEPORT"]             = "Teleport"
L["TAB_KEYSTONE"]             = "Keystone Panels"
L["TAB_PROFILES"]             = "Profiles"

L["OPT_SCORE_NAME"]           = "Dungeon Name"
L["OPT_SCORE_LEVEL"]          = "Best Level"
L["OPT_SCORE_SCORE"]          = "Score"
L["OPT_SCORE_SHOW_NAME"]      = "Show dungeon name"
L["OPT_SCORE_SHOW_LEVEL"]     = "Show best level"
L["OPT_SCORE_SHOW_SCORE"]     = "Show score"
L["OPT_RELATIVE_POINT"]       = "Relative point"

L["OPT_ENABLED"]              = "Enabled"
L["OPT_LOCKED"]               = "Locked"
L["OPT_UNLOCK_FRAMES"]        = "Unlock (drag to move this panel)"
L["OPT_FONT"]                 = "Font"
L["OPT_FONT_SIZE"]            = "Font size"
L["OPT_FONT_OUTLINE"]         = "Font outline"
L["OPT_ROW_SPACING"]          = "Row spacing"
L["OPT_MINIMAP_ICON"]         = "Show minimap icon"
L["OPT_USE_ABBREVIATION"]     = "Use short dungeon names (abbreviations)"
L["OPT_USE_MODIFIER"]         = "Hold Shift to switch weekly/season view"
L["OPT_ANNOUNCE_ENABLED"]     = "Announce teleport spell to party/instance"
L["OPT_ANNOUNCE_TEMPLATE"]    = "Announce template"
L["OPT_ANNOUNCE_HELP"]        = "Placeholders: {spell} = spell link, {dungeon} = dungeon name"
L["OPT_RESET"]                = "Reset to default"
L["OPT_ANCHOR_POINT"]         = "Anchor point"
L["OPT_X_OFFSET"]             = "X offset"
L["OPT_Y_OFFSET"]             = "Y offset"
L["OPT_BANNER_DURATION"]      = "Banner display duration (seconds)"
L["OPT_SHOW_OFFLINE"]         = "Include members with no keystone"
L["OPT_KEYSTONE_LIST"]        = "Party keystone list"
L["OPT_CENTER_BANNER"]        = "Keystone owners"
L["OPT_OUTLINE_NONE"]         = "None"
L["OPT_OUTLINE_THIN"]         = "Thin"
L["OPT_OUTLINE_THICK"]        = "Thick"
L["OPT_OUTLINE_MONOCHROME"]   = "Monochrome"

L["ANCHOR_CENTER"]            = "CENTER"
L["ANCHOR_LEFT"]              = "LEFT"
L["ANCHOR_RIGHT"]             = "RIGHT"
L["ANCHOR_TOP"]               = "TOP"
L["ANCHOR_BOTTOM"]            = "BOTTOM"
L["ANCHOR_TOPLEFT"]           = "TOPLEFT"
L["ANCHOR_TOPRIGHT"]          = "TOPRIGHT"
L["ANCHOR_BOTTOMLEFT"]        = "BOTTOMLEFT"
L["ANCHOR_BOTTOMRIGHT"]       = "BOTTOMRIGHT"

-- ============================================================================
-- Weekly panel
-- ============================================================================
L["WEEKLY_BEST_HEADER"]       = "Weekly Best"
L["SEASON_RECORD_HEADER"]     = "Season Record"
L["COMPLETION_COUNT_LABEL"]   = "Runs:"
L["NO_WEEKLY_RECORD"]         = "No weekly runs"
L["NO_SEASON_RECORD"]         = "No season runs"
L["NO_RECORD"]                = "No records"
L["ITEM_LEVEL"]               = "ilvl"

-- ============================================================================
-- Teleport
-- ============================================================================
L["TELEPORT_TEMPLATE_DEFAULT"] = "Casting %s, teleporting to %s"
L["TELEPORT_TOOLTIP_TITLE"]    = "Teleport to dungeon"
L["TELEPORT_UNKNOWN_COOLDOWN"] = "Unknown cooldown"
L["TELEPORT_READY"]            = "Ready"
L["TELEPORT_NOT_LEARNED"]      = "Not learned"
L["TELEPORT_UNKNOWN_DUNGEON"]  = "Unknown dungeon"

-- ============================================================================
-- Keystone
-- ============================================================================
L["KEYSTONE_LIST_HEADER"]      = "Party Keystones"
L["KEYSTONE_NONE"]             = "No keystone"
L["KEYSTONE_BANNER_FORMAT"]    = "%s's Keystone: %s +%d"
L["KEYSTONE_NO_PARTY"]         = "Not in a group"

-- ============================================================================
-- Errors / misc
-- ============================================================================
L["ERROR_NO_CHALLENGES_UI"]    = "Blizzard_ChallengesUI failed to load"
L["ERROR_NO_LIBOPENRAID"]      = "LibOpenRaid not available - party keystones will not sync"
L["UNKNOWN"]                   = "Unknown"

-- ============================================================================
-- Dungeon abbreviations (mapID -> short name)
-- Sourced from SavedInstances' KeystoneAbbrev table. Missing keys fall
-- through to C_ChallengeMode.GetMapUIInfo full name at runtime.
-- ============================================================================
-- WotLK
L["ABBR_556"]  = "POS"        -- Pit of Saron
-- Cataclysm
L["ABBR_438"]  = "VP"         -- The Vortex Pinnacle
L["ABBR_456"]  = "TOTT"       -- Throne of the Tides
L["ABBR_507"]  = "GB"         -- Grim Batol
-- Mists of Pandaria
L["ABBR_2"]    = "TJS"        -- Temple of the Jade Serpent
-- Warlords of Draenor
L["ABBR_161"]  = "SR"         -- Skyreach
L["ABBR_165"]  = "SBG"        -- Shadowmoon Burial Grounds
L["ABBR_166"]  = "GD"         -- Grimrail Depot
L["ABBR_168"]  = "EB"         -- Everbloom
L["ABBR_169"]  = "ID"         -- Iron Docks
-- Legion
L["ABBR_197"]  = "EOA"        -- Eye of Azshara
L["ABBR_198"]  = "DHT"        -- Darkheart Thicket
L["ABBR_199"]  = "BRH"        -- Black Rook Hold
L["ABBR_200"]  = "HOV"        -- Halls of Valor
L["ABBR_206"]  = "NL"         -- Neltharion's Lair
L["ABBR_207"]  = "VOTW"       -- Vault of the Wardens
L["ABBR_208"]  = "MOS"        -- Maw of Souls
L["ABBR_209"]  = "ARC"        -- The Arcway
L["ABBR_210"]  = "COS"        -- Court of Stars
L["ABBR_227"]  = "LOWR"       -- Return to Karazhan: Lower
L["ABBR_233"]  = "COEN"       -- Cathedral of Eternal Night
L["ABBR_234"]  = "UPPR"       -- Return to Karazhan: Upper
L["ABBR_239"]  = "SEAT"       -- Seat of the Triumvirate
-- Battle for Azeroth
L["ABBR_244"]  = "AD"         -- Atal'Dazar
L["ABBR_245"]  = "FH"         -- Freehold
L["ABBR_246"]  = "TD"         -- Tol Dagor
L["ABBR_247"]  = "ML"         -- The MOTHERLODE!!
L["ABBR_248"]  = "WM"         -- Waycrest Manor
L["ABBR_249"]  = "KR"         -- Kings' Rest
L["ABBR_250"]  = "TOS"        -- Temple of Sethraliss
L["ABBR_251"]  = "UNDR"       -- The Underrot
L["ABBR_252"]  = "SOTS"       -- Shrine of the Storm
L["ABBR_353"]  = "SIEGE"      -- Siege of Boralus
L["ABBR_369"]  = "YARD"       -- Operation: Mechagon - Junkyard
L["ABBR_370"]  = "WORK"       -- Operation: Mechagon - Workshop
-- Shadowlands
L["ABBR_375"]  = "MISTS"      -- Mists of Tirna Scithe
L["ABBR_376"]  = "NW"         -- The Necrotic Wake
L["ABBR_377"]  = "DOS"        -- De Other Side
L["ABBR_378"]  = "HOA"        -- Halls of Atonement
L["ABBR_379"]  = "PF"         -- Plaguefall
L["ABBR_380"]  = "SD"         -- Sanguine Depths
L["ABBR_381"]  = "SOA"        -- Spires of Ascension
L["ABBR_382"]  = "TOP"        -- Theater of Pain
L["ABBR_391"]  = "STRT"       -- Tazavesh: Streets of Wonder
L["ABBR_392"]  = "GMBT"       -- Tazavesh: So'leah's Gambit
-- Dragonflight
L["ABBR_399"]  = "RLP"        -- Ruby Life Pools
L["ABBR_400"]  = "TNO"        -- The Nokhud Offensive
L["ABBR_401"]  = "TAV"        -- The Azure Vault
L["ABBR_402"]  = "AA"         -- Algeth'ar Academy
L["ABBR_403"]  = "ULD"        -- Uldaman: Legacy of Tyr
L["ABBR_404"]  = "NELT"       -- Neltharus
L["ABBR_405"]  = "BH"         -- Brackenhide Hollow
L["ABBR_406"]  = "HOI"        -- Halls of Infusion
L["ABBR_463"]  = "FALL"       -- Dawn of the Infinite: Galakrond's Fall
L["ABBR_464"]  = "RISE"       -- Dawn of the Infinite: Murozond's Rise
-- The War Within
L["ABBR_499"]  = "PSF"        -- Priory of the Sacred Flame
L["ABBR_500"]  = "ROOK"       -- The Rookery
L["ABBR_501"]  = "SV"         -- The Stonevault
L["ABBR_502"]  = "COT"        -- City of Threads
L["ABBR_503"]  = "ARAK"       -- Ara-Kara, City of Echoes
L["ABBR_504"]  = "DFC"        -- Darkflame Cleft
L["ABBR_505"]  = "DAWN"       -- The Dawnbreaker
L["ABBR_506"]  = "BREW"       -- Cinderbrew Meadery
L["ABBR_525"]  = "FLOOD"      -- Operation: Floodgate
L["ABBR_542"]  = "EDA"        -- Eco-Dome Al'dani
-- Midnight
L["ABBR_557"]  = "WS"         -- Windrunner Spire
L["ABBR_558"]  = "MT"         -- Magisters' Terrace
L["ABBR_559"]  = "NPX"        -- Nexus-Point Xenas
L["ABBR_560"]  = "MC"         -- Maisara Caverns
