local L = LibStub("AceLocale-3.0"):NewLocale("MythicPlusBox", "zhTW", false, true)
if not L then return end

-- UI
L["ADDON_TITLE"]              = "大祕境工具箱"
L["TAB_GENERAL"]              = "一般"
L["TAB_SCORE"]                = "副本分數"
L["TAB_WEEKLY"]               = "統計面板"
L["TAB_TELEPORT"]             = "副本傳送"
L["TAB_KEYSTONE"]             = "鑰石面板"
L["TAB_PROFILES"]             = "設定檔"

L["OPT_SCORE_NAME"]           = "副本名稱"
L["OPT_SCORE_LEVEL"]          = "最高層數"
L["OPT_SCORE_SCORE"]          = "副本分數"
L["OPT_SCORE_SHOW_NAME"]      = "顯示副本名稱"
L["OPT_SCORE_SHOW_LEVEL"]     = "顯示最高層數"
L["OPT_SCORE_SHOW_SCORE"]     = "顯示副本分數"
L["OPT_RELATIVE_POINT"]       = "相對錨點"

L["OPT_ENABLED"]              = "啟用"
L["OPT_LOCKED"]               = "鎖定"
L["OPT_UNLOCK_FRAMES"]        = "解鎖(拖曳以移動本面板)"
L["OPT_FONT"]                 = "字型"
L["OPT_FONT_SIZE"]            = "字型大小"
L["OPT_FONT_OUTLINE"]         = "字型描邊"
L["OPT_ROW_SPACING"]          = "行距"
L["OPT_MINIMAP_ICON"]         = "顯示小地圖按鈕"
L["OPT_USE_ABBREVIATION"]     = "使用副本簡稱"
L["OPT_USE_MODIFIER"]         = "按住 Shift 切換本週/賽季"
L["OPT_ANNOUNCE_ENABLED"]     = "施放傳送法術時向隊伍/團隊廣播"
L["OPT_ANNOUNCE_TEMPLATE"]    = "廣播範本"
L["OPT_ANNOUNCE_HELP"]        = "佔位符:{spell} = 法術連結,{dungeon} = 副本名"
L["OPT_RESET"]                = "恢復預設"
L["OPT_ANCHOR_POINT"]         = "錨點"
L["OPT_X_OFFSET"]             = "X 位移"
L["OPT_Y_OFFSET"]             = "Y 位移"
L["OPT_BANNER_DURATION"]      = "橫幅顯示時間(秒)"
L["OPT_SHOW_OFFLINE"]         = "顯示無鑰石的隊員"
L["OPT_KEYSTONE_LIST"]        = "隊伍鑰石列表"
L["OPT_CENTER_BANNER"]        = "誰有鑰石"
L["OPT_OUTLINE_NONE"]         = "無"
L["OPT_OUTLINE_THIN"]         = "細"
L["OPT_OUTLINE_THICK"]        = "粗"
L["OPT_OUTLINE_MONOCHROME"]   = "單色"

L["ANCHOR_CENTER"]            = "置中"
L["ANCHOR_LEFT"]              = "左"
L["ANCHOR_RIGHT"]             = "右"
L["ANCHOR_TOP"]               = "上"
L["ANCHOR_BOTTOM"]            = "下"
L["ANCHOR_TOPLEFT"]           = "左上"
L["ANCHOR_TOPRIGHT"]          = "右上"
L["ANCHOR_BOTTOMLEFT"]        = "左下"
L["ANCHOR_BOTTOMRIGHT"]       = "右下"

-- Weekly
L["WEEKLY_BEST_HEADER"]       = "本週最佳"
L["SEASON_RECORD_HEADER"]     = "賽季記錄"
L["COMPLETION_COUNT_LABEL"]   = "完成次數:"
L["NO_WEEKLY_RECORD"]         = "無本週記錄"
L["NO_SEASON_RECORD"]         = "無賽季記錄"
L["NO_RECORD"]                = "無記錄"
L["ITEM_LEVEL"]               = "裝等"

-- Teleport
L["TELEPORT_TEMPLATE_DEFAULT"] = "正在施放:%s,傳送到:%s"
L["TELEPORT_TOOLTIP_TITLE"]    = "傳送到副本"
L["TELEPORT_UNKNOWN_COOLDOWN"] = "未知冷卻"
L["TELEPORT_READY"]            = "已就緒"
L["TELEPORT_NOT_LEARNED"]      = "未學會"
L["TELEPORT_UNKNOWN_DUNGEON"]  = "未知副本"

-- Keystone
L["KEYSTONE_LIST_HEADER"]      = "隊伍鑰石"
L["KEYSTONE_NONE"]             = "無鑰石"
L["KEYSTONE_BANNER_FORMAT"]    = "%s 的鑰石:%s +%d"
L["KEYSTONE_NO_PARTY"]         = "未組隊"

-- Errors
L["ERROR_NO_CHALLENGES_UI"]    = "Blizzard_ChallengesUI 載入失敗"
L["ERROR_NO_LIBOPENRAID"]      = "LibOpenRaid 不可用,隊伍鑰石無法同步"
L["UNKNOWN"]                   = "未知"

-- Abbreviations (mapID -> short name, sourced from SavedInstances zhTW;
-- gaps filled with our own Traditional-Chinese short form)
-- WotLK
L["ABBR_556"]  = "薩倫"       -- 薩倫礦坑
-- Cataclysm
L["ABBR_438"]  = "漩渦"       -- 漩渦頂峰
L["ABBR_456"]  = "海潮"       -- 海潮王座
L["ABBR_507"]  = "格瑞"       -- 格瑞姆巴托
-- Mists of Pandaria
L["ABBR_2"]    = "玉蛟"       -- 玉蛟寺
-- Warlords of Draenor
L["ABBR_161"]  = "擎天"       -- 擎天峰
L["ABBR_165"]  = "影月"
L["ABBR_166"]  = "車站"
L["ABBR_168"]  = "永茂"
L["ABBR_169"]  = "碼頭"
-- Legion
L["ABBR_197"]  = "艾眼"       -- 艾薩拉之眼
L["ABBR_198"]  = "暗心"       -- 暗心森林
L["ABBR_199"]  = "玄鴉"       -- 玄鴉巢穴
L["ABBR_200"]  = "英靈殿"
L["ABBR_206"]  = "巢穴"       -- 奈薩里奧的巢穴
L["ABBR_207"]  = "看守"       -- 看守者穹殿
L["ABBR_208"]  = "靈魂"       -- 靈魂之口
L["ABBR_209"]  = "秘徑"       -- 神秘祕徑
L["ABBR_210"]  = "眾星"       -- 眾星庭
L["ABBR_227"]  = "卡拉下"     -- 卡拉贊下層
L["ABBR_233"]  = "永夜"       -- 永夜大教堂
L["ABBR_234"]  = "卡拉上"     -- 卡拉贊上層
L["ABBR_239"]  = "三傑"       -- 三傑之座
-- Battle for Azeroth
L["ABBR_244"]  = "阿塔"       -- 阿塔達薩
L["ABBR_245"]  = "自由"       -- 自由鎮
L["ABBR_246"]  = "托達"       -- 托爾達戈
L["ABBR_247"]  = "晶喜鎮"
L["ABBR_248"]  = "莊園"       -- 維克雷斯莊園
L["ABBR_249"]  = "諸王"       -- 諸王安眠
L["ABBR_250"]  = "神廟"       -- 塞司拉里斯神廟
L["ABBR_251"]  = "幽腐"       -- 幽腐之地
L["ABBR_252"]  = "風暴"       -- 風暴聖殿
L["ABBR_353"]  = "圍城"       -- 圍城伯拉勒斯
L["ABBR_369"]  = "廢料場"     -- 密卡尼可行動:廢料場
L["ABBR_370"]  = "工坊"       -- 密卡尼可行動:工坊
-- Shadowlands
L["ABBR_375"]  = "迷霧"       -- 提爾納席司之霧
L["ABBR_376"]  = "死靈"       -- 死靈昇醒
L["ABBR_377"]  = "彼界"
L["ABBR_378"]  = "贖罪"       -- 贖罪大廳
L["ABBR_379"]  = "瘟疫"       -- 瘟疫之殤
L["ABBR_380"]  = "血紅"       -- 血紅深淵
L["ABBR_381"]  = "晉升"       -- 晉升尖塔
L["ABBR_382"]  = "劇場"       -- 死傷劇場
L["ABBR_391"]  = "街道"       -- 塔扎維許:奇景之街
L["ABBR_392"]  = "險招"       -- 塔扎維許:蘇歐蕾的險招
-- Dragonflight
L["ABBR_399"]  = "晶紅"       -- 晶紅生命之池
L["ABBR_400"]  = "諾庫德"     -- 諾庫德進攻戰
L["ABBR_401"]  = "蒼藍"       -- 蒼藍寶庫
L["ABBR_402"]  = "學院"       -- 阿爾蓋薩學院
L["ABBR_403"]  = "奧達曼"     -- 奧達曼:提爾之遺產
L["ABBR_404"]  = "奈堡"       -- 奈薩魯斯
L["ABBR_405"]  = "蕨皮"       -- 蕨皮谷地
L["ABBR_406"]  = "灌注"       -- 灌注大廳
L["ABBR_463"]  = "殞落"       -- 時空:加拉克隆的殞落
L["ABBR_464"]  = "崛起"       -- 時空:莫佐加德的崛起
-- The War Within
L["ABBR_499"]  = "隱修院"     -- 聖焰隱修院
L["ABBR_500"]  = "培育所"
L["ABBR_501"]  = "石庫"       -- 石之寶庫
L["ABBR_502"]  = "蛛絲"       -- 蛛絲之城
L["ABBR_503"]  = "回音"       -- 回音之城阿拉卡拉
L["ABBR_504"]  = "暗焰"       -- 暗焰裂口
L["ABBR_505"]  = "破曉"       -- 破曉號
L["ABBR_506"]  = "酒莊"       -- 醇火酒莊
L["ABBR_525"]  = "水閘"       -- 水閘行動
L["ABBR_542"]  = "埃達尼秘境" -- 埃達尼秘境
-- Midnight
L["ABBR_557"]  = "風行"       -- 風行者尖塔
L["ABBR_558"]  = "博學"       -- 博學者殿堂
L["ABBR_559"]  = "奧核"       -- 奧核據點
L["ABBR_560"]  = "洞穴"       -- 梅薩拉洞穴
