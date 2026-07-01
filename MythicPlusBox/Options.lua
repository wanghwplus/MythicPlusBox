local addonName, ns = ...

local AceGUI          = LibStub("AceGUI-3.0")
local AceConfig       = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions    = LibStub("AceDBOptions-3.0")
local LSM             = LibStub("LibSharedMedia-3.0")
local LibDualSpec     = LibStub("LibDualSpec-1.0", true)

local ANCHOR_POINTS = {
    "CENTER", "LEFT", "RIGHT", "TOP", "BOTTOM",
    "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT",
}
local OUTLINE_OPTIONS = { "NONE", "OUTLINE", "THICKOUTLINE", "MONOCHROME" }

-- ==========================================================================
-- Helper closures modelled on Stats.lua AddCheckbox/AddSlider/AddDropdown.
-- Each returns the AceGUI widget so callers can further tweak it.
-- ==========================================================================
local function AddSeparator(container, text)
    local heading = AceGUI:Create("Heading")
    heading:SetText(text or " ")
    heading:SetFullWidth(true)
    container:AddChild(heading)
    return heading
end

local function AddCheckbox(container, label, getValue, setValue)
    local w = AceGUI:Create("CheckBox")
    w:SetLabel(label)
    w:SetValue(getValue())
    w:SetCallback("OnValueChanged", function(_, _, val)
        setValue(val)
        ns:RefreshAll()
    end)
    container:AddChild(w)
    return w
end

local function AddSlider(container, label, minV, maxV, step, getValue, setValue)
    local w = AceGUI:Create("Slider")
    w:SetLabel(label)
    w:SetSliderValues(minV, maxV, step)
    w:SetValue(getValue())
    w:SetCallback("OnValueChanged", function(_, _, val)
        setValue(val)
        ns:RefreshAll()
    end)
    container:AddChild(w)
    return w
end

local function AddDropdown(container, label, values, order, getValue, setValue)
    local w = AceGUI:Create("Dropdown")
    w:SetLabel(label)
    w:SetList(values, order)
    w:SetValue(getValue())
    w:SetCallback("OnValueChanged", function(_, _, val)
        setValue(val)
        ns:RefreshAll()
    end)
    container:AddChild(w)
    return w
end

local function AddLSMFontDropdown(container, label, getValue, setValue)
    local fonts = LSM:HashTable("font")
    local order = {}
    for k in pairs(fonts) do table.insert(order, k) end
    table.sort(order)
    local w = AceGUI:Create("LSM30_Font")
    w:SetLabel(label)
    w:SetList(fonts, order)
    w:SetValue(getValue() or ns.BUNDLED_FONT_NAME)
    w:SetCallback("OnValueChanged", function(_, _, val)
        setValue(val)
        ns:RefreshAll()
    end)
    container:AddChild(w)
    return w
end

local function AddEditBox(container, label, multiline, getValue, setValue)
    local w = AceGUI:Create(multiline and "MultiLineEditBox" or "EditBox")
    w:SetLabel(label)
    w:SetText(getValue() or "")
    if multiline then w:SetNumLines(3) end
    w:SetFullWidth(true)
    w:SetCallback("OnEnterPressed", function(_, _, val)
        setValue(val)
        ns:RefreshAll()
    end)
    container:AddChild(w)
    return w
end

local function AddButton(container, label, onClick)
    local w = AceGUI:Create("Button")
    w:SetText(label)
    w:SetCallback("OnClick", onClick)
    container:AddChild(w)
    return w
end

local function AnchorValueTable(L)
    local values = {}
    for _, p in ipairs(ANCHOR_POINTS) do
        values[p] = L["ANCHOR_" .. p] or p
    end
    return values
end

local function OutlineValueTable(L)
    return {
        NONE         = L["OPT_OUTLINE_NONE"],
        OUTLINE      = L["OPT_OUTLINE_THIN"],
        THICKOUTLINE = L["OPT_OUTLINE_THICK"],
        MONOCHROME   = L["OPT_OUTLINE_MONOCHROME"],
    }
end

-- ==========================================================================
-- Position controls (anchor point + relativePoint + x/y sliders) reused
-- by Weekly, KeystoneList, CenterBanner tabs.
-- ==========================================================================
local function AddPositionControls(container, L, getAnchor)
    AddSeparator(container, L["OPT_ANCHOR_POINT"])
    local anchorValues = AnchorValueTable(L)

    AddDropdown(container, L["OPT_ANCHOR_POINT"], anchorValues, ANCHOR_POINTS,
        function() return getAnchor().point end,
        function(v) getAnchor().point = v end)

    AddDropdown(container, "Relative point", anchorValues, ANCHOR_POINTS,
        function() return getAnchor().relativePoint end,
        function(v) getAnchor().relativePoint = v end)

    AddSlider(container, L["OPT_X_OFFSET"], -800, 800, 1,
        function() return getAnchor().x end,
        function(v) getAnchor().x = v end)

    AddSlider(container, L["OPT_Y_OFFSET"], -600, 600, 1,
        function() return getAnchor().y end,
        function(v) getAnchor().y = v end)
end

-- ==========================================================================
-- Tab draw functions
-- ==========================================================================
local function DrawGeneralTab(container)
    local L, db = ns.L, ns.db.profile
    AddSeparator(container, L["TAB_GENERAL"])

    AddLSMFontDropdown(container, L["OPT_FONT"],
        function() return db.font.name end,
        function(v) db.font.name = v end)

    AddSlider(container, L["OPT_FONT_SIZE"], 8, 32, 1,
        function() return db.font.size end,
        function(v) db.font.size = v end)

    AddDropdown(container, L["OPT_FONT_OUTLINE"], OutlineValueTable(L), OUTLINE_OPTIONS,
        function() return db.font.outline end,
        function(v) db.font.outline = v end)

    AddCheckbox(container, L["OPT_MINIMAP_ICON"],
        function() return not ns.db.global.minimap.hide end,
        function(v)
            ns.db.global.minimap.hide = not v
            local icon = LibStub("LibDBIcon-1.0", true)
            if icon then
                if v then icon:Show(addonName) else icon:Hide(addonName) end
            end
        end)

    AddCheckbox(container, L["OPT_USE_ABBREVIATION"],
        function() return db.score.useAbbreviation end,
        function(v) db.score.useAbbreviation = v end)
end

local function DrawScoreTab(container)
    local L, db = ns.L, ns.db.profile
    AddSeparator(container, L["TAB_SCORE"])

    AddCheckbox(container, L["OPT_ENABLED"],
        function() return db.score.enabled end,
        function(v) db.score.enabled = v end)

    for _, key in ipairs({ "name", "level", "score" }) do
        AddSeparator(container, key)
        local cfg = db.score.overlay[key]
        AddCheckbox(container, "Show " .. key,
            function() return cfg.shown end,
            function(v) cfg.shown = v end)
        AddSlider(container, L["OPT_FONT_SIZE"], 8, 32, 1,
            function() return cfg.size end,
            function(v) cfg.size = v end)
        AddSlider(container, L["OPT_X_OFFSET"], -80, 80, 1,
            function() return cfg.x end,
            function(v) cfg.x = v end)
        AddSlider(container, L["OPT_Y_OFFSET"], -80, 80, 1,
            function() return cfg.y end,
            function(v) cfg.y = v end)
    end
end

local function DrawWeeklyTab(container)
    local L, db = ns.L, ns.db.profile
    AddSeparator(container, L["TAB_WEEKLY"])

    AddCheckbox(container, L["OPT_ENABLED"],
        function() return db.weekly.enabled end,
        function(v) db.weekly.enabled = v end)

    AddCheckbox(container, L["OPT_USE_MODIFIER"],
        function() return db.weekly.useModifierKey end,
        function(v) db.weekly.useModifierKey = v end)

    AddLSMFontDropdown(container, L["OPT_FONT"],
        function() return db.weekly.font.name end,
        function(v) db.weekly.font.name = v end)

    AddSlider(container, L["OPT_FONT_SIZE"], 8, 32, 1,
        function() return db.weekly.font.size end,
        function(v) db.weekly.font.size = v end)

    AddSlider(container, L["OPT_ROW_SPACING"], 0, 20, 1,
        function() return db.weekly.font.rowSpacing end,
        function(v) db.weekly.font.rowSpacing = v end)

    AddPositionControls(container, L, function() return db.weekly.anchor end)
end

local function DrawTeleportTab(container)
    local L, db = ns.L, ns.db.profile
    AddSeparator(container, L["TAB_TELEPORT"])

    AddCheckbox(container, L["OPT_ENABLED"],
        function() return db.teleport.enabled end,
        function(v) db.teleport.enabled = v end)

    AddCheckbox(container, L["OPT_ANNOUNCE_ENABLED"],
        function() return db.teleport.announceEnabled end,
        function(v) db.teleport.announceEnabled = v end)

    AddEditBox(container, L["OPT_ANNOUNCE_TEMPLATE"], true,
        function() return db.teleport.announceTemplate end,
        function(v) db.teleport.announceTemplate = v end)

    local help = AceGUI:Create("Label")
    help:SetText(L["OPT_ANNOUNCE_HELP"])
    help:SetFullWidth(true)
    container:AddChild(help)

    AddButton(container, L["OPT_RESET"], function()
        db.teleport.announceTemplate = L["TELEPORT_TEMPLATE_DEFAULT"]
        ns:OpenOptions()
    end)
end

local function DrawKeystoneTab(container)
    local L, db = ns.L, ns.db.profile
    AddSeparator(container, L["TAB_KEYSTONE"])

    AddCheckbox(container, L["OPT_UNLOCK_FRAMES"],
        function() return (not db.keystoneList.locked) or (not db.centerBanner.locked) end,
        function(v)
            db.keystoneList.locked = not v
            db.centerBanner.locked = not v
        end)

    AddSeparator(container, L["OPT_KEYSTONE_LIST"])

    AddCheckbox(container, L["OPT_ENABLED"],
        function() return db.keystoneList.enabled end,
        function(v) db.keystoneList.enabled = v end)

    AddCheckbox(container, L["OPT_SHOW_OFFLINE"],
        function() return db.keystoneList.showOffline end,
        function(v) db.keystoneList.showOffline = v end)

    AddLSMFontDropdown(container, L["OPT_FONT"],
        function() return db.keystoneList.font.name end,
        function(v) db.keystoneList.font.name = v end)

    AddSlider(container, L["OPT_FONT_SIZE"], 8, 32, 1,
        function() return db.keystoneList.font.size end,
        function(v) db.keystoneList.font.size = v end)

    AddSlider(container, L["OPT_ROW_SPACING"], 0, 20, 1,
        function() return db.keystoneList.rowSpacing end,
        function(v) db.keystoneList.rowSpacing = v end)

    AddPositionControls(container, L, function() return db.keystoneList.anchor end)

    AddSeparator(container, L["OPT_CENTER_BANNER"])

    AddCheckbox(container, L["OPT_ENABLED"],
        function() return db.centerBanner.enabled end,
        function(v) db.centerBanner.enabled = v end)

    AddLSMFontDropdown(container, L["OPT_FONT"],
        function() return db.centerBanner.font.name end,
        function(v) db.centerBanner.font.name = v end)

    AddSlider(container, L["OPT_FONT_SIZE"], 10, 48, 1,
        function() return db.centerBanner.font.size end,
        function(v) db.centerBanner.font.size = v end)

    AddSlider(container, L["OPT_BANNER_DURATION"], 2, 30, 1,
        function() return db.centerBanner.duration end,
        function(v) db.centerBanner.duration = v end)

    AddPositionControls(container, L, function() return db.centerBanner.anchor end)
end

-- ==========================================================================
-- Profiles tab: uses AceDBOptions + AceConfigDialog embedded.
-- ==========================================================================
local function RegisterProfileOptions()
    if ns._profileOptionsRegistered then return end
    ns._profileOptionsRegistered = true
    local profileOpts = AceDBOptions:GetOptionsTable(ns.db)
    if LibDualSpec then LibDualSpec:EnhanceOptions(profileOpts, ns.db) end
    AceConfig:RegisterOptionsTable("MythicPlusBox_Profiles", profileOpts)
end

-- ==========================================================================
-- Top-level frame builder.
-- ==========================================================================
local function BuildTabContent(container, group)
    container:ReleaseChildren()
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    container:AddChild(scroll)

    if group == "general"  then DrawGeneralTab(scroll)
    elseif group == "score"    then DrawScoreTab(scroll)
    elseif group == "weekly"   then DrawWeeklyTab(scroll)
    elseif group == "teleport" then DrawTeleportTab(scroll)
    elseif group == "keystone" then DrawKeystoneTab(scroll)
    elseif group == "profiles" then
        container:ReleaseChildren()
        RegisterProfileOptions()
        AceConfigDialog:Open("MythicPlusBox_Profiles", container)
    end
end

function ns:OpenOptions()
    local L = self.L
    if self._optionsFrame then
        self._optionsFrame:Show()
        return
    end

    local f = AceGUI:Create("Frame")
    f:SetTitle(L["ADDON_TITLE"])
    f:SetStatusText("v" .. ns.version)
    f:SetLayout("Fill")
    f:SetWidth(800)
    f:SetHeight(600)
    f:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        ns._optionsFrame = nil
    end)
    self._optionsFrame = f

    local tab = AceGUI:Create("TabGroup")
    tab:SetLayout("Flow")
    tab:SetFullWidth(true)
    tab:SetFullHeight(true)
    tab:SetTabs({
        { text = L["TAB_GENERAL"],  value = "general"  },
        { text = L["TAB_SCORE"],    value = "score"    },
        { text = L["TAB_WEEKLY"],   value = "weekly"   },
        { text = L["TAB_TELEPORT"], value = "teleport" },
        { text = L["TAB_KEYSTONE"], value = "keystone" },
        { text = L["TAB_PROFILES"], value = "profiles" },
    })
    tab:SetCallback("OnGroupSelected", function(container, _, group)
        BuildTabContent(container, group)
    end)
    tab:SelectTab("general")
    f:AddChild(tab)
end

-- ==========================================================================
-- Blizzard interface-options entry so the panel can be opened from the ESC menu.
-- ==========================================================================
local function RegisterBlizzardCategory()
    local L = ns.L
    local blizzOpt = CreateFrame("Frame")
    blizzOpt.name = L["ADDON_TITLE"]

    local title = blizzOpt:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(L["ADDON_TITLE"])

    local hint = blizzOpt:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    hint:SetText("/mpb")

    local button = CreateFrame("Button", nil, blizzOpt, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -16)
    button:SetSize(180, 22)
    button:SetText(L["ADDON_TITLE"] .. "  /mpb")
    button:SetScript("OnClick", function()
        HideUIPanel(SettingsPanel or InterfaceOptionsFrame)
        HideUIPanel(GameMenuFrame)
        ns:OpenOptions()
    end)

    if _G.Settings and _G.Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(blizzOpt, L["ADDON_TITLE"])
        category.ID = L["ADDON_TITLE"]
        Settings.RegisterAddOnCategory(category)
    elseif _G.InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(blizzOpt)
    end
end

local login = CreateFrame("Frame")
login:RegisterEvent("PLAYER_LOGIN")
login:SetScript("OnEvent", function()
    RegisterBlizzardCategory()
end)
