-- Optional display language: "en" or "zh-Hans". Reload after changing.
-- 可选显示语言：英文 "en"／简体中文 "zh-Hans"。修改后重新加载脚本。
local POKELUA_LANGUAGE = "en"
local function _pokeluaText(english, chinese)
 if POKELUA_LANGUAGE == "zh-Hans" then return chinese end
 return english
end
-- END POKELUA LOCALIZATION

local botTargetInitialSeeds = {}  -- Write the bot target Initial Seeds you prefer inside the brackets preceding this text (e.g. {0, 0xBAD, 0xDEAD, 0xBEEF, 0xDAD, 0x1EE7, 0xDEAF, 0xB0B, 0xFEE, 0xFADE})
local botTargetTIDs = {}  -- Write the bot target TIDs you prefer inside the brackets preceding this text (e.g. {0, 1, 1337, 8453, 8411, 11233, 11111, 22222, 33333, 12345})

local JUMP_DATA = {
 {0x41C64E6D, 0x6073}, {0xC2A29A69, 0xE97E7B6A}, {0xEE067F11, 0x31B0DDE4}, {0xCFDDDF21, 0x67DBB608},
 {0x5F748241, 0xCBA72510}, {0x8B2E1481, 0x1D29AE20}, {0x76006901, 0xBA84EC40}, {0x1711D201, 0x79F01880},
 {0xBE67A401, 0x8793100}, {0xDDDF4801, 0x6B566200}, {0x3FFE9001, 0x803CC400}, {0x90FD2001, 0xA6B98800},
 {0x65FA4001, 0xE6731000}, {0xDBF48001, 0x30E62000}, {0xF7E90001, 0xF1CC4000}, {0xEFD20001, 0x23988000},
 {0xDFA40001, 0x47310000}, {0xBF480001, 0x8E620000}, {0x7E900001, 0x1CC40000}, {0xFD200001, 0x39880000},
 {0xFA400001, 0x73100000}, {0xF4800001, 0xE6200000}, {0xE9000001, 0xCC400000}, {0xD2000001, 0x98800000},
 {0xA4000001, 0x31000000}, {0x48000001, 0x62000000}, {0x90000001, 0xC4000000}, {0x20000001, 0x88000000},
 {0x40000001, 0x10000000}, {0x80000001, 0x20000000}, {0x1, 0x40000000}, {0x1, 0x80000000}}

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
 _pokeluaText("Bulbasaur", "妙蛙种子"), _pokeluaText("Ivysaur", "妙蛙草"), _pokeluaText("Venusaur", "妙蛙花"), _pokeluaText("Charmander", "小火龙"), _pokeluaText("Charmeleon", "火恐龙"), _pokeluaText("Charizard", "喷火龙"), _pokeluaText("Squirtle", "杰尼龟"), _pokeluaText("Wartortle", "卡咪龟"), _pokeluaText("Blastoise", "水箭龟"),
 _pokeluaText("Caterpie", "绿毛虫"), _pokeluaText("Metapod", "铁甲蛹"), _pokeluaText("Butterfree", "巴大蝶"), _pokeluaText("Weedle", "独角虫"), _pokeluaText("Kakuna", "铁壳蛹"), _pokeluaText("Beedrill", "大针蜂"), _pokeluaText("Pidgey", "波波"), _pokeluaText("Pidgeotto", "比比鸟"), _pokeluaText("Pidgeot", "大比鸟"), _pokeluaText("Rattata", "小拉达"),
 _pokeluaText("Raticate", "拉达"), _pokeluaText("Spearow", "烈雀"), _pokeluaText("Fearow", "大嘴雀"), _pokeluaText("Ekans", "阿柏蛇"), _pokeluaText("Arbok", "阿柏怪"), _pokeluaText("Pikachu", "皮卡丘"), _pokeluaText("Raichu", "雷丘"), _pokeluaText("Sandshrew", "穿山鼠"), _pokeluaText("Sandslash", "穿山王"), _pokeluaText("Nidoran♀", "尼多兰"),
 _pokeluaText("Nidorina", "尼多娜"), _pokeluaText("Nidoqueen", "尼多后"), _pokeluaText("Nidoran♂", "尼多朗"), _pokeluaText("Nidorino", "尼多力诺"), _pokeluaText("Nidoking", "尼多王"), _pokeluaText("Clefairy", "皮皮"), _pokeluaText("Clefable", "皮可西"), _pokeluaText("Vulpix", "六尾"), _pokeluaText("Ninetales", "九尾"),
 _pokeluaText("Jigglypuff", "胖丁"), _pokeluaText("Wigglytuff", "胖可丁"), _pokeluaText("Zubat", "超音蝠"), _pokeluaText("Golbat", "大嘴蝠"), _pokeluaText("Oddish", "走路草"), _pokeluaText("Gloom", "臭臭花"), _pokeluaText("Vileplume", "霸王花"), _pokeluaText("Paras", "派拉斯"), _pokeluaText("Parasect", "派拉斯特"), _pokeluaText("Venonat", "毛球"),
 _pokeluaText("Venomoth", "摩鲁蛾"), _pokeluaText("Diglett", "地鼠"), _pokeluaText("Dugtrio", "三地鼠"), _pokeluaText("Meowth", "喵喵"), _pokeluaText("Persian", "猫老大"), _pokeluaText("Psyduck", "可达鸭"), _pokeluaText("Golduck", "哥达鸭"), _pokeluaText("Mankey", "猴怪"), _pokeluaText("Primeape", "火暴猴"), _pokeluaText("Growlithe", "卡蒂狗"),
 _pokeluaText("Arcanine", "风速狗"), _pokeluaText("Poliwag", "蚊香蝌蚪"), _pokeluaText("Poliwhirl", "蚊香君"), _pokeluaText("Poliwrath", "蚊香泳士"), _pokeluaText("Abra", "凯西"), _pokeluaText("Kadabra", "勇基拉"), _pokeluaText("Alakazam", "胡地"), _pokeluaText("Machop", "腕力"), _pokeluaText("Machoke", "豪力"), _pokeluaText("Machamp", "怪力"),
 _pokeluaText("Bellsprout", "喇叭芽"), _pokeluaText("Weepinbell", "口呆花"), _pokeluaText("Victreebel", "大食花"), _pokeluaText("Tentacool", "玛瑙水母"), _pokeluaText("Tentacruel", "毒刺水母"), _pokeluaText("Geodude", "小拳石"), _pokeluaText("Graveler", "隆隆石"), _pokeluaText("Golem", "隆隆岩"), _pokeluaText("Ponyta", "小火马"),
 _pokeluaText("Rapidash", "烈焰马"), _pokeluaText("Slowpoke", "呆呆兽"), _pokeluaText("Slowbro", "呆壳兽"), _pokeluaText("Magnemite", "小磁怪"), _pokeluaText("Magneton", "三合一磁怪"), _pokeluaText("Farfetch'd", "大葱鸭"), _pokeluaText("Doduo", "嘟嘟"), _pokeluaText("Dodrio", "嘟嘟利"), _pokeluaText("Seel", "小海狮"), _pokeluaText("Dewgong", "白海狮"),
 _pokeluaText("Grimer", "臭泥"), _pokeluaText("Muk", "臭臭泥"), _pokeluaText("Shellder", "大舌贝"), _pokeluaText("Cloyster", "刺甲贝"), _pokeluaText("Gastly", "鬼斯"), _pokeluaText("Haunter", "鬼斯通"), _pokeluaText("Gengar", "耿鬼"), _pokeluaText("Onix", "大岩蛇"), _pokeluaText("Drowzee", "催眠貘"), _pokeluaText("Hypno", "引梦貘人"), _pokeluaText("Krabby", "大钳蟹"),
 _pokeluaText("Kingler", "巨钳蟹"), _pokeluaText("Voltorb", "霹雳电球"), _pokeluaText("Electrode", "顽皮雷弹"), _pokeluaText("Exeggcute", "蛋蛋"), _pokeluaText("Exeggutor", "椰蛋树"), _pokeluaText("Cubone", "卡拉卡拉"), _pokeluaText("Marowak", "嘎啦嘎啦"), _pokeluaText("Hitmonlee", "飞腿郎"), _pokeluaText("Hitmonchan", "快拳郎"),
 _pokeluaText("Lickitung", "大舌头"), _pokeluaText("Koffing", "瓦斯弹"), _pokeluaText("Weezing", "双弹瓦斯"), _pokeluaText("Rhyhorn", "独角犀牛"), _pokeluaText("Rhydon", "钻角犀兽"), _pokeluaText("Chansey", "吉利蛋"), _pokeluaText("Tangela", "蔓藤怪"), _pokeluaText("Kangaskhan", "袋兽"), _pokeluaText("Horsea", "墨海马"), _pokeluaText("Seadra", "海刺龙"),
 _pokeluaText("Goldeen", "角金鱼"), _pokeluaText("Seaking", "金鱼王"), _pokeluaText("Staryu", "海星星"), _pokeluaText("Starmie", "宝石海星"), _pokeluaText("Mr. Mime", "魔墙人偶"), _pokeluaText("Scyther", "飞天螳螂"), _pokeluaText("Jynx", "迷唇姐"), _pokeluaText("Electabuzz", "电击兽"), _pokeluaText("Magmar", "鸭嘴火兽"), _pokeluaText("Pinsir", "凯罗斯"),
 _pokeluaText("Tauros", "肯泰罗"), _pokeluaText("Magikarp", "鲤鱼王"), _pokeluaText("Gyarados", "暴鲤龙"), _pokeluaText("Lapras", "拉普拉斯"), _pokeluaText("Ditto", "百变怪"), _pokeluaText("Eevee", "伊布"), _pokeluaText("Vaporeon", "水伊布"), _pokeluaText("Jolteon", "雷伊布"), _pokeluaText("Flareon", "火伊布"), _pokeluaText("Porygon", "多边兽"),
 _pokeluaText("Omanyte", "菊石兽"), _pokeluaText("Omastar", "多刺菊石兽"), _pokeluaText("Kabuto", "化石盔"), _pokeluaText("Kabutops", "镰刀盔"), _pokeluaText("Aerodactyl", "化石翼龙"), _pokeluaText("Snorlax", "卡比兽"), _pokeluaText("Articuno", "急冻鸟"), _pokeluaText("Zapdos", "闪电鸟"), _pokeluaText("Moltres", "火焰鸟"), _pokeluaText("Dratini", "迷你龙"),
 _pokeluaText("Dragonair", "哈克龙"), _pokeluaText("Dragonite", "快龙"), _pokeluaText("Mewtwo", "超梦"), _pokeluaText("Mew", "梦幻"),
 -- Gen 2
 _pokeluaText("Chikorita", "菊草叶"), _pokeluaText("Bayleef", "月桂叶"), _pokeluaText("Meganium", "大竺葵"), _pokeluaText("Cyndaquil", "火球鼠"), _pokeluaText("Quilava", "火岩鼠"), _pokeluaText("Typhlosion", "火暴兽"), _pokeluaText("Totodile", "小锯鳄"), _pokeluaText("Croconaw", "蓝鳄"), _pokeluaText("Feraligatr", "大力鳄"),
 _pokeluaText("Sentret", "尾立"), _pokeluaText("Furret", "大尾立"), _pokeluaText("Hoothoot", "咕咕"), _pokeluaText("Noctowl", "猫头夜鹰"), _pokeluaText("Ledyba", "芭瓢虫"), _pokeluaText("Ledian", "安瓢虫"), _pokeluaText("Spinarak", "圆丝蛛"), _pokeluaText("Ariados", "阿利多斯"), _pokeluaText("Crobat", "叉字蝠"), _pokeluaText("Chinchou", "灯笼鱼"),
 _pokeluaText("Lanturn", "电灯怪"), _pokeluaText("Pichu", "皮丘"), _pokeluaText("Cleffa", "皮宝宝"), _pokeluaText("Igglybuff", "宝宝丁"), _pokeluaText("Togepi", "波克比"), _pokeluaText("Togetic", "波克基古"), _pokeluaText("Natu", "天然雀"), _pokeluaText("Xatu", "天然鸟"), _pokeluaText("Mareep", "咩利羊"), _pokeluaText("Flaaffy", "茸茸羊"), _pokeluaText("Ampharos", "电龙"),
 _pokeluaText("Bellossom", "美丽花"), _pokeluaText("Marill", "玛力露"), _pokeluaText("Azumarill", "玛力露丽"), _pokeluaText("Sudowoodo", "树才怪"), _pokeluaText("Politoed", "蚊香蛙皇"), _pokeluaText("Hoppip", "毽子草"), _pokeluaText("Skiploom", "毽子花"), _pokeluaText("Jumpluff", "毽子棉"), _pokeluaText("Aipom", "长尾怪手"), _pokeluaText("Sunkern", "向日种子"),
 _pokeluaText("Sunflora", "向日花怪"), _pokeluaText("Yanma", "蜻蜻蜓"), _pokeluaText("Wooper", "乌波"), _pokeluaText("Quagsire", "沼王"), _pokeluaText("Espeon", "太阳伊布"), _pokeluaText("Umbreon", "月亮伊布"), _pokeluaText("Murkrow", "黑暗鸦"), _pokeluaText("Slowking", "呆呆王"), _pokeluaText("Misdreavus", "梦妖"), _pokeluaText("Unown", "未知图腾"),
 _pokeluaText("Wobbuffet", "果然翁"), _pokeluaText("Girafarig", "麒麟奇"), _pokeluaText("Pineco", "榛果球"), _pokeluaText("Forretress", "佛烈托斯"), _pokeluaText("Dunsparce", "土龙弟弟"), _pokeluaText("Gligar", "天蝎"), _pokeluaText("Steelix", "大钢蛇"), _pokeluaText("Snubbull", "布鲁"), _pokeluaText("Granbull", "布鲁皇"),
 _pokeluaText("Qwilfish", "千针鱼"), _pokeluaText("Scizor", "巨钳螳螂"), _pokeluaText("Shuckle", "壶壶"), _pokeluaText("Heracross", "赫拉克罗斯"), _pokeluaText("Sneasel", "狃拉"), _pokeluaText("Teddiursa", "熊宝宝"), _pokeluaText("Ursaring", "圈圈熊"), _pokeluaText("Slugma", "熔岩虫"), _pokeluaText("Magcargo", "熔岩蜗牛"), _pokeluaText("Swinub", "小山猪"),
 _pokeluaText("Piloswine", "长毛猪"), _pokeluaText("Corsola", "太阳珊瑚"), _pokeluaText("Remoraid", "铁炮鱼"), _pokeluaText("Octillery", "章鱼桶"), _pokeluaText("Delibird", "信使鸟"), _pokeluaText("Mantine", "巨翅飞鱼"), _pokeluaText("Skarmory", "盔甲鸟"), _pokeluaText("Houndour", "戴鲁比"), _pokeluaText("Houndoom", "黑鲁加"),
 _pokeluaText("Kingdra", "刺龙王"), _pokeluaText("Phanpy", "小小象"), _pokeluaText("Donphan", "顿甲"), _pokeluaText("Porygon2", "多边兽2型"), _pokeluaText("Stantler", "惊角鹿"), _pokeluaText("Smeargle", "图图犬"), _pokeluaText("Tyrogue", "无畏小子"), _pokeluaText("Hitmontop", "战舞郎"), _pokeluaText("Smoochum", "迷唇娃"), _pokeluaText("Elekid", "电击怪"),
 _pokeluaText("Magby", "鸭嘴宝宝"), _pokeluaText("Miltank", "大奶罐"), _pokeluaText("Blissey", "幸福蛋"), _pokeluaText("Raikou", "雷公"), _pokeluaText("Entei", "炎帝"), _pokeluaText("Suicune", "水君"), _pokeluaText("Larvitar", "幼基拉斯"), _pokeluaText("Pupitar", "沙基拉斯"), _pokeluaText("Tyranitar", "班基拉斯"), _pokeluaText("Lugia", "洛奇亚"), _pokeluaText("Ho-Oh", "凤王"),
 _pokeluaText("Celebi", "时拉比"),
 -- Gen 3
 _pokeluaText("Treecko", "木守宫"), _pokeluaText("Grovyle", "森林蜥蜴"), _pokeluaText("Sceptile", "蜥蜴王"), _pokeluaText("Torchic", "火稚鸡"), _pokeluaText("Combusken", "力壮鸡"), _pokeluaText("Blaziken", "火焰鸡"), _pokeluaText("Mudkip", "水跃鱼"), _pokeluaText("Marshtomp", "沼跃鱼"), _pokeluaText("Swampert", "巨沼怪"),
 _pokeluaText("Poochyena", "土狼犬"), _pokeluaText("Mightyena", "大狼犬"), _pokeluaText("Zigzagoon", "蛇纹熊"), _pokeluaText("Linoone", "直冲熊"), _pokeluaText("Wurmple", "刺尾虫"), _pokeluaText("Silcoon", "甲壳茧"), _pokeluaText("Beautifly", "狩猎凤蝶"), _pokeluaText("Cascoon", "盾甲茧"), _pokeluaText("Dustox", "毒粉蛾"), _pokeluaText("Lotad", "莲叶童子"),
 _pokeluaText("Lombre", "莲帽小童"), _pokeluaText("Ludicolo", "乐天河童"), _pokeluaText("Seedot", "橡实果"), _pokeluaText("Nuzleaf", "长鼻叶"), _pokeluaText("Shiftry", "狡猾天狗"), _pokeluaText("Taillow", "傲骨燕"), _pokeluaText("Swellow", "大王燕"), _pokeluaText("Wingull", "长翅鸥"), _pokeluaText("Pelipper", "大嘴鸥"), _pokeluaText("Ralts", "拉鲁拉丝"),
 _pokeluaText("Kirlia", "奇鲁莉安"), _pokeluaText("Gardevoir", "沙奈朵"), _pokeluaText("Surskit", "溜溜糖球"), _pokeluaText("Masquerain", "雨翅蛾"), _pokeluaText("Shroomish", "蘑蘑菇"), _pokeluaText("Breloom", "斗笠菇"), _pokeluaText("Slakoth", "懒人獭"), _pokeluaText("Vigoroth", "过动猿"), _pokeluaText("Slaking", "请假王"),
 _pokeluaText("Nincada", "土居忍士"), _pokeluaText("Ninjask", "铁面忍者"), _pokeluaText("Shedinja", "脱壳忍者"), _pokeluaText("Whismur", "咕妞妞"), _pokeluaText("Loudred", "吼爆弹"), _pokeluaText("Exploud", "爆音怪"), _pokeluaText("Makuhita", "幕下力士"), _pokeluaText("Hariyama", "铁掌力士"), _pokeluaText("Azurill", "露力丽"), _pokeluaText("Nosepass", "朝北鼻"),
 _pokeluaText("Skitty", "向尾喵"), _pokeluaText("Delcatty", "优雅猫"), _pokeluaText("Sableye", "勾魂眼"), _pokeluaText("Mawile", "大嘴娃"), _pokeluaText("Aron", "可可多拉"), _pokeluaText("Lairon", "可多拉"), _pokeluaText("Aggron", "波士可多拉"), _pokeluaText("Meditite", "玛沙那"), _pokeluaText("Medicham", "恰雷姆"), _pokeluaText("Electrike", "落雷兽"),
 _pokeluaText("Manectric", "雷电兽"), _pokeluaText("Plusle", "正电拍拍"), _pokeluaText("Minun", "负电拍拍"), _pokeluaText("Volbeat", "电萤虫"), _pokeluaText("Illumise", "甜甜萤"), _pokeluaText("Roselia", "毒蔷薇"), _pokeluaText("Gulpin", "溶食兽"), _pokeluaText("Swalot", "吞食兽"), _pokeluaText("Carvanha", "利牙鱼"), _pokeluaText("Sharpedo", "巨牙鲨"),
 _pokeluaText("Wailmer", "吼吼鲸"), _pokeluaText("Wailord", "吼鲸王"), _pokeluaText("Numel", "呆火驼"), _pokeluaText("Camerupt", "喷火驼"), _pokeluaText("Torkoal", "煤炭龟"), _pokeluaText("Spoink", "跳跳猪"), _pokeluaText("Grumpig", "噗噗猪"), _pokeluaText("Spinda", "晃晃斑"), _pokeluaText("Trapinch", "大颚蚁"), _pokeluaText("Vibrava", "超音波幼虫"),
 _pokeluaText("Flygon", "沙漠蜻蜓"), _pokeluaText("Cacnea", "刺球仙人掌"), _pokeluaText("Cacturne", "梦歌仙人掌"), _pokeluaText("Swablu", "青绵鸟"), _pokeluaText("Altaria", "七夕青鸟"), _pokeluaText("Zangoose", "猫鼬斩"), _pokeluaText("Seviper", "饭匙蛇"), _pokeluaText("Lunatone", "月石"), _pokeluaText("Solrock", "太阳岩"), _pokeluaText("Barboach", "泥泥鳅"),
 _pokeluaText("Whiscash", "鲶鱼王"), _pokeluaText("Corphish", "龙虾小兵"), _pokeluaText("Crawdaunt", "铁螯龙虾"), _pokeluaText("Baltoy", "天秤偶"), _pokeluaText("Claydol", "念力土偶"), _pokeluaText("Lileep", "触手百合"), _pokeluaText("Cradily", "摇篮百合"), _pokeluaText("Anorith", "太古羽虫"), _pokeluaText("Armaldo", "太古盔甲"), _pokeluaText("Feebas", "丑丑鱼"),
 _pokeluaText("Milotic", "美纳斯"), _pokeluaText("Castform", "飘浮泡泡"), _pokeluaText("Kecleon", "变隐龙"), _pokeluaText("Shuppet", "怨影娃娃"), _pokeluaText("Banette", "诅咒娃娃"), _pokeluaText("Duskull", "夜巡灵"), _pokeluaText("Dusclops", "彷徨夜灵"), _pokeluaText("Tropius", "热带龙"), _pokeluaText("Chimecho", "风铃铃"), _pokeluaText("Absol", "阿勃梭鲁"),
 _pokeluaText("Wynaut", "小果然"), _pokeluaText("Snorunt", "雪童子"), _pokeluaText("Glalie", "冰鬼护"), _pokeluaText("Spheal", "海豹球"), _pokeluaText("Sealeo", "海魔狮"), _pokeluaText("Walrein", "帝牙海狮"), _pokeluaText("Clamperl", "珍珠贝"), _pokeluaText("Huntail", "猎斑鱼"), _pokeluaText("Gorebyss", "樱花鱼"), _pokeluaText("Relicanth", "古空棘鱼"),
 _pokeluaText("Luvdisc", "爱心鱼"), _pokeluaText("Bagon", "宝贝龙"), _pokeluaText("Shelgon", "甲壳龙"), _pokeluaText("Salamence", "暴飞龙"), _pokeluaText("Beldum", "铁哑铃"), _pokeluaText("Metang", "金属怪"), _pokeluaText("Metagross", "巨金怪"), _pokeluaText("Regirock", "雷吉洛克"), _pokeluaText("Regice", "雷吉艾斯"), _pokeluaText("Registeel", "雷吉斯奇鲁"),
 _pokeluaText("Latias", "拉帝亚斯"), _pokeluaText("Latios", "拉帝欧斯"),  _pokeluaText("Kyogre", "盖欧卡"), _pokeluaText("Groudon", "固拉多"), _pokeluaText("Rayquaza", "烈空坐"), _pokeluaText("Jirachi", "基拉祈"), _pokeluaText("Deoxys", "代欧奇希斯")}

local abilityNamesList = {
 _pokeluaText("Stench", "恶臭"), _pokeluaText("Drizzle", "降雨"), _pokeluaText("Speed Boost", "加速"), _pokeluaText("Battle Armor", "战斗盔甲"), _pokeluaText("Sturdy", "结实"), _pokeluaText("Damp", "湿气"), _pokeluaText("Limber", "柔软"), _pokeluaText("Sand Veil", "沙隐"), _pokeluaText("Static", "静电"),
 _pokeluaText("Volt Absorb", "蓄电"), _pokeluaText("Water Absorb", "储水"), _pokeluaText("Oblivious", "迟钝"), _pokeluaText("Cloud Nine", "无关天气"), _pokeluaText("Compound Eyes", "复眼"), _pokeluaText("Insomnia", "不眠"), _pokeluaText("Color Change", "变色"), _pokeluaText("Immunity", "免疫"),
 _pokeluaText("Flash Fire", "引火"), _pokeluaText("Shield Dust", "鳞粉"), _pokeluaText("Own Tempo", "我行我素"), _pokeluaText("Suction Cups", "吸盘"), _pokeluaText("Intimidate", "威吓"), _pokeluaText("Shadow Tag", "踩影"), _pokeluaText("Rough Skin", "粗糙皮肤"), _pokeluaText("Wonder Guard", "神奇守护"),
 _pokeluaText("Levitate", "飘浮"), _pokeluaText("Effect Spore", "孢子"), _pokeluaText("Synchronize", "同步"), _pokeluaText("Clear Body", "恒净之躯"), _pokeluaText("Natural Cure", "自然回复"), _pokeluaText("Lightning Rod", "避雷针"), _pokeluaText("Serene Grace", "天恩"),
 _pokeluaText("Swift Swim", "悠游自如"), _pokeluaText("Chlorophyll", "叶绿素"), _pokeluaText("Illuminate", "发光"), _pokeluaText("Trace", "复制"), _pokeluaText("Huge Power", "大力士"), _pokeluaText("Poison Point", "毒刺"), _pokeluaText("Inner Focus", "精神力"), _pokeluaText("Magma Armor", "熔岩铠甲"),
 _pokeluaText("Water Veil", "水幕"), _pokeluaText("Magnet Pull", "磁力"), _pokeluaText("Soundproof", "隔音"), _pokeluaText("Rain Dish", "雨盘"), _pokeluaText("Sand Stream", "扬沙"), _pokeluaText("Pressure", "压迫感"), _pokeluaText("Thick Fat", "厚脂肪"), _pokeluaText("Early Bird", "早起"),
 _pokeluaText("Flame Body", "火焰之躯"), _pokeluaText("Run Away", "逃跑"), _pokeluaText("Keen Eye", "锐利目光"), _pokeluaText("Hyper Cutter", "怪力钳"), _pokeluaText("Pickup", "捡拾"), _pokeluaText("Truant", "懒惰"), _pokeluaText("Hustle", "活力"), _pokeluaText("Cute Charm", "迷人之躯"), _pokeluaText("Plus", "正电"), _pokeluaText("Minus", "负电"),
 _pokeluaText("Forecast", "阴晴不定"), _pokeluaText("Sticky Hold", "黏着"), _pokeluaText("Shed Skin", "蜕皮"), _pokeluaText("Guts", "毅力"), _pokeluaText("Marvel Scale", "神奇鳞片"), _pokeluaText("Liquid Ooze", "污泥浆"), _pokeluaText("Overgrow", "茂盛"), _pokeluaText("Blaze", "猛火"), _pokeluaText("Torrent", "激流"),
 _pokeluaText("Swarm", "虫之预感"), _pokeluaText("Rock Head", "坚硬脑袋"), _pokeluaText("Drought", "日照"), _pokeluaText("Arena Trap", "沙穴"), _pokeluaText("Vital Spirit", "干劲"), _pokeluaText("White Smoke", "白色烟雾"), _pokeluaText("Pure Power", "瑜伽之力"), _pokeluaText("Shell Armor", "硬壳盔甲"),
 _pokeluaText("Cacophony", "杂音"), _pokeluaText("Air Lock", "气闸")}

local moveNamesList = {
 "--" , _pokeluaText("Pound", "拍击"), _pokeluaText("Karate Chop", "空手劈"), _pokeluaText("Double Slap", "连环巴掌"), _pokeluaText("Comet Punch", "连续拳"), _pokeluaText("Mega Punch", "百万吨重拳"), _pokeluaText("Pay Day", "聚宝功"), _pokeluaText("Fire Punch", "火焰拳"), _pokeluaText("Ice Punch", "冰冻拳"),
 _pokeluaText("Thunder Punch", "雷电拳"), _pokeluaText("Scratch", "抓"), _pokeluaText("Vice Grip", "夹住"), _pokeluaText("Guillotine", "断头钳"), _pokeluaText("Razor Wind", "旋风刀"), _pokeluaText("Swords Dance", "剑舞"), _pokeluaText("Cut", "居合斩"), _pokeluaText("Gust", "起风"), _pokeluaText("Wing Attack", "翅膀攻击"),
 _pokeluaText("Whirlwind", "吹飞"), _pokeluaText("Fly", "飞翔"), _pokeluaText("Bind", "绑紧"), _pokeluaText("Slam", "摔打"), _pokeluaText("Vine Whip", "藤鞭"), _pokeluaText("Stomp", "踩踏"), _pokeluaText("Double Kick", "二连踢"), _pokeluaText("Mega Kick", "百万吨重踢"), _pokeluaText("Jump Kick", "飞踢"), _pokeluaText("Rolling Kick", "回旋踢"),
 _pokeluaText("Sand Attack", "泼沙"), _pokeluaText("Headbutt", "头锤"), _pokeluaText("Horn Attack", "角撞"), _pokeluaText("Fury Attack", "乱击"), _pokeluaText("Horn Drill", "角钻"), _pokeluaText("Tackle", "撞击"), _pokeluaText("Body Slam", "泰山压顶"), _pokeluaText("Wrap", "紧束"), _pokeluaText("Take Down", "猛撞"),
 _pokeluaText("Thrash", "大闹一番"), _pokeluaText("Double-Edge", "舍身冲撞"), _pokeluaText("Tail Whip", "摇尾巴"), _pokeluaText("Poison Sting", "毒针"), _pokeluaText("Twineedle", "双针"), _pokeluaText("Pin Missile", "飞弹针"), _pokeluaText("Leer", "瞪眼"), _pokeluaText("Bite", "咬住"), _pokeluaText("Growl", "叫声"), _pokeluaText("Roar", "吼叫"),
 _pokeluaText("Sing", "唱歌"), _pokeluaText("Supersonic", "超音波"), _pokeluaText("Sonic Boom", "音爆"), _pokeluaText("Disable", "定身法"), _pokeluaText("Acid", "溶解液"), _pokeluaText("Ember", "火花"), _pokeluaText("Flamethrower", "喷射火焰"), _pokeluaText("Mist", "白雾"), _pokeluaText("Water Gun", "水枪"), _pokeluaText("Hydro Pump", "水炮"),
 _pokeluaText("Surf", "冲浪"), _pokeluaText("Ice Beam", "冰冻光束"), _pokeluaText("Blizzard", "暴风雪"), _pokeluaText("Psybeam", "幻象光线"), _pokeluaText("Bubble Beam", "泡沫光线"), _pokeluaText("Aurora Beam", "极光束"), _pokeluaText("Hyper Beam", "破坏光线"), _pokeluaText("Peck", "啄"), _pokeluaText("Drill Peck", "啄钻"),
 _pokeluaText("Submission", "地狱翻滚"), _pokeluaText("Low Kick", "踢倒"), _pokeluaText("Counter", "双倍奉还"), _pokeluaText("Seismic Toss", "地球上投"), _pokeluaText("Strength", "怪力"), _pokeluaText("Absorb", "吸取"), _pokeluaText("Mega Drain", "超级吸取"), _pokeluaText("Leech Seed", "寄生种子"), _pokeluaText("Growth", "生长"),
 _pokeluaText("Razor Leaf", "飞叶快刀"), _pokeluaText("Solar Beam", "日光束"), _pokeluaText("Poison Powder", "毒粉"), _pokeluaText("Stun Spore", "麻痹粉"), _pokeluaText("Sleep Powder", "催眠粉"), _pokeluaText("Petal Dance", "花瓣舞"), _pokeluaText("String Shot", "吐丝"),
 _pokeluaText("Dragon Rage", "龙之怒"), _pokeluaText("Fire Spin", "火焰旋涡"), _pokeluaText("Thunder Shock", "电击"), _pokeluaText("Thunderbolt", "十万伏特"), _pokeluaText("Thunder Wave", "电磁波"), _pokeluaText("Thunder", "打雷"), _pokeluaText("Rock Throw", "落石"), _pokeluaText("Earthquake", "地震"),
 _pokeluaText("Fissure", "地裂"), _pokeluaText("Dig", "挖洞"), _pokeluaText("Toxic", "剧毒"), _pokeluaText("Confusion", "念力"), _pokeluaText("Psychic", "精神强念"), _pokeluaText("Hypnosis", "催眠术"), _pokeluaText("Meditate", "瑜伽姿势"), _pokeluaText("Agility", "高速移动"), _pokeluaText("Quick Attack", "电光一闪"), _pokeluaText("Rage", "愤怒"),
 _pokeluaText("Teleport", "瞬间移动"), _pokeluaText("Night Shade", "黑夜魔影"), _pokeluaText("Mimic", "模仿"), _pokeluaText("Screech", "刺耳声"), _pokeluaText("Double Team", "影子分身"), _pokeluaText("Recover", "自我再生"), _pokeluaText("Harden", "变硬"), _pokeluaText("Minimize", "变小"), _pokeluaText("Smokescreen", "烟幕"),
 _pokeluaText("Confuse Ray", "奇异之光"), _pokeluaText("Withdraw", "缩入壳中"), _pokeluaText("Defense Curl", "变圆"), _pokeluaText("Barrier", "屏障"), _pokeluaText("Light Screen", "光墙"), _pokeluaText("Haze", "黑雾"), _pokeluaText("Reflect", "反射壁"), _pokeluaText("Focus Energy", "聚气"), _pokeluaText("Bide", "忍耐"),
 _pokeluaText("Metronome", "挥指"), _pokeluaText("Mirror Move", "鹦鹉学舌"), _pokeluaText("Self-Destruct", "自爆"), _pokeluaText("Egg Bomb", "炸蛋"), _pokeluaText("Lick", "舌舔"), _pokeluaText("Smog", "浊雾"), _pokeluaText("Sludge", "污泥攻击"), _pokeluaText("Bone Club", "骨棒"), _pokeluaText("Fire Blast", "大字爆炎"),
 _pokeluaText("Waterfall", "攀瀑"), _pokeluaText("Clamp", "贝壳夹击"), _pokeluaText("Swift", "高速星星"), _pokeluaText("Skull Bash", "火箭头锤"), _pokeluaText("Spike Cannon", "尖刺加农炮"), _pokeluaText("Constrict", "缠绕"), _pokeluaText("Amnesia", "瞬间失忆"), _pokeluaText("Kinesis", "折弯汤匙"), _pokeluaText("Soft-Boiled", "生蛋"),
 _pokeluaText("High Jump Kick", "飞膝踢"), _pokeluaText("Glare", "大蛇瞪眼"), _pokeluaText("Dream Eater", "食梦"), _pokeluaText("Poison Gas", "毒瓦斯"), _pokeluaText("Barrage", "投球"), _pokeluaText("Leech Life", "吸血"), _pokeluaText("Lovely Kiss", "恶魔之吻"), _pokeluaText("Sky Attack", "神鸟猛击"),
 _pokeluaText("Transform", "变身"), _pokeluaText("Bubble", "泡沫"), _pokeluaText("Dizzy Punch", "迷昏拳"), _pokeluaText("Spore", "蘑菇孢子"), _pokeluaText("Flash", "闪光"), _pokeluaText("Psywave", "精神波"), _pokeluaText("Splash", "跃起"), _pokeluaText("Acid Armor", "溶化"), _pokeluaText("Crabhammer", "蟹钳锤"),
 _pokeluaText("Explosion", "大爆炸"), _pokeluaText("Fury Swipes", "乱抓"), _pokeluaText("Bonemerang", "骨头回力镖"), _pokeluaText("Rest", "睡觉"), _pokeluaText("Rock Slide", "岩崩"), _pokeluaText("Hyper Fang", "必杀门牙"), _pokeluaText("Sharpen", "棱角化"), _pokeluaText("Conversion", "纹理"), _pokeluaText("Tri Attack", "三重攻击"),
 _pokeluaText("Super Fang", "愤怒门牙"), _pokeluaText("Slash", "劈开"), _pokeluaText("Substitute", "替身"), _pokeluaText("Struggle", "挣扎"), _pokeluaText("Sketch", "写生"), _pokeluaText("Triple Kick", "三连踢"), _pokeluaText("Thief", "小偷"), _pokeluaText("Spider Web", "蛛网"), _pokeluaText("Mind Reader", "心之眼"),
 _pokeluaText("Nightmare", "恶梦"), _pokeluaText("Flame Wheel", "火焰轮"), _pokeluaText("Snore", "打鼾"), _pokeluaText("Curse", "诅咒"), _pokeluaText("Flail", "抓狂"), _pokeluaText("Conversion 2", "纹理２"), _pokeluaText("Aeroblast", "气旋攻击"), _pokeluaText("Cotton Spore", "棉孢子"), _pokeluaText("Reversal", "起死回生"),
 _pokeluaText("Spite", "怨恨"), _pokeluaText("Powder Snow", "细雪"), _pokeluaText("Protect", "守住"), _pokeluaText("Mach Punch", "音速拳"), _pokeluaText("Scary Face", "鬼面"), _pokeluaText("Feint Attack", "出奇一击"), _pokeluaText("Sweet Kiss", "天使之吻"), _pokeluaText("Belly Drum", "腹鼓"),
 _pokeluaText("Sludge Bomb", "污泥炸弹"), _pokeluaText("Mud-Slap", "掷泥"), _pokeluaText("Octazooka", "章鱼桶炮"), _pokeluaText("Spikes", "撒菱"), _pokeluaText("Zap Cannon", "电磁炮"), _pokeluaText("Foresight", "识破"), _pokeluaText("Destiny Bond", "同命"), _pokeluaText("Perish Song", "灭亡之歌"),
 _pokeluaText("Icy Wind", "冰冻之风"), _pokeluaText("Detect", "看穿"), _pokeluaText("Bone Rush", "骨棒乱打"), _pokeluaText("Lock-On", "锁定"), _pokeluaText("Outrage", "逆鳞"), _pokeluaText("Sandstorm", "沙暴"), _pokeluaText("Giga Drain", "终极吸取"), _pokeluaText("Endure", "挺住"), _pokeluaText("Charm", "撒娇"), _pokeluaText("Rollout", "滚动"),
 _pokeluaText("False Swipe", "点到为止"), _pokeluaText("Swagger", "虚张声势"), _pokeluaText("Milk Drink", "喝牛奶"), _pokeluaText("Spark", "电光"), _pokeluaText("Fury Cutter", "连斩"), _pokeluaText("Steel Wing", "钢翼"), _pokeluaText("Mean Look", "黑色目光"), _pokeluaText("Attract", "迷人"), _pokeluaText("Sleep Talk", "梦话"),
 _pokeluaText("Heal Bell", "治愈铃声"), _pokeluaText("Return", "报恩"), _pokeluaText("Present", "礼物"), _pokeluaText("Frustration", "迁怒"), _pokeluaText("Safeguard", "神秘守护"), _pokeluaText("Pain Split", "分担痛楚"), _pokeluaText("Sacred Fire", "神圣之火"), _pokeluaText("Magnitude", "震级"),
 _pokeluaText("Dynamic Punch", "爆裂拳"), _pokeluaText("Megahorn", "超级角击"), _pokeluaText("Dragon Breath", "龙息"), _pokeluaText("Baton Pass", "接棒"), _pokeluaText("Encore", "再来一次"), _pokeluaText("Pursuit", "追打"), _pokeluaText("Rapid Spin", "高速旋转"), _pokeluaText("Sweet Scent", "甜甜香气"),
 _pokeluaText("Iron Tail", "铁尾"), _pokeluaText("Metal Claw", "金属爪"), _pokeluaText("Vital Throw", "借力摔"), _pokeluaText("Morning Sun", "晨光"), _pokeluaText("Synthesis", "光合作用"), _pokeluaText("Moonlight", "月光"), _pokeluaText("Hidden Power", "觉醒力量"), _pokeluaText("Cross Chop", "十字劈"),
 _pokeluaText("Twister", "龙卷风"), _pokeluaText("Rain Dance", "求雨"), _pokeluaText("Sunny Day", "大晴天"), _pokeluaText("Crunch", "咬碎"), _pokeluaText("Mirror Coat", "镜面反射"), _pokeluaText("Psych Up", "自我暗示"), _pokeluaText("Extreme Speed", "神速"), _pokeluaText("Ancient Power", "原始之力"),
 _pokeluaText("Shadow Ball", "暗影球"), _pokeluaText("Future Sight", "预知未来"), _pokeluaText("Rock Smash", "碎岩"), _pokeluaText("Whirlpool", "潮旋"), _pokeluaText("Beat Up", "围攻"), _pokeluaText("Fake Out", "击掌奇袭"), _pokeluaText("Uproar", "吵闹"), _pokeluaText("Stockpile", "蓄力"), _pokeluaText("Spit Up", "喷出"),
 _pokeluaText("Swallow", "吞下"), _pokeluaText("Heat Wave", "热风"), _pokeluaText("Hail", "冰雹"), _pokeluaText("Torment", "无理取闹"), _pokeluaText("Flatter", "吹捧"), _pokeluaText("Will-O-Wisp", "鬼火"), _pokeluaText("Memento", "临别礼物"), _pokeluaText("Facade", "硬撑"), _pokeluaText("Focus Punch", "真气拳"),
 _pokeluaText("Smelling Salts", "清醒"), _pokeluaText("Follow Me", "看我嘛"), _pokeluaText("Nature Power", "自然之力"), _pokeluaText("Charge", "充电"), _pokeluaText("Taunt", "挑衅"), _pokeluaText("Helping Hand", "帮助"), _pokeluaText("Trick", "戏法"), _pokeluaText("Role Play", "扮演"), _pokeluaText("Wish", "祈愿"),
 _pokeluaText("Assist", "借助"), _pokeluaText("Ingrain", "扎根"), _pokeluaText("Superpower", "蛮力"), _pokeluaText("Magic Coat", "魔法反射"), _pokeluaText("Recycle", "回收利用"), _pokeluaText("Revenge", "报复"), _pokeluaText("Brick Break", "劈瓦"), _pokeluaText("Yawn", "哈欠"), _pokeluaText("Knock Off", "拍落"), _pokeluaText("Endeavor", "蛮干"),
 _pokeluaText("Eruption", "喷火"), _pokeluaText("Skill Swap", "特性互换"), _pokeluaText("Imprison", "封印"), _pokeluaText("Refresh", "焕然一新"), _pokeluaText("Grudge", "怨念"), _pokeluaText("Snatch", "抢夺"), _pokeluaText("Secret Power", "秘密之力"), _pokeluaText("Dive", "潜水"), _pokeluaText("Arm Thrust", "猛推"), _pokeluaText("Camouflage", "保护色"),
 _pokeluaText("Tail Glow", "萤火"), _pokeluaText("Luster Purge", "洁净光芒"), _pokeluaText("Mist Ball", "薄雾球"), _pokeluaText("Feather Dance", "羽毛舞"), _pokeluaText("Teeter Dance", "摇晃舞"), _pokeluaText("Blaze Kick", "火焰踢"), _pokeluaText("Mud Sport", "玩泥巴"), _pokeluaText("Ice Ball", "冰球"),
 _pokeluaText("Needle Arm", "尖刺臂"), _pokeluaText("Slack Off", "偷懒"), _pokeluaText("Hyper Voice", "巨声"), _pokeluaText("Poison Fang", "剧毒牙"), _pokeluaText("Crush Claw", "撕裂爪"), _pokeluaText("Blast Burn", "爆炸烈焰"), _pokeluaText("Hydro Cannon", "加农水炮"), _pokeluaText("Meteor Mash", "彗星拳"),
 _pokeluaText("Astonish", "惊吓"), _pokeluaText("Weather Ball", "气象球"), _pokeluaText("Aromatherapy", "芳香治疗"), _pokeluaText("Fake Tears", "假哭"), _pokeluaText("Air Cutter", "空气利刃"), _pokeluaText("Overheat", "过热"), _pokeluaText("Odor Sleuth", "气味侦测"), _pokeluaText("Rock Tomb", "岩石封锁"),
 _pokeluaText("Silver Wind", "银色旋风"), _pokeluaText("Metal Sound", "金属音"), _pokeluaText("Grass Whistle", "草笛"), _pokeluaText("Tickle", "挠痒"), _pokeluaText("Cosmic Power", "宇宙力量"), _pokeluaText("Water Spout", "喷水"), _pokeluaText("Signal Beam", "信号光束"), _pokeluaText("Shadow Punch", "暗影拳"),
 _pokeluaText("Extrasensory", "神通力"), _pokeluaText("Sky Uppercut", "冲天拳"), _pokeluaText("Sand Tomb", "流沙地狱"), _pokeluaText("Sheer Cold", "绝对零度"), _pokeluaText("Muddy Water", "浊流"), _pokeluaText("Bullet Seed", "种子机关枪"), _pokeluaText("Aerial Ace", "燕返"), _pokeluaText("Icicle Spear", "冰锥"),
 _pokeluaText("Iron Defense", "铁壁"), _pokeluaText("Block", "挡路"), _pokeluaText("Howl", "长嚎"), _pokeluaText("Dragon Claw", "龙爪"), _pokeluaText("Frenzy Plant", "疯狂植物"), _pokeluaText("Bulk Up", "健美"), _pokeluaText("Bounce", "弹跳"), _pokeluaText("Mud Shot", "泥巴射击"), _pokeluaText("Poison Tail", "毒尾"), _pokeluaText("Covet", "渴望"),
 _pokeluaText("Volt Tackle", "伏特攻击"), _pokeluaText("Magical Leaf", "魔法叶"), _pokeluaText("Water Sport", "玩水"), _pokeluaText("Calm Mind", "冥想"), _pokeluaText("Leaf Blade", "叶刃"), _pokeluaText("Dragon Dance", "龙之舞"), _pokeluaText("Rock Blast", "岩石爆击"), _pokeluaText("Shock Wave", "电击波"),
 _pokeluaText("Water Pulse", "水之波动"), _pokeluaText("Doom Desire", "破灭之愿"), _pokeluaText("Psycho Boost", "精神突进")}

local nationalDexList = {
 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74,
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

local pokemonAbilities = {
 [001] = {65, 34}, [002] = {65, 34}, [003] = {65, 34}, [004] = {66}, [005] = {66}, [006] = {66}, [007] = {67, 44},
 [008] = {67, 44}, [009] = {67, 44}, [010] = {19, 50}, [011] = {61}, [012] = {14}, [013] = {19, 50}, [014] = {61},
 [015] = {68}, [016] = {51}, [017] = {51}, [018] = {51}, [019] = {50, 62, 55}, [020] = {50, 62, 55}, [021] = {51},
 [022] = {51}, [023] = {22, 61}, [024] = {22, 61}, [025] = {9, 31}, [026] = {9, 31}, [027] = {8}, [028] = {8},
 [029] = {38, 55}, [030] = {38, 55}, [031] = {38}, [032] = {38, 55}, [033] = {38, 55}, [034] = {38}, [035] = {56},
 [036] = {56}, [037] = {18, 70}, [038] = {18, 70}, [039] = {56}, [040] = {56}, [041] = {39}, [042] = {39},
 [043] = {34, 50}, [044] = {34, 1}, [045] = {34, 27}, [046] = {27, 6}, [047] = {27, 6}, [048] = {14, 50},
 [049] = {19}, [050] = {8, 71}, [051] = {8, 71}, [052] = {53}, [053] = {7}, [054] = {6, 13, 33},
 [055] = {6, 13, 33}, [056] = {72}, [057] = {72}, [058] = {22, 18}, [059] = {22, 18}, [060] = {11, 6, 33},
 [061] = {11, 6, 33}, [062] = {11, 6, 33}, [063] = {28, 39}, [064] = {28, 39}, [065] = {28, 39}, [066] = {62},
 [067] = {62}, [068] = {62}, [069] = {34}, [070] = {34}, [071] = {34}, [072] = {29, 64, 44}, [073] = {29, 64, 44},
 [074] = {69, 5, 8}, [075] = {69, 5, 8}, [076] = {69, 5, 8}, [077] = {50, 18, 49}, [078] = {50, 18, 49},
 [079] = {12, 20}, [080] = {12, 20}, [081] = {42, 5}, [082] = {42, 5}, [083] = {51, 39}, [084] = {50, 48},
 [085] = {50, 48}, [086] = {47}, [087] = {47}, [088] = {1, 60}, [089] = {1, 60}, [090] = {75}, [091] = {75},
 [092] = {26}, [093] = {26}, [094] = {26}, [095] = {69, 5}, [096] = {15, 39}, [097] = {15, 39}, [098] = {52, 75},
 [099] = {52, 75}, [100] = {43, 9}, [101] = {43, 9}, [102] = {34}, [103] = {34}, [104] = {69, 31, 4},
 [105] = {69, 31, 4}, [106] = {7}, [107] = {51, 39}, [108] = {20, 12, 13}, [109] = {26, 1}, [110] = {26, 1},
 [111] = {31, 69}, [112] = {31, 69}, [113] = {30, 32}, [114] = {34}, [115] = {48, 39}, [116] = {33, 6},
 [117] = {38, 6}, [230] = {33, 6}, [118] = {33, 41, 31}, [119] = {33, 41, 31}, [120] = {35, 30}, [121] = {35, 30},
 [122] = {43}, [123] = {68}, [212] = {68}, [238] = {12}, [124] = {12}, [239] = {9, 72}, [125] = {9, 72},
 [240] = {49, 72}, [126] = {49, 72}, [127] = {52}, [128] = {22}, [129] = {33}, [130] = {22}, [131] = {11, 75},
 [132] = {7}, [133] = {50}, [134] = {11}, [135] = {10}, [136] = {18, 62}, [196] = {28}, [197] = {28, 39},
 [137] = {36}, [233] = {36}, [138] = {33, 75}, [139] = {33, 75}, [140] = {33, 4}, [141] = {33, 4}, [142] = {69, 46},
 [143] = {17, 47}, [144] = {46}, [145] = {46, 9}, [146] = {46, 49}, [147] = {61, 63}, [148] = {61, 63}, [149] = {39},
 [150] = {46}, [151] = {28}, [152] = {65}, [153] = {65}, [154] = {65}, [155] = {66, 18}, [156] = {66, 18},
 [157] = {66, 18}, [158] = {67}, [159] = {67}, [160] = {67}, [161] = {50, 51}, [162] = {50, 51}, [163] = {15, 51},
 [164] = {15, 51}, [165] = {68, 48}, [166] = {68, 48}, [167] = {68, 15}, [168] = {68, 15}, [169] = {39},
 [170] = {10, 35, 11}, [171] = {10, 35, 11}, [172] = {9, 31}, [173] = {56}, [174] = {56}, [175] = {55, 32},
 [176] = {55, 32}, [177] = {28, 48}, [178] = {28, 48}, [179] = {9, 57}, [180] = {9, 57}, [181] = {9, 57}, [182] = {34},
 [183] = {47, 37}, [184] = {47, 37}, [185] = {5, 69}, [186] = {11, 6, 2}, [187] = {34}, [188] = {34}, [189] = {34},
 [190] = {50, 53}, [191] = {34, 48}, [192] = {34, 48}, [193] = {3, 14}, [194] = {6, 11}, [195] = {6, 11}, [198] = {15},
 [199] = {12, 20}, [200] = {26}, [201] = {26}, [202] = {23}, [203] = {39, 48}, [204] = {5}, [205] = {5},
 [206] = {32, 50}, [207] = {52, 8, 17}, [208] = {69, 5}, [209] = {22, 50}, [210] = {22}, [211] = {38, 33, 22},
 [213] = {5}, [214] = {68, 62}, [215] = {39, 51}, [216] = {53}, [217] = {62}, [218] = {40, 49}, [219] = {40, 49},
 [220] = {12, 47}, [221] = {12, 47}, [222] = {55, 30}, [223] = {55}, [224] = {21}, [225] = {72, 55, 15},
 [226] = {33, 11, 41}, [227] = {51, 5}, [228] = {48, 18}, [229] = {48, 18}, [231] = {53, 8}, [232] = {5, 8},
 [234] = {22}, [235] = {20}, [236] = {62, 72}, [237] = {22}, [241] = {47}, [242] = {30, 32}, [243] = {46, 39},
 [244] = {46, 39}, [245] = {46, 39}, [246] = {62, 8}, [247] = {61}, [248] = {45}, [249] = {46}, [250] = {46},
 [251] = {30}, [252] = {65}, [253] = {65}, [254] = {65}, [255] = {66, 3}, [256] = {66, 3}, [257] = {66, 3},
 [258] = {67, 6}, [259] = {67, 6}, [260] = {67, 6}, [261] = {50}, [262] = {22}, [263] = {53}, [264] = {53},
 [265] = {19, 50}, [266] = {61}, [267] = {68}, [268] = {61}, [269] = {19, 14}, [270] = {33, 44, 20}, [271] = {33, 44, 20},
 [272] = {33, 44, 20}, [273] = {34, 48}, [274] = {34, 48}, [275] = {34, 48}, [276] = {62}, [277] = {62}, [278] = {51, 44},
 [279] = {51, 2, 44}, [280] = {28, 36}, [281] = {28, 36}, [282] = {28, 36}, [283] = {33, 44}, [284] = {22}, [285] = {27},
 [286] = {27}, [287] = {54}, [288] = {72}, [289] = {54}, [290] = {14, 50}, [291] = {3}, [292] = {25}, [293] = {43},
 [294] = {43}, [295] = {43}, [296] = {47, 62}, [297] = {47, 62}, [298] = {47, 37}, [299] = {5, 42}, [300] = {56},
 [301] = {56}, [302] = {51}, [303] = {52, 22}, [304] = {5, 69}, [305] = {5, 69}, [306] = {5, 69}, [307] = {74},
 [308] = {74}, [309] = {9, 31, 58}, [310] = {9, 31, 58}, [311] = {57, 31}, [312] = {58, 10}, [313] = {35, 68},
 [314] = {12}, [315] = {30, 38}, [316] = {64, 60}, [317] = {64, 60}, [318] = {24, 3}, [319] = {24, 3},
 [320] = {41, 12, 46}, [321] = {41, 12, 46}, [322] = {12, 20}, [323] = {40}, [324] = {73, 70, 75}, [325] = {47, 20},
 [326] = {47, 20}, [327] = {20}, [328] = {52, 71}, [329] = {26}, [330] = {26}, [331] = {8, 11}, [332] = {8, 11},
 [333] = {30, 13}, [334] = {30, 13}, [335] = {17}, [336] = {61}, [337] = {26}, [338] = {26}, [339] = {12}, [340] = {12},
 [341] = {52, 75}, [342] = {52, 75}, [343] = {26}, [344] = {26}, [345] = {21}, [346] = {21}, [347] = {4, 33},
 [348] = {4, 33}, [349] = {33, 12}, [350] = {63, 56}, [351] = {59}, [352] = {16}, [353] = {15}, [354] = {15},
 [355] = {26}, [356] = {46}, [357] = {34}, [358] = {26}, [359] = {46}, [360] = {23}, [361] = {39}, [362] = {39},
 [363] = {47, 12}, [364] = {47, 12}, [365] = {47, 12}, [366] = {75}, [367] = {33, 41}, [368] = {33}, [369] = {33, 69, 5},
 [370] = {33}, [371] = {69}, [372] = {69}, [373] = {22}, [374] = {29}, [375] = {29}, [376] = {29}, [377] = {29, 5},
 [378] = {29}, [379] = {29}, [380] = {26}, [381] = {26}, [382] = {2}, [383] = {70}, [384] = {77}, [385] = {32}, [386] = {46}}

local itemNamesList = {
 _pokeluaText("None", "无"), _pokeluaText("Master Ball", "大师球"), _pokeluaText("Ultra Ball", "高级球"), _pokeluaText("Great Ball", "超级球"), _pokeluaText("Poke Ball", "精灵球"), _pokeluaText("Safari Ball", "狩猎球"), _pokeluaText("Net Ball", "捕网球"), _pokeluaText("Dive Ball", "潜水球"), _pokeluaText("Nest Ball", "巢穴球"),
 _pokeluaText("Repeat Ball", "重复球"), _pokeluaText("Timer Ball", "计时球"), _pokeluaText("Luxury Ball", "豪华球"), _pokeluaText("Premier Ball", "纪念球"), _pokeluaText("Potion", "伤药"), _pokeluaText("Antidote", "解毒药"), _pokeluaText("Burn Heal", "灼伤药"), _pokeluaText("Ice Heal", "解冻药"), _pokeluaText("Awakening", "解眠药"),
 _pokeluaText("Parlyz Heal", "解麻药"), _pokeluaText("Full Restore", "全复药"), _pokeluaText("Max Potion", "全满药"), _pokeluaText("Hyper Potion", "厉害伤药"), _pokeluaText("Super Potion", "好伤药"), _pokeluaText("Full Heal", "万灵药"), _pokeluaText("Revive", "活力碎片"), _pokeluaText("Max Revive", "活力块"),
 _pokeluaText("Fresh Water", "美味之水"), _pokeluaText("Soda Pop", "劲爽汽水"), _pokeluaText("Lemonade", "果汁牛奶"), _pokeluaText("Moomoo Milk", "哞哞鲜奶"), _pokeluaText("EnergyPowder", "元气粉"), _pokeluaText("Energy Root", "元气根"), _pokeluaText("Heal Powder", "万能粉"), _pokeluaText("Revival Herb", "复活草"),
 _pokeluaText("Ether", "ＰＰ单项小补剂"), _pokeluaText("Max Ether", "ＰＰ单项全补剂"), _pokeluaText("Elixir", "ＰＰ多项小补剂"), _pokeluaText("Max Elixir", "ＰＰ多项全补剂"), _pokeluaText("Lava Cookie", "釜炎仙贝"), _pokeluaText("Blue Flute", "蓝色玻璃哨"), _pokeluaText("Yellow Flute", "黄色玻璃哨"), _pokeluaText("Red Flute", "红色玻璃哨"), _pokeluaText("Black Flute", "黑色玻璃哨"),
 _pokeluaText("White Flute", "白色玻璃哨"), _pokeluaText("Berry Juice", "树果汁"), _pokeluaText("Sacred Ash", "圣灰"), _pokeluaText("Shoal Salt", "浅滩海盐"), _pokeluaText("Shoal Shell", "浅滩贝壳"), _pokeluaText("Red Shard", "红色碎片"), _pokeluaText("Blue Shard", "蓝色碎片"), _pokeluaText("Yellow Shard", "黄色碎片"),
 _pokeluaText("Green Shard", "绿色碎片"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"),
 _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("HP Up", "ＨＰ增强剂"), _pokeluaText("Protein", "攻击增强剂"), _pokeluaText("Iron", "防御增强剂"), _pokeluaText("Carbos", "速度增强剂"), _pokeluaText("Calcium", "特攻增强剂"), _pokeluaText("Rare Candy", "神奇糖果"), _pokeluaText("PP Up", "ＰＰ提升剂"), _pokeluaText("Zinc", "特防增强剂"), _pokeluaText("PP Max", "ＰＰ极限提升剂"),
 _pokeluaText("unknown", "未知"), _pokeluaText("Guard Spec.", "能力防守"), _pokeluaText("Dire Hit", "要害攻击"), _pokeluaText("X Attack", "力量强化"), _pokeluaText("X Defend", "防御强化"), _pokeluaText("X Speed", "速度强化"), _pokeluaText("X Accuracy", "命中强化"), _pokeluaText("X Special", "特攻强化"), _pokeluaText("Poke Doll", "皮皮玩偶"),
 _pokeluaText("Fluffy Tail", "向尾喵的尾巴"), _pokeluaText("unknown", "未知"), _pokeluaText("Super Repel", "白银喷雾"), _pokeluaText("Max Repel", "黄金喷雾"), _pokeluaText("Escape Rope", "离洞绳"), _pokeluaText("Repel", "除虫喷雾"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"),
 _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("Sun Stone", "日之石"), _pokeluaText("Moon Stone", "月之石"), _pokeluaText("Fire Stone", "火之石"), _pokeluaText("Thunderstone", "雷之石"), _pokeluaText("Water Stone", "水之石"), _pokeluaText("Leaf Stone", "叶之石"),
 _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("TinyMushroom", "小蘑菇"), _pokeluaText("Big Mushroom", "大蘑菇"), _pokeluaText("unknown", "未知"), _pokeluaText("Pearl", "珍珠"), _pokeluaText("Big Pearl", "大珍珠"), _pokeluaText("Stardust", "星星沙子"),
 _pokeluaText("Star Piece", "星星碎片"), _pokeluaText("Nugget", "金珠"), _pokeluaText("Heart Scale", "心之鳞片"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"),
 _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("Orange Mail", "橙色邮件"), _pokeluaText("Harbor Mail", "港口邮件"), _pokeluaText("Glitter Mail", "闪亮邮件"), _pokeluaText("Mech Mail", "机械邮件"), _pokeluaText("Wood Mail", "木纹邮件"), _pokeluaText("Wave Mail", "波涛邮件"), _pokeluaText("Bead Mail", "珠宝邮件"),
 _pokeluaText("Shadow Mail", "影子邮件"), _pokeluaText("Tropic Mail", "热带邮件"), _pokeluaText("Dream Mail", "梦境邮件"), _pokeluaText("Fab Mail", "奇迹邮件"), _pokeluaText("Retro Mail", "复古邮件"), _pokeluaText("Cheri Berry", "樱子果"), _pokeluaText("Chesto Berry", "零余果"), _pokeluaText("Pecha Berry", "桃桃果"),
 _pokeluaText("Rawst Berry", "莓莓果"), _pokeluaText("Aspear Berry", "利木果"), _pokeluaText("Leppa Berry", "苹野果"), _pokeluaText("Oran Berry", "橙橙果"), _pokeluaText("Persim Berry", "柿仔果"), _pokeluaText("Lum Berry", "木子果"), _pokeluaText("Sitrus Berry", "文柚果"), _pokeluaText("Figy Berry", "勿花果"),
 _pokeluaText("Wiki Berry", "异奇果"), _pokeluaText("Mago Berry", "芒芒果"), _pokeluaText("Aguav Berry", "乐芭果"), _pokeluaText("Iapapa Berry", "芭亚果"), _pokeluaText("Razz Berry", "蔓莓果"), _pokeluaText("Bluk Berry", "墨莓果"), _pokeluaText("Nanab Berry", "蕉香果"), _pokeluaText("Wepear Berry", "西梨果"),
 _pokeluaText("Pinap Berry", "凰梨果"), _pokeluaText("Pomeg Berry", "榴石果"), _pokeluaText("Kelpsy Berry", "藻根果"), _pokeluaText("Qualot Berry", "比巴果"), _pokeluaText("Hondew Berry", "哈密果"), _pokeluaText("Grepa Berry", "萄葡果"), _pokeluaText("Tamato Berry", "茄番果"),
 _pokeluaText("Cornn Berry", "玉黍果"), _pokeluaText("Magost Berry", "岳竹果"), _pokeluaText("Rabuta Berry", "茸丹果"), _pokeluaText("Nomel Berry", "檬柠果"), _pokeluaText("Spelon Berry", "刺角果"), _pokeluaText("Pamtre Berry", "椰木果"), _pokeluaText("Watmel Berry", "瓜西果"),
 _pokeluaText("Durin Berry", "金枕果"), _pokeluaText("Belue Berry", "靛莓果"), _pokeluaText("Liechi Berry", "枝荔果"), _pokeluaText("Ganlon Berry", "龙睛果"), _pokeluaText("Salac Berry", "沙鳞果"), _pokeluaText("Petaya Berry", "龙火果"), _pokeluaText("Apicot Berry", "杏仔果"),
 _pokeluaText("Lansat Berry", "兰萨果"), _pokeluaText("Starf Berry", "星桃果"), _pokeluaText("Enigma Berry", "谜芝果"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("BrightPowder", "光粉"), _pokeluaText("White Herb", "白色香草"),
 _pokeluaText("Macho Brace", "强制锻炼器"), _pokeluaText("Exp. Share", "学习装置"), _pokeluaText("Quick Claw", "先制之爪"), _pokeluaText("Soothe Bell", "安抚之铃"), _pokeluaText("Mental Herb", "心灵香草"), _pokeluaText("Choice Band", "讲究头带"), _pokeluaText("King's Rock", "王者之证"), _pokeluaText("SilverPowder", "银粉"),
 _pokeluaText("Amulet Coin", "护符金币"), _pokeluaText("Cleanse Tag", "洁净之符"), _pokeluaText("Soul Dew", "心之水滴"), _pokeluaText("DeepSeaTooth", "深海之牙"), _pokeluaText("DeepSeaScale", "深海鳞片"), _pokeluaText("Smoke Ball", "烟雾球"), _pokeluaText("Everstone", "不变之石"), _pokeluaText("Focus Band", "气势头带"),
 _pokeluaText("Lucky Egg", "幸运蛋"), _pokeluaText("Scope Lens", "焦点镜"), _pokeluaText("Metal Coat", "金属膜"), _pokeluaText("Leftovers", "吃剩的东西"), _pokeluaText("Dragon Scale", "龙之鳞片"), _pokeluaText("Light Ball", "电气球"), _pokeluaText("Soft Sand", "柔软沙子"), _pokeluaText("Hard Stone", "硬石头"),
 _pokeluaText("Miracle Seed", "奇迹种子"), _pokeluaText("BlackGlasses", "黑色眼镜"), _pokeluaText("Black Belt", "黑带"), _pokeluaText("Magnet", "磁铁"), _pokeluaText("Mystic Water", "神秘水滴"), _pokeluaText("Sharp Beak", "锐利鸟嘴"), _pokeluaText("Poison Barb", "毒针"), _pokeluaText("NeverMeltIce", "不融冰"),
 _pokeluaText("Spell Tag", "诅咒之符"), _pokeluaText("TwistedSpoon", "弯曲的汤匙"), _pokeluaText("Charcoal", "木炭"), _pokeluaText("Dragon Fang", "龙之牙"), _pokeluaText("Silk Scarf", "丝绸围巾"), _pokeluaText("Up-Grade", "升级数据"), _pokeluaText("Shell Bell", "贝壳之铃"), _pokeluaText("Sea Incense", "海潮薰香"),
 _pokeluaText("Lax Incense", "悠闲薰香"), _pokeluaText("Lucky Punch", "吉利拳"), _pokeluaText("Metal Powder", "金属粉"), _pokeluaText("Thick Club", "粗骨头"), _pokeluaText("Stick", "大葱"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"),
 _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"),
 _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"),
 _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("Red Scarf", "红色头巾"), _pokeluaText("Blue Scarf", "蓝色头巾"), _pokeluaText("Pink Scarf", "粉红头巾"), _pokeluaText("Green Scarf", "绿色头巾"), _pokeluaText("Yellow Scarf", "黄色头巾"), _pokeluaText("Mach Bike", "音速自行车"), _pokeluaText("Coin Case", "代币盒"),
 _pokeluaText("Itemfinder", "探宝器"), _pokeluaText("Old Rod", "破旧钓竿"), _pokeluaText("Good Rod", "好钓竿"), _pokeluaText("Super Rod", "厉害钓竿"), _pokeluaText("S.S. Ticket", "船票"), _pokeluaText("Contest Pass", "华丽大赛参加证"), _pokeluaText("unknown", "未知"), _pokeluaText("Wailmer Pail", "吼吼鲸喷壶"), _pokeluaText("Devon Goods", "得文的物品"),
 _pokeluaText("Soot Sack", "集灰袋"), _pokeluaText("Basement Key", "地下钥匙"), _pokeluaText("Acro Bike", "越野自行车"), _pokeluaText("Pokeblock Case", "宝可方块盒"), _pokeluaText("Letter", "给大吾的信"), _pokeluaText("Eon Ticket", "无限船票"), _pokeluaText("Red Orb", "朱红色宝珠"), _pokeluaText("Blue Orb", "靛蓝色宝珠"), _pokeluaText("Scanner", "探测器"),
 _pokeluaText("Go-Goggles", "ＧＯＧＯ护目镜"), _pokeluaText("Meteorite", "陨石"), _pokeluaText("Rm. 1 Key", "１号客房的钥匙"), _pokeluaText("Rm. 2 Key", "２号客房的钥匙"), _pokeluaText("Rm. 4 Key", "４号客房的钥匙"), _pokeluaText("Rm. 6 Key", "６号客房的钥匙"), _pokeluaText("Storage Key", "仓库钥匙"), _pokeluaText("Root Fossil", "根状化石"), _pokeluaText("Claw Fossil", "爪子化石"),
 _pokeluaText("Devon Scope", "得文侦测镜"), _pokeluaText("TM 01", "招式学习器01"), _pokeluaText("TM 02", "招式学习器02"), _pokeluaText("TM 03", "招式学习器03"), _pokeluaText("TM 04", "招式学习器04"), _pokeluaText("TM 05", "招式学习器05"), _pokeluaText("TM 06", "招式学习器06"), _pokeluaText("TM 07", "招式学习器07"), _pokeluaText("TM 08", "招式学习器08"), _pokeluaText("TM 09", "招式学习器09"), _pokeluaText("TM 10", "招式学习器10"), _pokeluaText("TM 11", "招式学习器11"), _pokeluaText("TM 12", "招式学习器12"),
 _pokeluaText("TM 13", "招式学习器13"), _pokeluaText("TM 14", "招式学习器14"), _pokeluaText("TM 15", "招式学习器15"), _pokeluaText("TM 16", "招式学习器16"), _pokeluaText("TM 17", "招式学习器17"), _pokeluaText("TM 18", "招式学习器18"), _pokeluaText("TM 19", "招式学习器19"), _pokeluaText("TM 20", "招式学习器20"), _pokeluaText("TM 21", "招式学习器21"), _pokeluaText("TM 22", "招式学习器22"), _pokeluaText("TM 23", "招式学习器23"), _pokeluaText("TM 24", "招式学习器24"), _pokeluaText("TM 25", "招式学习器25"),
 _pokeluaText("TM 26", "招式学习器26"), _pokeluaText("TM 27", "招式学习器27"), _pokeluaText("TM 28", "招式学习器28"), _pokeluaText("TM 29", "招式学习器29"), _pokeluaText("TM 30", "招式学习器30"), _pokeluaText("TM 31", "招式学习器31"), _pokeluaText("TM 32", "招式学习器32"), _pokeluaText("TM 33", "招式学习器33"), _pokeluaText("TM 34", "招式学习器34"), _pokeluaText("TM 35", "招式学习器35"), _pokeluaText("TM 36", "招式学习器36"), _pokeluaText("TM 37", "招式学习器37"), _pokeluaText("TM 38", "招式学习器38"), _pokeluaText("TM 39", "招式学习器39"),
 _pokeluaText("TM 40", "招式学习器40"), _pokeluaText("TM 41", "招式学习器41"), _pokeluaText("TM 42", "招式学习器42"), _pokeluaText("TM 43", "招式学习器43"), _pokeluaText("TM 44", "招式学习器44"), _pokeluaText("TM 45", "招式学习器45"), _pokeluaText("TM 46", "招式学习器46"), _pokeluaText("TM 47", "招式学习器47"), _pokeluaText("TM 48", "招式学习器48"), _pokeluaText("TM 49", "招式学习器49"), _pokeluaText("TM 50", "招式学习器50"), _pokeluaText("HM 01", "秘传学习器01"), _pokeluaText("HM 02", "秘传学习器02"), _pokeluaText("HM 03", "秘传学习器03"),
 _pokeluaText("HM 04", "秘传学习器04"), _pokeluaText("HM 05", "秘传学习器05"), _pokeluaText("HM 06", "秘传学习器06"), _pokeluaText("HM 07", "秘传学习器07"), _pokeluaText("HM 08", "秘传学习器08"), _pokeluaText("unknown", "未知"), _pokeluaText("unknown", "未知"), _pokeluaText("Oak's Parcel", "大木的包裹"), _pokeluaText("Poke Flute", "宝可梦之笛"), _pokeluaText("Secret Key", "秘密钥匙"), _pokeluaText("Bike Voucher", "兑换券"),
 _pokeluaText("Gold Teeth", "金假牙"), _pokeluaText("Old Amber", "秘密琥珀"), _pokeluaText("Card Key", "钥匙卡"), _pokeluaText("Lift Key", "电梯钥匙"), _pokeluaText("Helix Fossil", "贝壳化石"), _pokeluaText("Dome Fossil", "甲壳化石"), _pokeluaText("Silph Scope", "西尔佛检视镜"), _pokeluaText("Bicycle", "自行车"), _pokeluaText("Town Map", "城镇地图"),
 _pokeluaText("VS Seeker", "对战搜寻器"), _pokeluaText("Fame Checker", "声音记录器"), _pokeluaText("TM Case", "招式学习器盒"), _pokeluaText("Berry Pouch", "树果袋"), _pokeluaText("Teachy TV", "教学电视"), _pokeluaText("Tri-Pass", "三岛通行船券"), _pokeluaText("Rainbow Pass", "七彩通行船券"), _pokeluaText("Tea", "茶"), _pokeluaText("MysticTicket", "神秘船票"),
 _pokeluaText("AuroraTicket", "极光船票"), _pokeluaText("Powder Jar", "粉末瓶"), _pokeluaText("Ruby", "红宝石"), _pokeluaText("Sapphire", "蓝宝石"), _pokeluaText("Magma Emblem", "熔岩标志"), _pokeluaText("Old Sea Map", "古航海图")}

local catchRatesList = {
 -- Gen 1
 45, 45, 45, 45, 45, 45, 45, 45, 45, 255, 120, 45, 255, 120, 45, 255, 120, 45, 255, 127, 255, 90, 255,
 90, 190, 75, 255, 90, 235, 120, 45, 235, 120, 45, 150, 25, 190, 75, 170, 50, 255, 90, 255, 120, 45,
 190, 75, 190, 75, 255, 50, 255, 90, 190, 75, 190, 75, 190, 75, 255, 120, 45, 200, 100, 50, 180, 90,
 45, 255, 120, 45, 190, 60, 255, 120, 45, 190, 60, 190, 75, 190, 60, 45, 190, 45, 190, 75, 190, 75,
 190, 60, 190, 90, 45, 45, 190, 75, 225, 60, 190, 60, 90, 45, 190, 75, 45, 45, 45, 190, 60, 120, 60,
 30, 45, 45, 225, 75, 225, 60, 225, 60, 45, 45, 45, 45, 45, 45, 45, 255, 45, 45, 35, 45, 45, 45, 45,
 45, 45, 45, 45, 45, 45, 25, 3, 3, 3, 45, 45, 45, 3, 45,
 -- Gen 2
 45, 45, 45, 45, 45, 45, 45, 45, 45, 255, 90, 255, 90, 255, 90, 255, 90, 90, 190, 75, 190, 150, 170,
 190, 75, 190, 75, 235, 120, 45, 45, 190, 75, 65, 45, 255, 120, 45, 45, 235, 120, 75, 255, 90, 45, 45,
 30, 70, 45, 225, 45, 60, 190, 75, 190, 60, 25, 190, 75, 45, 25, 190, 45, 60, 120, 60, 190, 75, 225,
 75, 60, 190, 75, 45, 25, 25, 120, 45, 45, 120, 60, 45, 45, 45, 75, 45, 45, 45, 45, 45, 30, 3, 3, 3, 45,
 45, 45, 3, 3, 45,
 -- Gen 3
 45, 45, 45, 45, 45, 45, 45, 45, 45, 255, 127, 255, 90, 255, 120, 45, 120, 45, 255, 120, 45, 255, 120,
 45, 200, 45, 190, 45, 235, 120, 45, 200, 75, 255, 90, 255, 120, 45, 255, 120, 45, 190, 120, 45, 180,
 200, 150, 255, 255, 60, 45, 45, 180, 90, 45, 180, 90, 120, 45, 200, 200, 150, 150, 150, 225, 75, 225,
 60, 125, 60, 255, 150, 90, 255, 60, 255, 255, 120, 45, 190, 60, 255, 45, 90, 90, 45, 45, 190, 75, 205,
 155, 255, 90, 45, 45, 45, 45, 255, 60, 45, 200, 225, 45, 190, 90, 200, 45, 30, 125, 190, 75, 255, 120,
 45, 255, 60, 60, 25, 225, 45, 45, 45, 3, 3, 3, 3, 3, 3, 3, 3, 5, 5, 3, 3, 3}

local locationNamesList = {
 _pokeluaText("Pallet Town", "真新镇"), _pokeluaText("Viridian City", "常青市"), _pokeluaText("Pewter City", "深灰市"), _pokeluaText("Cerulean City", "华蓝市"), _pokeluaText("Lavender Town", "紫苑镇"), _pokeluaText("Vermilion City", "枯叶市"),
 _pokeluaText("Celadon City", "玉虹市"), _pokeluaText("Fuchsia City", "浅红市"), _pokeluaText("Cinnabar Island", "红莲镇"), _pokeluaText("Indigo Plateau Exterior", "石英高原外部"), _pokeluaText("Saffron City", "金黄市"),
 _pokeluaText("Saffron City Connection", "金黄市连接通道"), _pokeluaText("One Island", "第1岛"), _pokeluaText("Two Island", "第２岛"), _pokeluaText("Three Island", "第３岛"), _pokeluaText("Four Island", "第4岛"), _pokeluaText("Five Island", "第5岛"),
 _pokeluaText("Seven Island", "第７岛"), _pokeluaText("Six Island", "第６岛"), _pokeluaText("Route 1", "1号道路"), _pokeluaText("Route 2", "2号道路"), _pokeluaText("Route 3", "3号道路"), _pokeluaText("Route 4", "4号道路"), _pokeluaText("Route 5", "5号道路"), _pokeluaText("Route 6", "6号道路"), _pokeluaText("Route 7", "7号道路"),
 _pokeluaText("Route 8", "8号道路"), _pokeluaText("Route 9", "9号道路"), _pokeluaText("Route 10", "10号道路"), _pokeluaText("Route 11", "11号道路"), _pokeluaText("Route 12", "12号道路"), _pokeluaText("Route 13", "13号道路"), _pokeluaText("Route 14", "14号道路"), _pokeluaText("Route 15", "15号道路"), _pokeluaText("Route 16", "16号道路"),
 _pokeluaText("Route 17", "17号道路"), _pokeluaText("Route 18", "18号道路"), _pokeluaText("Route 19", "19号道路"), _pokeluaText("Route 20", "20号道路"), _pokeluaText("Route 21 North", "21号道路北部"), _pokeluaText("Route 21 South", "21号道路南部"), _pokeluaText("Route 22", "22号道路"), _pokeluaText("Route 23", "23号道路"),
 _pokeluaText("Route 24", "24号道路"), _pokeluaText("Route 25", "25号道路"), _pokeluaText("One Island Kindle Road", "热气之路"), _pokeluaText("One Island Treasure Beach", "宝物海滩"), _pokeluaText("Two Island Cape Brink", "边缘海岬"),
 _pokeluaText("Three Island Bond Bridge", "索桥"), _pokeluaText("Three Island Port", "第3岛码头"), _pokeluaText("Prototype Sevii Isle 6", "七岛原型6"), _pokeluaText("Prototype Sevii Isle 7", "七岛原型7"),
 _pokeluaText("Prototype Sevii Isle 8", "七岛原型8"), _pokeluaText("Prototype Sevii Isle 9", "七岛原型9"), _pokeluaText("Five Island Resort Gorgeous", "豪华度假区"),
 _pokeluaText("Five Island Water Labyrinth", "水之迷宫"), _pokeluaText("Five Island Meadow", "第5岛空地"), _pokeluaText("Five Island Memorial Pillar", "回忆之塔"),
 _pokeluaText("Six Island Outcast Island", "外岛"), _pokeluaText("Six Island Green Path", "绿之步道"), _pokeluaText("Six Island Water Path", "水之步道"), _pokeluaText("Six Island Ruin Valley", "遗迹山谷"),
 _pokeluaText("Seven Island Trainer Tower", "训练家塔"), _pokeluaText("Seven Island Sevault Canyon Entrance", "溪谷入口"), _pokeluaText("Seven Island Sevault Canyon", "七宝溪谷"),
 _pokeluaText("Seven Island Tanoby Ruins", "阿斯卡纳遗迹")}

local statusConditionNamesList = {_pokeluaText("None", "无"), _pokeluaText("SLP", "睡眠"), _pokeluaText("PSN", "中毒"), _pokeluaText("BRN", "灼伤"), _pokeluaText("FRZ", "冰冻"), _pokeluaText("PAR", "麻痹"), _pokeluaText("PSN", "中毒")}

local pokemonStatsScreen2Addr, pokemonStatsScreenAddr, pokemonBattleStatsScreenAddr, speciesDexIndexAddr, wildTypeAddr, partySlotsCounterAddr,
      enemyAddr, partyAddr, safariCatchFactorPointerAddr, playerWalkRunStateAddr, wildEncounterDataAddr, boxSelectedSlotIndexAddr, eggLowPIDPointerAddr,
      safariZoneStepsCounterAddr, selectedItemAddr, partySelectedSlotIndexAddr, roamerMapGroupAndNumAddr, battleTurnsCounterAddr, currentSeedAddr,
      saveBlock1PointerAddr, saveBlock2PointerAddr, currBoxIndexPointerAddr

local GameInfo, CaptureInfo, RoamerInfo, BreedingInfo, PandoraInfo, InitialSeedBotInfo, PokemonInfo

function initializeBuffers()
 GameInfo = console:createBuffer(_pokeluaText("Game Info", "游戏信息"))
 GameInfo:setSize(100, 100)
 CaptureInfo = console:createBuffer(_pokeluaText("Capture", "捕获"))
 CaptureInfo:setSize(100, 100)
 BreedingInfo = console:createBuffer(_pokeluaText("Breeding", "培育"))
 BreedingInfo:setSize(100, 100)
 RoamerInfo = console:createBuffer(_pokeluaText("Roamer", "游走宝可梦"))
 RoamerInfo:setSize(100, 100)
 PandoraInfo = console:createBuffer(_pokeluaText("Pandora", "潘多拉"))
 PandoraInfo:setSize(100, 100)
 InitialSeedBotInfo = console:createBuffer(_pokeluaText("Initial Seed Bot", "初始种子机器人"))
 InitialSeedBotInfo:setSize(100, 100)
 TIDBotInfo = console:createBuffer(_pokeluaText("TID Bot", "TID 机器人"))
 TIDBotInfo:setSize(100, 100)
 PokemonInfo = console:createBuffer(_pokeluaText("Pokemon Info", "宝可梦信息"))
 PokemonInfo:setSize(100, 100)
end

local gameVersion, gameLanguage = "", ""
local wrongGameVersion

function setGameVersion()
 local gameVersionCode = emu:read8(0x80000AE)
 local gameLanguageCode = emu:read8(0x80000AF)
 local gameRev = emu:read8(0x80000BC) == 0x1

 if gameVersionCode == 0x45 then  -- Check game version
  gameVersion = "Emerald"
 elseif gameVersionCode == 0x47 then
  gameVersion = "LeafGreen"
 elseif gameVersionCode == 0x50 then
  gameVersion = "Sapphire"
 elseif gameVersionCode == 0x52 then
  gameVersion = "FireRed"
 elseif gameVersionCode == 0x56 then
  gameVersion = "Ruby"
 end

 if gameLanguageCode == 0x45 then  -- Check game language and set addresses
  gameLanguage = "USA"
  pokemonStatsScreen2Addr = 0x20032A0
  pokemonStatsScreenAddr = 0x2006498
  pokemonBattleStatsScreenAddr = 0x20119C4
  speciesDexIndexAddr = 0x20235C8
  wildTypeAddr = 0x2023C5D
  partySlotsCounterAddr = 0x2024029
  enemyAddr = 0x202402C
  partyAddr = 0x2024284
  safariCatchFactorPointerAddr = 0x202449C
  playerWalkRunStateAddr = 0x2037078
  wildEncounterDataAddr = 0x20386D0
  boxSelectedSlotIndexAddr = 0x2039821
  eggLowPIDPointerAddr = 0x2039894
  safariZoneStepsCounterAddr = 0x2039996
  selectedItemAddr = 0x203AD30
  partySelectedSlotIndexAddr = 0x203B0A9
  roamerMapGroupAndNumAddr = 0x203F3AE
  battleTurnsCounterAddr = 0x3004FA3
  currentSeedAddr = 0x3005000
  saveBlock1PointerAddr = 0x3005008
  saveBlock2PointerAddr = 0x300500C
  currBoxIndexPointerAddr = 0x3005010
 elseif gameLanguageCode == 0x4A then
  gameLanguage = "JPN"
  pokemonStatsScreen2Addr = 0x200324C
  pokemonStatsScreenAddr = 0x2006410
  pokemonBattleStatsScreenAddr = 0x2011970
  speciesDexIndexAddr = 0x2023528
  wildTypeAddr = 0x2023BBD
  partySlotsCounterAddr = 0x2023F89
  enemyAddr = 0x2023F8C
  partyAddr = 0x20241E4
  safariCatchFactorPointerAddr = 0x2024140
  playerWalkRunStateAddr = 0x2036FAC
  wildEncounterDataAddr = 0x203861C
  boxSelectedSlotIndexAddr = 0x203976D
  eggLowPIDPointerAddr = 0x20397E0
  safariZoneStepsCounterAddr = 0x203990E
  selectedItemAddr = 0x203ACA8
  partySelectedSlotIndexAddr = 0x203B01D
  roamerMapGroupAndNumAddr = 0x203F322
  battleTurnsCounterAddr = 0x3004F43
  currentSeedAddr = gameRev and 0x3004FA0 or 0x3005040
  saveBlock1PointerAddr = gameRev and 0x3004FA8 or 0x3005048
  saveBlock2PointerAddr = gameRev and 0x3004FAC or 0x300504C
  currBoxIndexPointerAddr = gameRev and 0x3004FB0 or 0x3005050
 elseif gameLanguageCode == 0x44 or gameLanguageCode == 0x46 or gameLanguageCode == 0x49 or gameLanguageCode == 0x53 then
  gameLanguage = "EUR"
  pokemonStatsScreen2Addr = 0x20032A0
  pokemonStatsScreenAddr = 0x2006498
  pokemonBattleStatsScreenAddr = 0x20119C4
  speciesDexIndexAddr = 0x20235C8
  wildTypeAddr = 0x2023C5D
  partySlotsCounterAddr = 0x2024029
  enemyAddr = 0x202402C
  partyAddr = 0x2024284
  safariCatchFactorPointerAddr = 0x202449C
  playerWalkRunStateAddr = 0x2037078
  wildEncounterDataAddr = 0x20386D0
  boxSelectedSlotIndexAddr = 0x2039821
  eggLowPIDPointerAddr = 0x2039894
  safariZoneStepsCounterAddr = 0x2039996
  selectedItemAddr = 0x203AD30
  partySelectedSlotIndexAddr = 0x203B0A9
  roamerMapGroupAndNumAddr = 0x203F3AE
  battleTurnsCounterAddr = 0x3004EF3
  currentSeedAddr = 0x3004F50
  saveBlock1PointerAddr = 0x3004F58
  saveBlock2PointerAddr = 0x3004F5C
  currBoxIndexPointerAddr = 0x3004F60
 end
end

function printGameInfo()
 setGameVersion()
 wrongGameVersion = true
 GameInfo:clear()

 if gameVersion == "" then  -- Print game info
  GameInfo:print(_pokeluaText("Version: Unknown game", "版本：未知游戏"))
 elseif gameVersion ~= "FireRed" and gameVersion ~= "LeafGreen" then
  GameInfo:print(string.format(_pokeluaText("Version: %s - Wrong game version! Use FireRed/LeafGreen instead\n", "版本：%s - 游戏版本错误！请改用火红／叶绿\n"), gameVersion))
 elseif gameLanguage == "" then
  GameInfo:print(_pokeluaText("Version: ", "版本：")..gameVersion.."\n".._pokeluaText("Language: Unknown language\n", "语言：未知语言\n"))
 else
  wrongGameVersion = false
  GameInfo:print(_pokeluaText("Version: ", "版本：")..gameVersion.."\n"..string.format(_pokeluaText("Language: %s\n", "语言：%s\n"), gameLanguage))
 end
end

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

 return dist > 999 and dist - 0x100000000 or dist
end

local initialSeedAddr, tempInitialSeed, advances = 0x2020000, 0, 0

function getRngInfo()
 local initial = emu:read16(initialSeedAddr)
 local current = emu:read32(currentSeedAddr)

 if initial == current or tempInitialSeed ~= initial then  -- Initial Seed generation check
  tempInitialSeed = initial
  tempCurrentSeed = initial
  advances = 0
 end

 advances = advances + LCRNGDistance(tempCurrentSeed, current)

 return initial, current, advances
end

function showRngInfo(buffer)
 local initialSeed, currentSeed, currentAdvances = getRngInfo()
 buffer:clear()
 buffer:print(string.format(_pokeluaText("Initial Seed: %04X\nCurrent Seed: %08X\nAdvances: %d\n\n\n", "初始种子：%04X\n当前种子：%08X\n推进数：%d\n\n\n"), initialSeed, currentSeed, currentAdvances))
end

function getBikeMod(rate)
 local isPlayerOnBike = emu:read8(playerWalkRunStateAddr) & 6 ~= 0

 return isPlayerOnBike and (rate * 80) // 100 or rate
end

function getActivedFluteType()
 local fluteFlagsAddr = emu:read32(saveBlock1PointerAddr) + 0xFE0
 local fluteEffectActivedFlag = emu:read8(fluteFlagsAddr)
 local isWhiteFlute = fluteEffectActivedFlag >> 3 == 1
 local isBlackFlute = fluteEffectActivedFlag >> 4 == 1

 return isWhiteFlute and 1 or isBlackFlute and 2 or 0
end

function getFluteEffectMod(finalRate)
 local activedFluteType = getActivedFluteType()
 local isWhiteFluteActived = activedFluteType == 1
 local isBlackFluteActived = activedFluteType == 2

 return isWhiteFluteActived and finalRate + finalRate // 2 or isBlackFluteActived and finalRate // 2 or finalRate
end

function getCleanseTagEffectMod(finalRate)
 local partyLeadHeldItem = emu:read8(wildEncounterDataAddr + 0xA)
 local isPartyLeadHoldingCleanseTag = partyLeadHeldItem == 0xBE

 return isPartyLeadHoldingCleanseTag and (finalRate * 2) // 3 or finalRate
end

function getAbilityEffectMod(finalRate)
 local partyLeadAbilityEffectType = emu:read8(wildEncounterDataAddr + 0x9)

 return partyLeadAbilityEffectType == 1 and finalRate // 2 or partyLeadAbilityEffectType == 2 and finalRate * 2 or finalRate
end

function getEncounterCheckValue(seed)
 return (seed >> 16) % 0x640
end

function getEncounterMissingSteps(rate, rateBuff, rateBase)
 local wildEncounterSeed = emu:read32(wildEncounterDataAddr)
 local isEncounterStep = false
 local missingSteps = 0
 local finalRate = 0

 while not isEncounterStep do
  wildEncounterSeed = LCRNG(wildEncounterSeed, 0x41C64E6D, 0x3039)
  rateBuff = rateBuff + rateBase
  finalRate = rate + (16 * rateBuff) // 200
  finalRate = getFluteEffectMod(finalRate)
  finalRate = getCleanseTagEffectMod(finalRate)
  finalRate = getAbilityEffectMod(finalRate)

  isEncounterStep = getEncounterCheckValue(wildEncounterSeed) < (finalRate > 1600 and 1600 or finalRate)
  missingSteps = missingSteps + 1
 end

 return missingSteps
end

local encounterRateBase, encounterRateFlag = 0, false

function showEncounterMissingSteps(buffer)
 local encounterRateBuff = emu:read16(wildEncounterDataAddr + 0x6)

 if encounterRateBuff == 0 then
  encounterRateFlag = false
 elseif not encounterRateFlag then
  encounterRateBase = encounterRateBuff
  encounterRateFlag = true
 end

 local encounterRate = getBikeMod(16 * encounterRateBase)
 local encounterMissingSteps = encounterRateBuff == 0 and 0 or getEncounterMissingSteps(encounterRate, encounterRateBuff, encounterRateBase)
 buffer:print(string.format(_pokeluaText("Steps for wild encounter: %d\n", "距离野生遭遇的步数：%d\n"), encounterMissingSteps))
end

function showStepCounter(buffer)
 local stepCounterAddr = emu:read32(saveBlock1PointerAddr) + 0x309A
 local stepCounter = 255 - emu:read8(stepCounterAddr)
 buffer:print(string.format(_pokeluaText("Steps counter (Egg cycles): %d\n\n\n", "步数计数（孵蛋周期）：%d\n\n\n"), stepCounter))
end

function getPokemonIDs(addr)
 local pokemonIDs = emu:read32(addr + 0x4)
 local TID = pokemonIDs & 0xFFFF
 local SID = pokemonIDs >> 16

 return TID, SID
end

function getTrainerIDs()
 local trainerIDsAddr = emu:read32(saveBlock2PointerAddr) + 0xA
 local TID = emu:read16(trainerIDsAddr)
 local SID = emu:read16(trainerIDsAddr + 0x2)

 return TID, SID
end

function shinyCheck(PID, addr)
 addr = addr or nil

 local trainerTID, trainerSID

 if addr then
  trainerTID, trainerSID = getPokemonIDs(addr)
 else
  trainerTID, trainerSID = getTrainerIDs()
 end

 local lowPID = PID & 0xFFFF
 local highPID = PID >> 16
 local shinyTypeValue = (trainerSID ~ trainerTID) ~ (lowPID ~ highPID)

 if shinyTypeValue < 8 then
  return shinyTypeValue == 0 and _pokeluaText(" (Square)", "（方块）") or _pokeluaText(" (Star)", "（星星）")
 end

 return ""
end

function getOffset(offsetType, orderIndex)
 local offsets = {[_pokeluaText("growth", "成长")] = {0,0,0,0,0,0, 1,1,2,3,2,3, 1,1,2,3,2,3, 1,1,2,3,2,3},
                  [_pokeluaText("attack", "攻击")] = {1,1,2,3,2,3, 0,0,0,0,0,0, 2,3,1,1,3,2, 2,3,1,1,3,2},
                  ["misc"]   = {3,2,3,2,1,1, 3,2,3,2,1,1, 3,2,3,2,1,1, 0,0,0,0,0,0}}

 return offsets[offsetType][orderIndex] * 12
end

function getIVs(ivsValue)
 local hpIV = ivsValue & 0x1F
 local atkIV = (ivsValue & (0x1F * 0x20)) / 0x20
 local defIV = (ivsValue & (0x1F * 0x400)) / 0x400
 local spAtkIV = (ivsValue & (0x1F * 0x100000)) / 0x100000
 local spDefIV = (ivsValue & (0x1F * 0x2000000)) / 0x2000000
 local spdIV = (ivsValue & (0x1F * 0x8000)) / 0x8000

 return hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV
end

function getHPTypeAndPower(hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV)
 local hpType = (((hpIV & 1) + (2 * (atkIV & 1)) + (4 * (defIV & 1)) + (8 * (spdIV & 1)) + (16 * (spAtkIV & 1))
                + (32 * (spDefIV & 1))) * 15) // 63
 local hpPower = (((((hpIV >> 1) & 1) + (2 * ((atkIV >> 1) & 1)) + (4 * ((defIV >> 1) & 1)) + (8 * ((spdIV >> 1) & 1))
                 + (16 * ((spAtkIV >> 1) & 1)) + (32 * ((spDefIV >> 1) & 1))) * 40) // 63) + 30

 return hpType, hpPower
end

function showIVsAndHP(ivsValue, buffer)
 local hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV = getIVs(ivsValue)
 local hpType, hpPower = getHPTypeAndPower(hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV)
 buffer:print(string.format(_pokeluaText("IVs: %02d/%02d/%02d/%02d/%02d/%02d\nHPower: %s %d\n", "个体值：%02d/%02d/%02d/%02d/%02d/%02d\n觉醒力量：%s %d\n"),
              hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV, HPTypeNamesList[hpType + 1], hpPower))
end

function getMoves(value1, value2)
 local move1 = value1 & 0xFFF
 local move2 = value1 >> 16
 local move3 = value2 & 0xFFF
 local move4 = value2 >> 16

 return move1, move2, move3, move4
end

function getPP(value)
 local PP1 = value & 0xFF
 local PP2 = (value >> 8) & 0xFF
 local PP3 = (value >> 16) & 0xFF
 local PP4 = value >> 24

 return PP1, PP2, PP3, PP4
end

function isEgg(addr)
 return emu:read16(addr + 0x12) == 0x601
end

function strPadding(moveStr, maxLength)
 local spaces = ""
 local moveStrLength = string.len(moveStr)

 if moveStrLength < maxLength then
  local padding = maxLength - moveStrLength

  for i = 0, padding do
   spaces = spaces.." "
  end
 end

 return moveStr..spaces
end

function showMovesAndPP(movesValue1, movesValue2, ppValue, buffer)
 local move1Index, move2Index, move3Index, move4Index = getMoves(movesValue1, movesValue2)
 local PPmove1, PPmove2, PPmove3, PPmove4 = getPP(ppValue)
 buffer:print(string.format(_pokeluaText("Move: %sPP: %d\n", "招式：%sPP：%d\n"), strPadding(moveNamesList[move1Index <= 354 and move1Index + 1 or 1], 15), PPmove1))
 buffer:print(string.format(_pokeluaText("Move: %sPP: %d\n", "招式：%sPP：%d\n"), strPadding(moveNamesList[move2Index <= 354 and move2Index + 1 or 1], 15), PPmove2))
 buffer:print(string.format(_pokeluaText("Move: %sPP: %d\n", "招式：%sPP：%d\n"), strPadding(moveNamesList[move3Index <= 354 and move3Index + 1 or 1], 15), PPmove3))
 buffer:print(string.format(_pokeluaText("Move: %sPP: %d\n\n\n", "招式：%sPP：%d\n\n\n"), strPadding(moveNamesList[move4Index <= 354 and move4Index + 1 or 1], 15), PPmove4))
end

function showInfo(pidAddr, buffer)
 local pokemonPID = emu:read32(pidAddr)
 local shinyType = shinyCheck(pokemonPID, pidAddr)
 local natureIndex = pokemonPID % 25
 local pokemonIDs = emu:read32(pidAddr + 0x4)
 local orderIndex = (pokemonPID % 24) + 1
 local decryptionKey = pokemonPID ~ pokemonIDs
 local growthOffset = getOffset(_pokeluaText("growth", "成长"), orderIndex)
 local attacksOffset = getOffset(_pokeluaText("attack", "攻击"), orderIndex)
 local miscOffset = getOffset("misc", orderIndex)

 local ivsAndAbilityValue = emu:read32(pidAddr + 0x20 + miscOffset + 0x4) ~ decryptionKey
 local speciesAndItemValue = emu:read32(pidAddr + 0x20 + growthOffset) ~ decryptionKey
 local friendshipAndPPbonusesValue = emu:read32(pidAddr + 0x20 + growthOffset + 0x8) ~ decryptionKey
 local movesValue1 = emu:read32(pidAddr + 0x20 + attacksOffset) ~ decryptionKey
 local movesValue2 = emu:read32(pidAddr + 0x20 + attacksOffset + 0x4) ~ decryptionKey
 local PPValue = emu:read32(pidAddr + 0x20 + attacksOffset + 0x8) ~ decryptionKey

 local speciesDexIndex = speciesAndItemValue & 0xFFFF
 local speciesDexNumber = nationalDexList[speciesDexIndex + 1]
 local speciesName = speciesNamesList[speciesDexNumber]

 local itemIndex = speciesAndItemValue >> 16
 local itemName = itemNamesList[itemIndex + 1]

 local friendship = (friendshipAndPPbonusesValue >> 8) & 0xFF

 local abilityNumber = (ivsAndAbilityValue >> 0x1F) + 1
 local abilityName = abilityNamesList[pokemonAbilities[(speciesDexNumber ~= nil and speciesDexNumber < 387) and speciesDexNumber or 1][abilityNumber]]

 buffer:print(string.format(_pokeluaText("Species: %s\n", "种类：%s\n"), speciesName ~= nil and speciesName or "--"))
 buffer:print(string.format(_pokeluaText("PID: %08X%s\n", "PID：%08X%s\n"), pokemonPID, shinyType))
 buffer:print(string.format(_pokeluaText("Nature: %s\n", "性格：%s\n"), natureNamesList[natureIndex + 1]))
 buffer:print(string.format(_pokeluaText("Ability: %s (%d)\n", "特性：%s (%d)\n"), abilityName == nil and "--" or abilityName, abilityNumber))
 showIVsAndHP(ivsAndAbilityValue, buffer)
 buffer:print(string.format(isEgg(pidAddr) and _pokeluaText("Egg cycles: %d\n", "蛋周期：%d\n") or _pokeluaText("Friendship: %d\n", "亲密度：%d\n"), friendship))
 buffer:print(string.format(_pokeluaText("Held item: %s\n\n", "携带道具：%s\n\n"), itemName ~= nil and itemName or "--"))
 showMovesAndPP(movesValue1, movesValue2, PPValue, buffer)
end

function showTrainerIDs(buffer)
 local trainerTID, trainerSID = getTrainerIDs()
 buffer:print(string.format(_pokeluaText("TID: %d\nSID: %d", "TID：%d\nSID：%d"), trainerTID, trainerSID))
end

function getDayCareInfo()
 local eggLowPIDAddr = emu:read32(eggLowPIDPointerAddr) + 0x2CE0
 local eggStepsCounter = 255 - emu:read8(eggLowPIDAddr - 0x4)
 local eggFlagAddr = emu:read32(saveBlock1PointerAddr) + 0xF2C
 local isEggReady = (emu:read8(eggFlagAddr) >> 6) & 0x1 == 1

 return isEggReady, eggStepsCounter, eggLowPIDAddr
end

function showDayCareInfo(buffer)
 local isEggReady, eggStepsCounter, eggLowPIDAddr = getDayCareInfo()

 if not isEggReady then
  buffer:print(string.format(_pokeluaText("Steps Counter: %d\nEgg is not ready\n", "步数计数器：%d\n蛋尚未准备好\n"), eggStepsCounter))
 end

 if isEggReady then
  local eggLowPid = emu:read16(eggLowPIDAddr)
  buffer:print(string.format(_pokeluaText("Egg generated, go get it!\nEgg lower PID: %04X\n\n\n", "蛋已生成，去领取吧！\n蛋低位 PID：%04X\n\n\n"), eggLowPid))
 elseif eggStepsCounter == 1 then
  buffer:print(_pokeluaText("Next step might generate an egg!\n\n\n", "下一步可能生成蛋！\n\n\n"))
 elseif eggStepsCounter == 0 then
  buffer:print(_pokeluaText("255th step taken\n\n\n", "已走第 255 步\n\n\n"))
 else
  buffer:print(_pokeluaText("Keep on steppin'\n\n\n", "继续走动\n\n\n"))
 end
end

function showPartyEggInfo(buffer)
 local partySlotsCounter = emu:read8(partySlotsCounterAddr) - 1
 local lastPartySlotAddr = partyAddr + (partySlotsCounter * 0x64)

 if isEgg(lastPartySlotAddr) then
  showInfo(lastPartySlotAddr, buffer)
 end
end

function getRoamerInfo()
 local roamerAddr = emu:read32(saveBlock1PointerAddr) + 0x30D0
 local roamerIVsValue = emu:read32(roamerAddr) & 0xFF  -- Raomes IVs bug (RS/FRLG only)
 local roamerPID = emu:read32(roamerAddr + 0x4)
 local roamerShinyType = shinyCheck(roamerPID)
 local roamerNatureIndex = roamerPID % 25
 local roamerSpeciesIndex = emu:read16(roamerAddr + 0x8)
 local roamerDexIndex = nationalDexList[roamerSpeciesIndex + 1]
 local roamerSpeciesName = speciesNamesList[roamerDexIndex]
 local roamerHP = emu:read16(roamerAddr + 0xA)
 local roamerLevel = emu:read8(roamerAddr + 0xC)
 local roamerStatusIndex = emu:read8(roamerAddr + 0xD)
 local roamerStatus = statusConditionNamesList[1]  -- No altered status condition

 local roamerMapGroupAndNum = emu:read16(roamerMapGroupAndNumAddr)
 local roamerMapIndex = roamerMapGroupAndNum >> 8
 local playerMapGroupAndNumAddr = emu:read32(saveBlock1PointerAddr) + 0x4
 local playerMapGroupAndNum = emu:read16(playerMapGroupAndNumAddr)

 if roamerStatusIndex > 0 and roamerStatusIndex < 0x8 then  -- Sleep
  roamerStatus = statusConditionNamesList[2]
 elseif roamerStatusIndex == 0x8 then  -- Poison
  roamerStatus = statusConditionNamesList[3]
 elseif roamerStatusIndex == 0x10 then  -- Burn
  roamerStatus = statusConditionNamesList[4]
 elseif roamerStatusIndex == 0x20 then  -- Freeze
  roamerStatus = statusConditionNamesList[5]
 elseif roamerStatusIndex == 0x40 then  -- Paralysis
  roamerStatus = statusConditionNamesList[6]
 elseif roamerStatusIndex == 0x80 then  -- Bad Poison
  roamerStatus = statusConditionNamesList[7]
 end

 local isRoamerActive = emu:read8(roamerAddr + 0x13) == 1

 return roamerSpeciesName, roamerPID, roamerShinyType, roamerNatureIndex, roamerIVsValue, isRoamerActive,
        roamerLevel, roamerHP, roamerStatus, roamerMapIndex, roamerMapGroupAndNum, playerMapGroupAndNum
end

function showRoamerInfo(buffer)
 local roamerSpeciesName, roamerPID, roamerShinyType, roamerNatureIndex, roamerIVsValue, isRoamerActive,
       roamerLevel, roamerHP, roamerStatus, roamerMapIndex, roamerMapGroupAndNum, playerMapGroupAndNum = getRoamerInfo()

 if isRoamerActive then
  buffer:print(_pokeluaText("Active Roamer? Yes\n", "存在活跃游走宝可梦？ 是\n"))
  buffer:print(string.format(_pokeluaText("Species: %s\n", "种类：%s\n"), roamerSpeciesName))
  buffer:print(string.format(_pokeluaText("PID: %08X%s\n", "PID：%08X%s\n"), roamerPID, roamerShinyType))
  buffer:print(string.format(_pokeluaText("Nature: %s\n", "性格：%s\n"), natureNamesList[roamerNatureIndex + 1]))
  showIVsAndHP(roamerIVsValue, buffer)
  buffer:print(string.format(_pokeluaText("Level: %d\n", "等级：%d\n"), roamerLevel))
  buffer:print(string.format(_pokeluaText("HP: %d\n", "HP：%d\n"), roamerHP))
  buffer:print(string.format(_pokeluaText("Status condition: %s\n", "异常状态：%s\n"), roamerStatus))
  buffer:print(string.format(_pokeluaText("Current position: %s%s\n\n\n", "当前位置：%s%s\n\n\n"), locationNamesList[roamerMapIndex + 1],
                              roamerMapGroupAndNum == playerMapGroupAndNum and " (!!!)" or ""))
 else
  buffer:print(_pokeluaText("Active Roamer? No\n\n\n", "存在活跃游走宝可梦？ 否\n\n\n"))
 end
end

local prevKeyInfo, infoIndex, infoMode = {}, 1, {
      _pokeluaText("Gift", "礼物"), _pokeluaText("Party", "同行"), _pokeluaText("Party Stats", "同行状态"), _pokeluaText("Battle Party Stats", "对战队伍状态"), _pokeluaText("Box", "盒子"), _pokeluaText("1st Floor Box Stats", "1 楼盒子状态"), _pokeluaText("2nd Floor Box Stats", "2 楼盒子状态"), _pokeluaText("DayCare Box Stats", "寄放屋盒子状态")}

function getInfoInput(buffer)
 local key = emu:getKeys()

 if key == 0x120 and prevKeyInfo ~= key then
  infoIndex = infoIndex - 1 < 1 and 8 or infoIndex - 1
 elseif key == 0x110 and prevKeyInfo ~= key then
  infoIndex = infoIndex + 1 > 8 and 1 or infoIndex + 1
 end

 prevKeyInfo = key
 buffer:print(string.format(_pokeluaText("Mode: %s(Change mode pressing R+Right/R+Left)\n\n", "模式：%s（按 R+右/R+左切换模式）\n\n"), strPadding(infoMode[infoIndex], 20)))
end

function showPokemonIDs(addr, buffer)
 local pokemonTID, pokemonSID = getPokemonIDs(addr)
 buffer:print(string.format(_pokeluaText("TID: %d\nSID: %d", "TID：%d\nSID：%d"), pokemonTID, pokemonSID))
end

function showPokemonInfo(buffer)
 getInfoInput(buffer)

 if infoMode[infoIndex] == _pokeluaText("Gift", "礼物") then
  local partySlotsCounter = emu:read8(partySlotsCounterAddr) - 1
  local lastPartySlotAddr = partyAddr + (partySlotsCounter * 0x64)

  showInfo(lastPartySlotAddr, buffer)
  showPokemonIDs(lastPartySlotAddr, buffer)
 elseif infoMode[infoIndex] == _pokeluaText("Party", "同行") then
  local partySelectedSlotIndex = emu:read8(partySelectedSlotIndexAddr)
  local partySelectedPokemonAddr = partyAddr + (partySelectedSlotIndex * 0x64)

  showInfo(partySelectedPokemonAddr, buffer)
  showPokemonIDs(partySelectedPokemonAddr, buffer)
 elseif infoMode[infoIndex] == _pokeluaText("Box", "盒子") then
  local currBoxIndexAddr = emu:read32(currBoxIndexPointerAddr)
  local currBoxIndex = emu:read8(currBoxIndexAddr)
  local boxAddr = currBoxIndexAddr + 0x4
  local boxSelectedSlotIndex = emu:read8(boxSelectedSlotIndexAddr)
  local boxSelectedPokemonAddr = boxAddr + (0x1E * currBoxIndex * 0x50) + (boxSelectedSlotIndex * 0x50)

  showInfo(boxSelectedPokemonAddr, buffer)
  showPokemonIDs(boxSelectedPokemonAddr, buffer)
 elseif infoMode[infoIndex] == _pokeluaText("Battle Party Stats", "对战队伍状态") then
  showInfo(pokemonBattleStatsScreenAddr, buffer)
  showPokemonIDs(pokemonBattleStatsScreenAddr, buffer)
 elseif infoMode[infoIndex] == _pokeluaText("1st Floor Box Stats", "1 楼盒子状态") then
  showInfo(pokemonStatsScreenAddr, buffer)
  showPokemonIDs(pokemonStatsScreenAddr, buffer)
 elseif infoMode[infoIndex] == _pokeluaText("Party Stats", "同行状态") or infoMode[infoIndex] == _pokeluaText("2nd Floor Box Stats", "2 楼盒子状态")
        or infoMode[infoIndex] == _pokeluaText("DayCare Box Stats", "寄放屋盒子状态")
 then
  showInfo(pokemonStatsScreen2Addr, buffer)
  showPokemonIDs(pokemonStatsScreen2Addr, buffer)
 end
end

function updateCaptureBuffer()
 showRngInfo(CaptureInfo)
 showEncounterMissingSteps(CaptureInfo)
 showStepCounter(CaptureInfo)
 showInfo(enemyAddr, CaptureInfo)
 showTrainerIDs(CaptureInfo)
end

function updateBreedingBuffer()
 showRngInfo(BreedingInfo)
 showDayCareInfo(BreedingInfo)
 showPartyEggInfo(BreedingInfo)
 showTrainerIDs(BreedingInfo)
end

function updateRoamerBuffer()
 showRngInfo(RoamerInfo)
 showRoamerInfo(RoamerInfo)
 showTrainerIDs(RoamerInfo)
end

function updatePandoraBuffer()
 showRngInfo(PandoraInfo)
 PandoraInfo:print(string.format(_pokeluaText("Temporary TID: %d\n\n\n", "临时 TID：%d\n\n\n"), emu:read16(initialSeedAddr)))
 showTrainerIDs(PandoraInfo)
end

function printInitialSeedBotInstructions()
 InitialSeedBotInfo:clear()
 InitialSeedBotInfo:print(_pokeluaText("1) Edit the first line of this script\n", "1）编辑此脚本第一行\n"))
 InitialSeedBotInfo:print(_pokeluaText("2) Go to the continue screen\n", "2）进入继续游戏画面\n"))
 InitialSeedBotInfo:print(_pokeluaText("3) Press Shift + SELECT\n\n\n", "3）按 Shift + SELECT\n\n\n"))
end

local initialSeedWrittenFlag = false

function initialSeedWritten()
 initialSeedWrittenFlag = true
end

local initialSeedAddrWatchpoint = emu:setWatchpoint(initialSeedWritten, initialSeedAddr, 1)

function initialSeedFoundCheck(initialSeed)
 for _, targetInitialSeed in ipairs(botTargetInitialSeeds) do
  if initialSeed == targetInitialSeed then
   return true
  end
 end

 return false
end

local currentEmuFrame, continueScreen
local initialSeedBotStartedFlag, initialSeedFoundFlag = false, false

function initialSeedBotLoop()
 if currentEmuFrame == emu:currentFrame() - 1 then  -- Save a temporary state and press B one frame after the starting one
  continueScreen = emu:saveStateBuffer()
  emu:addKey(C.GBA_KEY.B)
 end

 if currentEmuFrame == emu:currentFrame() - 35 then  -- Press A 35 frame after the starting one
  emu:addKey(C.GBA_KEY.A)
 end

 if emu:getKey(C.GBA_KEY.A) == 1 and currentEmuFrame == emu:currentFrame() - 36 then  -- Clear the A button press one frame after the button press
  emu:clearKey(C.GBA_KEY.A)
 end

 if currentEmuFrame == emu:currentFrame() - 40 then  -- Press A 40 frame after the starting one
  emu:addKey(C.GBA_KEY.A)
 end

 if emu:getKey(C.GBA_KEY.A) == 1 and currentEmuFrame == emu:currentFrame() - 41 then  -- Clear the A button press one frame after the button press
  emu:clearKey(C.GBA_KEY.A)
 end

 if initialSeedWrittenFlag then
  local tempInitialSeed = emu:read16(initialSeedAddr)

  if initialSeedFoundCheck(tempInitialSeed) then
   initialSeedBotStartedFlag = false
   initialSeedFoundFlag = true
   emu:clearKey(C.GBA_KEY.B)
  else
   initialSeedWrittenFlag = false
   emu:loadStateBuffer(continueScreen)
   currentEmuFrame = emu:currentFrame()
  end

  InitialSeedBotInfo:clear()
  InitialSeedBotInfo:print(string.format(_pokeluaText("Initial Seed: %04X", "初始种子：%04X"), tempInitialSeed))
 end
end

function updateInitialSeedBotBuffer()
 if not initialSeedBotStartedFlag then
  printInitialSeedBotInstructions()
 end

 if input:isKeyActive(8388658) and emu:getKey(C.GBA_KEY.SELECT) == 1 and not initialSeedBotStartedFlag then  -- Check if Shift + SELECT is being pressed
  initialSeedBotStartedFlag = true
  initialSeedFoundFlag = false
  initialSeedWrittenFlag = false
  currentEmuFrame = emu:currentFrame()
 end

 if initialSeedBotStartedFlag then
  initialSeedBotLoop()
 end

 if initialSeedFoundFlag then
  InitialSeedBotInfo:print(string.format(_pokeluaText("Initial Seed found!\nInitial Seed: %04X", "已找到初始种子！\n初始种子：%04X"), emu:read16(initialSeedAddr)))
 end
end

function printTIDBotInstructions()
 TIDBotInfo:clear()
 TIDBotInfo:print(_pokeluaText("1) Edit the second line of this script\n", "1）编辑此脚本第二行\n"))
 TIDBotInfo:print(_pokeluaText("2) Go to the name insertion screen\n", "2）进入名字输入画面\n"))
 TIDBotInfo:print(_pokeluaText("3) Input the name you like\n", "3）输入你喜欢的名字\n"))
 TIDBotInfo:print(_pokeluaText("4) Place the selection cursor on the OK button\n", "4）将选择光标放在 OK 按钮上\n"))
 TIDBotInfo:print(_pokeluaText("5) Press Shift + START\n\n\n", "5）按 Shift + START\n\n\n"))
end

function TIDFoundCheck(TID)
 for _, targetTID in ipairs(botTargetTIDs) do
  if TID == targetTID then
   return true
  end
 end

 return false
end

local insertionNameState
local TIDBotStartedFlag, TIDFoundFlag = false, false

function TIDBotLoop()
 if currentEmuFrame == emu:currentFrame() - 1 then  -- Save a temporary state and press A one frame after the starting one
  insertionNameState = emu:saveStateBuffer()
  emu:addKey(C.GBA_KEY.A)
 end

 if emu:getKey(C.GBA_KEY.A) == 1 and currentEmuFrame == emu:currentFrame() - 2 then  -- Clear the A button press one frame after the button press
  emu:clearKey(C.GBA_KEY.A)
 end

 if initialSeedWrittenFlag then
  local tempTID = emu:read16(initialSeedAddr)

  if TIDFoundCheck(tempTID) then
   TIDBotStartedFlag = false
   TIDFoundFlag = true
  else
   initialSeedWrittenFlag = false
   emu:loadStateBuffer(insertionNameState)
   currentEmuFrame = emu:currentFrame()
  end

  TIDBotInfo:clear()
  TIDBotInfo:print(string.format(_pokeluaText("TID: %d", "TID：%d"), tempTID))
 end
end

function updateTIDBotBuffer()
 if not TIDBotStartedFlag then
  printTIDBotInstructions()
 end

 if input:isKeyActive(8388658) and emu:getKey(C.GBA_KEY.START) == 1 and not TIDBotStartedFlag then  -- Check if Shift + START is being pressed
  TIDBotStartedFlag = true
  TIDFoundFlag = false
  initialSeedWrittenFlag = false
  currentEmuFrame = emu:currentFrame()
 end

 if TIDBotStartedFlag then
  TIDBotLoop()
 end

 if TIDFoundFlag then
  TIDBotInfo:print(string.format(_pokeluaText("TID found!\nTID: %d", "已找到 TID！\nTID：%d"), emu:read16(initialSeedAddr)))
 end
end

function updatePokemonInfoBuffer()
 showRngInfo(PokemonInfo)
 showPokemonInfo(PokemonInfo)
end

function createStateFile(statesFileName, stateSlot)
 os.execute("mkdir states")
 local statesFile = io.open(statesFileName, "w")

 if statesFile then  -- Check if the state file has been created correctly
  for slotNumber = 1, 9 do
   if slotNumber == stateSlot then  -- Write only in the line of the saved slot
    statesFile:write(string.format("%08X %08X %d\n", tempInitialSeed, tempCurrentSeed, advances))
   else  -- Fill with empty data the lines of not saved state
    statesFile:write("00000000 00000000 0\n")
   end
  end

  statesFile:close()
 end
end

function writeStateFile(statesFileName, stateSlot)
 local statesFile = io.open(statesFileName, "r")
 local line_num = 1
 local lines = ""

 for line in statesFile:lines() do
  if line_num == stateSlot then  -- Overwrite only the line of the saved slot
   line = string.format("%08X %08X %d", tempInitialSeed, tempCurrentSeed, advances)
  end

  lines = lines..line.."\n"
  line_num = line_num + 1
 end

 statesFile:close()
 statesFile = io.open(statesFileName, "w")
 statesFile:write(lines)
 statesFile:close()
end

function writeSaveStateValues(statesFileName, stateSlot)
 local statesFileCheck = io.open(statesFileName, "r")

 if not statesFileCheck then  -- Check if the states file does not exist
  createStateFile(statesFileName, stateSlot)
 else  -- States file already exists
  statesFileCheck:close()
  writeStateFile(statesFileName, stateSlot)
 end
end

function setSaveStateValues(statesFileName, stateSlot)
 local statesFile = io.open(statesFileName, "r")

 if statesFile then
  local line_num = 1
  local values = {}

  for line in statesFile:lines() do
   if line_num == stateSlot then  -- Load values from the line of the loaded slot only
    for value in line:gmatch("%S+") do
     table.insert(values, value)
    end

    break
   end

   line_num = line_num + 1
  end

  statesFile:close()
  tempInitialSeed = tonumber(values[1], 16)
  tempCurrentSeed = tonumber(values[2], 16)
  advances = tonumber(values[3])
 end
end

function getSaveStateInput()
 local slotNumber = nil

 if input:isKeyActive(49) or input:isKeyActive(33) then  -- Check if (n) is being pressed
  slotNumber = 1
 elseif input:isKeyActive(50) or input:isKeyActive(34) then
  slotNumber = 2
 elseif input:isKeyActive(51) or input:isKeyActive(163) then
  slotNumber = 3
 elseif input:isKeyActive(52) or input:isKeyActive(36) then
  slotNumber = 4
 elseif input:isKeyActive(53) or input:isKeyActive(37) then
  slotNumber = 5
 elseif input:isKeyActive(54) or input:isKeyActive(38) then
  slotNumber = 6
 elseif input:isKeyActive(55) or input:isKeyActive(47) then
  slotNumber = 7
 elseif input:isKeyActive(56) or input:isKeyActive(40) then
  slotNumber = 8
 elseif input:isKeyActive(57) or input:isKeyActive(41) then
  slotNumber = 9
 end

 if slotNumber ~= nil then
  local savingStateFlag = input:isKeyActive(8388658)  -- Check if Shift is being pressed
  local statesFileName = string.format("states/%s_%s_states_values.txt", gameVersion, string.gsub(gameLanguage, "/", "_"))

  if savingStateFlag then  -- Saving a state
   emu:saveStateSlot(slotNumber)
   writeSaveStateValues(statesFileName, slotNumber)
  else  -- Loading a state
   emu:loadStateSlot(slotNumber)
   setSaveStateValues(statesFileName, slotNumber)
  end
 end
end

function updateBuffers()
 if (not wrongGameVersion) then
  updateCaptureBuffer()
  updateBreedingBuffer()
  updateRoamerBuffer()
  updatePandoraBuffer()
  updateInitialSeedBotBuffer()
  updateTIDBotBuffer()
  updatePokemonInfoBuffer()
  getSaveStateInput()
 end
end

emu:reset()
initializeBuffers()
printGameInfo()
callbacks:add("frame", updateBuffers)
callbacks:add("reset", printGameInfo)