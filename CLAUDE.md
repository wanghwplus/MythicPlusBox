# MythicPlusBox — Project Guide for Claude

This document orients Claude (and any human collaborator) to the codebase, the
conventions it follows, and the workflows it expects. Keep it in sync with the
code — if you change how things work, update this file in the same PR.

## What the addon does

MythicPlusBox is a Retail World of Warcraft addon that bundles four
Mythic+-focused features into one shippable folder:

1. **Score overlay** — writes dungeon name, best level and season score onto
   each Blizzard dungeon icon (`ChallengesFrame.DungeonIcons`).
2. **Weekly / season panel** — a small frame beside the Group Finder that shows
   the current week's or full season's Mythic+ runs.
3. **Teleport buttons + announce** — secure buttons overlayed on each dungeon
   icon, plus an optional chat announcement when the teleport spell casts.
4. **Party keystone tracker** — a left-side list of every party member's
   keystone, and a center-of-screen banner when a run starts.

All four are driven by a single AceDB profile and exposed through one
AceGUI-based settings panel.

## Directory layout

```
MythicPlusBox/                         ← git repo root
├── .gitignore                         zMPlus/ Stats/ Details/ MPBox-v*.zip
├── README.md
├── CHANGELOG.md
├── CLAUDE.md                          ← you are here
├── release.sh                         bash script → MPBox-v<VER>.zip
├── .claude/commands/release.md        Claude command that drives releases
├── zMPlus/  Stats/  Details/          reference addons (git-ignored)
└── MythicPlusBox/                     ← shippable addon folder
    ├── MythicPlusBox.toc              file load order lives here
    ├── Init.lua                       ns namespace, LSM font register, /mpb slash
    ├── Config.lua                     AceDB defaults, InitializeDB()
    ├── Locales/                       enUS.lua (default), zhCN.lua, zhTW.lua
    ├── Data/Seasons.lua               current-season mapIDs + evergreen spell table
    ├── Modules/                       Score, Weekly, Teleport, KeystoneList, CenterBanner
    ├── Options.lua                    AceGUI TabGroup settings window
    ├── Libs/                          Ace3 + LSM + LibDBIcon + LibOpenRaid
    └── Media/font.ttf, icon.tga
```

The **outer** `MythicPlusBox/` is the git repository. The **inner**
`MythicPlusBox/MythicPlusBox/` is the addon folder that ships. `release.sh`
never packages the outer directory — only the inner one goes into the zip.

## Load order (from `.toc`)

Libraries first, then locales, then data, then `Init.lua`, then `Config.lua`,
then modules, then `Options.lua`. **Locales must load before `Init.lua`** so
`ns.L` is populated before modules run their bodies. **`Config.lua` runs after
locales** so default template strings can reference `L[...]`.

## Coding conventions

### Namespace and modules

Every Lua file begins with

```lua
local addonName, ns = ...
```

`ns` is the private table shared across all files in the addon (Blizzard's `...`
mechanism). Never touch a raw global — use `ns.<thing>`.

Each feature module in `Modules/` follows the same shape:

```lua
local M = {}
ns:RegisterModule("<id>", M)

function M:OnDBReady()        -- ADDON_LOADED, after AceDB init
function M:OnPlayerLogin()    -- PLAYER_LOGIN, safe to hook Blizzard UI
function M:Refresh()          -- called by ns:RefreshAll() after option changes
```

`Init.lua` wires these up. Do not add per-file `CreateFrame("Frame"):
RegisterEvent("PLAYER_LOGIN")` bootstrap frames — use `OnPlayerLogin` instead.

### Localisation

**Every string that reaches a human eye must go through `ns.L[...]`.** No
hardcoded Chinese, no hardcoded English, no `("[MPBox] Casting…"):format(...)`
inlined literals. If a string is missing from a locale, `AceLocale-3.0`
returns the key back to you — that's the visible signal that translation is
missing.

- Add the key to `Locales/enUS.lua` first (it's the default with `true`).
- Add the same key to `zhCN.lua` and `zhTW.lua` with translations.
- Reference as `ns.L["KEY"]` or `local L = ns.L; L["KEY"]`.

Dungeon short names live as `L["ABBR_<mapID>"]`. Missing keys fall through to
`C_ChallengeMode.GetMapUIInfo(mapID)` full names — see `ns:GetDungeonName`
in `Data/Seasons.lua`.

### Config and SavedVariables

- Only one SavedVariable: `MythicPlusBoxDB` (declared in the `.toc`).
- Access via `ns.db.profile.<field>` and `ns.db.global.<field>`.
- Defaults live in `Config.lua`'s `defaults` table — change them there, not
  inline in modules.
- After changing anything at runtime, call `ns:RefreshAll()` to give every
  module a chance to re-render.

### Fonts and font sizes

Fonts are **never** referenced by file path. Use LSM:

```lua
local path, size, outline = ns:GetFont({ name = ..., size = ..., outline = ... })
text:SetFont(path, size, outline)
```

The bundled TTF is registered as `"MythicPlusBox"` in `Init.lua`. Users can
pick any LSM-registered font through the settings panel.

### Movable frames

The keystone list and center banner both persist their position to
`db.profile.<module>.anchor`. The `.locked` flag on each gates dragging via
`RegisterForDrag("LeftButton")` — the frame's `OnDragStart` refuses to move
unless unlocked. The Options panel exposes a single "Unlock frames" checkbox
that flips both `.locked` fields at once.

### Anti-patterns (do not do)

- Do **not** hardcode `"Interface\\AddOns\\zMPlus\\font.ttf"` or any similar
  path. Use LSM.
- Do **not** paste literal Chinese/English UI strings into module bodies. Add a
  locale key.
- Do **not** call `SetFont(cfg.GlobalFont, ...)` directly — use `ns:GetFont`.
- Do **not** create parallel `CreateFrame` bootstraps in each module for
  `PLAYER_LOGIN` — implement `OnPlayerLogin` instead.
- Do **not** write "added for X" / "fixed in Y" / "see issue Z" in source
  comments — that belongs in the commit/PR.

## Slash commands

`/mpb` and `/mpbox` are the two aliases. `/mpb` alone opens the settings
window. Sub-commands: `unlock`, `lock`, `reset`.

## Release workflow

Releases are cut through the Claude slash command at
`.claude/commands/release.md`. In short:

1. Read version from `MythicPlusBox/MythicPlusBox.toc`.
2. Summarise `git log <last-tag>..HEAD` into `CHANGELOG.md` as one bilingual
   (EN + zhCN) entry under a new `## v<VER>` heading.
3. `bash release.sh` produces `MPBox-v<VER>.zip` at repo root.
4. `git add CHANGELOG.md release.sh MythicPlusBox/`, commit as
   `release: v<VER>`, then `git tag v<VER>`. Do **not** push automatically.
5. Bump `## Version:` in `MythicPlusBox/MythicPlusBox.toc` to the next minor,
   commit as `chore: bump version to <VER+1>`.

Nothing uploads to CurseForge/WoWInterface — those are manual uploads of the
generated zip.
