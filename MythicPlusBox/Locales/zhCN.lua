local L = LibStub("AceLocale-3.0"):NewLocale("MythicPlusBox", "zhCN", false, true)
if not L then return end

-- UI
L["ADDON_TITLE"]              = "大秘境工具箱"
L["TAB_GENERAL"]              = "常规"
L["TAB_SCORE"]                = "副本得分"
L["TAB_WEEKLY"]               = "本周面板"
L["TAB_TELEPORT"]             = "副本传送"
L["TAB_KEYSTONE"]             = "钥石面板"
L["TAB_PROFILES"]             = "配置文件"

L["OPT_ENABLED"]              = "启用"
L["OPT_LOCKED"]               = "锁定"
L["OPT_UNLOCK_FRAMES"]        = "解锁(拖动以移动本面板)"
L["OPT_FONT"]                 = "字体"
L["OPT_FONT_SIZE"]            = "字号"
L["OPT_FONT_OUTLINE"]         = "字体描边"
L["OPT_ROW_SPACING"]          = "行间距"
L["OPT_MINIMAP_ICON"]         = "显示小地图按钮"
L["OPT_USE_ABBREVIATION"]     = "使用副本名缩略显示"
L["OPT_USE_MODIFIER"]         = "按住 Alt/Shift/Ctrl 切换本周/赛季记录"
L["OPT_ANNOUNCE_ENABLED"]     = "施放传送法术时向队伍/团队广播"
L["OPT_ANNOUNCE_TEMPLATE"]    = "广播模板"
L["OPT_ANNOUNCE_HELP"]        = "占位符:{spell} = 法术链接,{dungeon} = 副本名"
L["OPT_RESET"]                = "恢复默认"
L["OPT_ANCHOR_POINT"]         = "锚点"
L["OPT_X_OFFSET"]             = "X 偏移"
L["OPT_Y_OFFSET"]             = "Y 偏移"
L["OPT_BANNER_DURATION"]      = "横幅显示时长(秒)"
L["OPT_SHOW_OFFLINE"]         = "显示无钥石的队员"
L["OPT_KEYSTONE_LIST"]        = "队伍钥石列表"
L["OPT_CENTER_BANNER"]        = "副本内钥石横幅"
L["OPT_OUTLINE_NONE"]         = "无"
L["OPT_OUTLINE_THIN"]         = "细"
L["OPT_OUTLINE_THICK"]        = "粗"
L["OPT_OUTLINE_MONOCHROME"]   = "单色"

L["ANCHOR_CENTER"]            = "居中"
L["ANCHOR_LEFT"]              = "左"
L["ANCHOR_RIGHT"]             = "右"
L["ANCHOR_TOP"]               = "上"
L["ANCHOR_BOTTOM"]            = "下"
L["ANCHOR_TOPLEFT"]           = "左上"
L["ANCHOR_TOPRIGHT"]          = "右上"
L["ANCHOR_BOTTOMLEFT"]        = "左下"
L["ANCHOR_BOTTOMRIGHT"]       = "右下"

-- Weekly
L["WEEKLY_BEST_HEADER"]       = "本周最佳"
L["SEASON_RECORD_HEADER"]     = "赛季记录"
L["COMPLETION_COUNT_LABEL"]   = "完成次数:"
L["NO_WEEKLY_RECORD"]         = "无本周记录"
L["NO_SEASON_RECORD"]         = "无赛季记录"
L["NO_RECORD"]                = "无记录"
L["ITEM_LEVEL"]               = "装等"

-- Teleport
L["TELEPORT_TEMPLATE_DEFAULT"] = "正在施放:%s,传送到:%s"
L["TELEPORT_TOOLTIP_TITLE"]    = "传送到副本"
L["TELEPORT_UNKNOWN_COOLDOWN"] = "未知冷却"
L["TELEPORT_READY"]            = "已准备好"
L["TELEPORT_NOT_LEARNED"]      = "未学会"
L["TELEPORT_UNKNOWN_DUNGEON"]  = "未知副本"

-- Keystone
L["KEYSTONE_LIST_HEADER"]      = "队伍钥石"
L["KEYSTONE_NONE"]             = "无钥石"
L["KEYSTONE_BANNER_FORMAT"]    = "%s 的钥石:%s +%d"
L["KEYSTONE_NO_PARTY"]         = "未组队"

-- Errors
L["ERROR_NO_CHALLENGES_UI"]    = "Blizzard_ChallengesUI 加载失败"
L["ERROR_NO_LIBOPENRAID"]      = "LibOpenRaid 不可用,队伍钥石无法同步"
L["UNKNOWN"]                   = "未知"

-- Abbreviations (mapID -> short name, sourced from SavedInstances zhCN)
-- WotLK
L["ABBR_556"]  = "矿坑"       -- 萨隆矿坑
-- Cataclysm
L["ABBR_438"]  = "旋云"       -- 旋云之巅
L["ABBR_456"]  = "潮汐"       -- 潮汐王座
L["ABBR_507"]  = "格瑞姆巴托"
-- Mists of Pandaria
L["ABBR_2"]    = "青龙寺"
-- Warlords of Draenor
L["ABBR_161"]  = "通天峰"
L["ABBR_165"]  = "影月"       -- 影月墓地
L["ABBR_166"]  = "车站"       -- 恐轨车站
L["ABBR_168"]  = "永茂"       -- 永茂林地
L["ABBR_169"]  = "码头"       -- 钢铁码头
-- Legion
L["ABBR_197"]  = "艾萨拉"     -- 艾萨拉之眼
L["ABBR_198"]  = "黑心"       -- 黑心林地
L["ABBR_199"]  = "黑鸦"       -- 黑鸦堡垒
L["ABBR_200"]  = "英灵殿"
L["ABBR_206"]  = "巢穴"       -- 奈萨里奥的巢穴
L["ABBR_207"]  = "地窟"       -- 守望者地窟
L["ABBR_208"]  = "噬魂"       -- 噬魂之喉
L["ABBR_209"]  = "回廊"       -- 奥金尼回廊
L["ABBR_210"]  = "群星"       -- 群星庭院
L["ABBR_227"]  = "卡下"       -- 卡拉赞下层
L["ABBR_233"]  = "大教堂"     -- 永夜大教堂
L["ABBR_234"]  = "卡上"       -- 卡拉赞上层
L["ABBR_239"]  = "执政团"     -- 执政团之座
-- Battle for Azeroth
L["ABBR_244"]  = "阿塔"       -- 阿塔达萨
L["ABBR_245"]  = "自由镇"
L["ABBR_246"]  = "托尔"       -- 托尔达戈
L["ABBR_247"]  = "暴富"       -- 暴富矿区!!
L["ABBR_248"]  = "庄园"       -- 维克雷斯庄园
L["ABBR_249"]  = "诸王"       -- 诸王之眠
L["ABBR_250"]  = "神庙"       -- 赛塔里斯神庙
L["ABBR_251"]  = "孢林"       -- 地底之泉
L["ABBR_252"]  = "风暴"       -- 风暴神殿
L["ABBR_353"]  = "围攻"       -- 围攻伯拉勒斯
L["ABBR_369"]  = "垃圾场"     -- 麦卡贡:垃圾场
L["ABBR_370"]  = "车间"       -- 麦卡贡:车间
-- Shadowlands
L["ABBR_375"]  = "仙林"       -- 提尔纳仙林的迷雾
L["ABBR_376"]  = "通灵"       -- 通灵战潮
L["ABBR_377"]  = "彼界"
L["ABBR_378"]  = "赎罪"       -- 赎罪大厅
L["ABBR_379"]  = "凋魂"       -- 凋魂之殇
L["ABBR_380"]  = "赤红"       -- 赤红深渊
L["ABBR_381"]  = "高塔"       -- 晋升高塔
L["ABBR_382"]  = "剧场"       -- 伤逝剧场
L["ABBR_391"]  = "天街"       -- 塔扎维什:漫幻之街
L["ABBR_392"]  = "宏图"       -- 塔扎维什:苏雷安的宏图
-- Dragonflight
L["ABBR_399"]  = "红玉"       -- 红玉新生法池
L["ABBR_400"]  = "阻击战"     -- 诺库德阻击战
L["ABBR_401"]  = "魔馆"       -- 碧蓝魔馆
L["ABBR_402"]  = "学院"       -- 阿尔盖萨学院
L["ABBR_403"]  = "奥达曼"     -- 奥达曼:泰尔的遗产
L["ABBR_404"]  = "奈萨"       -- 奈萨鲁斯
L["ABBR_405"]  = "蕨皮"       -- 蕨皮谷
L["ABBR_406"]  = "注能"       -- 注能大厅
L["ABBR_463"]  = "陨落"       -- 时空:加拉克隆的陨落
L["ABBR_464"]  = "崛起"       -- 时空:莫佐加德的崛起
-- The War Within
L["ABBR_499"]  = "隐修院"     -- 圣焰隐修院
L["ABBR_500"]  = "栖巢"
L["ABBR_501"]  = "宝库"       -- 石之宝库
L["ABBR_502"]  = "千丝"       -- 千丝之城
L["ABBR_503"]  = "回响"       -- 回响之城阿拉卡拉
L["ABBR_504"]  = "暗焰"       -- 暗焰裂口
L["ABBR_505"]  = "破晨号"
L["ABBR_506"]  = "酒庄"       -- 醇酒烈焰酒庄
L["ABBR_525"]  = "水闸"       -- 水闸行动
L["ABBR_542"]  = "圆顶"       -- 圆顶生态站
-- Midnight
L["ABBR_557"]  = "风行"       -- 风行者尖塔
L["ABBR_558"]  = "平台"       -- 魔导师平台
L["ABBR_559"]  = "节点"       -- 节点核心
L["ABBR_560"]  = "洞窟"       -- 迈萨拉洞窟
