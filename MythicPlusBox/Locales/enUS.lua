local L = LibStub("AceLocale-3.0"):NewLocale("MythicPlusBox", "enUS", true, true)
if not L then return end

-- ============================================================================
-- UI (settings panel)
-- ============================================================================
L["ADDON_TITLE"]              = "MythicPlusBox"
L["TAB_GENERAL"]              = "General"
L["TAB_SCORE"]                = "Score Overlay"
L["TAB_WEEKLY"]               = "Weekly Panel"
L["TAB_TELEPORT"]             = "Teleport"
L["TAB_KEYSTONE"]             = "Keystone Panels"
L["TAB_PROFILES"]             = "Profiles"

L["OPT_ENABLED"]              = "Enabled"
L["OPT_LOCKED"]               = "Locked"
L["OPT_UNLOCK_FRAMES"]        = "Unlock frames (drag to reposition)"
L["OPT_FONT"]                 = "Font"
L["OPT_FONT_SIZE"]            = "Font size"
L["OPT_FONT_OUTLINE"]         = "Font outline"
L["OPT_ROW_SPACING"]          = "Row spacing"
L["OPT_MINIMAP_ICON"]         = "Show minimap icon"
L["OPT_USE_ABBREVIATION"]     = "Use short dungeon names (abbreviations)"
L["OPT_USE_MODIFIER"]         = "Hold Alt/Shift/Ctrl to switch weekly/season view"
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
L["OPT_CENTER_BANNER"]        = "In-dungeon center banner"
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
L["TELEPORT_TEMPLATE_DEFAULT"] = "[MPBox] Casting %s, teleporting to %s"
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
-- Current-season dungeon abbreviations (mapID -> short name)
-- Missing keys fall through to C_ChallengeMode.GetMapUIInfo full name.
-- ============================================================================
L["ABBR_239"]  = "Arc"       -- Court of Stars
L["ABBR_556"]  = "Mines"
L["ABBR_161"]  = "Skyreach"
L["ABBR_402"]  = "Aca"       -- Algeth'ar Academy
L["ABBR_557"]  = "Windrider"
L["ABBR_558"]  = "Terrace"
L["ABBR_560"]  = "Cave"
L["ABBR_559"]  = "Nexus"
