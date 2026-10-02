-- Optional display language: "en" or "zh-Hans". Reload after changing.
-- 可选显示语言：英文 "en"／简体中文 "zh-Hans"。修改后重新加载脚本。
local POKELUA_LANGUAGE = "en"
local function _pokeluaText(english, chinese)
 if POKELUA_LANGUAGE == "zh-Hans" then return chinese end
 return english
end
-- END POKELUA LOCALIZATION

read32Bit = ReadValue32
read16Bit = ReadValue16
read8Bit = ReadValue8

local JUMP_DATA = {
 {0x343FD, 0x269EC3}, {0xA9FC6809, 0x1E278E7A}, {0xDDFF5051, 0x98520C4}, {0xF490B9A1, 0x7E1DBEC8},
 {0x43BA1741, 0x3E314290}, {0xD290BE81, 0x824E1920}, {0x82E3BD01, 0x844E8240}, {0xBF507A01, 0xFD864480},
 {0xF8C4F401, 0xDFB18900}, {0x7A19E801, 0xD9F71200}, {0x1673D001, 0x5E3E2400}, {0xB5E7A001, 0x65BC4800},
 {0x8FCF4001, 0x70789000}, {0xAF9E8001, 0x74F12000}, {0x9F3D0001, 0x39E24000}, {0x3E7A0001, 0xB3C48000},
 {0x7CF40001, 0x67890000}, {0xF9E80001, 0xCF120000}, {0xF3D00001, 0x9E240000}, {0xE7A00001, 0x3C480000},
 {0xCF400001, 0x78900000}, {0x9E800001, 0xF1200000}, {0x3D000001, 0xE2400000}, {0x7A000001, 0xC4800000},
 {0xF4000001, 0x89000000}, {0xE8000001, 0x12000000}, {0xD0000001, 0x24000000}, {0xA0000001, 0x48000000},
 {0x40000001, 0x90000000}, {0x80000001, 0x20000000}, {0x1, 0x40000000}, {0x1, 0x80000000}}

local natureNamesList = {
 _pokeluaText("Hardy", "勤奋"), _pokeluaText("Lonely", "怕寂寞"), _pokeluaText("Brave", "勇敢"), _pokeluaText("Adamant", "固执"), _pokeluaText("Naughty", "顽皮"),
 _pokeluaText("Bold", "大胆"), _pokeluaText("Docile", "坦率"), _pokeluaText("Relaxed", "悠闲"), _pokeluaText("Impish", "淘气"), _pokeluaText("Lax", "乐天"),
 _pokeluaText("Timid", "胆小"), _pokeluaText("Hasty", "急躁"), _pokeluaText("Serious", "认真"), _pokeluaText("Jolly", "爽朗"), _pokeluaText("Naive", "天真"),
 _pokeluaText("Modest", "内敛"), _pokeluaText("Mild", "慢吞吞"), _pokeluaText("Quiet", "冷静"), _pokeluaText("Bashful", "害羞"), _pokeluaText("Rash", "马虎"),
 _pokeluaText("Calm", "温和"), _pokeluaText("Gentle", "温顺"), _pokeluaText("Sassy", "自大"), _pokeluaText("Careful", "慎重"), _pokeluaText("Quirky", "浮躁")}

local HPTypeNamesList = {
 _pokeluaText("Fighting", "格斗"), _pokeluaText("Flying", "飞行"), _pokeluaText("Poison", "毒"), _pokeluaText("Ground", "地面"),
 _pokeluaText("Rock", "岩石"), _pokeluaText("Bug", "虫"), _pokeluaText("Ghost", "幽灵"), _pokeluaText("Steel", "钢"),
 _pokeluaText("Fire", "火"), _pokeluaText("Water", "水"), _pokeluaText("Grass", "草"), _pokeluaText("Electric", "电"),
 _pokeluaText("Psychic", "超能力"), _pokeluaText("Ice", "冰"), _pokeluaText("Dragon", "龙"), _pokeluaText("Dark", "恶")}

local speciesNamesList = {
 -- Gen 1
 _pokeluaText("NONE", "无"), _pokeluaText("BULBASAUR", "妙蛙种子"), _pokeluaText("IVYSAUR", "妙蛙草"), _pokeluaText("VENUSAUR", "妙蛙花"), _pokeluaText("CHARMANDER", "小火龙"), _pokeluaText("CHARMELEON", "火恐龙"), _pokeluaText("CHARIZARD", "喷火龙"), _pokeluaText("SQUIRTLE", "杰尼龟"), _pokeluaText("WARTORTLE", "卡咪龟"), _pokeluaText("BLASTOISE", "水箭龟"),
 _pokeluaText("CATERPIE", "绿毛虫"), _pokeluaText("METAPOD", "铁甲蛹"), _pokeluaText("BUTTERFREE", "巴大蝶"), _pokeluaText("WEEDLE", "独角虫"), _pokeluaText("KAKUNA", "铁壳蛹"), _pokeluaText("BEEDRILL", "大针蜂"), _pokeluaText("PIDGEY", "波波"), _pokeluaText("PIDGEOTTO", "比比鸟"), _pokeluaText("PIDGEOT", "大比鸟"), _pokeluaText("RATTATA", "小拉达"), _pokeluaText("RATICATE", "拉达"),
 _pokeluaText("SPEAROW", "烈雀"), _pokeluaText("FEAROW", "大嘴雀"), _pokeluaText("EKANS", "阿柏蛇"), _pokeluaText("ARBOK", "阿柏怪"), _pokeluaText("PIKACHU", "皮卡丘"), _pokeluaText("RAICHU", "雷丘"), _pokeluaText("SANDSHREW", "穿山鼠"), _pokeluaText("SANDSLASH", "穿山王"), _pokeluaText("NIDORAN♀", "尼多兰"), _pokeluaText("NIDORINA", "尼多娜"), _pokeluaText("NIDOQUEEN", "尼多后"),
 _pokeluaText("NIDORAN♂", "尼多朗"), _pokeluaText("NIDORINO", "尼多力诺"), _pokeluaText("NIDOKING", "尼多王"), _pokeluaText("CLEFAIRY", "皮皮"), _pokeluaText("CLEFABLE", "皮可西"), _pokeluaText("VULPIX", "六尾"), _pokeluaText("NINETALES", "九尾"), _pokeluaText("JIGGLYPUFF", "胖丁"), _pokeluaText("WIGGLYTUFF", "胖可丁"), _pokeluaText("ZUBAT", "超音蝠"), _pokeluaText("GOLBAT", "大嘴蝠"),
 _pokeluaText("ODDISH", "走路草"), _pokeluaText("GLOOM", "臭臭花"), _pokeluaText("VILEPLUME", "霸王花"), _pokeluaText("PARAS", "派拉斯"), _pokeluaText("PARASECT", "派拉斯特"), _pokeluaText("VENONAT", "毛球"), _pokeluaText("VENOMOTH", "摩鲁蛾"), _pokeluaText("DIGLETT", "地鼠"), _pokeluaText("DUGTRIO", "三地鼠"), _pokeluaText("MEOWTH", "喵喵"), _pokeluaText("PERSIAN", "猫老大"), _pokeluaText("PSYDUCK", "可达鸭"),
 _pokeluaText("GOLDUCK", "哥达鸭"), _pokeluaText("MANKEY", "猴怪"), _pokeluaText("PRIMEAPE", "火暴猴"), _pokeluaText("GROWLITHE", "卡蒂狗"), _pokeluaText("ARCANINE", "风速狗"), _pokeluaText("POLIWAG", "蚊香蝌蚪"), _pokeluaText("POLIWHIRL", "蚊香君"), _pokeluaText("POLIWRATH", "蚊香泳士"), _pokeluaText("ABRA", "凯西"), _pokeluaText("KADABRA", "勇基拉"), _pokeluaText("ALAKAZAM", "胡地"),
 _pokeluaText("MACHOP", "腕力"), _pokeluaText("MACHOKE", "豪力"), _pokeluaText("MACHAMP", "怪力"), _pokeluaText("BELLSPROUT", "喇叭芽"), _pokeluaText("WEEPINBELL", "口呆花"), _pokeluaText("VICTREEBEL", "大食花"), _pokeluaText("TENTACOOL", "玛瑙水母"), _pokeluaText("TENTACRUEL", "毒刺水母"), _pokeluaText("GEODUDE", "小拳石"), _pokeluaText("GRAVELER", "隆隆石"),
 _pokeluaText("GOLEM", "隆隆岩"), _pokeluaText("PONYTA", "小火马"), _pokeluaText("RAPIDASH", "烈焰马"), _pokeluaText("SLOWPOKE", "呆呆兽"), _pokeluaText("SLOWBRO", "呆壳兽"), _pokeluaText("MAGNEMITE", "小磁怪"), _pokeluaText("MAGNETON", "三合一磁怪"), _pokeluaText("FARFETCH'D", "大葱鸭"), _pokeluaText("DODUO", "嘟嘟"), _pokeluaText("DODRIO", "嘟嘟利"), _pokeluaText("SEEL", "小海狮"), _pokeluaText("DEWGONG", "白海狮"),
 _pokeluaText("GRIMER", "臭泥"), _pokeluaText("MUK", "臭臭泥"), _pokeluaText("SHELLDER", "大舌贝"), _pokeluaText("CLOYSTER", "刺甲贝"), _pokeluaText("GASTLY", "鬼斯"), _pokeluaText("HAUNTER", "鬼斯通"), _pokeluaText("GENGAR", "耿鬼"), _pokeluaText("ONIX", "大岩蛇"), _pokeluaText("DROWZEE", "催眠貘"), _pokeluaText("HYPNO", "引梦貘人"), _pokeluaText("KRABBY", "大钳蟹"), _pokeluaText("KINGLER", "巨钳蟹"), _pokeluaText("VOLTORB", "霹雳电球"),
 _pokeluaText("ELECTRODE", "顽皮雷弹"), _pokeluaText("EXEGGCUTE", "蛋蛋"), _pokeluaText("EXEGGUTOR", "椰蛋树"), _pokeluaText("CUBONE", "卡拉卡拉"), _pokeluaText("MAROWAK", "嘎啦嘎啦"), _pokeluaText("HITMONLEE", "飞腿郎"), _pokeluaText("HITMONCHAN", "快拳郎"), _pokeluaText("LICKITUNG", "大舌头"), _pokeluaText("KOFFING", "瓦斯弹"), _pokeluaText("WEEZING", "双弹瓦斯"), _pokeluaText("RHYHORN", "独角犀牛"),
 _pokeluaText("RHYDON", "钻角犀兽"), _pokeluaText("CHANSEY", "吉利蛋"), _pokeluaText("TANGELA", "蔓藤怪"), _pokeluaText("KANGASKHAN", "袋兽"), _pokeluaText("HORSEA", "墨海马"), _pokeluaText("SEADRA", "海刺龙"), _pokeluaText("GOLDEEN", "角金鱼"), _pokeluaText("SEAKING", "金鱼王"), _pokeluaText("STARYU", "海星星"), _pokeluaText("STARMIE", "宝石海星"), _pokeluaText("MR.MIME", "魔墙人偶"), _pokeluaText("SCYTHER", "飞天螳螂"),
 _pokeluaText("JYNX", "迷唇姐"), _pokeluaText("ELECTABUZZ", "电击兽"), _pokeluaText("MAGMAR", "鸭嘴火兽"), _pokeluaText("PINSIR", "凯罗斯"), _pokeluaText("TAUROS", "肯泰罗"), _pokeluaText("MAGIKARP", "鲤鱼王"), _pokeluaText("GYARADOS", "暴鲤龙"), _pokeluaText("LAPRAS", "拉普拉斯"), _pokeluaText("DITTO", "百变怪"), _pokeluaText("EEVEE", "伊布"), _pokeluaText("VAPOREON", "水伊布"), _pokeluaText("JOLTEON", "雷伊布"),
 _pokeluaText("FLAREON", "火伊布"), _pokeluaText("PORYGON", "多边兽"), _pokeluaText("OMANYTE", "菊石兽"), _pokeluaText("OMASTAR", "多刺菊石兽"), _pokeluaText("KABUTO", "化石盔"), _pokeluaText("KABUTOPS", "镰刀盔"), _pokeluaText("AERODACTYL", "化石翼龙"), _pokeluaText("SNORLAX", "卡比兽"), _pokeluaText("ARTICUNO", "急冻鸟"), _pokeluaText("ZAPDOS", "闪电鸟"), _pokeluaText("MOLTRES", "火焰鸟"),
 _pokeluaText("DRATINI", "迷你龙"), _pokeluaText("DRAGONAIR", "哈克龙"), _pokeluaText("DRAGONITE", "快龙"), _pokeluaText("MEWTWO", "超梦"), _pokeluaText("MEW", "梦幻"),
 -- Gen 2
 _pokeluaText("CHIKORITA", "菊草叶"), _pokeluaText("BAYLEEF", "月桂叶"), _pokeluaText("MEGANIUM", "大竺葵"), _pokeluaText("CYNDAQUIL", "火球鼠"), _pokeluaText("QUILAVA", "火岩鼠"), _pokeluaText("TYPHLOSION", "火暴兽"), _pokeluaText("TOTODILE", "小锯鳄"), _pokeluaText("CROCONAW", "蓝鳄"), _pokeluaText("FERALIGATR", "大力鳄"), _pokeluaText("SENTRET", "尾立"), _pokeluaText("FURRET", "大尾立"),
 _pokeluaText("HOOTHOOT", "咕咕"), _pokeluaText("NOCTOWL", "猫头夜鹰"), _pokeluaText("LEDYBA", "芭瓢虫"), _pokeluaText("LEDIAN", "安瓢虫"), _pokeluaText("SPINARAK", "圆丝蛛"), _pokeluaText("ARIADOS", "阿利多斯"), _pokeluaText("CROBAT", "叉字蝠"), _pokeluaText("CHINCHOU", "灯笼鱼"), _pokeluaText("LANTURN", "电灯怪"), _pokeluaText("PICHU", "皮丘"), _pokeluaText("CLEFFA", "皮宝宝"), _pokeluaText("IGGLYBUFF", "宝宝丁"),
 _pokeluaText("TOGEPI", "波克比"), _pokeluaText("TOGETIC", "波克基古"), _pokeluaText("NATU", "天然雀"), _pokeluaText("XATU", "天然鸟"), _pokeluaText("MAREEP", "咩利羊"), _pokeluaText("FLAAFFY", "茸茸羊"), _pokeluaText("AMPHAROS", "电龙"), _pokeluaText("BELLOSSOM", "美丽花"), _pokeluaText("MARILL", "玛力露"), _pokeluaText("AZUMARILL", "玛力露丽"), _pokeluaText("SUDOWOODO", "树才怪"), _pokeluaText("POLITOED", "蚊香蛙皇"),
 _pokeluaText("HOPPIP", "毽子草"), _pokeluaText("SKIPLOOM", "毽子花"), _pokeluaText("JUMPLUFF", "毽子棉"), _pokeluaText("AIPOM", "长尾怪手"), _pokeluaText("SUNKERN", "向日种子"), _pokeluaText("SUNFLORA", "向日花怪"), _pokeluaText("YANMA", "蜻蜻蜓"), _pokeluaText("WOOPER", "乌波"), _pokeluaText("QUAGSIRE", "沼王"), _pokeluaText("ESPEON", "太阳伊布"), _pokeluaText("UMBREON", "月亮伊布"), _pokeluaText("MURKROW", "黑暗鸦"),
 _pokeluaText("SLOWKING", "呆呆王"), _pokeluaText("MISDREAVUS", "梦妖"), _pokeluaText("UNOWN", "未知图腾"), _pokeluaText("WOBBUFFET", "果然翁"), _pokeluaText("GIRAFARIG", "麒麟奇"), _pokeluaText("PINECO", "榛果球"), _pokeluaText("FORRETRESS", "佛烈托斯"), _pokeluaText("DUNSPARCE", "土龙弟弟"), _pokeluaText("GLIGAR", "天蝎"), _pokeluaText("STEELIX", "大钢蛇"), _pokeluaText("SNUBBULL", "布鲁"),
 _pokeluaText("GRANBULL", "布鲁皇"), _pokeluaText("QWILFISH", "千针鱼"), _pokeluaText("SCIZOR", "巨钳螳螂"), _pokeluaText("SHUCKLE", "壶壶"), _pokeluaText("HERACROSS", "赫拉克罗斯"), _pokeluaText("SNEASEL", "狃拉"), _pokeluaText("TEDDIURSA", "熊宝宝"), _pokeluaText("URSARING", "圈圈熊"), _pokeluaText("SLUGMA", "熔岩虫"), _pokeluaText("MAGCARGO", "熔岩蜗牛"), _pokeluaText("SWINUB", "小山猪"),
 _pokeluaText("PILOSWINE", "长毛猪"), _pokeluaText("CORSOLA", "太阳珊瑚"), _pokeluaText("REMORAID", "铁炮鱼"), _pokeluaText("OCTILLERY", "章鱼桶"), _pokeluaText("DELIBIRD", "信使鸟"), _pokeluaText("MANTINE", "巨翅飞鱼"), _pokeluaText("SKARMORY", "盔甲鸟"), _pokeluaText("HOUNDOUR", "戴鲁比"), _pokeluaText("HOUNDOOM", "黑鲁加"), _pokeluaText("KINGDRA", "刺龙王"), _pokeluaText("PHANPY", "小小象"),
 _pokeluaText("DONPHAN", "顿甲"), _pokeluaText("PORYGON2", "多边兽2型"), _pokeluaText("STANTLER", "惊角鹿"), _pokeluaText("SMEARGLE", "图图犬"), _pokeluaText("TYROGUE", "无畏小子"), _pokeluaText("HITMONTOP", "战舞郎"), _pokeluaText("SMOOCHUM", "迷唇娃"), _pokeluaText("ELEKID", "电击怪"), _pokeluaText("MAGBY", "鸭嘴宝宝"), _pokeluaText("MILTANK", "大奶罐"), _pokeluaText("BLISSEY", "幸福蛋"), _pokeluaText("RAIKOU", "雷公"),
 _pokeluaText("ENTEI", "炎帝"), _pokeluaText("SUICUNE", "水君"), _pokeluaText("LARVITAR", "幼基拉斯"), _pokeluaText("PUPITAR", "沙基拉斯"), _pokeluaText("TYRANITAR", "班基拉斯"), _pokeluaText("LUGIA", "洛奇亚"), _pokeluaText("HO-OH", "凤王"), _pokeluaText("CELEBI", "时拉比"),
 -- Gen 3
 _pokeluaText("TREECKO", "木守宫"), _pokeluaText("GROVYLE", "森林蜥蜴"), _pokeluaText("SCEPTILE", "蜥蜴王"), _pokeluaText("TORCHIC", "火稚鸡"), _pokeluaText("COMBUSKEN", "力壮鸡"), _pokeluaText("BLAZIKEN", "火焰鸡"), _pokeluaText("MUDKIP", "水跃鱼"), _pokeluaText("MARSHTOMP", "沼跃鱼"), _pokeluaText("SWAMPERT", "巨沼怪"), _pokeluaText("POOCHYENA", "土狼犬"), _pokeluaText("MIGHTYENA", "大狼犬"),
 _pokeluaText("ZIGZAGOON", "蛇纹熊"), _pokeluaText("LINOONE", "直冲熊"), _pokeluaText("WURMPLE", "刺尾虫"), _pokeluaText("SILCOON", "甲壳茧"), _pokeluaText("BEAUTIFLY", "狩猎凤蝶"), _pokeluaText("CASCOON", "盾甲茧"), _pokeluaText("DUSTOX", "毒粉蛾"), _pokeluaText("LOTAD", "莲叶童子"), _pokeluaText("LOMBRE", "莲帽小童"), _pokeluaText("LUDICOLO", "乐天河童"), _pokeluaText("SEEDOT", "橡实果"), _pokeluaText("NUZLEAF", "长鼻叶"),
 _pokeluaText("SHIFTRY", "狡猾天狗"), _pokeluaText("TAILLOW", "傲骨燕"), _pokeluaText("SWELLOW", "大王燕"), _pokeluaText("WINGULL", "长翅鸥"), _pokeluaText("PELIPPER", "大嘴鸥"), _pokeluaText("RALTS", "拉鲁拉丝"), _pokeluaText("KIRLIA", "奇鲁莉安"), _pokeluaText("GARDEVOIR", "沙奈朵"), _pokeluaText("SURSKIT", "溜溜糖球"), _pokeluaText("MASQUERAIN", "雨翅蛾"), _pokeluaText("SHROOMISH", "蘑蘑菇"), _pokeluaText("BRELOOM", "斗笠菇"),
 _pokeluaText("SLAKOTH", "懒人獭"), _pokeluaText("VIGOROTH", "过动猿"), _pokeluaText("SLAKING", "请假王"), _pokeluaText("NINCADA", "土居忍士"), _pokeluaText("NINJASK", "铁面忍者"), _pokeluaText("SHEDINJA", "脱壳忍者"), _pokeluaText("WHISMUR", "咕妞妞"), _pokeluaText("LOUDRED", "吼爆弹"), _pokeluaText("EXPLOUD", "爆音怪"), _pokeluaText("MAKUHITA", "幕下力士"), _pokeluaText("HARIYAMA", "铁掌力士"), _pokeluaText("AZURILL", "露力丽"),
 _pokeluaText("NOSEPASS", "朝北鼻"), _pokeluaText("SKITTY", "向尾喵"), _pokeluaText("DELCATTY", "优雅猫"), _pokeluaText("SABLEYE", "勾魂眼"), _pokeluaText("MAWILE", "大嘴娃"), _pokeluaText("ARON", "可可多拉"), _pokeluaText("LAIRON", "可多拉"), _pokeluaText("AGGRON", "波士可多拉"), _pokeluaText("MEDITITE", "玛沙那"), _pokeluaText("MEDICHAM", "恰雷姆"), _pokeluaText("ELECTRIKE", "落雷兽"), _pokeluaText("MANECTRIC", "雷电兽"),
 _pokeluaText("PLUSLE", "正电拍拍"), _pokeluaText("MINUN", "负电拍拍"), _pokeluaText("VOLBEAT", "电萤虫"), _pokeluaText("ILLUMISE", "甜甜萤"), _pokeluaText("ROSELIA", "毒蔷薇"), _pokeluaText("GULPIN", "溶食兽"), _pokeluaText("SWALOT", "吞食兽"), _pokeluaText("CARVANHA", "利牙鱼"), _pokeluaText("SHARPEDO", "巨牙鲨"), _pokeluaText("WAILMER", "吼吼鲸"), _pokeluaText("WAILORD", "吼鲸王"), _pokeluaText("NUMEL", "呆火驼"),
 _pokeluaText("CAMERUPT", "喷火驼"), _pokeluaText("TORKOAL", "煤炭龟"), _pokeluaText("SPOINK", "跳跳猪"), _pokeluaText("GRUMPIG", "噗噗猪"), _pokeluaText("SPINDA", "晃晃斑"), _pokeluaText("TRAPINCH", "大颚蚁"), _pokeluaText("VIBRAVA", "超音波幼虫"), _pokeluaText("FLYGON", "沙漠蜻蜓"), _pokeluaText("CACNEA", "刺球仙人掌"), _pokeluaText("CACTURNE", "梦歌仙人掌"), _pokeluaText("SWABLU", "青绵鸟"), _pokeluaText("ALTARIA", "七夕青鸟"),
 _pokeluaText("ZANGOOSE", "猫鼬斩"), _pokeluaText("SEVIPER", "饭匙蛇"), _pokeluaText("LUNATONE", "月石"), _pokeluaText("SOLROCK", "太阳岩"), _pokeluaText("BARBOACH", "泥泥鳅"), _pokeluaText("WHISCASH", "鲶鱼王"), _pokeluaText("CORPHISH", "龙虾小兵"), _pokeluaText("CRAWDAUNT", "铁螯龙虾"), _pokeluaText("BALTOY", "天秤偶"), _pokeluaText("CLAYDOL", "念力土偶"), _pokeluaText("LILEEP", "触手百合"), _pokeluaText("CRADILY", "摇篮百合"),
 _pokeluaText("ANORITH", "太古羽虫"), _pokeluaText("ARMALDO", "太古盔甲"), _pokeluaText("FEEBAS", "丑丑鱼"), _pokeluaText("MILOTIC", "美纳斯"), _pokeluaText("CASTFORM", "飘浮泡泡"), _pokeluaText("KECLEON", "变隐龙"), _pokeluaText("SHUPPET", "怨影娃娃"), _pokeluaText("BANETTE", "诅咒娃娃"), _pokeluaText("DUSKULL", "夜巡灵"), _pokeluaText("DUSCLOPS", "彷徨夜灵"), _pokeluaText("TROPIUS", "热带龙"), _pokeluaText("CHIMECHO", "风铃铃"),
 _pokeluaText("ABSOL", "阿勃梭鲁"), _pokeluaText("WYNAUT", "小果然"), _pokeluaText("SNORUNT", "雪童子"), _pokeluaText("GLALIE", "冰鬼护"), _pokeluaText("SPHEAL", "海豹球"), _pokeluaText("SEALEO", "海魔狮"), _pokeluaText("WALREIN", "帝牙海狮"), _pokeluaText("CLAMPERL", "珍珠贝"), _pokeluaText("HUNTAIL", "猎斑鱼"), _pokeluaText("GOREBYSS", "樱花鱼"), _pokeluaText("RELICANTH", "古空棘鱼"), _pokeluaText("LUVDISC", "爱心鱼"), _pokeluaText("BAGON", "宝贝龙"),
 _pokeluaText("SHELGON", "甲壳龙"), _pokeluaText("SALAMENCE", "暴飞龙"), _pokeluaText("BELDUM", "铁哑铃"), _pokeluaText("METANG", "金属怪"), _pokeluaText("METAGROSS", "巨金怪"), _pokeluaText("REGIROCK", "雷吉洛克"), _pokeluaText("REGICE", "雷吉艾斯"), _pokeluaText("REGISTEEL", "雷吉斯奇鲁"), _pokeluaText("LATIAS", "拉帝亚斯"), _pokeluaText("LATIOS", "拉帝欧斯"), _pokeluaText("KYOGRE", "盖欧卡"), _pokeluaText("GROUDON", "固拉多"),
 _pokeluaText("RAYQUAZA", "烈空坐"), _pokeluaText("JIRACHI", "基拉祈"), _pokeluaText("DEOXYS", "代欧奇希斯")}

local nationalDexList = {
 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
 51,  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74,
 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139,
 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179,
 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199,
 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219,
 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 387, 388, 389, 390, 391, 392, 393, 394,
 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 252, 253, 254,
 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274,
 275, 290, 291, 292, 276, 277, 285, 286, 327, 278, 279, 283, 284, 320, 321, 300, 301, 352, 343, 344,
 299, 324, 302, 339, 340, 370, 341, 342, 349, 350, 318, 319, 328, 329, 330, 296, 297, 309, 310, 322,
 323, 363, 364, 365, 331, 332, 361, 362, 337, 338, 298, 325, 326, 311, 312, 303, 307, 308, 333, 334,
 360, 355, 356, 315, 287, 288, 289, 316, 317, 357, 293, 294, 295, 366, 367, 368, 359, 353, 354, 336,
 335, 369, 304, 305, 306, 351, 313, 314, 345, 346, 347, 348, 280, 281, 282, 371, 372, 373, 374, 375,
 376, 377, 378, 379, 382, 383, 384, 380, 381, 385, 386, 358}

local catchRatesList = {
 -- Gen 1
 0, 45, 45, 45, 45, 45, 45, 45, 45, 45, 255, 120, 90, 255, 120, 90, 255, 120,
 45, 255, 127, 255, 90, 255, 90, 190, 75, 255, 90, 235, 120, 45, 235, 120,
 45, 150, 25, 190, 75, 170, 50, 255, 90, 255, 120, 45, 190, 75, 190, 120,
 255, 100, 255, 90, 190, 120, 190, 80, 190, 75, 255, 120, 90, 200, 100, 50,
 180, 90, 45, 255, 120, 45, 190, 60, 255, 120, 45, 190, 110, 190, 75, 190,
 110, 80, 190, 90, 190, 75, 190, 75, 190, 60, 190, 90, 45, 45, 190, 80, 225,
 60, 190, 60, 90, 80, 190, 110, 90, 90, 90, 190, 60, 120, 100, 70, 90, 90,
 225, 75, 225, 60, 225, 110, 90, 90, 45, 90, 90, 90, 80, 255, 45, 80, 35, 45,
 45, 45, 45, 45, 45, 45, 45, 45, 45, 70, 25, 25, 25, 45, 45, 45, 3, 45,
 -- Gen2
 45, 180, 45, 45, 180, 45, 45, 180, 45, 255, 90, 255, 90, 255, 90, 255, 90,
 90, 190, 75, 190, 150, 170, 190, 45, 190, 75, 235, 120, 45, 45, 190, 75, 65,
 45, 255, 120, 45, 45, 235, 120, 75, 255, 90, 45, 45, 30, 70, 90, 225, 45, 60,
 190, 75, 190, 60, 25, 190, 75, 45, 25, 190, 45, 60, 120, 60, 190, 120, 225,
 75, 60, 190, 75, 45, 90, 15, 225, 45, 45, 120, 60, 45, 45, 45, 75, 45, 45, 45,
 45, 45, 30, 15, 15, 15, 45, 45, 10, 3, 3, 45,
 -- Gen3
 45, 45, 45, 45, 45, 45, 45, 45, 45, 255, 127, 255, 90, 255, 120, 45, 120, 45,
 255, 120, 45, 255, 120, 45, 200, 90, 255, 45, 235, 120, 45, 200, 75, 255, 90,
 255, 120, 45, 255, 120, 45, 190, 120, 45, 255, 200, 150, 255, 255, 120, 90, 120,
 180, 90, 45, 180, 90, 120, 80, 200, 200, 150, 150, 150, 225, 75, 225, 60, 125,
 60, 255, 150, 90, 255, 60, 255, 255, 120, 45, 190, 60, 255, 80, 90, 90, 100, 90,
 190, 75, 205, 155, 255, 90, 45, 45, 45, 45, 255, 60, 45, 200, 225, 90, 190, 90,
 45, 45, 30, 125, 190, 75, 255, 120, 45, 255, 60, 60, 25, 225, 45, 45, 80, 3, 3,
 15, 3, 3, 3, 3, 3, 5, 5, 3, 3, 3}

function LCRNG(s, mul, sum)
 local a = (mul >> 16) * (s % 0x10000) + (s >> 16) * (mul % 0x10000)
 local b = (mul % 0x10000) * (s % 0x10000) + (a % 0x10000) * 0x10000 + sum

 return b % 0x100000000
end

local tempCurrentSeed = 0

function LCRNGDistance(state0, state1)
 local mask = 1
 local dist = 0

 if state0 ~= state1 then
  for _, data in ipairs(JUMP_DATA) do
   local mult, add = table.unpack(data)

   if state0 == state1 then
    break
   end

   if ((state0 ~ state1) & mask) ~= 0 then
    state0 = LCRNG(state0, mult, add)
    dist = dist + mask
   end

   mask = mask << 1
  end

  tempCurrentSeed = state1
 end

 return dist > 1000000 and dist - 0x100000000 or dist
end

local boxSelectedPokemonAddr, enemyAddr, boxFlagAddr, currentSeedAddr, boxPointerAddr, pointerAddr, initialSeed, advances

function onScriptStart()
 local gameLang = read8Bit(0x3)

 if gameLang == 0x45 then -- U
  boxSelectedPokemonAddr = 0x3A95EC
  enemyAddr = 0x473070
  boxFlagAddr = 0x478B1A
  currentSeedAddr = 0x478C90
  boxPointerAddr = 0x47ADB8
  pointerAddr = 0x7EFDCC
 elseif gameLang == 0x4A then -- J
  boxSelectedPokemonAddr = 0x395CBC
  enemyAddr = 0x45E750
  boxFlagAddr = 0x4641EA
  currentSeedAddr = 0x464360
  boxPointerAddr = 0x466468
  pointerAddr = 0x75E088
 else -- E
  boxSelectedPokemonAddr = 0x3F6A6C
  enemyAddr = 0x4C0508
  boxFlagAddr = 0x4C5FBA
  currentSeedAddr = 0x4C6130
  boxPointerAddr = 0x4C8268
  pointerAddr = 0x90C300
 end

 initialSeed = read32Bit(currentSeedAddr)
 tempCurrentSeed = initialSeed
 advances = 0
end

function getTrainerIDs(pointer)
 local trainerIDsAddr = pointer + 0x7FFE42E0
 local trainerIDs = read32Bit(trainerIDsAddr)
 local TID = trainerIDs & 0xFFFF
 local SID = trainerIDs >> 16

 return TID, SID
end

function setPadding(maxLength, goodSpacing, stringVar)
 local spaces = ""
 local stringVarLength = string.len(stringVar)

 if stringVarLength <= maxLength then
  local padding = maxLength - stringVarLength

  for i = 0, padding + goodSpacing do
   spaces = spaces.." "
  end
 end

 return spaces
end

function calcCatchRate(HP, bonusBall, rate)
 if HP ~= 0 then
  local a = (HP * rate * bonusBall) // (3 * HP)

  return 1048560 // math.sqrt(math.sqrt(16711680 // a))
 end

 return 0
end

function getPokemonInfo(addr, trainerTID, trainerSID)
 trainerTID = trainerTID or nil
 trainerSID = trainerSID or nil

 local pokemonPID = read32Bit(addr)
 local speciesDexIndex = read16Bit(addr - 0x4)
 local OTSID = trainerSID and trainerSID or read16Bit(addr + 0x10)
 local OTID = trainerTID and trainerTID or read16Bit(addr + 0x12)

 local ivsAddr = addr + 0xA1
 local hpIV = read8Bit(ivsAddr)
 local atkIV = read8Bit(ivsAddr + 0x2)
 local defIV = read8Bit(ivsAddr + 0x4)
 local spAtkIV = read8Bit(ivsAddr + 0x6)
 local spDefIV = read8Bit(ivsAddr + 0x8)
 local spdIV = read8Bit(ivsAddr + 0xA)

 local speciesDexNumber = nationalDexList[((speciesDexIndex > 411 or speciesDexIndex < 1) and 0 or speciesDexIndex) + 1] + 1
 local speciesName = speciesNamesList[speciesDexNumber]
 speciesName = speciesName..setPadding(10, 5, speciesName)
 local natureName = natureNamesList[(pokemonPID % 25) + 1]
 natureName = natureName..setPadding(7, 9, natureName)

 local hpType = (((hpIV & 1) + (2 * (atkIV & 1)) + (4 * (defIV & 1)) + (8 * (spdIV & 1)) + (16 * (spAtkIV & 1))
                + (32 * (spDefIV & 1))) * 15) // 63
 local hpPower = (((((hpIV >> 1) & 1) + (2 * ((atkIV >> 1) & 1)) + (4 * ((defIV >> 1) & 1)) + (8 * ((spdIV >> 1) & 1))
                 + (16 * ((spAtkIV >> 1) & 1)) + (32 * ((spDefIV >> 1) & 1))) * 40) // 63) + 30

 local catchRateValue = calcCatchRate(read16Bit(addr + 0x86), 1, catchRatesList[speciesDexNumber])

 return pokemonPID, OTSID, OTID, speciesName, natureName, hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV, hpType, hpPower, catchRateValue
end

function isBoxOpened()
 return read16Bit(boxFlagAddr) == 0x391
end

function shinyCheck(PID, trainerID, trainerSID)
 local lowPID = PID & 0xFFFF
 local highPID = PID >> 16
 local shinyTypeValue = trainerID ~ trainerSID ~ lowPID ~ highPID

 if shinyTypeValue < 8 then
  return shinyTypeValue == 0 and _pokeluaText(" (Square)   ", "（方块）   ") or _pokeluaText(" (Star)     ", "（星星）     ")
 end

 return "            "
end

function getPokemonInfoText(pointer, trainerTID, trainerSID)
 local text = ""

 local boxPID, boxOTID, boxOTSID, boxSpeciesName, boxNatureName, boxHpIV, boxAtkIV, boxDefIV, boxSpAtkIV, boxSpDefIV, boxSpdIV, boxHpType,
       boxHpPower, boxCatchRateValue = getPokemonInfo(isBoxOpened() and boxSelectedPokemonAddr or read32Bit(boxPointerAddr) + 0xBA0)  -- Current selected Pokémon or 1st slot of 1st box

 for i = 0, 5 do
  local enemyPID, enemyOTID, enemyOTSID, enemySpeciesName, enemyNatureName, enemyHpIV, enemyAtkIV, enemyDefIV, enemySpAtkIV, enemySpDefIV,
        enemySpdIV, enemyHpType, enemyHpPower, enemyCatchRateValue = getPokemonInfo(enemyAddr + (0x138 * i), trainerTID, trainerSID)

  local partyAddr = pointer + 0x7FFE42E8
  local partyPID, partyOTID, partyOTSID, partySpeciesName, partyNatureName, partyHpIV, partyAtkIV, partyDefIV, partySpAtkIV, partySpDefIV,
        partySpdIV, partyHpType, partyHpPower, partyCatchRateValue = getPokemonInfo(partyAddr + (0x138 * i))

  local speciesText = string.format(_pokeluaText("Species: %sSpecies: %s", "种类：%s种类：%s"), enemySpeciesName, partySpeciesName)..(i == 0 and string.format(_pokeluaText("Species: %s", "种类：%s"), boxSpeciesName) or "")
  local PIDsText = string.format(_pokeluaText("\nPID: %08X%sPID: %08X%s", "\nPID：%08X%sPID：%08X%s"), enemyPID, shinyCheck(enemyPID, enemyOTID, enemyOTSID), partyPID, shinyCheck(partyPID, partyOTID, partyOTSID))..
                   (i == 0 and string.format(_pokeluaText("PID: %08X%s", "PID：%08X%s"), boxPID, shinyCheck(boxPID, boxOTID, boxOTSID)) or "")
  local naturesText = string.format(_pokeluaText("\nNature: %sNature: %s", "\n性格：%s性格：%s"), enemyNatureName, partyNatureName)..(i == 0 and string.format(_pokeluaText("Nature: %s", "性格：%s"), boxNatureName) or "")
  local ivsText = string.format(_pokeluaText("\nIVs: %02d/%02d/%02d/%02d/%02d/%02d   IVs: %02d/%02d/%02d/%02d/%02d/%02d", "\n个体值：%02d/%02d/%02d/%02d/%02d/%02d   个体值：%02d/%02d/%02d/%02d/%02d/%02d"),
                                enemyHpIV, enemyAtkIV, enemyDefIV, enemySpAtkIV, enemySpDefIV, enemySpdIV, partyHpIV, partyAtkIV, partyDefIV, partySpAtkIV, partySpDefIV, partySpdIV)..
                                (i == 0 and string.format(_pokeluaText("   IVs: %02d/%02d/%02d/%02d/%02d/%02d", "   个体值：%02d/%02d/%02d/%02d/%02d/%02d"), boxHpIV, boxAtkIV, boxDefIV, boxSpAtkIV, boxSpDefIV, boxSpdIV) or "")
  local HPText = string.format(_pokeluaText("\nHPower: %s %02d", "\n觉醒力量：%s %02d"), HPTypeNamesList[enemyHpType + 1], enemyHpPower)..setPadding(11, 5, string.format("%s %02d", HPTypeNamesList[enemyHpType + 1], enemyHpPower))..
                 string.format(_pokeluaText("HPower: %s %02d", "觉醒力量：%s %02d"), HPTypeNamesList[partyHpType + 1], partyHpPower)..
                 (i == 0 and setPadding(11, 5, string.format("%s %02d", HPTypeNamesList[partyHpType + 1], partyHpPower))..
                 string.format(_pokeluaText("HPower: %s %02d", "觉醒力量：%s %02d"), HPTypeNamesList[boxHpType + 1], boxHpPower) or "")
  local catchRngText = string.format(_pokeluaText("\nCatch Rate Value: %d\n\n", "\n捕获率值：%d\n\n"), enemyCatchRateValue)

  text = text..speciesText..PIDsText..naturesText..ivsText..HPText..catchRngText
 end

 return text
end

function onScriptUpdate()
 local currentSeed = read32Bit(currentSeedAddr)
 advances = advances + LCRNGDistance(tempCurrentSeed, currentSeed)
 local pointer = read32Bit(pointerAddr)
 local trainerTID, trainerSID = 0, 0

 local RNGInfoText = string.format(_pokeluaText("Initial Seed: %08X\nCurrent Seed: %08X\nAdvances: %d", "初始种子：%08X\n当前种子：%08X\n推进数：%d"), initialSeed, currentSeed, advances)
 local infoText = "\n\n"

 if pointer ~= 0 then
  trainerTID, trainerSID = getTrainerIDs(pointer)
  infoText = string.format(_pokeluaText("\n\nOpponent                 Party                    Box\n\n", "\n\n对手                 同行                    盒子\n\n"))..getPokemonInfoText(pointer, trainerTID, trainerSID)
 end

 local IDsInfoText = string.format(_pokeluaText("\nTID: %05d\nSID: %05d", "\nTID：%05d\nSID：%05d"), trainerTID, trainerSID)

 SetScreenText(RNGInfoText..infoText..IDsInfoText)
end

function onScriptCancel()
 SetScreenText("")
end

function onStateLoaded()
end

function onStateSaved()
end