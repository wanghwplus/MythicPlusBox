local addonName, ns = ...

local AceGUI          = LibStub("AceGUI-3.0")
local AceConfig       = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions    = LibStub("AceDBOptions-3.0")
local LSM             = LibStub("LibSharedMedia-3.0")

local ANCHOR_POINTS = {
    "CENTER", "LEFT", "RIGHT", "TOP", "BOTTOM",
    "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT",
}

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

local function AddLSMFontDropdown(container, label, getValue, setValue, relativeWidth)
    local fonts = LSM:HashTable("font")
    local order = {}
    for k in pairs(fonts) do table.insert(order, k) end
    table.sort(order)
    local w = AceGUI:Create("LSM30_Font")
    w:SetLabel(label)
    w:SetList(fonts, order)
    w:SetValue(getValue() or LSM:GetDefault("font"))
    if relativeWidth then w:SetRelativeWidth(relativeWidth) end
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

-- Font + Size + RowSpacing on a single row shared by the panel modules.
local function AddFontRow(container, L, cfgFont, spacingGetter, spacingSetter)
    local row = AceGUI:Create("SimpleGroup")
    row:SetFullWidth(true)
    row:SetLayout("Flow")
    container:AddChild(row)

    local fonts = LSM:HashTable("font")
    local order = {}
    for k in pairs(fonts) do table.insert(order, k) end
    table.sort(order)
    local fd = AceGUI:Create("LSM30_Font")
    fd:SetLabel(L["OPT_FONT"])
    fd:SetList(fonts, order)
    fd:SetValue(cfgFont.name or LSM:GetDefault("font"))
    fd:SetRelativeWidth(0.2)
    fd:SetCallback("OnValueChanged", function(_, _, v)
        cfgFont.name = v
        ns:RefreshAll()
    end)
    row:AddChild(fd)

    local ss = AceGUI:Create("Slider")
    ss:SetLabel(L["OPT_FONT_SIZE"])
    ss:SetSliderValues(8, 32, 1)
    ss:SetValue(cfgFont.size or 12)
    ss:SetRelativeWidth(0.4)
    ss:SetCallback("OnValueChanged", function(_, _, v)
        cfgFont.size = v
        ns:RefreshAll()
    end)
    row:AddChild(ss)

    if spacingGetter then
        local rs = AceGUI:Create("Slider")
        rs:SetLabel(L["OPT_ROW_SPACING"])
        rs:SetSliderValues(0, 20, 1)
        rs:SetValue(spacingGetter() or 4)
        rs:SetRelativeWidth(0.4)
        rs:SetCallback("OnValueChanged", function(_, _, v)
            spacingSetter(v)
            ns:RefreshAll()
        end)
        row:AddChild(rs)
    end
end

-- ==========================================================================
-- Position controls (anchor point + relativePoint + x/y sliders) reused
-- by Weekly, KeystoneList, CenterBanner tabs. x/y share one row.
-- ==========================================================================
local function AddPositionControls(container, L, getAnchor)
    AddSeparator(container, L["OPT_ANCHOR_POINT"])
    local anchorValues = AnchorValueTable(L)

    AddDropdown(container, L["OPT_ANCHOR_POINT"], anchorValues, ANCHOR_POINTS,
        function() return getAnchor().point end,
        function(v) getAnchor().point = v end)

    AddDropdown(container, L["OPT_RELATIVE_POINT"], anchorValues, ANCHOR_POINTS,
        function() return getAnchor().relativePoint end,
        function(v) getAnchor().relativePoint = v end)

    local row = AceGUI:Create("SimpleGroup")
    row:SetFullWidth(true)
    row:SetLayout("Flow")
    container:AddChild(row)

    local xs = AceGUI:Create("Slider")
    xs:SetLabel(L["OPT_X_OFFSET"])
    xs:SetSliderValues(-800, 800, 1)
    xs:SetValue(getAnchor().x)
    xs:SetRelativeWidth(0.5)
    xs:SetCallback("OnValueChanged", function(_, _, v)
        getAnchor().x = v
        ns:RefreshAll()
    end)
    row:AddChild(xs)

    local ys = AceGUI:Create("Slider")
    ys:SetLabel(L["OPT_Y_OFFSET"])
    ys:SetSliderValues(-600, 600, 1)
    ys:SetValue(getAnchor().y)
    ys:SetRelativeWidth(0.5)
    ys:SetCallback("OnValueChanged", function(_, _, v)
        getAnchor().y = v
        ns:RefreshAll()
    end)
    row:AddChild(ys)
end

-- ==========================================================================
-- Tab draw functions
-- ==========================================================================
local function DrawGeneralTab(container)
    local L, db = ns.L, ns.db.profile
    AddSeparator(container, L["TAB_GENERAL"])

    AddCheckbox(container, L["OPT_MINIMAP_ICON"],
        function() return not ns.db.global.minimap.hide end,
        function(v)
            ns.db.global.minimap.hide = not v
            if ns.SetupMinimapIcon then ns:SetupMinimapIcon() end
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

    local labels = {
        name  = { section = L["OPT_SCORE_NAME"],  toggle = L["OPT_SCORE_SHOW_NAME"]  },
        level = { section = L["OPT_SCORE_LEVEL"], toggle = L["OPT_SCORE_SHOW_LEVEL"] },
        score = { section = L["OPT_SCORE_SCORE"], toggle = L["OPT_SCORE_SHOW_SCORE"] },
    }
    for _, key in ipairs({ "name", "level", "score" }) do
        AddSeparator(container, labels[key].section)
        local cfg = db.score.overlay[key]
        AddCheckbox(container, labels[key].toggle,
            function() return cfg.shown end,
            function(v) cfg.shown = v end)
        AddSeparator(container, " ")

        -- Font dropdown + Font size share one row.
        local fontRow = AceGUI:Create("SimpleGroup")
        fontRow:SetFullWidth(true)
        fontRow:SetLayout("Flow")
        container:AddChild(fontRow)
        AddLSMFontDropdown(fontRow, L["OPT_FONT"],
            function() return cfg.font end,
            function(v) cfg.font = v end, 0.5)
        local sz = AceGUI:Create("Slider")
        sz:SetLabel(L["OPT_FONT_SIZE"])
        sz:SetSliderValues(8, 32, 1)
        sz:SetValue(cfg.size)
        sz:SetRelativeWidth(0.5)
        sz:SetCallback("OnValueChanged", function(_, _, v)
            cfg.size = v
            ns:RefreshAll()
        end)
        fontRow:AddChild(sz)

        -- X / Y offsets share one row.
        local offsetRow = AceGUI:Create("SimpleGroup")
        offsetRow:SetFullWidth(true)
        offsetRow:SetLayout("Flow")
        container:AddChild(offsetRow)
        local xs = AceGUI:Create("Slider")
        xs:SetLabel(L["OPT_X_OFFSET"])
        xs:SetSliderValues(-80, 80, 1)
        xs:SetValue(cfg.x)
        xs:SetRelativeWidth(0.5)
        xs:SetCallback("OnValueChanged", function(_, _, v)
            cfg.x = v
            ns:RefreshAll()
        end)
        offsetRow:AddChild(xs)
        local ys = AceGUI:Create("Slider")
        ys:SetLabel(L["OPT_Y_OFFSET"])
        ys:SetSliderValues(-80, 80, 1)
        ys:SetValue(cfg.y)
        ys:SetRelativeWidth(0.5)
        ys:SetCallback("OnValueChanged", function(_, _, v)
            cfg.y = v
            ns:RefreshAll()
        end)
        offsetRow:AddChild(ys)
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

    AddSeparator(container, " ")

    AddLSMFontDropdown(container, L["OPT_FONT"],
        function() return db.weekly.font.name end,
        function(v) db.weekly.font.name = v end, 2 / 3)

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

    AddSeparator(container, L["OPT_KEYSTONE_LIST"])

    AddCheckbox(container, L["OPT_ENABLED"],
        function() return db.keystoneList.enabled end,
        function(v) db.keystoneList.enabled = v end)

    AddCheckbox(container, L["OPT_LOCKED"],
        function() return db.keystoneList.locked end,
        function(v) db.keystoneList.locked = v end)

    AddFontRow(container, L, db.keystoneList.font,
        function() return db.keystoneList.rowSpacing end,
        function(v) db.keystoneList.rowSpacing = v end)

    AddPositionControls(container, L, function() return db.keystoneList.anchor end)

    AddSeparator(container, L["OPT_CENTER_BANNER"])

    AddCheckbox(container, L["OPT_ENABLED"],
        function() return db.centerBanner.enabled end,
        function(v) db.centerBanner.enabled = v end)

    AddCheckbox(container, L["OPT_LOCKED"],
        function() return db.centerBanner.locked end,
        function(v) db.centerBanner.locked = v end)

    AddFontRow(container, L, db.centerBanner.font,
        function() return db.centerBanner.rowSpacing end,
        function(v) db.centerBanner.rowSpacing = v end)

    AddPositionControls(container, L, function() return db.centerBanner.anchor end)
end

-- ==========================================================================
-- Profiles tab: uses AceDBOptions + AceConfigDialog embedded.
-- ==========================================================================
local function RegisterProfileOptions()
    if ns._profileOptionsRegistered then return end
    ns._profileOptionsRegistered = true
    local profileOpts = AceDBOptions:GetOptionsTable(ns.db)
    AceConfig:RegisterOptionsTable("MythicPlusBox_Profiles", profileOpts)
end

-- ==========================================================================
-- Top-level frame builder.
-- ==========================================================================
local function BuildTabContent(container, group)
    container:ReleaseChildren()
    -- ScrollFrame is the sole child so a Fill-layout parent gives it a bounded
    -- height, which is what lets it actually scroll when the content overflows.
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
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
        -- Frames unlocked to reposition should not stay unlocked after the
        -- options window closes — otherwise a stray click drags them again.
        ns.db.profile.keystoneList.locked = true
        ns.db.profile.centerBanner.locked = true
        ns:RefreshAll()
        AceGUI:Release(widget)
        ns._optionsFrame = nil
    end)
    self._optionsFrame = f

    local tab = AceGUI:Create("TabGroup")
    tab:SetLayout("Fill")
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
