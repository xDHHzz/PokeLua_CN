-- Optional display language: "en" or "zh-Hans". Reload after changing.
-- 可选显示语言：英文 "en"／简体中文 "zh-Hans"。修改后重新加载脚本。
local POKELUA_LANGUAGE = "en"
local function _pokeluaText(english, chinese)
 if POKELUA_LANGUAGE == "zh-Hans" then return chinese end
 return english
end
-- END POKELUA LOCALIZATION

read32Bit = memory.readdwordunsigned
read16Bit = memory.readword
read8Bit = memory.readbyte
rshift = bit.rshift
lshift = bit.lshift
band = bit.band
bxor = bit.bxor
bor = bit.bor
floor = math.floor

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
 _pokeluaText("Latias", "拉帝亚斯"), _pokeluaText("Latios", "拉帝欧斯"),  _pokeluaText("Kyogre", "盖欧卡"), _pokeluaText("Groudon", "固拉多"), _pokeluaText("Rayquaza", "烈空坐"), _pokeluaText("Jirachi", "基拉祈"), _pokeluaText("Deoxys", "代欧奇希斯"),
 -- Gen 4
 _pokeluaText("Turtwig", "草苗龟"), _pokeluaText("Grotle", "树林龟"), _pokeluaText("Torterra", "土台龟"), _pokeluaText("Chimchar", "小火焰猴"), _pokeluaText("Monferno", "猛火猴"), _pokeluaText("Infernape", "烈焰猴"), _pokeluaText("Piplup", "波加曼"), _pokeluaText("Prinplup", "波皇子"), _pokeluaText("Empoleon", "帝王拿波"), _pokeluaText("Starly", "姆克儿"),
 _pokeluaText("Staravia", "姆克鸟"), _pokeluaText("Staraptor", "姆克鹰"), _pokeluaText("Bidoof", "大牙狸"), _pokeluaText("Bibarel", "大尾狸"), _pokeluaText("Kricketot", "圆法师"), _pokeluaText("Kricketune", "音箱蟀"), _pokeluaText("Shinx", "小猫怪"), _pokeluaText("Luxio", "勒克猫"), _pokeluaText("Luxray", "伦琴猫"), _pokeluaText("Budew", "含羞苞"),
 _pokeluaText("Roserade", "罗丝雷朵"), _pokeluaText("Cranidos", "头盖龙"), _pokeluaText("Rampardos", "战槌龙"), _pokeluaText("Shieldon", "盾甲龙"), _pokeluaText("Bastiodon", "护城龙"), _pokeluaText("Burmy", "结草儿"), _pokeluaText("Wormadam", "结草贵妇"), _pokeluaText("Mothim", "绅士蛾"), _pokeluaText("Combee", "三蜜蜂"), _pokeluaText("Vespiquen", "蜂女王"),
 _pokeluaText("Pachirisu", "帕奇利兹"), _pokeluaText("Buizel", "泳圈鼬"), _pokeluaText("Floatzel", "浮潜鼬"), _pokeluaText("Cherubi", "樱花宝"), _pokeluaText("Cherrim", "樱花儿"), _pokeluaText("Shellos", "无壳海兔"), _pokeluaText("Gastrodon", "海兔兽"), _pokeluaText("Ambipom", "双尾怪手"), _pokeluaText("Drifloon", "飘飘球"), _pokeluaText("Drifblim", "随风球"),
 _pokeluaText("Buneary", "卷卷耳"), _pokeluaText("Lopunny", "长耳兔"), _pokeluaText("Mismagius", "梦妖魔"), _pokeluaText("Honchkrow", "乌鸦头头"), _pokeluaText("Glameow", "魅力喵"), _pokeluaText("Purugly", "东施喵"), _pokeluaText("Chingling", "铃铛响"), _pokeluaText("Stunky", "臭鼬噗"), _pokeluaText("Skuntank", "坦克臭鼬"), _pokeluaText("Bronzor", "铜镜怪"),
 _pokeluaText("Bronzong", "青铜钟"), _pokeluaText("Bonsly", "盆才怪"), _pokeluaText("Mime Jr.", "魔尼尼"), _pokeluaText("Happiny", "小福蛋"), _pokeluaText("Chatot", "聒噪鸟"), _pokeluaText("Spiritomb", "花岩怪"), _pokeluaText("Gible", "圆陆鲨"), _pokeluaText("Gabite", "尖牙陆鲨"), _pokeluaText("Garchomp", "烈咬陆鲨"), _pokeluaText("Munchlax", "小卡比兽"),
 _pokeluaText("Riolu", "利欧路"), _pokeluaText("Lucario", "路卡利欧"), _pokeluaText("Hippopotas", "沙河马"), _pokeluaText("Hippowdon", "河马兽"), _pokeluaText("Skorupi", "钳尾蝎"), _pokeluaText("Drapion", "龙王蝎"), _pokeluaText("Croagunk", "不良蛙"), _pokeluaText("Toxicroak", "毒骷蛙"), _pokeluaText("Carnivine", "尖牙笼"), _pokeluaText("Finneon", "荧光鱼"),
 _pokeluaText("Lumineon", "霓虹鱼"), _pokeluaText("Mantyke", "小球飞鱼"), _pokeluaText("Snover", "雪笠怪"), _pokeluaText("Abomasnow", "暴雪王"), _pokeluaText("Weavile", "玛狃拉"), _pokeluaText("Magnezone", "自爆磁怪"), _pokeluaText("Lickilicky", "大舌舔"), _pokeluaText("Rhyperior", "超甲狂犀"), _pokeluaText("Tangrowth", "巨蔓藤"),
 _pokeluaText("Electivire", "电击魔兽"), _pokeluaText("Magmortar", "鸭嘴炎兽"), _pokeluaText("Togekiss", "波克基斯"), _pokeluaText("Yanmega", "远古巨蜓"), _pokeluaText("Leafeon", "叶伊布"), _pokeluaText("Glaceon", "冰伊布"), _pokeluaText("Gliscor", "天蝎王"), _pokeluaText("Mamoswine", "象牙猪"), _pokeluaText("Porygon-Z", "多边兽乙型"),
 _pokeluaText("Gallade", "艾路雷朵"), _pokeluaText("Probopass", "大朝北鼻"), _pokeluaText("Dusknoir", "黑夜魔灵"), _pokeluaText("Froslass", "雪妖女"), _pokeluaText("Rotom", "洛托姆"), _pokeluaText("Uxie", "由克希"), _pokeluaText("Mesprit", "艾姆利多"), _pokeluaText("Azelf", "亚克诺姆"), _pokeluaText("Dialga", "帝牙卢卡"), _pokeluaText("Palkia", "帕路奇亚"), _pokeluaText("Heatran", "席多蓝恩"),
 _pokeluaText("Regigigas", "雷吉奇卡斯"), _pokeluaText("Giratina", "骑拉帝纳"), _pokeluaText("Cresselia", "克雷色利亚"), _pokeluaText("Phione", "霏欧纳"), _pokeluaText("Manaphy", "玛纳霏"), _pokeluaText("Darkrai", "达克莱伊"), _pokeluaText("Shaymin", "谢米"), _pokeluaText("Arceus", "阿尔宙斯")}

local abilityNamesList = {
 -- Gen 3
 _pokeluaText("Stench", "恶臭"), _pokeluaText("Drizzle", "降雨"), _pokeluaText("Speed Boost", "加速"), _pokeluaText("Battle Armor", "战斗盔甲"), _pokeluaText("Sturdy", "结实"), _pokeluaText("Damp", "湿气"), _pokeluaText("Limber", "柔软"), _pokeluaText("Sand Veil", "沙隐"), _pokeluaText("Static", "静电"),
 _pokeluaText("Volt Absorb", "蓄电"), _pokeluaText("Water Absorb", "储水"), _pokeluaText("Oblivious", "迟钝"), _pokeluaText("Cloud Nine", "无关天气"), _pokeluaText("Compound Eyes", "复眼"), _pokeluaText("Insomnia", "不眠"), _pokeluaText("Color Change", "变色"), _pokeluaText("Immunity", "免疫"),
 _pokeluaText("Flash Fire", "引火"), _pokeluaText("Shield Dust", "鳞粉"), _pokeluaText("Own Tempo", "我行我素"), _pokeluaText("Suction Cups", "吸盘"), _pokeluaText("Intimidate", "威吓"), _pokeluaText("Shadow Tag", "踩影"), _pokeluaText("Rough Skin", "粗糙皮肤"), _pokeluaText("Wonder Guard", "神奇守护"),
 _pokeluaText("Levitate", "飘浮"), _pokeluaText("Effect Spore", "孢子"), _pokeluaText("Synchronize", "同步"), _pokeluaText("Clear Body", "恒净之躯"), _pokeluaText("Natural Cure", "自然回复"), _pokeluaText("Lightning Rod", "避雷针"), _pokeluaText("Serene Grace", "天恩"),
 _pokeluaText("Swift Swim", "悠游自如"), _pokeluaText("Chlorophyll", "叶绿素"), _pokeluaText("Illuminate", "发光"), _pokeluaText("Trace", "复制"), _pokeluaText("Huge Power", "大力士"), _pokeluaText("Poison Point", "毒刺"), _pokeluaText("Inner Focus", "精神力"), _pokeluaText("Magma Armor", "熔岩铠甲"),
 _pokeluaText("Water Veil", "水幕"), _pokeluaText("Magnet Pull", "磁力"), _pokeluaText("Soundproof", "隔音"), _pokeluaText("Rain Dish", "雨盘"), _pokeluaText("Sand Stream", "扬沙"), _pokeluaText("Pressure", "压迫感"), _pokeluaText("Thick Fat", "厚脂肪"), _pokeluaText("Early Bird", "早起"),
 _pokeluaText("Flame Body", "火焰之躯"), _pokeluaText("Run Away", "逃跑"), _pokeluaText("Keen Eye", "锐利目光"), _pokeluaText("Hyper Cutter", "怪力钳"), _pokeluaText("Pickup", "捡拾"), _pokeluaText("Truant", "懒惰"), _pokeluaText("Hustle", "活力"), _pokeluaText("Cute Charm", "迷人之躯"), _pokeluaText("Plus", "正电"), _pokeluaText("Minus", "负电"),
 _pokeluaText("Forecast", "阴晴不定"), _pokeluaText("Sticky Hold", "黏着"), _pokeluaText("Shed Skin", "蜕皮"), _pokeluaText("Guts", "毅力"), _pokeluaText("Marvel Scale", "神奇鳞片"), _pokeluaText("Liquid Ooze", "污泥浆"), _pokeluaText("Overgrow", "茂盛"), _pokeluaText("Blaze", "猛火"), _pokeluaText("Torrent", "激流"),
 _pokeluaText("Swarm", "虫之预感"), _pokeluaText("Rock Head", "坚硬脑袋"), _pokeluaText("Drought", "日照"), _pokeluaText("Arena Trap", "沙穴"), _pokeluaText("Vital Spirit", "干劲"), _pokeluaText("White Smoke", "白色烟雾"), _pokeluaText("Pure Power", "瑜伽之力"), _pokeluaText("Shell Armor", "硬壳盔甲"),
 _pokeluaText("Air Lock", "气闸"),
 -- Gen 4
 _pokeluaText("Tangled Feet", "蹒跚"), _pokeluaText("Motor Drive", "电气引擎"), _pokeluaText("Rivalry", "斗争心"), _pokeluaText("Steadfast", "不屈之心"), _pokeluaText("Snow Cloak", "雪隐"), _pokeluaText("Gluttony", "贪吃鬼"), _pokeluaText("Anger Point", "愤怒穴位"), _pokeluaText("Unburden", "轻装"),
 _pokeluaText("Heatproof", "耐热"), _pokeluaText("Simple", "单纯"), _pokeluaText("Dry Skin", "干燥皮肤"), _pokeluaText("Download", "下载"), _pokeluaText("Iron Fist", "铁拳"), _pokeluaText("Poison Heal", "毒疗"), _pokeluaText("Adaptability", "适应力"), _pokeluaText("Skill Link", "连续攻击"), _pokeluaText("Hydration", "湿润之躯"),
 _pokeluaText("Solar Power", "太阳之力"), _pokeluaText("Quick Feet", "飞毛腿"), _pokeluaText("Normalize", "一般皮肤"), _pokeluaText("Sniper", "狙击手"), _pokeluaText("Magic Guard", "魔法防守"), _pokeluaText("No Guard", "无防守"), _pokeluaText("Stall", "慢出"), _pokeluaText("Technician", "技术高手"), _pokeluaText("Leaf Guard", "叶子防守"),
 _pokeluaText("Klutz", "笨拙"), _pokeluaText("Mold Breaker", "破格"), _pokeluaText("Super Luck", "超幸运"), _pokeluaText("Aftermath", "引爆"), _pokeluaText("Anticipation", "危险预知"), _pokeluaText("Forewarn", "预知梦"), _pokeluaText("Unaware", "纯朴"), _pokeluaText("Tinted Lens", "有色眼镜"), _pokeluaText("Filter", "过滤"),
 _pokeluaText("Slow Start", "慢启动"), _pokeluaText("Scrappy", "胆量"), _pokeluaText("Storm Drain", "引水"), _pokeluaText("Ice Body", "冰冻之躯"), _pokeluaText("Solid Rock", "坚硬岩石"), _pokeluaText("Snow Warning", "降雪"), _pokeluaText("Honey Gather", "采蜜"), _pokeluaText("Frisk", "察觉"), _pokeluaText("Reckless", "舍身"),
 _pokeluaText("Multitype", "多属性"), _pokeluaText("Flower Gift", "花之礼"), _pokeluaText("Bad Dreams", "梦魇")}

local pokemonAbilities = {
 [1] = {65}, [2] = {65}, [3] = {65}, [4] = {66}, [5] = {66}, [6] = {66}, [7] = {67}, [8] = {67},
 [9] = {67}, [10] = {19}, [11] = {61}, [12] = {14}, [13] = {19}, [14] = {61}, [15] = {68}, [16] = {51, 77},
 [17] = {51, 77}, [18] = {51, 77}, [19] = {50, 62}, [20] = {50, 62}, [21] = {51}, [22] = {51}, [23] = {22, 61},
 [24] = {22, 61}, [25] = {9}, [26] = {9}, [27] = {8}, [28] = {8}, [29] = {38, 79}, [30] = {38, 79},
 [31] = {38, 79}, [32] = {38, 79}, [33] = {38, 79}, [34] = {38, 79}, [35] = {56, 98}, [36] = {56, 98}, [37] = {18},
 [38] = {18}, [39] = {56}, [40] = {56}, [41] = {39}, [42] = {39}, [43] = {34}, [44] = {34}, [45] = {34},
 [46] = {27, 87}, [47] = {27, 87}, [48] = {14, 110}, [49] = {19, 110}, [50] = {8, 71}, [51] = {8, 71}, [52] = {53, 101},
 [53] = {7, 101}, [54] = {6, 13}, [55] = {6, 13}, [56] = {72, 83}, [57] = {72, 83}, [58] = {22, 18}, [59] = {22, 18},
 [60] = {11, 6}, [61] = {11, 6}, [62] = {11, 6}, [63] = {28, 39}, [64] = {28, 39}, [65] = {28, 39}, [66] = {62, 99},
 [67] = {62, 99}, [68] = {62, 99}, [69] = {34}, [70] = {34}, [71] = {34}, [72] = {29, 64}, [73] = {29, 64}, [74] = {69, 5},
 [75] = {69, 5}, [76] = {69, 5}, [77] = {50, 18}, [78] = {50, 18}, [79] = {12, 20}, [80] = {12, 20}, [81] = {42, 5},
 [82] = {42, 5}, [83] = {51, 39}, [84] = {50, 48}, [85] = {50, 48}, [86] = {47, 93}, [87] = {47, 93}, [88] = {1, 60},
 [89] = {1, 60}, [90] = {75, 92}, [91] = {75, 92}, [92] = {26}, [93] = {26}, [94] = {26}, [95] = {69, 5}, [96] = {15, 108},
 [97] = {15, 108}, [98] = {52, 75}, [99] = {52, 75}, [100] = {43, 9}, [101] = {43, 9}, [102] = {34}, [103] = {34}, [104] = {69, 31},
 [105] = {69, 31}, [106] = {7, 120}, [107] = {51, 89}, [108] = {20, 12}, [109] = {26}, [110] = {26}, [111] = {31, 69}, [112] = {31, 69},
 [113] = {30, 32}, [114] = {34, 102}, [115] = {48, 113}, [116] = {33, 97}, [117] = {38, 97}, [118] = {33, 41}, [119] = {33, 41},
 [120] = {35, 30}, [121] = {35, 30}, [122] = {43, 111}, [123] = {68, 101}, [124] = {12, 108}, [125] = {9}, [126] = {49}, [127] = {52, 104},
 [128] = {22, 83}, [129] = {33}, [130] = {22}, [131] = {11, 75}, [132] = {7}, [133] = {50, 91}, [134] = {11}, [135] = {10}, [136] = {18},
 [137] = {36, 88}, [138] = {33, 75}, [139] = {33, 75}, [140] = {33, 4}, [141] = {33, 4}, [142] = {69, 46}, [143] = {17, 47}, [144] = {46},
 [145] = {46}, [146] = {46}, [147] = {61}, [148] = {61}, [149] = {39}, [150] = {46}, [151] = {28}, [152] = {65}, [153] = {65}, [154] = {65},
 [155] = {66}, [156] = {66}, [157] = {66}, [158] = {67}, [159] = {67}, [160] = {67}, [161] = {50, 51}, [162] = {50, 51}, [163] = {15, 51},
 [164] = {15, 51}, [165] = {68, 48}, [166] = {68, 48}, [167] = {68, 15}, [168] = {68, 15}, [169] = {39}, [170] = {10, 35}, [171] = {10, 35},
 [172] = {9}, [173] = {56, 98}, [174] = {56}, [175] = {55, 32}, [176] = {55, 32}, [177] = {28, 48}, [178] = {28, 48}, [179] = {9},
 [180] = {9}, [181] = {9}, [182] = {34}, [183] = {47, 37}, [184] = {47, 37}, [185] = {5, 69}, [186] = {11, 6}, [187] = {34, 102},
 [188] = {34, 102}, [189] = {34, 102}, [190] = {50, 53}, [191] = {34, 94}, [192] = {34, 94}, [193] = {3, 14}, [194] = {6, 11}, [195] = {6, 11},
 [196] = {28}, [197] = {28}, [198] = {15, 105}, [199] = {12, 20}, [200] = {26}, [201] = {26}, [202] = {23}, [203] = {39, 48}, [204] = {5},
 [205] = {5}, [206] = {32, 50}, [207] = {52, 8}, [208] = {69, 5}, [209] = {22, 50}, [210] = {22, 95}, [211] = {38, 33}, [212] = {68, 101},
 [213] = {5, 82}, [214] = {68, 62}, [215] = {39, 51}, [216] = {53, 95}, [217] = {62, 95}, [218] = {40, 49}, [219] = {40, 49}, [220] = {12, 81},
 [221] = {12, 81}, [222] = {55, 30}, [223] = {55, 97}, [224] = {21, 97}, [225] = {72, 55}, [226] = {33, 11}, [227] = {51, 5}, [228] = {48, 18},
 [229] = {48, 18}, [230] = {33, 97}, [231] = {53}, [232] = {5}, [233] = {36, 88}, [234] = {22, 119}, [235] = {20, 101}, [236] = {62, 80},
 [237] = {22, 101}, [238] = {12, 108}, [239] = {9}, [240] = {49}, [241] = {47, 113}, [242] = {30, 32}, [243] = {46}, [244] = {46}, [245] = {46},
 [246] = {62}, [247] = {61}, [248] = {45}, [249] = {46}, [250] = {46}, [251] = {30}, [252] = {65}, [253] = {65}, [254] = {65}, [255] = {66},
 [256] = {66}, [257] = {66}, [258] = {67}, [259] = {67}, [260] = {67}, [261] = {50, 95}, [262] = {22, 95}, [263] = {53, 82}, [264] = {53, 82},
 [265] = {19}, [266] = {61}, [267] = {68}, [268] = {61}, [269] = {19}, [270] = {33, 44}, [271] = {33, 44}, [272] = {33, 44}, [273] = {34, 48},
 [274] = {34, 48}, [275] = {34, 48}, [276] = {62}, [277] = {62}, [278] = {51}, [279] = {51}, [280] = {28, 36}, [281] = {28, 36}, [282] = {28, 36},
 [283] = {33}, [284] = {22}, [285] = {27, 90}, [286] = {27, 90}, [287] = {54}, [288] = {72}, [289] = {54}, [290] = {14}, [291] = {3}, [292] = {25},
 [293] = {43}, [294] = {43}, [295] = {43}, [296] = {47, 62}, [297] = {47, 62}, [298] = {47, 37}, [299] = {5, 42}, [300] = {56, 96}, [301] = {56, 96},
 [302] = {51, 100}, [303] = {52, 22}, [304] = {5, 69}, [305] = {5, 69}, [306] = {5, 69}, [307] = {74}, [308] = {74}, [309] = {9, 31}, [310] = {9, 31},
 [311] = {57}, [312] = {58}, [313] = {35, 68}, [314] = {12, 110}, [315] = {30, 38}, [316] = {64, 60}, [317] = {64, 60}, [318] = {24}, [319] = {24},
 [320] = {41, 12}, [321] = {41, 12}, [322] = {12, 86}, [323] = {40, 116}, [324] = {73}, [325] = {47, 20}, [326] = {47, 20}, [327] = {20, 77},
 [328] = {52, 71}, [329] = {26}, [330] = {26}, [331] = {8}, [332] = {8}, [333] = {30}, [334] = {30}, [335] = {17}, [336] = {61}, [337] = {26},
 [338] = {26}, [339] = {12, 107}, [340] = {12, 107}, [341] = {52, 75}, [342] = {52, 75}, [343] = {26}, [344] = {26}, [345] = {21}, [346] = {21},
 [347] = {4}, [348] = {4}, [349] = {33}, [350] = {63}, [351] = {59}, [352] = {16}, [353] = {15, 119}, [354] = {15, 119}, [355] = {26}, [356] = {46},
 [357] = {34, 94}, [358] = {26}, [359] = {46, 105}, [360] = {23}, [361] = {39, 115}, [362] = {39, 115}, [363] = {47, 115}, [364] = {47, 115},
 [365] = {47, 115}, [366] = {75}, [367] = {33}, [368] = {33}, [369] = {33, 69}, [370] = {33}, [371] = {69}, [372] = {69}, [373] = {22}, [374] = {29},
 [375] = {29}, [376] = {29}, [377] = {29}, [378] = {29}, [379] = {29}, [380] = {26}, [381] = {26}, [382] = {2}, [383] = {70}, [384] = {76},
 [385] = {32}, [386] = {46}, [387] = {65}, [388] = {65}, [389] = {65}, [390] = {66}, [391] = {66}, [392] = {66}, [393] = {67}, [394] = {67},
 [395] = {67}, [396] = {51}, [397] = {22}, [398] = {22}, [399] = {86, 109}, [400] = {86, 109}, [401] = {61}, [402] = {68}, [403] = {79, 22},
 [404] = {79, 22}, [405] = {79, 22}, [406] = {30, 38}, [407] = {30, 38}, [408] = {104}, [409] = {104}, [410] = {5}, [411] = {5}, [412] = {61},
 [413] = {107}, [414] = {68}, [415] = {118}, [416] = {46}, [417] = {50, 53}, [418] = {33}, [419] = {33}, [420] = {34}, [421] = {122},
 [422] = {60, 114}, [423] = {60, 114}, [424] = {101, 53}, [425] = {106, 84}, [426] = {106, 84}, [427] = {50, 103}, [428] = {56, 103}, [429] = {26},
 [430] = {15, 105}, [431] = {7, 20}, [432] = {47, 20}, [433] = {26}, [434] = {1, 106}, [435] = {1, 106}, [436] = {26, 85}, [437] = {26, 85},
 [438] = {5, 69}, [439] = {43, 111}, [440] = {30, 32}, [441] = {51, 77}, [442] = {46}, [443] = {8}, [444] = {8}, [445] = {8}, [446] = {53, 47},
 [447] = {80, 39}, [448] = {80, 39}, [449] = {45}, [450] = {45}, [451] = {4, 97}, [452] = {4, 97}, [453] = {107, 87}, [454] = {107, 87}, [455] = {26},
 [456] = {33, 114}, [457] = {33, 114}, [458] = {33, 11}, [459] = {117}, [460] = {117}, [461] = {46}, [462] = {42, 5}, [463] = {20, 12},
 [464] = {31, 116}, [465] = {34, 102}, [466] = {78}, [467] = {49}, [468] = {55, 32}, [469] = {3, 110}, [470] = {102}, [471] = {81}, [472] = {52, 8},
 [473] = {12, 81}, [474] = {91, 88}, [475] = {80}, [476] = {5, 42}, [477] = {46}, [478] = {81}, [479] = {26}, [480] = {26}, [481] = {26}, [482] = {26},
 [483] = {46}, [484] = {46}, [485] = {18}, [486] = {112}, [487] = {46}, [488] = {26}, [489] = {93}, [490] = {93}, [491] = {123}, [492] = {30},
 [493] = {121}}

local moveNamesList = {
 -- Gen 1
 "--", _pokeluaText("Pound", "拍击"), _pokeluaText("Karate Chop", "空手劈"), _pokeluaText("Double Slap", "连环巴掌"), _pokeluaText("Comet Punch", "连续拳"), _pokeluaText("Mega Punch", "百万吨重拳"), _pokeluaText("Pay Day", "聚宝功"), _pokeluaText("Fire Punch", "火焰拳"), _pokeluaText("Ice Punch", "冰冻拳"),
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
 _pokeluaText("Super Fang", "愤怒门牙"), _pokeluaText("Slash", "劈开"), _pokeluaText("Substitute", "替身"), _pokeluaText("Struggle", "挣扎"),
 -- Gen 2
 _pokeluaText("Sketch", "写生"), _pokeluaText("Triple Kick", "三连踢"), _pokeluaText("Thief", "小偷"), _pokeluaText("Spider Web", "蛛网"), _pokeluaText("Mind Reader", "心之眼"),
 _pokeluaText("Nightmare", "恶梦"), _pokeluaText("Flame Wheel", "火焰轮"), _pokeluaText("Snore", "打鼾"), _pokeluaText("Curse", "诅咒"), _pokeluaText("Flail", "抓狂"), _pokeluaText("Conversion 2", "纹理２"), _pokeluaText("Aeroblast", "气旋攻击"), _pokeluaText("Cotton Spore", "棉孢子"), _pokeluaText("Reversal", "起死回生"),
 _pokeluaText("Spite", "怨恨"), _pokeluaText("Powder Snow", "细雪"), _pokeluaText("Protect", "守住"), _pokeluaText("Mach Punch", "音速拳"), _pokeluaText("Scary Face", "鬼面"), _pokeluaText("Feint Attack", "出奇一击"), _pokeluaText("Sweet Kiss", "天使之吻"), _pokeluaText("Belly Drum", "腹鼓"),
 _pokeluaText("Sludge Bomb", "污泥炸弹"), _pokeluaText("Mud-Slap", "掷泥"), _pokeluaText("Octazooka", "章鱼桶炮"), _pokeluaText("Spikes", "撒菱"), _pokeluaText("Zap Cannon", "电磁炮"), _pokeluaText("Foresight", "识破"), _pokeluaText("Destiny Bond", "同命"), _pokeluaText("Perish Song", "灭亡之歌"),
 _pokeluaText("Icy Wind", "冰冻之风"), _pokeluaText("Detect", "看穿"), _pokeluaText("Bone Rush", "骨棒乱打"), _pokeluaText("Lock-On", "锁定"), _pokeluaText("Outrage", "逆鳞"), _pokeluaText("Sandstorm", "沙暴"), _pokeluaText("Giga Drain", "终极吸取"), _pokeluaText("Endure", "挺住"), _pokeluaText("Charm", "撒娇"), _pokeluaText("Rollout", "滚动"),
 _pokeluaText("False Swipe", "点到为止"), _pokeluaText("Swagger", "虚张声势"), _pokeluaText("Milk Drink", "喝牛奶"), _pokeluaText("Spark", "电光"), _pokeluaText("Fury Cutter", "连斩"), _pokeluaText("Steel Wing", "钢翼"), _pokeluaText("Mean Look", "黑色目光"), _pokeluaText("Attract", "迷人"), _pokeluaText("Sleep Talk", "梦话"),
 _pokeluaText("Heal Bell", "治愈铃声"), _pokeluaText("Return", "报恩"), _pokeluaText("Present", "礼物"), _pokeluaText("Frustration", "迁怒"), _pokeluaText("Safeguard", "神秘守护"), _pokeluaText("Pain Split", "分担痛楚"), _pokeluaText("Sacred Fire", "神圣之火"), _pokeluaText("Magnitude", "震级"),
 _pokeluaText("Dynamic Punch", "爆裂拳"), _pokeluaText("Megahorn", "超级角击"), _pokeluaText("Dragon Breath", "龙息"), _pokeluaText("Baton Pass", "接棒"), _pokeluaText("Encore", "再来一次"), _pokeluaText("Pursuit", "追打"), _pokeluaText("Rapid Spin", "高速旋转"), _pokeluaText("Sweet Scent", "甜甜香气"),
 _pokeluaText("Iron Tail", "铁尾"), _pokeluaText("Metal Claw", "金属爪"), _pokeluaText("Vital Throw", "借力摔"), _pokeluaText("Morning Sun", "晨光"), _pokeluaText("Synthesis", "光合作用"), _pokeluaText("Moonlight", "月光"), _pokeluaText("Hidden Power", "觉醒力量"), _pokeluaText("Cross Chop", "十字劈"),
 _pokeluaText("Twister", "龙卷风"), _pokeluaText("Rain Dance", "求雨"), _pokeluaText("Sunny Day", "大晴天"), _pokeluaText("Crunch", "咬碎"), _pokeluaText("Mirror Coat", "镜面反射"), _pokeluaText("Psych Up", "自我暗示"), _pokeluaText("Extreme Speed", "神速"), _pokeluaText("Ancient Power", "原始之力"),
 _pokeluaText("Shadow Ball", "暗影球"), _pokeluaText("Future Sight", "预知未来"), _pokeluaText("Rock Smash", "碎岩"), _pokeluaText("Whirlpool", "潮旋"), _pokeluaText("Beat Up", "围攻"),
 -- Gen 3
 _pokeluaText("Fake Out", "击掌奇袭"), _pokeluaText("Uproar", "吵闹"), _pokeluaText("Stockpile", "蓄力"), _pokeluaText("Spit Up", "喷出"), _pokeluaText("Swallow", "吞下"), _pokeluaText("Heat Wave", "热风"), _pokeluaText("Hail", "冰雹"), _pokeluaText("Torment", "无理取闹"), _pokeluaText("Flatter", "吹捧"), _pokeluaText("Will-O-Wisp", "鬼火"),
 _pokeluaText("Memento", "临别礼物"), _pokeluaText("Facade", "硬撑"), _pokeluaText("Focus Punch", "真气拳"), _pokeluaText("Smelling Salts", "清醒"), _pokeluaText("Follow Me", "看我嘛"), _pokeluaText("Nature Power", "自然之力"), _pokeluaText("Charge", "充电"), _pokeluaText("Taunt", "挑衅"), _pokeluaText("Helping Hand", "帮助"),
 _pokeluaText("Trick", "戏法"), _pokeluaText("Role Play", "扮演"), _pokeluaText("Wish", "祈愿"), _pokeluaText("Assist", "借助"), _pokeluaText("Ingrain", "扎根"), _pokeluaText("Superpower", "蛮力"), _pokeluaText("Magic Coat", "魔法反射"), _pokeluaText("Recycle", "回收利用"), _pokeluaText("Revenge", "报复"), _pokeluaText("Brick Break", "劈瓦"),
 _pokeluaText("Yawn", "哈欠"), _pokeluaText("Knock Off", "拍落"), _pokeluaText("Endeavor", "蛮干"), _pokeluaText("Eruption", "喷火"), _pokeluaText("Skill Swap", "特性互换"), _pokeluaText("Imprison", "封印"), _pokeluaText("Refresh", "焕然一新"), _pokeluaText("Grudge", "怨念"), _pokeluaText("Snatch", "抢夺"), _pokeluaText("Secret Power", "秘密之力"),
 _pokeluaText("Dive", "潜水"), _pokeluaText("Arm Thrust", "猛推"), _pokeluaText("Camouflage", "保护色"), _pokeluaText("Tail Glow", "萤火"), _pokeluaText("Luster Purge", "洁净光芒"), _pokeluaText("Mist Ball", "薄雾球"), _pokeluaText("Feather Dance", "羽毛舞"), _pokeluaText("Teeter Dance", "摇晃舞"),
 _pokeluaText("Blaze Kick", "火焰踢"), _pokeluaText("Mud Sport", "玩泥巴"), _pokeluaText("Ice Ball", "冰球"), _pokeluaText("Needle Arm", "尖刺臂"), _pokeluaText("Slack Off", "偷懒"), _pokeluaText("Hyper Voice", "巨声"), _pokeluaText("Poison Fang", "剧毒牙"), _pokeluaText("Crush Claw", "撕裂爪"),
 _pokeluaText("Blast Burn", "爆炸烈焰"), _pokeluaText("Hydro Cannon", "加农水炮"), _pokeluaText("Meteor Mash", "彗星拳"), _pokeluaText("Astonish", "惊吓"), _pokeluaText("Weather Ball", "气象球"), _pokeluaText("Aromatherapy", "芳香治疗"), _pokeluaText("Fake Tears", "假哭"), _pokeluaText("Air Cutter", "空气利刃"),
 _pokeluaText("Overheat", "过热"), _pokeluaText("Odor Sleuth", "气味侦测"), _pokeluaText("Rock Tomb", "岩石封锁"), _pokeluaText("Silver Wind", "银色旋风"), _pokeluaText("Metal Sound", "金属音"), _pokeluaText("Grass Whistle", "草笛"), _pokeluaText("Tickle", "挠痒"), _pokeluaText("Cosmic Power", "宇宙力量"),
 _pokeluaText("Water Spout", "喷水"), _pokeluaText("Signal Beam", "信号光束"), _pokeluaText("Shadow Punch", "暗影拳"), _pokeluaText("Extrasensory", "神通力"), _pokeluaText("Sky Uppercut", "冲天拳"), _pokeluaText("Sand Tomb", "流沙地狱"), _pokeluaText("Sheer Cold", "绝对零度"), _pokeluaText("Muddy Water", "浊流"),
 _pokeluaText("Bullet Seed", "种子机关枪"), _pokeluaText("Aerial Ace", "燕返"), _pokeluaText("Icicle Spear", "冰锥"), _pokeluaText("Iron Defense", "铁壁"), _pokeluaText("Block", "挡路"), _pokeluaText("Howl", "长嚎"), _pokeluaText("Dragon Claw", "龙爪"), _pokeluaText("Frenzy Plant", "疯狂植物"), _pokeluaText("Bulk Up", "健美"),
 _pokeluaText("Bounce", "弹跳"), _pokeluaText("Mud Shot", "泥巴射击"), _pokeluaText("Poison Tail", "毒尾"), _pokeluaText("Covet", "渴望"), _pokeluaText("Volt Tackle", "伏特攻击"), _pokeluaText("Magical Leaf", "魔法叶"), _pokeluaText("Water Sport", "玩水"), _pokeluaText("Calm Mind", "冥想"), _pokeluaText("Leaf Blade", "叶刃"),
 _pokeluaText("Dragon Dance", "龙之舞"), _pokeluaText("Rock Blast", "岩石爆击"), _pokeluaText("Shock Wave", "电击波"), _pokeluaText("Water Pulse", "水之波动"), _pokeluaText("Doom Desire", "破灭之愿"), _pokeluaText("Psycho Boost", "精神突进"),
 -- Gen 4
 _pokeluaText("Roost", "羽栖"), _pokeluaText("Gravity", "重力"), _pokeluaText("Miracle Eye", "奇迹之眼"), _pokeluaText("Wake-Up Slap", "唤醒巴掌"), _pokeluaText("Hammer Arm", "臂锤"), _pokeluaText("Gyro Ball", "陀螺球"), _pokeluaText("Healing Wish", "治愈之愿"), _pokeluaText("Brine", "盐水"), _pokeluaText("Natural Gift", "自然之恩"),
 _pokeluaText("Feint", "佯攻"), _pokeluaText("Pluck", "啄食"), _pokeluaText("Tailwind", "顺风"), _pokeluaText("Acupressure", "点穴"), _pokeluaText("Metal Burst", "金属爆炸"), _pokeluaText("U-turn", "急速折返"), _pokeluaText("Close Combat", "近身战"), _pokeluaText("Payback", "以牙还牙"), _pokeluaText("Assurance", "恶意追击"), _pokeluaText("Embargo", "查封"),
 _pokeluaText("Fling", "投掷"), _pokeluaText("Psycho Shift", "精神转移"), _pokeluaText("Trump Card", "王牌"), _pokeluaText("Heal Block", "回复封锁"), _pokeluaText("Wring Out", "绞紧"), _pokeluaText("Power Trick", "力量戏法"), _pokeluaText("Gastro Acid", "胃液"), _pokeluaText("Lucky Chant", "幸运咒语"), _pokeluaText("Me First", "抢先一步"),
 _pokeluaText("Copycat", "仿效"), _pokeluaText("Power Swap", "力量互换"), _pokeluaText("Guard Swap", "防守互换"), _pokeluaText("Punishment", "惩罚"), _pokeluaText("Last Resort", "珍藏"), _pokeluaText("Worry Seed", "烦恼种子"), _pokeluaText("Sucker Punch", "突袭"), _pokeluaText("Toxic Spikes", "毒菱"),
 _pokeluaText("Heart Swap", "心灵互换"), _pokeluaText("Aqua Ring", "水流环"), _pokeluaText("Magnet Rise", "电磁飘浮"), _pokeluaText("Flare Blitz", "闪焰冲锋"), _pokeluaText("Force Palm", "发劲"), _pokeluaText("Aura Sphere", "波导弹"), _pokeluaText("Rock Polish", "岩石打磨"), _pokeluaText("Poison Jab", "毒击"),
 _pokeluaText("Dark Pulse", "恶之波动"), _pokeluaText("Night Slash", "暗袭要害"), _pokeluaText("Aqua Tail", "水流尾"), _pokeluaText("Seed Bomb", "种子炸弹"), _pokeluaText("Air Slash", "空气斩"), _pokeluaText("X-Scissor", "十字剪"), _pokeluaText("Bug Buzz", "虫鸣"), _pokeluaText("Dragon Pulse", "龙之波动"), _pokeluaText("Dragon Rush", "龙之俯冲"),
 _pokeluaText("Power Gem", "力量宝石"), _pokeluaText("Drain Punch", "吸取拳"), _pokeluaText("Vacuum Wave", "真空波"), _pokeluaText("Focus Blast", "真气弹"), _pokeluaText("Energy Ball", "能量球"), _pokeluaText("Brave Bird", "勇鸟猛攻"), _pokeluaText("Earth Power", "大地之力"), _pokeluaText("Switcheroo", "掉包"),
 _pokeluaText("Giga Impact", "终极冲击"), _pokeluaText("Nasty Plot", "诡计"), _pokeluaText("Bullet Punch", "子弹拳"), _pokeluaText("Avalanche", "雪崩"), _pokeluaText("Ice Shard", "冰砾"), _pokeluaText("Shadow Claw", "暗影爪"), _pokeluaText("Thunder Fang", "雷电牙"), _pokeluaText("Ice Fang", "冰冻牙"),
 _pokeluaText("Fire Fang", "火焰牙"), _pokeluaText("Shadow Sneak", "影子偷袭"), _pokeluaText("Mud Bomb", "泥巴炸弹"), _pokeluaText("Psycho Cut", "精神利刃"), _pokeluaText("Zen Headbutt", "意念头锤"), _pokeluaText("Mirror Shot", "镜光射击"), _pokeluaText("Flash Cannon", "加农光炮"), _pokeluaText("Rock Climb", "攀岩"),
 _pokeluaText("Defog", "清除浓雾"), _pokeluaText("Trick Room", "戏法空间"), _pokeluaText("Draco Meteor", "流星群"), _pokeluaText("Discharge", "放电"), _pokeluaText("Lava Plume", "喷烟"), _pokeluaText("Leaf Storm", "飞叶风暴"), _pokeluaText("Power Whip", "强力鞭打"), _pokeluaText("Rock Wrecker", "岩石炮"),
 _pokeluaText("Cross Poison", "十字毒刃"), _pokeluaText("Gunk Shot", "垃圾射击"), _pokeluaText("Iron Head", "铁头"), _pokeluaText("Magnet Bomb", "磁铁炸弹"), _pokeluaText("Stone Edge", "尖石攻击"), _pokeluaText("Captivate", "诱惑"), _pokeluaText("Stealth Rock", "隐形岩"), _pokeluaText("Grass Knot", "打草结"), _pokeluaText("Chatter", "喋喋不休"),
 _pokeluaText("Judgment", "制裁光砾"), _pokeluaText("Bug Bite", "虫咬"), _pokeluaText("Charge Beam", "充电光束"), _pokeluaText("Wood Hammer", "木槌"), _pokeluaText("Aqua Jet", "水流喷射"), _pokeluaText("Attack Order", "攻击指令"), _pokeluaText("Defend Order", "防御指令"), _pokeluaText("Heal Order", "回复指令"), _pokeluaText("Head Smash", "双刃头锤"),
 _pokeluaText("Double Hit", "二连击"), _pokeluaText("Roar of Time", "时光咆哮"), _pokeluaText("Spacial Rend", "亚空裂斩"), _pokeluaText("Lunar Dance", "新月舞"), _pokeluaText("Crush Grip", "捏碎"), _pokeluaText("Magma Storm", "熔岩风暴"), _pokeluaText("Dark Void", "暗黑洞"), _pokeluaText("Seed Flare", "种子闪光"),
 _pokeluaText("Ominous Wind", "奇异之风"), _pokeluaText("Shadow Force", "暗影潜袭")}

local itemNamesList = {
 _pokeluaText("None", "无"), _pokeluaText("Master Ball", "大师球"), _pokeluaText("Ultra Ball", "高级球"), _pokeluaText("Great Ball", "超级球"), _pokeluaText("Poké Ball", "精灵球"), _pokeluaText("Safari Ball", "狩猎球"), _pokeluaText("Net Ball", "捕网球"), _pokeluaText("Dive Ball", "潜水球"),
 _pokeluaText("Nest Ball", "巢穴球"), _pokeluaText("Repeat Ball", "重复球"), _pokeluaText("Timer Ball", "计时球"), _pokeluaText("Luxury Ball", "豪华球"), _pokeluaText("Premier Ball", "纪念球"), _pokeluaText("Dusk Ball", "黑暗球"), _pokeluaText("Heal Ball", "治愈球"),
 _pokeluaText("Quick Ball", "先机球"), _pokeluaText("Cherish Ball", "贵重球"), _pokeluaText("Potion", "伤药"), _pokeluaText("Antidote", "解毒药"), _pokeluaText("Burn Heal", "灼伤药"), _pokeluaText("Ice Heal", "解冻药"), _pokeluaText("Awakening", "解眠药"), _pokeluaText("Parlyz Heal", "解麻药"),
 _pokeluaText("Full Restore", "全复药"), _pokeluaText("Max Potion", "全满药"), _pokeluaText("Hyper Potion", "厉害伤药"), _pokeluaText("Super Potion", "好伤药"), _pokeluaText("Full Heal", "万灵药"), _pokeluaText("Revive", "活力碎片"), _pokeluaText("Max Revive", "活力块"),
 _pokeluaText("Fresh Water", "美味之水"), _pokeluaText("Soda Pop", "劲爽汽水"), _pokeluaText("Lemonade", "果汁牛奶"), _pokeluaText("Moomoo Milk", "哞哞鲜奶"), _pokeluaText("EnergyPowder", "元气粉"), _pokeluaText("Energy Root", "元气根"), _pokeluaText("Heal Powder", "万能粉"),
 _pokeluaText("Revival Herb", "复活草"), _pokeluaText("Ether", "ＰＰ单项小补剂"), _pokeluaText("Max Ether", "ＰＰ单项全补剂"), _pokeluaText("Elixir", "ＰＰ多项小补剂"), _pokeluaText("Max Elixir", "ＰＰ多项全补剂"), _pokeluaText("Lava Cookie", "釜炎仙贝"), _pokeluaText("Berry Juice", "树果汁"),
 _pokeluaText("Sacred Ash", "圣灰"), _pokeluaText("HP Up", "ＨＰ增强剂"), _pokeluaText("Protein", "攻击增强剂"), _pokeluaText("Iron", "防御增强剂"), _pokeluaText("Carbos", "速度增强剂"), _pokeluaText("Calcium", "特攻增强剂"), _pokeluaText("Rare Candy", "神奇糖果"), _pokeluaText("PP Up", "ＰＰ提升剂"), _pokeluaText("Zinc", "特防增强剂"),
 _pokeluaText("PP Max", "ＰＰ极限提升剂"), _pokeluaText("Old Gateau", "森之羊羹"), _pokeluaText("Guard Spec.", "能力防守"), _pokeluaText("Dire Hit", "要害攻击"), _pokeluaText("X Attack", "力量强化"), _pokeluaText("X Defend", "防御强化"), _pokeluaText("X Speed", "速度强化"), _pokeluaText("X Accuracy", "命中强化"),
 _pokeluaText("X Special", "特攻强化"), _pokeluaText("X Sp. Def", "特防强化"), _pokeluaText("Poké Doll", "皮皮玩偶"), _pokeluaText("Fluffy Tail", "向尾喵的尾巴"), _pokeluaText("Blue Flute", "蓝色玻璃哨"), _pokeluaText("Yellow Flute", "黄色玻璃哨"), _pokeluaText("Red Flute", "红色玻璃哨"),
 _pokeluaText("Black Flute", "黑色玻璃哨"), _pokeluaText("White Flute", "白色玻璃哨"), _pokeluaText("Shoal Salt", "浅滩海盐"), _pokeluaText("Shoal Shell", "浅滩贝壳"), _pokeluaText("Red Shard", "红色碎片"), _pokeluaText("Blue Shard", "蓝色碎片"), _pokeluaText("Yellow Shard", "黄色碎片"),
 _pokeluaText("Green Shard", "绿色碎片"), _pokeluaText("Super Repel", "白银喷雾"), _pokeluaText("Max Repel", "黄金喷雾"), _pokeluaText("Escape Rope", "离洞绳"), _pokeluaText("Repel", "除虫喷雾"), _pokeluaText("Sun Stone", "日之石"), _pokeluaText("Moon Stone", "月之石"),
 _pokeluaText("Fire Stone", "火之石"), _pokeluaText("Thunderstone", "雷之石"), _pokeluaText("Water Stone", "水之石"), _pokeluaText("Leaf Stone", "叶之石"), _pokeluaText("TinyMushroom", "小蘑菇"), _pokeluaText("Big Mushroom", "大蘑菇"), _pokeluaText("Pearl", "珍珠"),
 _pokeluaText("Big Pearl", "大珍珠"), _pokeluaText("Stardust", "星星沙子"), _pokeluaText("Star Piece", "星星碎片"), _pokeluaText("Nugget", "金珠"), _pokeluaText("Heart Scale", "心之鳞片"), _pokeluaText("Honey", "甜甜蜜"), _pokeluaText("Growth Mulch", "速速肥"),
 _pokeluaText("Damp Mulch", "湿湿肥"), _pokeluaText("Stable Mulch", "久久肥"), _pokeluaText("Gooey Mulch", "粘粘肥"), _pokeluaText("Root Fossil", "根状化石"), _pokeluaText("Claw Fossil", "爪子化石"), _pokeluaText("Helix Fossil", "贝壳化石"), _pokeluaText("Dome Fossil", "甲壳化石"),
 _pokeluaText("Old Amber", "秘密琥珀"), _pokeluaText("Armor Fossil", "盾甲化石"), _pokeluaText("Skull Fossil", "头盖化石"), _pokeluaText("Rare Bone", "贵重骨头"), _pokeluaText("Shiny Stone", "光之石"), _pokeluaText("Dusk Stone", "暗之石"), _pokeluaText("Dawn Stone", "觉醒之石"),
 _pokeluaText("Oval Stone", "浑圆之石"), _pokeluaText("Odd Keystone", "楔石"), _pokeluaText("Griseous Orb", "白金宝珠"), _pokeluaText("unknown1", "未知1"), _pokeluaText("unknown2", "未知2"), _pokeluaText("unknown3", "未知3"), _pokeluaText("unknown4", "未知4"), _pokeluaText("unknown5", "未知5"),
 _pokeluaText("unknown6", "未知6"), _pokeluaText("unknown7", "未知7"), _pokeluaText("unknown8", "未知8"), _pokeluaText("unknown9", "未知9"), _pokeluaText("unknown10", "未知10"), _pokeluaText("unknown11", "未知11"), _pokeluaText("unknown12", "未知12"), _pokeluaText("unknown13", "未知13"),
 _pokeluaText("unknown14", "未知14"), _pokeluaText("unknown15", "未知15"), _pokeluaText("unknown16", "未知16"), _pokeluaText("unknown17", "未知17"), _pokeluaText("unknown18", "未知18"), _pokeluaText("unknown19", "未知19"), _pokeluaText("unknown20", "未知20"), _pokeluaText("unknown21", "未知21"),
 _pokeluaText("unknown22", "未知22"), _pokeluaText("Adamant Orb", "金刚宝珠"), _pokeluaText("Lustrous Orb", "白玉宝珠"), _pokeluaText("Grass Mail", "青草邮件"), _pokeluaText("Flame Mail", "火焰邮件"), _pokeluaText("Bubble Mail", "水蓝邮件"), _pokeluaText("Bloom Mail", "绽放邮件"),
 _pokeluaText("Tunnel Mail", "隧道邮件"), _pokeluaText("Steel Mail", "钢铁邮件"), _pokeluaText("Heart Mail", "甜蜜邮件"), _pokeluaText("Snow Mail", "暴雪邮件"), _pokeluaText("Space Mail", "空间邮件"), _pokeluaText("Air Mail", "天空邮件"), _pokeluaText("Mosaic Mail", "彩嵌邮件"), _pokeluaText("Brick Mail", "砖块邮件"),
 _pokeluaText("Cheri Berry", "樱子果"), _pokeluaText("Chesto Berry", "零余果"), _pokeluaText("Pecha Berry", "桃桃果"), _pokeluaText("Rawst Berry", "莓莓果"), _pokeluaText("Aspear Berry", "利木果"), _pokeluaText("Leppa Berry", "苹野果"), _pokeluaText("Oran Berry", "橙橙果"),
 _pokeluaText("Persim Berry", "柿仔果"), _pokeluaText("Lum Berry", "木子果"), _pokeluaText("Sitrus Berry", "文柚果"), _pokeluaText("Figy Berry", "勿花果"), _pokeluaText("Wiki Berry", "异奇果"), _pokeluaText("Mago Berry", "芒芒果"), _pokeluaText("Aguav Berry", "乐芭果"),
 _pokeluaText("Iapapa Berry", "芭亚果"), _pokeluaText("Razz Berry", "蔓莓果"), _pokeluaText("Bluk Berry", "墨莓果"), _pokeluaText("Nanab Berry", "蕉香果"), _pokeluaText("Wepear Berry", "西梨果"), _pokeluaText("Pinap Berry", "凰梨果"), _pokeluaText("Pomeg Berry", "榴石果"),
 _pokeluaText("Kelpsy Berry", "藻根果"), _pokeluaText("Qualot Berry", "比巴果"), _pokeluaText("Hondew Berry", "哈密果"), _pokeluaText("Grepa Berry", "萄葡果"), _pokeluaText("Tamato Berry", "茄番果"), _pokeluaText("Cornn Berry", "玉黍果"), _pokeluaText("Magost Berry", "岳竹果"),
 _pokeluaText("Rabuta Berry", "茸丹果"), _pokeluaText("Nomel Berry", "檬柠果"), _pokeluaText("Spelon Berry", "刺角果"), _pokeluaText("Pamtre Berry", "椰木果"), _pokeluaText("Watmel Berry", "瓜西果"), _pokeluaText("Durin Berry", "金枕果"),
 _pokeluaText("Belue Berry", "靛莓果"), _pokeluaText("Occa Berry", "巧可果"), _pokeluaText("Passho Berry", "千香果"), _pokeluaText("Wacan Berry", "烛木果"), _pokeluaText("Rindo Berry", "罗子果"), _pokeluaText("Yache Berry", "番荔果"),
 _pokeluaText("Chople Berry", "莲蒲果"), _pokeluaText("Kebia Berry", "通通果"), _pokeluaText("Shuca Berry", "腰木果"), _pokeluaText("Coba Berry", "棱瓜果"), _pokeluaText("Payapa Berry", "福禄果"), _pokeluaText("Tanga Berry", "扁樱果"),
 _pokeluaText("Charti Berry", "草蚕果"), _pokeluaText("Kasib Berry", "佛柑果"), _pokeluaText("Haban Berry", "莓榴果"), _pokeluaText("Colbur Berry", "刺耳果"), _pokeluaText("Babiri Berry", "霹霹果"), _pokeluaText("Chilan Berry", "灯浆果"), _pokeluaText("Liechi Berry", "枝荔果"),
 _pokeluaText("Ganlon Berry", "龙睛果"), _pokeluaText("Salac Berry", "沙鳞果"), _pokeluaText("Petaya Berry", "龙火果"), _pokeluaText("Apicot Berry", "杏仔果"), _pokeluaText("Lansat Berry", "兰萨果"), _pokeluaText("Starf Berry", "星桃果"),
 _pokeluaText("Enigma Berry", "谜芝果"), _pokeluaText("Micle Berry", "奇秘果"), _pokeluaText("Custap Berry", "释陀果"), _pokeluaText("Jaboca Berry", "嘉珍果"), _pokeluaText("Rowap Berry", "雾莲果"), _pokeluaText("BrightPowder", "光粉"),
 _pokeluaText("White Herb", "白色香草"), _pokeluaText("Macho Brace", "强制锻炼器"), _pokeluaText("Exp. Share", "学习装置"), _pokeluaText("Quick Claw", "先制之爪"), _pokeluaText("Soothe Bell", "安抚之铃"), _pokeluaText("Mental Herb", "心灵香草"), _pokeluaText("Choice Band", "讲究头带"),
 _pokeluaText("King's Rock", "王者之证"), _pokeluaText("SilverPowder", "银粉"), _pokeluaText("Amulet Coin", "护符金币"), _pokeluaText("Cleanse Tag", "洁净之符"), _pokeluaText("Soul Dew", "心之水滴"), _pokeluaText("DeepSeaTooth", "深海之牙"),
 _pokeluaText("DeepSeaScale", "深海鳞片"), _pokeluaText("Smoke Ball", "烟雾球"), _pokeluaText("Everstone", "不变之石"), _pokeluaText("Focus Band", "气势头带"), _pokeluaText("Lucky Egg", "幸运蛋"), _pokeluaText("Scope Lens", "焦点镜"), _pokeluaText("Metal Coat", "金属膜"),
 _pokeluaText("Leftovers", "吃剩的东西"), _pokeluaText("Dragon Scale", "龙之鳞片"), _pokeluaText("Light Ball", "电气球"), _pokeluaText("Soft Sand", "柔软沙子"), _pokeluaText("Hard Stone", "硬石头"), _pokeluaText("Miracle Seed", "奇迹种子"), _pokeluaText("BlackGlasses", "黑色眼镜"),
 _pokeluaText("Black Belt", "黑带"), _pokeluaText("Magnet", "磁铁"), _pokeluaText("Mystic Water", "神秘水滴"), _pokeluaText("Sharp Beak", "锐利鸟嘴"), _pokeluaText("Poison Barb", "毒针"), _pokeluaText("NeverMeltIce", "不融冰"), _pokeluaText("Spell Tag", "诅咒之符"),
 _pokeluaText("TwistedSpoon", "弯曲的汤匙"), _pokeluaText("Charcoal", "木炭"), _pokeluaText("Dragon Fang", "龙之牙"), _pokeluaText("Silk Scarf", "丝绸围巾"), _pokeluaText("Up-Grade", "升级数据"), _pokeluaText("Shell Bell", "贝壳之铃"), _pokeluaText("Sea Incense", "海潮薰香"),
 _pokeluaText("Lax Incense", "悠闲薰香"), _pokeluaText("Lucky Punch", "吉利拳"), _pokeluaText("Metal Powder", "金属粉"), _pokeluaText("Thick Club", "粗骨头"), _pokeluaText("Stick", "大葱"), _pokeluaText("Red Scarf", "红色头巾"), _pokeluaText("Blue Scarf", "蓝色头巾"),
 _pokeluaText("Pink Scarf", "粉红头巾"), _pokeluaText("Green Scarf", "绿色头巾"), _pokeluaText("Yellow Scarf", "黄色头巾"), _pokeluaText("Wide Lens", "广角镜"), _pokeluaText("Muscle Band", "力量头带"), _pokeluaText("Wise Glasses", "博识眼镜"), _pokeluaText("Expert Belt", "达人带"),
 _pokeluaText("Light Clay", "光之黏土"), _pokeluaText("Life Orb", "生命宝珠"), _pokeluaText("Power Herb", "强力香草"), _pokeluaText("Toxic Orb", "剧毒宝珠"), _pokeluaText("Flame Orb", "火焰宝珠"), _pokeluaText("Quick Powder", "速度粉"), _pokeluaText("Focus Sash", "气势披带"),
 _pokeluaText("Zoom Lens", "对焦镜"), _pokeluaText("Metronome", "节拍器"), _pokeluaText("Iron Ball", "黑色铁球"), _pokeluaText("Lagging Tail", "后攻之尾"), _pokeluaText("Destiny Knot", "红线"), _pokeluaText("Black Sludge", "黑色污泥"), _pokeluaText("Icy Rock", "冰冷岩石"),
 _pokeluaText("Smooth Rock", "沙沙岩石"), _pokeluaText("Heat Rock", "炽热岩石"), _pokeluaText("Damp Rock", "潮湿岩石"), _pokeluaText("Grip Claw", "紧缠钩爪"), _pokeluaText("Choice Scarf", "讲究围巾"), _pokeluaText("Sticky Barb", "附着针"), _pokeluaText("Power Bracer", "力量护腕"),
 _pokeluaText("Power Belt", "力量腰带"), _pokeluaText("Power Lens", "力量镜"), _pokeluaText("Power Band", "力量束带"), _pokeluaText("Power Anklet", "力量护踝"), _pokeluaText("Power Weight", "力量负重"), _pokeluaText("Shed Shell", "美丽空壳"),
 _pokeluaText("Big Root", "大根茎"), _pokeluaText("Choice Specs", "讲究眼镜"), _pokeluaText("Flame Plate", "火球石板"), _pokeluaText("Splash Plate", "水滴石板"), _pokeluaText("Zap Plate", "雷电石板"), _pokeluaText("Meadow Plate", "碧绿石板"), _pokeluaText("Icicle Plate", "冰柱石板"),
 _pokeluaText("Fist Plate", "拳头石板"), _pokeluaText("Toxic Plate", "剧毒石板"), _pokeluaText("Earth Plate", "大地石板"), _pokeluaText("Sky Plate", "蓝天石板"), _pokeluaText("Mind Plate", "神奇石板"), _pokeluaText("Insect Plate", "玉虫石板"),
 _pokeluaText("Stone Plate", "岩石石板"), _pokeluaText("Spooky Plate", "妖怪石板"), _pokeluaText("Draco Plate", "龙之石板"), _pokeluaText("Dread Plate", "恶颜石板"), _pokeluaText("Iron Plate", "钢铁石板"), _pokeluaText("Odd Incense", "奇异薰香"),
 _pokeluaText("Rock Incense", "岩石薰香"), _pokeluaText("Full Incense", "饱腹薰香"), _pokeluaText("Wave Incense", "涟漪薰香"), _pokeluaText("Rose Incense", "花朵薰香"), _pokeluaText("Luck Incense", "幸运薰香"), _pokeluaText("Pure Incense", "洁净薰香"),
 _pokeluaText("Protector", "护具"), _pokeluaText("Electirizer", "电力增幅器"), _pokeluaText("Magmarizer", "熔岩增幅器"), _pokeluaText("Dubious Disc", "可疑补丁"), _pokeluaText("Reaper Cloth", "灵界之布"), _pokeluaText("Razor Claw", "锐利之爪"), _pokeluaText("Razor Fang", "锐利之牙"),
 _pokeluaText("TM01", "招式学习器０１"), _pokeluaText("TM02", "招式学习器０２"), _pokeluaText("TM03", "招式学习器０３"), _pokeluaText("TM04", "招式学习器０４"), _pokeluaText("TM05", "招式学习器０５"), _pokeluaText("TM06", "招式学习器０６"), _pokeluaText("TM07", "招式学习器０７"), _pokeluaText("TM08", "招式学习器０８"), _pokeluaText("TM09", "招式学习器０９"), _pokeluaText("TM10", "招式学习器１０"), _pokeluaText("TM11", "招式学习器１１"), _pokeluaText("TM12", "招式学习器１２"),
 _pokeluaText("TM13", "招式学习器１３"), _pokeluaText("TM14", "招式学习器１４"), _pokeluaText("TM15", "招式学习器１５"), _pokeluaText("TM16", "招式学习器１６"), _pokeluaText("TM17", "招式学习器１７"), _pokeluaText("TM18", "招式学习器１８"), _pokeluaText("TM19", "招式学习器１９"), _pokeluaText("TM20", "招式学习器２０"), _pokeluaText("TM21", "招式学习器２１"), _pokeluaText("TM22", "招式学习器２２"), _pokeluaText("TM23", "招式学习器２３"), _pokeluaText("TM24", "招式学习器２４"),
 _pokeluaText("TM25", "招式学习器２５"), _pokeluaText("TM26", "招式学习器２６"), _pokeluaText("TM27", "招式学习器２７"), _pokeluaText("TM28", "招式学习器２８"), _pokeluaText("TM29", "招式学习器２９"), _pokeluaText("TM30", "招式学习器３０"), _pokeluaText("TM31", "招式学习器３１"), _pokeluaText("TM32", "招式学习器３２"), _pokeluaText("TM33", "招式学习器３３"), _pokeluaText("TM34", "招式学习器３４"), _pokeluaText("TM35", "招式学习器３５"), _pokeluaText("TM36", "招式学习器３６"),
 _pokeluaText("TM37", "招式学习器３７"), _pokeluaText("TM38", "招式学习器３８"), _pokeluaText("TM39", "招式学习器３９"), _pokeluaText("TM40", "招式学习器４０"), _pokeluaText("TM41", "招式学习器４１"), _pokeluaText("TM42", "招式学习器４２"), _pokeluaText("TM43", "招式学习器４３"), _pokeluaText("TM44", "招式学习器４４"), _pokeluaText("TM45", "招式学习器４５"), _pokeluaText("TM46", "招式学习器４６"), _pokeluaText("TM47", "招式学习器４７"), _pokeluaText("TM48", "招式学习器４８"),
 _pokeluaText("TM49", "招式学习器４９"), _pokeluaText("TM50", "招式学习器５０"), _pokeluaText("TM51", "招式学习器５１"), _pokeluaText("TM52", "招式学习器５２"), _pokeluaText("TM53", "招式学习器５３"), _pokeluaText("TM54", "招式学习器５４"), _pokeluaText("TM55", "招式学习器５５"), _pokeluaText("TM56", "招式学习器５６"), _pokeluaText("TM57", "招式学习器５７"), _pokeluaText("TM58", "招式学习器５８"), _pokeluaText("TM59", "招式学习器５９"), _pokeluaText("TM60", "招式学习器６０"),
 _pokeluaText("TM61", "招式学习器６１"), _pokeluaText("TM62", "招式学习器６２"), _pokeluaText("TM63", "招式学习器６３"), _pokeluaText("TM64", "招式学习器６４"), _pokeluaText("TM65", "招式学习器６５"), _pokeluaText("TM66", "招式学习器６６"), _pokeluaText("TM67", "招式学习器６７"), _pokeluaText("TM68", "招式学习器６８"), _pokeluaText("TM69", "招式学习器６９"), _pokeluaText("TM70", "招式学习器７０"), _pokeluaText("TM71", "招式学习器７１"), _pokeluaText("TM72", "招式学习器７２"),
 _pokeluaText("TM73", "招式学习器７３"), _pokeluaText("TM74", "招式学习器７４"), _pokeluaText("TM75", "招式学习器７５"), _pokeluaText("TM76", "招式学习器７６"), _pokeluaText("TM77", "招式学习器７７"), _pokeluaText("TM78", "招式学习器７８"), _pokeluaText("TM79", "招式学习器７９"), _pokeluaText("TM80", "招式学习器８０"), _pokeluaText("TM81", "招式学习器８１"), _pokeluaText("TM82", "招式学习器８２"), _pokeluaText("TM83", "招式学习器８３"), _pokeluaText("TM84", "招式学习器８４"),
 _pokeluaText("TM85", "招式学习器８５"), _pokeluaText("TM86", "招式学习器８６"), _pokeluaText("TM87", "招式学习器８７"), _pokeluaText("TM88", "招式学习器８８"), _pokeluaText("TM89", "招式学习器８９"), _pokeluaText("TM90", "招式学习器９０"), _pokeluaText("TM91", "招式学习器９１"), _pokeluaText("TM92", "招式学习器９２"), _pokeluaText("HM01", "秘传学习器０１"), _pokeluaText("HM02", "秘传学习器０２"), _pokeluaText("HM03", "秘传学习器０３"), _pokeluaText("HM04", "秘传学习器０４"),
 _pokeluaText("HM05", "秘传学习器０５"), _pokeluaText("HM06", "秘传学习器０６"), _pokeluaText("HM07", "秘传学习器０７"), _pokeluaText("HM08", "秘传学习器08"), _pokeluaText("Explorer Kit", "探险套装"), _pokeluaText("Loot Sack", "宝物袋"), _pokeluaText("Rule Book", "规则书"), _pokeluaText("Poké Radar", "宝可追踪"), _pokeluaText("Point Card", "点数卡"),
 _pokeluaText("Journal", "冒险笔记"), _pokeluaText("Seal Case", "贴纸盒"), _pokeluaText("Fashion Case", "饰品盒"), _pokeluaText("Seal Bag", "贴纸袋"), _pokeluaText("Pal Pad", "朋友手册"), _pokeluaText("Works Key", "发电厂钥匙"), _pokeluaText("Old Charm", "古代护符"),
 _pokeluaText("Galactic Key", "银河队钥匙"), _pokeluaText("Red Chain", "红色锁链"), _pokeluaText("Town Map", "城镇地图"), _pokeluaText("Vs. Seeker", "对战搜寻器"), _pokeluaText("Coin Case", "代币盒"), _pokeluaText("Old Rod", "破旧钓竿"), _pokeluaText("Good Rod", "好钓竿"), _pokeluaText("Super Rod", "厉害钓竿"),
 _pokeluaText("Sprayduck", "可达鸭喷壶"), _pokeluaText("Poffin Case", "宝芬盒"), _pokeluaText("Bicycle", "自行车"), _pokeluaText("Suite Key", "房间钥匙"), _pokeluaText("Oak's Letter", "大木的信"), _pokeluaText("Lunar Wing", "新月之羽"), _pokeluaText("Member Card", "会员卡"),
 _pokeluaText("Azure Flute", "天界之笛"), _pokeluaText("S.S. Ticket", "船票"), _pokeluaText("Contest Pass", "华丽大赛参加证"), _pokeluaText("Magma Stone", "火山镇石"), _pokeluaText("Parcel", "包裹"), _pokeluaText("Coupon 1", "兑换券１"), _pokeluaText("Coupon 2", "兑换券２"),
 _pokeluaText("Coupon 3", "兑换券３"), _pokeluaText("Storage Key", "仓库钥匙"), _pokeluaText("SecretPotion", "秘传之药"), _pokeluaText("Vs. Recorder", "对战记录器"), _pokeluaText("Gracidea", "葛拉西蒂亚花"), _pokeluaText("Secret Key", "秘密钥匙"),
 _pokeluaText("Apricorn Box", "球果盒"), _pokeluaText("Unown Report", "未知图腾笔记"), _pokeluaText("Berry Pots", "树果种植盆"), _pokeluaText("Dowsing MCHN", "探宝器"), _pokeluaText("Blue Card", "蓝卡"), _pokeluaText("Slowpoke Tail", "美味尾巴"),
 _pokeluaText("Clear Bell", "透明铃铛"), _pokeluaText("Card Key", "钥匙卡"), _pokeluaText("Basement Key", "地下钥匙"), _pokeluaText("SquirtBottle", "杰尼龟喷壶"), _pokeluaText("Red Scale", "红色鳞片"), _pokeluaText("Lost Item", "遗失物"), _pokeluaText("Pass", "磁浮列车自由票"),
 _pokeluaText("Machine Part", "机械零件"), _pokeluaText("Silver Wing", "银色之羽"), _pokeluaText("Rainbow Wing", "虹色之羽"), _pokeluaText("Mystery Egg", "神奇蛋"), _pokeluaText("Red Apricorn", "红球果"), _pokeluaText("Yellow Apricorn", "黄球果"),
 _pokeluaText("Blue Apricorn", "蓝球果"), _pokeluaText("Green Apricorn", "绿球果"), _pokeluaText("Pink Apricorn", "粉球果"), _pokeluaText("White Apricorn", "白球果"), _pokeluaText("Black Apricorn", "黑球果"), _pokeluaText("Fast Ball", "速度球"),
 _pokeluaText("Level Ball", "等级球"), _pokeluaText("Lure Ball", "诱饵球"), _pokeluaText("Heavy Ball", "沉重球"), _pokeluaText("Love Ball", "甜蜜球"), _pokeluaText("Friend Ball", "友友球"), _pokeluaText("Moon Ball", "月亮球"),
 _pokeluaText("Sport Ball", "竞赛球"), _pokeluaText("Park Ball", "公园球"), _pokeluaText("Photo Album", "相册"), _pokeluaText("GB Sounds", "ＧＢ播放器"), _pokeluaText("Tidal Bell", "海声铃铛"), _pokeluaText("RageCandyBar", "愤怒馒头"), _pokeluaText("Data Card 01", "数据卡０１"),
 _pokeluaText("Data Card 02", "数据卡０２"), _pokeluaText("Data Card 03", "数据卡０３"), _pokeluaText("Data Card 04", "数据卡０４"), _pokeluaText("Data Card 05", "数据卡０５"), _pokeluaText("Data Card 06", "数据卡０６"), _pokeluaText("Data Card 07", "数据卡０７"),
 _pokeluaText("Data Card 08", "数据卡０８"), _pokeluaText("Data Card 09", "数据卡０９"), _pokeluaText("Data Card 10", "数据卡１０"), _pokeluaText("Data Card 11", "数据卡１１"), _pokeluaText("Data Card 12", "数据卡１２"), _pokeluaText("Data Card 13", "数据卡１３"),
 _pokeluaText("Data Card 14", "数据卡１４"), _pokeluaText("Data Card 15", "数据卡１５"), _pokeluaText("Data Card 16", "数据卡１６"), _pokeluaText("Data Card 17", "数据卡１７"), _pokeluaText("Data Card 18", "数据卡１８"), _pokeluaText("Data Card 19", "数据卡１９"),
 _pokeluaText("Data Card 20", "数据卡２０"), _pokeluaText("Data Card 21", "数据卡２１"), _pokeluaText("Data Card 22", "数据卡２２"), _pokeluaText("Data Card 23", "数据卡２３"), _pokeluaText("Data Card 24", "数据卡２４"), _pokeluaText("Data Card 25", "数据卡２５"),
 _pokeluaText("Data Card 26", "数据卡２６"), _pokeluaText("Data Card 27", "数据卡２７"), _pokeluaText("Jade Orb", "草绿色宝珠"), _pokeluaText("Lock Capsule", "上锁的容器"), _pokeluaText("Red Orb", "朱红色宝珠"), _pokeluaText("Blue Orb", "靛蓝色宝珠"), _pokeluaText("Enigma Stone", "谜之水晶")}

local locationNamesList = {
 _pokeluaText("Mystery Zone", "谜之地点"), _pokeluaText("Mystery Zone", "谜之地点"), _pokeluaText("Mystery Zone", "谜之地点"), _pokeluaText("Mystery Zone", "谜之地点"), _pokeluaText("Mystery Zone", "谜之地点"), _pokeluaText("Mystery Zone", "谜之地点"),
 _pokeluaText("Bellchime Trail", "铃音小道"), _pokeluaText("Burned Tower", "烧焦塔"), _pokeluaText("Ruins of Alph", "阿露福遗迹"), _pokeluaText("Route 1", "1号道路"), _pokeluaText("Route 2", "2号道路"), _pokeluaText("Route 3", "3号道路"), _pokeluaText("Route 4", "4号道路"),
 _pokeluaText("Route 5", "5号道路"), _pokeluaText("Route 6", "6号道路"), _pokeluaText("Route 7", "7号道路"), _pokeluaText("Route 8", "8号道路"), _pokeluaText("Route 9", "9号道路"), _pokeluaText("Route 10", "10号道路"), _pokeluaText("Route 11", "11号道路"), _pokeluaText("Route 12", "12号道路"),
 _pokeluaText("Route 13", "13号道路"), _pokeluaText("Route 14", "14号道路"), _pokeluaText("Route 15", "15号道路"), _pokeluaText("Route 16", "16号道路"), _pokeluaText("Route 17", "17号道路"), _pokeluaText("Route 18", "18号道路"), _pokeluaText("Route 22", "22号道路"), _pokeluaText("Route 24", "24号道路"),
 _pokeluaText("Route 25", "25号道路"), _pokeluaText("Route 26", "26号道路"), _pokeluaText("Route 27", "27号道路"), _pokeluaText("Route 28", "28号道路"), _pokeluaText("Route 29", "29号道路"), _pokeluaText("Route 30", "30号道路"), _pokeluaText("Route 31", "31号道路"), _pokeluaText("Route 32", "32号道路"),
 _pokeluaText("Route 33", "33号道路"), _pokeluaText("Route 34", "34号道路"), _pokeluaText("Route 35", "35号道路"), _pokeluaText("Route 36", "36号道路"), _pokeluaText("Route 37", "37号道路"), _pokeluaText("Route 38", "38号道路"), _pokeluaText("Route 39", "39号道路"), _pokeluaText("Route 42", "42号道路"),
 _pokeluaText("Route 43", "43号道路"), _pokeluaText("Route 44", "44号道路"), _pokeluaText("Route 45", "45号道路"), _pokeluaText("Route 46", "46号道路"), _pokeluaText("Pallet Town", "真新镇"), _pokeluaText("Viridian City", "常青市"), _pokeluaText("Pewter City", "深灰市"),
 _pokeluaText("Cerulean City", "华蓝市"), _pokeluaText("Lavender Town", "紫苑镇"), _pokeluaText("Vermilion City", "枯叶市"), _pokeluaText("Celadon City", "玉虹市"), _pokeluaText("Fuchsia City", "浅红市"),
 _pokeluaText("Cinnabar Island", "红莲镇"), _pokeluaText("Indigo Plateau", "石英高原"), _pokeluaText("Saffron City", "金黄市"), _pokeluaText("New Bark Town", "若叶镇"), _pokeluaText("New Bark Town", "若叶镇"),
 _pokeluaText("New Bark Town", "若叶镇"), _pokeluaText("New Bark Town", "若叶镇"), _pokeluaText("New Bark Town", "若叶镇"), _pokeluaText("New Bark Town", "若叶镇"), _pokeluaText("New Bark Town", "若叶镇"),
 _pokeluaText("Cherrygrove City", "吉花市"), _pokeluaText("Cherrygrove City", "吉花市"), _pokeluaText("Cherrygrove City", "吉花市"), _pokeluaText("Cherrygrove City", "吉花市"), _pokeluaText("Cherrygrove City", "吉花市"),
 _pokeluaText("Cherrygrove City", "吉花市"), _pokeluaText("Violet City", "桔梗市"), _pokeluaText("Azalea Town", "桧皮镇"), _pokeluaText("Cianwood City", "湛蓝市"), _pokeluaText("Goldenrod City", "满金市"), _pokeluaText("Olivine City", "浅葱市"),
 _pokeluaText("Ecruteak City", "缘朱市"), _pokeluaText("Ecruteak City", "缘朱市"), _pokeluaText("Ecruteak City", "缘朱市"), _pokeluaText("Ecruteak City", "缘朱市"), _pokeluaText("Jubilife City", "祝庆市"), _pokeluaText("Ecruteak City", "缘朱市"),
 _pokeluaText("Ecruteak City", "缘朱市"), _pokeluaText("Ecruteak City", "缘朱市"), _pokeluaText("Ecruteak City", "缘朱市"), _pokeluaText("Mahogany Town", "卡吉镇"), _pokeluaText("Lake of Rage", "愤怒之湖"), _pokeluaText("Blackthorn City", "烟墨市"),
 _pokeluaText("Mt. Silver", "白银山"), _pokeluaText("Route 19", "19号道路"), _pokeluaText("Route 20", "20号道路"), _pokeluaText("Route 21", "21号道路")}

local statusConditionNamesList = {_pokeluaText("None", "无"), _pokeluaText("SLP", "睡眠"), _pokeluaText("PSN", "中毒"), _pokeluaText("BRN", "灼伤"), _pokeluaText("FRZ", "冰冻"), _pokeluaText("PAR", "麻痹"), _pokeluaText("PSN", "中毒")}

local mapAttributeData = {
 0, 0, 2, 2, 0, 2, 0, 0, 2, 0, 0, 2, 0, 0, 0, 0,
 3, 1, 3, 1, 1, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 2, 1, 0, 0, 0, 2, 1, 0, 0, 2, 1, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

emu.reset()

local gameCode = read32Bit(0x2FFFE0C)
local gameVersionCode = band(gameCode, 0xFFFFFF)
local gameVersion = ""
local gameLanguageCode = rshift(gameCode, 24)
local gameLanguage = ""
local wrongGameVersion = true

if gameVersionCode == 0x414441 then  -- Check game version
 gameVersion = "Diamond"
elseif gameVersionCode == 0x415041 then
 gameVersion = "Pearl"
elseif gameVersionCode == 0x555043 then
 gameVersion = "Platinum"
elseif gameVersionCode == 0x475049 then
 gameVersion = "SoulSilver"
elseif gameVersionCode == 0x4B5049 then
 gameVersion = "HeartGold"
end

local boxSelectedSlotIndexOffset, mtIndexAddr, pidPointerAddr, radioSoundValueAddr, delayAddr, currentSeedAddr, mtSeedAddr, trainerIDsPointerAddr,
      getRadioSoundValueFunctionBaseAddr, getMarchSoundValueFunctionAddr, getLullabySoundValueFunctionAddr, tempCurrentSeedDuringBattleAddr
local japanOffset = 0
local koreanOffset = 0

if gameLanguageCode == 0x44 then  -- Check game language and set addresses
 gameLanguage = "GER"
 boxSelectedSlotIndexOffset = 0x975F1
 mtIndexAddr = 0x210F6AC
 pidPointerAddr = 0x211184C
 radioSoundValueAddr = 0x21D05C0
 delayAddr = 0x21D1118
 currentSeedAddr = 0x21D1588
 mtSeedAddr = 0x21D158C
 trainerIDsPointerAddr = 0x21D2208
 getRadioSoundValueFunctionBaseAddr = 0x22522C0
 getMarchSoundValueFunctionAddr = 0x22522F0
 getLullabySoundValueFunctionAddr = 0x22522F4
 tempCurrentSeedDuringBattleAddr = 0x27E3618
elseif gameLanguageCode == 0x45 then
 gameLanguage = "EUR/USA"
 boxSelectedSlotIndexOffset = 0x97339
 mtIndexAddr = 0x210F6CC
 pidPointerAddr = 0x211186C
 radioSoundValueAddr = 0x21D05E0
 delayAddr = 0x21D1138
 currentSeedAddr = 0x21D15A8
 mtSeedAddr = 0x21D15AC
 trainerIDsPointerAddr = 0x21D2228
 getRadioSoundValueFunctionBaseAddr = 0x22522E0
 getMarchSoundValueFunctionAddr = 0x2252310
 getLullabySoundValueFunctionAddr = 0x2252314
 tempCurrentSeedDuringBattleAddr = 0x27E3618
elseif gameLanguageCode == 0x46 then
 gameLanguage = "FRE"
 boxSelectedSlotIndexOffset = 0x97611
 mtIndexAddr = 0x210F6EC
 pidPointerAddr = 0x211188C
 radioSoundValueAddr = 0x21D0600
 delayAddr = 0x21D1158
 currentSeedAddr = 0x21D15C8
 mtSeedAddr = 0x21D15CC
 trainerIDsPointerAddr = 0x21D2248
 getRadioSoundValueFunctionBaseAddr = 0x2252300
 getMarchSoundValueFunctionAddr = 0x2252330
 getLullabySoundValueFunctionAddr = 0x2252334
 tempCurrentSeedDuringBattleAddr = 0x27E3618
elseif gameLanguageCode == 0x49 then
 gameLanguage = "ITA"
 boxSelectedSlotIndexOffset = 0x975F1
 mtIndexAddr = 0x210F66C
 pidPointerAddr = 0x211180C
 radioSoundValueAddr = 0x21D0580
 delayAddr = 0x21D10D8
 currentSeedAddr = 0x21D1548
 mtSeedAddr = 0x21D154C
 trainerIDsPointerAddr = 0x21D21C8
 getRadioSoundValueFunctionBaseAddr = 0x2252280
 getMarchSoundValueFunctionAddr = 0x22522B0
 getLullabySoundValueFunctionAddr = 0x22522B4
 tempCurrentSeedDuringBattleAddr = 0x27E3618
elseif gameLanguageCode == 0x4A then
 gameLanguage = "JPN"
 japanOffset = 0x4
 boxSelectedSlotIndexOffset = 0x975C1
 mtIndexAddr = 0x210EC00
 pidPointerAddr = 0x2110DAC
 radioSoundValueAddr = 0x21CFB18
 delayAddr = 0x21D0678
 currentSeedAddr = 0x21D0AE8
 mtSeedAddr = 0x21D0AEC
 trainerIDsPointerAddr = 0x21D1768
 getRadioSoundValueFunctionBaseAddr = 0x2251694
 getMarchSoundValueFunctionAddr = 0x22516C4
 getLullabySoundValueFunctionAddr = 0x22516C8
 tempCurrentSeedDuringBattleAddr = 0x27E3618
elseif gameLanguageCode == 0x4B then
 gameLanguage = "KOR"
 koreanOffset = 0x44
 boxSelectedSlotIndexOffset = 0x971B5
 mtIndexAddr = 0x21100AC
 pidPointerAddr = 0x211226C
 radioSoundValueAddr = 0x21D0FE0
 delayAddr = 0x21D1B38
 currentSeedAddr = 0x21D1FA8
 mtSeedAddr = 0x21D1FAC
 trainerIDsPointerAddr = 0x21D2C28
 getRadioSoundValueFunctionBaseAddr = 0x2252CE0
 getMarchSoundValueFunctionAddr = 0x2252D10
 getLullabySoundValueFunctionAddr = 0x2252D14
 tempCurrentSeedDuringBattleAddr = 0x27E3618
elseif gameLanguageCode == 0x53 then
 gameLanguage = "SPA"
 boxSelectedSlotIndexOffset = 0x9760D
 mtIndexAddr =  gameVersion == "HeartGold" and 0x210F6EC or 0x210F70C
 pidPointerAddr = gameVersion == "HeartGold" and 0x211188C or 0x21118AC
 radioSoundValueAddr = gameVersion == "HeartGold" and 0x21D0600 or 0x21D0620
 delayAddr = gameVersion == "HeartGold" and 0x21D1158 or 0x21D1178
 currentSeedAddr = gameVersion == "HeartGold" and 0x21D15C8 or 0x21D15E8
 mtSeedAddr = gameVersion == "HeartGold" and 0x21D15CC or 0x21D15EC
 trainerIDsPointerAddr = gameVersion == "HeartGold" and 0x21D2248 or 0x21D2268
 getRadioSoundValueFunctionBaseAddr = gameVersion == "HeartGold" and 0x2252300 or 0x2252320
 getMarchSoundValueFunctionAddr = gameVersion == "HeartGold" and 0x2252330 or 0x2252350
 getLullabySoundValueFunctionAddr = gameVersion == "HeartGold" and 0x2252334 or 0x2252354
 tempCurrentSeedDuringBattleAddr = 0x27E3618
end

function printGameInfo()
 if gameVersion == "" then  -- Print game info
  print(_pokeluaText("Version: Unknown game", "版本：未知游戏"))
 elseif gameVersion ~= "HeartGold" and gameVersion ~= "SoulSilver" then
  print(string.format(_pokeluaText("Version: %s - Wrong game version! Use HeartGold/SoulSilver instead\n", "版本：%s - 游戏版本错误！请改用心金／魂银\n"), gameVersion))
 elseif gameLanguage == "" then
  print(_pokeluaText("Version: ", "版本：")..gameVersion)
  print(_pokeluaText("Language: Unknown language\n", "语言：未知语言\n"))
 else
  wrongGameVersion = false
  print(_pokeluaText("Version: ", "版本：")..gameVersion)
  print(string.format(_pokeluaText("Language: %s\n", "语言：%s\n"), gameLanguage))
 end
end

printGameInfo()

local mode, index = {_pokeluaText("None", "无"), _pokeluaText("Capture", "捕获"), _pokeluaText("Breeding", "培育"), _pokeluaText("Roamer", "游走宝可梦"), _pokeluaText("Pandora", "潘多拉"), _pokeluaText("Pokemon Info", "宝可梦信息")}, 1

function setBackgroundBoxes()  -- Set transparent black boxes
 if mode[index] == _pokeluaText("Capture", "捕获") or mode[index] == _pokeluaText("Breeding", "培育") or mode[index] == _pokeluaText("Pokemon Info", "宝可梦信息") then
  gui.box(1, -191, 156, -59, "#0000007F", "#0000007F")
 elseif mode[index] == _pokeluaText("Roamer", "游走宝可梦") then
  gui.box(1, -191, 156, -70, "#0000007F", "#0000007F")
 end

 gui.box(1, 55, 164, 66, "#0000007F", "#0000007F")

 if mode[index] ~= _pokeluaText("None", "无") then
  gui.box(151, 180, 254, 190, "#0000007F", "#0000007F")
  gui.box(193, -24, 254, -2, "#0000007F", "#0000007F")
 end
end

local dateTime = {["month"] = 1, ["day"] = 1, ["year"] = 0, ["hour"] = 0, ["minute"] = 0, ["second"] = 0}

function setDateTime()
 local dateTimeAddr = 0x23FFDE8

 dateTime["year"] = string.format("%02X", read8Bit(dateTimeAddr))
 dateTime["month"] = string.format("%02X", read8Bit(dateTimeAddr + 0x1))
 dateTime["day"] = string.format("%02X", read8Bit(dateTimeAddr + 0x2))
 dateTime["hour"] = string.format("%02X", read8Bit(dateTimeAddr + 0x4) % 0x40)
 dateTime["minute"] = string.format("%02X", read8Bit(dateTimeAddr + 0x5))
 dateTime["second"] = string.format("%02X", read8Bit(dateTimeAddr + 0x6))
end

function drawArrowLeft(a, b, c)
 gui.line(a, b + 3, a + 2, b + 5, c)
 gui.line(a, b + 3, a + 2, b + 1, c)
 gui.line(a, b + 3, a + 6, b + 3, c)
end

function drawArrowRight(a, b, c)
 gui.line(a, b + 3, a - 2, b + 5, c)
 gui.line(a, b + 3, a - 2, b + 1, c)
 gui.line(a, b + 3, a - 6, b + 3, c)
end

local prevKey = {}

function getTabInput()
 local leftArrowColor = "gray"
 local rightArrowColor = "gray"
 local key = input.get()

 if (key["1"] or key["numpad1"]) and (not prevKey["1"] and not prevKey["numpad1"]) then
  leftArrowColor = "orange"
  index = index - 1 < 1 and 6 or index - 1
 elseif (key["2"] or key["numpad2"]) and (not prevKey["2"] and not prevKey["numpad2"]) then
  rightArrowColor = "orange"
  index = index + 1 > 6 and 1 or index + 1
 end

 prevKey = key
 gui.text(2, 57, _pokeluaText("Mode: ", "模式：")..mode[index])
 drawArrowLeft(113, 57, leftArrowColor)
 gui.text(121, 57, "1 - 2")
 drawArrowRight(159, 57, rightArrowColor)
end

function buildSeedFromDelay(delay)
 local ab = ((dateTime["month"] * dateTime["day"]) + dateTime["minute"] + dateTime["second"]) % 0x100
 local cd = dateTime["hour"]
 local efgh = dateTime["year"] + delay

 return ((ab * 0x1000000) + (cd * 0x10000) + efgh) % 0x100000000
end

local prevMTSeed, initialSeed, tempCurrentSeed, mtCounter, hitDelay , hitDate, battleStartJumpFlag = 0, 0, 0, 0, 0, "2000/01/01\n00:00:00", false

function setInitialSeed(mtSeed, delay)
 if prevMTSeed ~= mtSeed and delay ~= 0 then
  prevMTSeed = mtSeed
  initialSeed = mtSeed
  tempCurrentSeed = mtSeed
  local mtSeedTest = buildSeedFromDelay(delay)
  local mtSeedTest2 = buildSeedFromDelay(delay - 1)
  local mtSeedTest3 = buildSeedFromDelay(delay - 2)
  local initilSeedGenerationFlag = mtSeed == mtSeedTest and 0 or mtSeed == mtSeedTest2 and 1 or
                                   mtSeed == mtSeedTest3 and 2 or nil

  if initilSeedGenerationFlag then
   print(string.format(_pokeluaText("Initial Seed: %08X", "初始种子：%08X"), initialSeed))
   hitDelay = delay - initilSeedGenerationFlag
   hitDate = string.format(_pokeluaText("20%s/%s/%s\n%s:%s:%s", "20%s/%s/%s\n%s：%s：%s"), dateTime["year"], dateTime["month"], dateTime["day"],
                           dateTime["hour"], dateTime["minute"], dateTime["second"])
  end
 elseif delay == 0 then
  prevMTSeed = 0
  initialSeed = 0
  tempCurrentSeed = 0
  mtCounter = 0
  hitDelay = 0
  hitDate = "2000/01/01\n00:00:00"
  battleStartJumpFlag = false
 end
end

function LCRNG(s, mul, sum)
 local a = rshift(mul, 16) * (s % 0x10000) + rshift(s, 16) * (mul % 0x10000)
 local b = (mul % 0x10000) * (s % 0x10000) + (a % 0x10000) * 0x10000 + sum

 return b % 0x100000000
end

function LCRNGDistance(state0, state1)
 local mask = 1
 local dist = 0

 if state0 ~= state1 then
  for _, data in ipairs(JUMP_DATA) do
   local mult, add = unpack(data)

   if state0 == state1 then
    break
   end

   if band(bxor(state0, state1), mask) ~= 0 then
    state0 = LCRNG(state0, mult, add)
    dist = dist + mask
   end

   mask = lshift(mask, 1)
  end

  tempCurrentSeed = state1
 end

 return dist > 999 and dist - 0x100000000 or dist
end

local lastCurrentSeedBeforeBattle, advances = 0, 0

function getRngInfo()
 local mtSeed = read32Bit(mtSeedAddr)
 local current = read32Bit(currentSeedAddr)
 local delay = read32Bit(delayAddr)
 local mtIndex = read32Bit(mtIndexAddr)

 if mtSeed == current then  -- Set the initial seed when the MT seed is equal to the LCRNG current seed
  setInitialSeed(mtSeed, delay)
 elseif prevMTSeed ~= mtSeed then  -- Check when the value of the MT seed changes in RAM
  if mtIndex ~= 624 then  -- Avoid advancing the MT counter when the MT seed changes the first time
   mtCounter = mtCounter + 1
  end

  prevMTSeed = mtSeed
 elseif tempCurrentSeed == read32Bit(tempCurrentSeedDuringBattleAddr) and tempCurrentSeed ~= 0 then  -- Check when current seed is set on battle temp current seed address
  lastCurrentSeedBeforeBattle = tempCurrentSeed
  battleStartJumpFlag = true
 elseif current == lastCurrentSeedBeforeBattle then  -- Check when battle ends
  battleStartJumpFlag = false
 end

 if not battleStartJumpFlag then  -- Calculate prng jumps only when not in battle
  advances = mtSeed == current and 0 or advances + LCRNGDistance(tempCurrentSeed, current)
 end

 local mtAdvances = (mtIndex - 624) + (mtCounter * 624)

 if mtAdvances < 0 then  -- Avoid negative MT advances (this may happens in korean games)
  mtCounter = mtCounter + 1
 end

 return current, mtAdvances, delay
end

local showInitialSeedInfoText = true

function getInitialSeedInfoInput()
 local key = input.get()

 if key["7"] or key["numpad7"] then
  showInitialSeedInfoText = false
 elseif key["8"] or key["numpad8"] then
  showInitialSeedInfoText = true
 end

 gui.box(1, 180, 110, 190, "#0000007F", "#0000007F")
 gui.text(2, 182, showInitialSeedInfoText and _pokeluaText("7 - Hide Seed info", "7 - 隐藏种子信息") or _pokeluaText("8 - Show Seed info", "8 - 显示种子信息"))
end

function showInitialSeedInfo(delay)
 local delayOffset = mode[index] == _pokeluaText("Pandora", "潘多拉") and 181 or 21

 gui.box(1, 67, 164, 141, "#0000007F", "#0000007F")
 gui.text(2, 68, string.format(_pokeluaText("Next Initial Seed: %08X", "下一初始种子：%08X"), buildSeedFromDelay(delay + delayOffset, true)))
 gui.text(2, 79, string.format(_pokeluaText("Next Delay: %d", "下一延迟：%d"), delay + delayOffset))
 gui.text(2, 90, string.format(_pokeluaText("Delay: %d", "延迟：%d"), delay))
 gui.text(2, 101, string.format(_pokeluaText("Hit Delay: %d", "命中延迟：%d"), hitDelay))
 gui.text(2, 112, string.format(_pokeluaText("Hit Date/Hour:\n%s", "命中日期/小时：\n%s"), hitDate))
end

function showDateTime()
 if mode[index] ~= _pokeluaText("None", "无") then
  gui.box(193, 0, 254, 22, "#0000007F", "#0000007F")
  gui.text(194, 2, string.format("20%s/%s/%s", dateTime["year"], dateTime["month"], dateTime["day"]))
  gui.text(194, 13, string.format(_pokeluaText("%s:%s:%s", "%s：%s：%s"), dateTime["hour"], dateTime["minute"], dateTime["second"]))
 end
end

local showRngInfoText = true

function showRngInfo()
 local currentSeed, mtAdvances, delay = getRngInfo()

 if showRngInfoText and mode[index] ~= _pokeluaText("None", "无") then
  gui.box(1, 0, 134, 44, "#0000007F", "#0000007F")
  gui.text(2, 2, string.format(_pokeluaText("Initial Seed: %08X", "初始种子：%08X"), initialSeed))
  gui.text(2, 13, string.format(_pokeluaText("Current Seed: %08X", "当前种子：%08X"), currentSeed))
  gui.text(2, 24, string.format(_pokeluaText("LCRNG Advances: %d", "LCRNG 推进数：%d"), advances))
  gui.text(2, 35, string.format(_pokeluaText("MT Advances: %d", "MT 推进数：%d"), mtAdvances))

  getInitialSeedInfoInput()

  if showInitialSeedInfoText then
   showInitialSeedInfo(delay)
   showDateTime()
  end
 end
end

function getRngInfoInput()
 local key = input.get()

 if key["6"] or key["numpad6"] then
  showRngInfoText = true
 elseif key["5"] or key["numpad5"] then
  showRngInfoText = false
 end

 gui.text(152, 182, showRngInfoText and _pokeluaText("5 - Hide RNG info", "5 - 隐藏 RNG 信息") or _pokeluaText("6 - Show RNG info", "6 - 显示 RNG 信息"))
end

function getTrainerIDs()
 local trainerIDsAddr = read32Bit(trainerIDsPointerAddr) + 0x84
 local trainerIDs = read32Bit(trainerIDsAddr)
 local TID = band(trainerIDs, 0xFFFF)
 local SID = rshift(trainerIDs, 16)

 return TID, SID
end

function showTrainerIDs()
 local trainerTID, trainerSID = getTrainerIDs()

 gui.text(194, -22, string.format(_pokeluaText("TID: %d", "TID：%d"), trainerTID))
 gui.text(194, -11, string.format(_pokeluaText("SID: %d", "SID：%d"), trainerSID))
end

local prevKeySlot, slotIndex = {}, 0

function getSlotInput()
 local leftSlotArrowColor = "gray"
 local rightSlotArrowColor = "gray"
 local key = input.get()

 if (key["3"] or key["numpad3"]) and (not prevKeySlot["3"] and not prevKeySlot["numpad3"]) then
  leftSlotArrowColor = "orange"
  slotIndex = slotIndex - 1 < 0 and 1 or slotIndex - 1
 elseif (key["4"] or key["numpad4"]) and (not prevKeySlot["4"] and not prevKeySlot["numpad4"]) then
  rightSlotArrowColor = "orange"
  slotIndex = slotIndex + 1 > 1 and 0 or slotIndex + 1
 end

 prevKeySlot = key
 gui.box(160, -191, 254, -180, "#0000007F", "#0000007F")
 drawArrowLeft(161, -189, leftSlotArrowColor)
 gui.text(169, -189, "3 - 4")
 drawArrowRight(207, -189, rightSlotArrowColor)
 gui.text(212, -189, _pokeluaText("Slot: ", "槽位：")..slotIndex + 1)

 return slotIndex
end

function getOffset(offsetType, orderIndex)
 local offsets = {["growth"] = {0,0,0,0,0,0, 1,1,2,3,2,3, 1,1,2,3,2,3, 1,1,2,3,2,3},
                  ["attack"] = {1,1,2,3,2,3, 0,0,0,0,0,0, 2,3,1,1,3,2, 2,3,1,1,3,2}}

 return offsets[offsetType][orderIndex]
end

function shinyCheck(PID, trainerTID, trainerSID)
 trainerTID = trainerTID or nil
 trainerSID = trainerSID or nil

 if not trainerTID then
  trainerTID, trainerSID = getTrainerIDs()
 end

 local lowPID = band(PID, 0xFFFF)
 local highPID = rshift(PID, 16)
 local shinyTypeValue = bxor(bxor(trainerTID, trainerSID), bxor(lowPID, highPID))

 if shinyTypeValue < 8 then
  return "green", shinyTypeValue == 0 and _pokeluaText(" (Square)", "（方块）") or _pokeluaText(" (Star)", "（星星）")
 end

 return nil, ""
end

function getBits(a, b, d)
 return rshift(a, b) % lshift(1, d)
end

function getIVs(ivsValue)
 local hpIV  = getBits(ivsValue, 0, 5)
 local atkIV = getBits(ivsValue, 5, 5)
 local defIV = getBits(ivsValue, 10, 5)
 local spdIV = getBits(ivsValue, 15, 5)
 local spAtkIV = getBits(ivsValue, 20, 5)
 local spDefIV = getBits(ivsValue, 25, 5)

 return hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV
end

function getHPTypeAndPower(hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV)
 local hpType = floor(((band(hpIV, 1) + (2 * band(atkIV, 1)) + (4 * band(defIV, 1)) + (8 * band(spdIV, 1)) + (16 * band(spAtkIV, 1))
                + (32 * band(spDefIV, 1))) * 15) / 63)
 local hpPower = floor((((band(rshift(hpIV, 1), 1) + (2 * band(rshift(atkIV, 1), 1)) + (4 * band(rshift(defIV, 1), 1)) + (8 * band(rshift(spdIV, 1), 1))
                 + (16 * band(rshift(spAtkIV, 1), 1)) + (32 * band(rshift(spDefIV, 1), 1))) * 40) / 63)) + 30

 return hpType, hpPower
end

function getIVColor(value)
 if value >= 30 then
  return "green"
 elseif value >= 1 and value <= 5 then
  return "orange"
 elseif value < 1 then
  return "red"
 end

 return nil  -- IV value from 6 to 29
end

function showIVsAndHP(ivsValue)
 local hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV = getIVs(ivsValue)
 local hpType, hpPower = getHPTypeAndPower(hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV)

 gui.text(2, -145, _pokeluaText("IVs:", "个体值："))
 gui.text(32, -145, string.format("%02d", hpIV), getIVColor(hpIV))
 gui.text(44, -145, "/")
 gui.text(50, -145, string.format("%02d", atkIV), getIVColor(atkIV))
 gui.text(62, -145, "/")
 gui.text(68, -145, string.format("%02d", defIV), getIVColor(defIV))
 gui.text(80, -145, "/")
 gui.text(86, -145, string.format("%02d", spAtkIV), getIVColor(spAtkIV))
 gui.text(98, -145, "/")
 gui.text(104, -145, string.format("%02d", spDefIV), getIVColor(spDefIV))
 gui.text(116, -145, "/")
 gui.text(122, -145, string.format("%02d", spdIV), getIVColor(spdIV))

 gui.text(2, -134, _pokeluaText("HPower: ", "觉醒力量：")..HPTypeNamesList[hpType + 1].." "..hpPower)
end

function showMoves(moveIndexesList)
 gui.text(2, -101, _pokeluaText("Move: ", "招式：")..moveNamesList[moveIndexesList[1] > 468 and 1 or moveIndexesList[1]])
 gui.text(2, -90, _pokeluaText("Move: ", "招式：")..moveNamesList[moveIndexesList[2] > 468 and 1 or moveIndexesList[2]])
 gui.text(2, -79, _pokeluaText("Move: ", "招式：")..moveNamesList[moveIndexesList[3] > 468 and 1 or moveIndexesList[3]])
 gui.text(2, -68, _pokeluaText("Move: ", "招式：")..moveNamesList[moveIndexesList[4] > 468 and 1 or moveIndexesList[4]])
end

function showPP(movePPList)
 gui.text(120, -101, _pokeluaText("PP: ", "PP：")..(movePPList[1] < 100 and movePPList[1] or 0))
 gui.text(120, -90, _pokeluaText("PP: ", "PP：")..(movePPList[2] < 100 and movePPList[2] or 0))
 gui.text(120, -79, _pokeluaText("PP: ", "PP：")..(movePPList[3] < 100 and movePPList[3] or 0))
 gui.text(120, -68, _pokeluaText("PP: ", "PP：")..(movePPList[4] < 100 and movePPList[4] or 0))
end

function showPokemonIDs(trainerTID, trainerSID)
 gui.text(194, -22, string.format(_pokeluaText("TID: %d", "TID：%d"), trainerTID))
 gui.text(194, -11, string.format(_pokeluaText("SID: %d", "SID：%d"), trainerSID))
end

function showInfo(pidAddr)
 local pokemonPID = read32Bit(pidAddr)
 local checksum = read16Bit(pidAddr + 0x6)
 local orderIndex = (rshift(band(pokemonPID, 0x3E000), 0xD) % 24) + 1
 local move = {}
 local movePP = {}
 local ivsPart = {}

 local growthOffset = getOffset("growth", orderIndex) * 32
 local attacksOffset = getOffset("attack", orderIndex) * 32
 local prng = checksum

 for i = 1, getOffset("growth", orderIndex) do
  prng = LCRNG(prng, 0x5F748241, 0xCBA72510)  -- 16 cycles
 end

 prng = LCRNG(prng, 0x41C64E6D, 0x6073)
 local speciesDexIndex = bxor(read16Bit(pidAddr + growthOffset + 0x8), rshift(prng, 16))

 prng = LCRNG(prng, 0x41C64E6D, 0x6073)
 local heldItemIndex = bxor(read16Bit(pidAddr + growthOffset + 0xA), rshift(prng, 16)) + 1

 local OTID, OTSID = nil, nil

 if mode[index] == _pokeluaText("Pokemon Info", "宝可梦信息") then
  prng = LCRNG(prng, 0x41C64E6D, 0x6073)
  OTID = bxor(read16Bit(pidAddr + growthOffset + 0xC), rshift(prng, 16))
  prng = LCRNG(prng, 0x41C64E6D, 0x6073)
  OTSID = bxor(read16Bit(pidAddr + growthOffset + 0xE), rshift(prng, 16))
 else
  prng = LCRNG(prng, 0xC2A29A69, 0xE97E7B6A)  -- 2 cycles
 end

 local shinyTypeTextColor, shinyType = shinyCheck(pokemonPID, OTID, OTSID)

 prng = LCRNG(prng, 0x807DBCB5, 0x52713895)  -- 3 cycles
 local abilityIndex = bxor(read16Bit(pidAddr + growthOffset + 0x14), rshift(prng, 16))
 abilityIndex = getBits(abilityIndex, 8, 8)

 prng = checksum

 for i = 1, getOffset("attack", orderIndex) do
  prng = LCRNG(prng, 0x5F748241, 0xCBA72510)  -- 16 cycles
 end

 prng = LCRNG(prng, 0x41C64E6D, 0x6073)
 move[1] = bxor(read16Bit(pidAddr + attacksOffset + 0x8), rshift(prng, 16)) + 1
 prng = LCRNG(prng, 0x41C64E6D, 0x6073)
 move[2] = bxor(read16Bit(pidAddr + attacksOffset + 0xA), rshift(prng, 16)) + 1
 prng = LCRNG(prng, 0x41C64E6D, 0x6073)
 move[3] = bxor(read16Bit(pidAddr + attacksOffset + 0xC), rshift(prng, 16)) + 1
 prng = LCRNG(prng, 0x41C64E6D, 0x6073)
 move[4] = bxor(read16Bit(pidAddr + attacksOffset + 0xE), rshift(prng, 16)) + 1

 prng = LCRNG(prng, 0x41C64E6D, 0x6073)
 local movePPAux = bxor(read16Bit(pidAddr + attacksOffset + 0x10), rshift(prng, 16))
 movePP[1] = getBits(movePPAux, 0, 8)
 movePP[2] = getBits(movePPAux, 8, 8)
 prng = LCRNG(prng, 0x41C64E6D, 0x6073)
 movePPAux = bxor(read16Bit(pidAddr + attacksOffset + 0x12), rshift(prng, 16))
 movePP[3] = getBits(movePPAux, 0, 8)
 movePP[4] = getBits(movePPAux, 8, 8)

 prng = LCRNG(prng, 0x807DBCB5, 0x52713895)  -- 3 cycles
 ivsPart[1] = bxor(read16Bit(pidAddr + attacksOffset + 0x18), rshift(prng, 16))
 prng = LCRNG(prng, 0x41C64E6D, 0x6073)
 ivsPart[2] = bxor(read16Bit(pidAddr + attacksOffset + 0x1A), rshift(prng, 16))
 local ivsValue = lshift(ivsPart[2], 16) + ivsPart[1]

 local isEgg = getBits(ivsValue, 30, 1) == 1
 local natureIndex = (pokemonPID % 25) + 1

 if mode[index] ~= _pokeluaText("Breeding", "培育") or isEgg then
  gui.text(2, -189, _pokeluaText("Species: ", "种类：")..speciesNamesList[(speciesDexIndex > 493 or speciesDexIndex < 1) and 1 or speciesDexIndex])
  gui.text(2, -178, _pokeluaText("PID:", "PID："))
  gui.text(32, -178, string.format("%08X%s", pokemonPID, shinyType), shinyTypeTextColor)
  gui.text(2, -167, _pokeluaText("Nature: ", "性格：")..natureNamesList[(natureIndex > 25 or natureIndex == nil) and 1 or natureIndex])
  gui.text(2, -156, string.format(_pokeluaText("Ability: %s (%s)", "特性：%s (%s)"), abilityNamesList[(abilityIndex > 123 or abilityIndex < 1) and 1 or abilityIndex],
           abilityIndex == pokemonAbilities[(speciesDexIndex > 493 or speciesDexIndex < 1) and 1 or speciesDexIndex][1] and "0" or "1"))

  showIVsAndHP(ivsValue)

  gui.text(2, -123, _pokeluaText("Held item: ", "携带道具：")..itemNamesList[(heldItemIndex > 537) and 1 or heldItemIndex])

  showMoves(move)
  showPP(movePP)

  if mode[index] == _pokeluaText("Pokemon Info", "宝可梦信息") then
   showPokemonIDs(OTID, OTSID)
  end
 end
end

function getRunningSurfingMod(currentVehicleIndex)
 local playerMovementStateAddr = read32Bit(pidPointerAddr) + 0x37888 + koreanOffset
 local playerMovementState = read8Bit(playerMovementStateAddr) - 0x58
 local isPlayerRunning = playerMovementState >= 0 and playerMovementState <= 0x3
 local isPlayerSurfing = currentVehicleIndex == 0x2

 return (isPlayerRunning or isPlayerSurfing) and 20 or 0
end

function getBikeMod(currentVehicleIndex)
 local isPlayerOnBike = currentVehicleIndex == 0x1

 return isPlayerOnBike and 50 or 0
end

function getHighGrassMod(matr)
 local isPlayerOnLongGrass = matr == 0x3

 return isPlayerOnLongGrass and 40 or 0
end

function getOppositeTurningMod()
 local oppositeTurningModAddr = read32Bit(pidPointerAddr) + 0x31044 + koreanOffset
 local oppositeTurningMod = read8Bit(oppositeTurningModAddr)

 return oppositeTurningMod == 2 and 30 or
        oppositeTurningMod == 3 and 40 or
        oppositeTurningMod >= 4 and 60 or 0 
end

function getRadioSoundMod()
 local radioSoundValueBase = 0x492
 local radioSoundValue = read16Bit(radioSoundValueAddr)

 if radioSoundValueBase < radioSoundValue then
  if radioSoundValueBase + 0x8E == radioSoundValue then
   return 25
  elseif radioSoundValueBase + 0x8D == radioSoundValue then
   return -25
  end
 elseif radioSoundValueBase > radioSoundValue and radioSoundValueBase - 0x44 >= radioSoundValue then
  local mul = radioSoundValue - (radioSoundValueBase - 0x47)
  local getRadioSoundValueFunctionAddress = (getRadioSoundValueFunctionBaseAddr + 0x2) + read8Bit(getRadioSoundValueFunctionBaseAddr + (mul * 2))

  if getRadioSoundValueFunctionAddress == getMarchSoundValueFunctionAddr then
   return 25
  elseif getRadioSoundValueFunctionAddress == getLullabySoundValueFunctionAddr then
   return -25
  end
 end

 return 0
end

function setMovementRate(matr)
 local rate = 20  -- Base wild encounter rate is 40
 local playerCurrentVehicleIndexAddr = read32Bit(pidPointerAddr) + 0xE294
 local playerCurrentVehicleIndex = read8Bit(playerCurrentVehicleIndexAddr)
 rate = rate + getRunningSurfingMod(playerCurrentVehicleIndex)
 rate = rate + getBikeMod(playerCurrentVehicleIndex)
 rate = rate + getHighGrassMod(matr)
 rate = rate + getOppositeTurningMod()
 rate = rate + getRadioSoundMod()

 return (rate < 1 or rate > 100) and 100 or rate  -- movement rate value can't be lower than 1 or higher than 100
end

function getTileRate(matr)
 local isWaterArea = band(mapAttributeData[matr + 1], 0x1) ~= 0
 local isCaveArea = matr == 0x8

 return (isWaterArea or isCaveArea) and 10 or 25
end

function getLeadAbility(pidAddr)
 local pokemonPID = read32Bit(pidAddr)
 local checksum = read16Bit(pidAddr + 0x6)
 local orderIndex = (rshift(band(pokemonPID, 0x3E000), 0xD) % 24) + 1

 local growthOffset = getOffset("growth", orderIndex) * 32
 local prng = checksum

 for i = 1, getOffset("growth", orderIndex) do
  prng = LCRNG(prng, 0x5F748241, 0xCBA72510)  -- 16 cycles
 end

 prng = LCRNG(prng, 0x9B355305, 0xAFC58AC9)  -- 7 cycles
 local abilityIndex = bxor(read16Bit(pidAddr + growthOffset + 0x14), rshift(prng, 16))

 return getBits(abilityIndex, 8, 8)
end

function getAbilityEffectType(pidAddr)
 local partyLeadAbility = getLeadAbility(pidAddr)

 if partyLeadAbility == 0x23 or partyLeadAbility == 0x47 or partyLeadAbility == 0x63 then  -- Illuminate / Arena Trap / No Guard
  return 2
 elseif partyLeadAbility == 0x51 then  -- Snow Cloak
  local weatherIndexAddr = read32Bit(pidPointerAddr) + 0xE28A
  local weatherIndex = read8Bit(weatherIndexAddr)

  if weatherIndex == 0x5 then  -- Snow Cloak effect is active only during the snowing
   return 1
  end
 elseif partyLeadAbility == 0x1 or partyLeadAbility == 0x49 or partyLeadAbility == 0x5F then  -- Stench / White Smoke / Quick Feet
  return 1
 end

 return 0
end

function getAbilityEffectMod(rate, pidAddr)
 local partyLeadAbilityEffectType = getAbilityEffectType(pidAddr)

 return partyLeadAbilityEffectType == 1 and floor(rate / 2) or partyLeadAbilityEffectType == 2 and rate * 2 or rate
end

function getActiveFluteType()
 local fluteFlagsAddr = read32Bit(pidPointerAddr) + 0x138FB
 local fluteActiveEffectFlag = read8Bit(fluteFlagsAddr)

 return fluteActiveEffectFlag
end

function getFluteEffectMod(rate)
 local activeFluteType = getActiveFluteType()
 local isBlackFluteActive = activeFluteType == 1
 local isWhiteFluteActive = activeFluteType == 2

 return isBlackFluteActive and floor(rate / 2) or isWhiteFluteActive and rate + floor(rate / 2) or rate
end

function getLeadHeldItem(pidAddr)
 local pokemonPID = read32Bit(pidAddr)
 local checksum = read16Bit(pidAddr + 0x6)
 local orderIndex = (rshift(band(pokemonPID, 0x3E000), 0xD) % 24) + 1

 local growthOffset = getOffset("growth", orderIndex) * 32
 local prng = checksum

 for i = 1, getOffset("growth", orderIndex) do
  prng = LCRNG(prng, 0x5F748241, 0xCBA72510)  -- 16 cycles
 end

 prng = LCRNG(prng, 0xC2A29A69, 0xE97E7B6A)  -- 2 cycles
 return bxor(read16Bit(pidAddr + growthOffset + 0xA), rshift(prng, 16))
end

function getTagOrIncenseEffectMod(rate, pidAddr)
 local partyLeadHeldItem = getLeadHeldItem(pidAddr)
 local isPartyLeadHoldingCleanseTag = partyLeadHeldItem == 0xE0
 local isPartyLeadHoldingPureIncense = partyLeadHeldItem == 0x140

 return (isPartyLeadHoldingCleanseTag or isPartyLeadHoldingPureIncense) and floor((rate * 2) / 3) or rate
end

function setEncounterRate(matr, pidAddr)
 local partyAddr = pidAddr + 0xD088
 local rate = getTileRate(matr)
 rate = getAbilityEffectMod(rate, partyAddr)
 rate = getFluteEffectMod(rate)
 rate = getTagOrIncenseEffectMod(rate, partyAddr)

 return rate
end

function coolDownEndCheck(steps, currentSteps)
 return steps + currentSteps >= 3 and true or false
end

function getEncounterCheckValue(seed)
 return rshift(seed, 16) % 0x64
end

function getEncounterMissingSteps(movement, encounter)
 local currentCoolDownStepsAddr = read32Bit(pidPointerAddr) + 0x31046 + koreanOffset
 local currentCoolDownSteps = read8Bit(currentCoolDownStepsAddr)
 local wildEncounterSeed = read32Bit(currentSeedAddr)
 local missingSteps, coolDownSteps = 0, 0

 while not battleStartJumpFlag do
  local isCoolDownEnded = true

  if not coolDownEndCheck(coolDownSteps, currentCoolDownSteps) then
   coolDownSteps = coolDownSteps + 1
   isCoolDownEnded = false
  end

  if isCoolDownEnded then
   wildEncounterSeed = LCRNG(wildEncounterSeed, 0x41C64E6D, 0x6073)
   missingSteps = missingSteps + 1

   if getEncounterCheckValue(wildEncounterSeed) < movement then
    wildEncounterSeed = LCRNG(wildEncounterSeed, 0x41C64E6D, 0x6073)

    if getEncounterCheckValue(wildEncounterSeed) < encounter then
     break
    end
   end
  end
 end

 return missingSteps + coolDownSteps, coolDownSteps
end

function showEncounterMissingSteps(pidAddr)
 local mapAttributeAddr = read32Bit(pidPointerAddr) + 0x32E0C + koreanOffset
 local mapAttribute = read8Bit(mapAttributeAddr)
 local isEncounterArea = band(mapAttributeData[mapAttribute + 1], 0x2) ~= 0
 local encounterMissingSteps, coolDownSteps = 0, 0

 if isEncounterArea then
  local movementRate = setMovementRate(mapAttribute)
  local encounterRate = setEncounterRate(mapAttribute, pidAddr)
  encounterMissingSteps, coolDownSteps = getEncounterMissingSteps(movementRate, encounterRate)
 end

 gui.box(1, -48, 176, -26, "#0000007F", "#0000007F")
 gui.text(2, -46, (_pokeluaText("Encounters cooldown? ", "遭遇冷却？ ")..(coolDownSteps == 0 and _pokeluaText("No", "否") or _pokeluaText("Yes", "是"))))
 gui.text(2, -35, (_pokeluaText("Steps for wild encounter: ", "距离野生遭遇的步数：")..encounterMissingSteps))
end

function showPartyEggInfo(pidAddr)
 local partyAddr = pidAddr + 0xD088
 local partySlotsCounterAddr = pidAddr + 0xD084
 local partySlotsCounter = read8Bit(partySlotsCounterAddr) - 1
 local lastPartySlotAddr = partyAddr + (partySlotsCounter * 0xEC)

 showInfo(lastPartySlotAddr)
end

local prevKeyRoamerSlot, roamerSlotIndex = {}, 0

function getRoamerSlotInput()
 local leftRoamerSlotArrowColor = "gray"
 local rightRoamerSlotArrowColor = "gray"
 local key = input.get()

 if (key["3"] or key["numpad3"]) and (not prevKeyRoamerSlot["3"] and not prevKeyRoamerSlot["numpad3"]) then
  leftRoamerSlotArrowColor = "orange"
  roamerSlotIndex = roamerSlotIndex - 1 < 0 and (gameVersion == "SoulSilver" and 3 or 2) or (gameVersion == "SoulSilver" and roamerSlotIndex - 1 == 2) and 1 or roamerSlotIndex - 1 
 elseif (key["4"] or key["numpad4"]) and (not prevKeyRoamerSlot["4"] and not prevKeyRoamerSlot["numpad4"]) then
  rightRoamerSlotArrowColor = "orange"
  roamerSlotIndex = roamerSlotIndex + 1 > 2 and 0 or (gameVersion == "SoulSilver" and roamerSlotIndex + 1 == 2) and 3 or roamerSlotIndex + 1
 end

 prevKeyRoamerSlot = key
 gui.box(160, -191, 254, -180, "#0000007F", "#0000007F")
 drawArrowLeft(161, -189, leftRoamerSlotArrowColor)
 gui.text(169, -189, "3 - 4")
 drawArrowRight(207, -189, rightRoamerSlotArrowColor)
 gui.text(212, -189, _pokeluaText("Slot: ", "槽位：")..(roamerSlotIndex + 1 == 4 and 3 or roamerSlotIndex + 1))

 return roamerSlotIndex
end

function getRoamerInfo(roamerAddr)
 local isRoamerActive = read8Bit(roamerAddr + 0x12) == 1

 if isRoamerActive then
  local roamerMapIndex = read16Bit(roamerAddr)
  local roamerIVsValue = read32Bit(roamerAddr + 0x4)
  local roamerPID = read32Bit(roamerAddr + 0x8)
  local roamerShinyTypeTextColor, roamerShinyType = shinyCheck(roamerPID)
  local roamerSpeciesIndex = read16Bit(roamerAddr + 0xC)
  local roamerHP = read16Bit(roamerAddr + 0xE)
  local roamerLevel = read8Bit(roamerAddr + 0x10)
  local roamerStatusIndex = read8Bit(roamerAddr + 0x11)
  local roamerStatus = statusConditionNamesList[1]  -- No altered status condition by default
  local roamerNatureIndex = (roamerPID % 25) + 1
  local playerMapIndexAddr = read32Bit(trainerIDsPointerAddr) + 0x1244
  local playerMapIndex = read16Bit(playerMapIndexAddr)

  if roamerStatusIndex > 0 and roamerStatusIndex < 0x8 then  -- Sleeping status condition
   roamerStatus = statusConditionNamesList[2]
  elseif roamerStatusIndex == 0x8 then  -- Poisoned status condition
   roamerStatus = statusConditionNamesList[3]
  elseif roamerStatusIndex == 0x10 then  -- Burned status condition
   roamerStatus = statusConditionNamesList[4]
  elseif roamerStatusIndex == 0x20 then  -- Freezed status condition
   roamerStatus = statusConditionNamesList[5]
  elseif roamerStatusIndex == 0x40 then  -- Paralyzed status condition
   roamerStatus = statusConditionNamesList[6]
  elseif roamerStatusIndex == 0x80 then  -- Badly poisoned status condition
   roamerStatus = statusConditionNamesList[7]
  end

  return isRoamerActive, roamerMapIndex, roamerIVsValue, roamerPID, roamerShinyTypeTextColor, roamerShinyType,
         (roamerSpeciesIndex > 493 or roamerSpeciesIndex < 1) and 1 or roamerSpeciesIndex, roamerHP, roamerLevel, 
         roamerStatus, (roamerNatureIndex > 25 or roamerNatureIndex == nil) and 1 or roamerNatureIndex,
         playerMapIndex
 end

 return nil
end

function showRoamerInfo(roamerAddr)
 local isRoamerActive, roamerMapIndex, roamerIVsValue, roamerPID, roamerShinyTypeTextColor, roamerShinyType,
       roamerSpeciesIndex, roamerHP, roamerLevel, roamerStatus, roamerNatureIndex, playerMapIndex = getRoamerInfo(roamerAddr)

 if isRoamerActive then
  gui.text(2, -189, _pokeluaText("Active Roamer? Yes", "存在活跃游走宝可梦？ 是"))
  gui.text(2, -178, _pokeluaText("Species: ", "种类：")..speciesNamesList[roamerSpeciesIndex])
  gui.text(2, -167, _pokeluaText("PID:", "PID："))
  gui.text(32, -167, string.format("%08X%s", roamerPID, roamerShinyType), roamerShinyTypeTextColor)
  gui.text(2, -156, _pokeluaText("Nature: ", "性格：")..natureNamesList[roamerNatureIndex])
  showIVsAndHP(roamerIVsValue)
  gui.text(2, -123, _pokeluaText("Level: ", "等级：")..roamerLevel)
  gui.text(2, -112, _pokeluaText("HP: ", "HP：")..roamerHP)
  gui.text(2, -101, _pokeluaText("Status condition: ", "异常状态：")..roamerStatus)
  gui.text(2, -90, _pokeluaText("Current position:", "当前位置："))
  gui.text(2, -79, locationNamesList[roamerMapIndex + 1], roamerMapIndex == playerMapIndex and "green" or nil)
 else
  gui.text(2, -189, _pokeluaText("Active Roamer? No", "存在活跃游走宝可梦？ 否"))
 end
end

local prevKeyInfo, infoIndex, infoMode = {}, 1, {_pokeluaText("Gift", "礼物"), _pokeluaText("Party", "同行"), _pokeluaText("Party Stats", "同行宝可梦能力值"), _pokeluaText("Box", "盒子"), _pokeluaText("Box Stats", "盒中宝可梦能力值")}

function getInfoInput()
 local leftInfoArrowColor = "gray"
 local rightInfoArrowColor = "gray"
 local key = input.get()

 if (key["3"] or key["numpad3"]) and (not prevKeyInfo["3"] and not prevKeyInfo["numpad3"]) then
  leftInfoArrowColor = "orange"
  infoIndex = infoIndex - 1 < 1 and 5 or infoIndex - 1
 elseif (key["4"] or key["numpad4"]) and (not prevKeyInfo["4"] and not prevKeyInfo["numpad4"]) then
  rightInfoArrowColor = "orange"
  infoIndex = infoIndex + 1 > 5 and 1 or infoIndex + 1
 end

 prevKeyInfo = key
 gui.box(1, 154, 134, 176, "#0000007F", "#0000007F")
 gui.text(2, 156, _pokeluaText("Info Mode: ", "信息模式：")..infoMode[infoIndex])
 drawArrowLeft(2, 167, leftInfoArrowColor)
 gui.text(10, 167, "3 - 4")
 drawArrowRight(48, 167, rightInfoArrowColor)
end

function showPokemonInfo(pidAddr)
 local partyAddr = pidAddr + 0xD088
 local boxAddr = pidAddr + 0x1C6F0
 local currBoxIndexAddr = pidAddr + 0x51007 + koreanOffset
 local currBoxIndex = read8Bit(currBoxIndexAddr)

 if infoMode[infoIndex] == _pokeluaText("Gift", "礼物") then
  local partySlotsCounterAddr = pidAddr + 0xD084
  local partySlotsCounter = read8Bit(partySlotsCounterAddr) - 1
  local lastPartySlotAddr = partyAddr + (partySlotsCounter * 0xEC)

  showInfo(lastPartySlotAddr)
 elseif infoMode[infoIndex] == _pokeluaText("Party", "同行") then
  local partySelectedSlotIndexAddr = pidAddr + 0x51CC1 + koreanOffset
  local partySelectedSlotIndex = read8Bit(partySelectedSlotIndexAddr)
  local partySelectedPokemonAddr = partyAddr + (partySelectedSlotIndex * 0xEC)

  showInfo(partySelectedPokemonAddr)
 elseif infoMode[infoIndex] == _pokeluaText("Party Stats", "同行宝可梦能力值") then
  local partyStatsSelectedSlotIndexAddr = pidAddr + 0x37CE8 + koreanOffset + japanOffset
  local partyStatsSelectedSlotIndex = read8Bit(partyStatsSelectedSlotIndexAddr)
  local pokemonPartyStatsAddr = partyAddr + (partyStatsSelectedSlotIndex * 0xEC)

  showInfo(pokemonPartyStatsAddr)
 elseif infoMode[infoIndex] == _pokeluaText("Box", "盒子") then
  local boxSelectedSlotIndexAddr = pidAddr + boxSelectedSlotIndexOffset + koreanOffset
  local boxSelectedSlotIndex = read8Bit(boxSelectedSlotIndexAddr)
  local boxSelectedPokemonAddr = boxAddr + (0x88 * boxSelectedSlotIndex) + ((0x1000 * currBoxIndex))

  showInfo(boxSelectedPokemonAddr)
 elseif infoMode[infoIndex] == _pokeluaText("Box Stats", "盒中宝可梦能力值") then
  local boxStatsSelectedSlotIndexAddr = pidAddr + 0x51054 + koreanOffset
  local boxStatsSelectedSlotIndex = read8Bit(boxStatsSelectedSlotIndexAddr)
  local pokemonBoxStatsAddr = boxAddr + (0x88 * boxStatsSelectedSlotIndex) + ((0x1000 * currBoxIndex))

  showInfo(pokemonBoxStatsAddr)
 end
end

function createStateFile(statesFileName, stateSlot)
 os.execute("mkdir states")
 local statesFile = io.open(statesFileName, "w")

 if statesFile then  -- Check if the state file has been created correctly
  for slotNumber = 1, 10 do
   if slotNumber == stateSlot then  -- Write only in the line of the saved slot
    statesFile:write(string.format("%08X %08X %d %d %d %s %08X %s\n", initialSeed, tempCurrentSeed, advances, mtCounter,
                                   hitDelay, (hitDate:gsub("\n", " ")), lastCurrentSeedBeforeBattle, tostring(battleStartJumpFlag)))
   else  -- Fill with empty data the lines of not saved state
    statesFile:write("00000000 00000000 0 0 0 2000/01/01 00:00:00 00000000 false\n")
   end
  end

  statesFile:close()
  gui.text(2, 145, string.format(_pokeluaText("Saved state on slot %s", "已保存即时存档至槽位 %s"), stateSlot))
 end
end

function writeStateFile(statesFileName, stateSlot)
 local statesFile = io.open(statesFileName, "r")
 local line_num = 1
 local lines = ""

 for line in statesFile:lines() do
  if line_num == stateSlot then  -- Overwrite only the line of the saved slot
   line = string.format("%08X %08X %d %d %d %s %08X %s", initialSeed, tempCurrentSeed, advances, mtCounter,
                        hitDelay, (hitDate:gsub("\n", " ")), lastCurrentSeedBeforeBattle, tostring(battleStartJumpFlag))
  end

  lines = lines..line.."\n"
  line_num = line_num + 1
 end

 statesFile:close()
 statesFile = io.open(statesFileName, "w")
 statesFile:write(lines)
 statesFile:close()
 gui.text(2, 145, string.format(_pokeluaText("Saved state on slot %s", "已保存即时存档至槽位 %s"), stateSlot))
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
  local prevInitialSeed = initialSeed
  initialSeed = tonumber(values[1], 16)
  tempCurrentSeed = tonumber(values[2], 16)
  advances = tonumber(values[3])
  mtCounter = tonumber(values[4])
  hitDelay = tonumber(values[5])
  hitDate = string.format("%s\n%s", values[6], values[7])
  lastCurrentSeedBeforeBattle = tonumber(values[8], 16)
  battleStartJumpFlag = values[9] ~= "false"
  prevMTSeed = read32Bit(mtSeedAddr)

  if prevInitialSeed ~= initialSeed and initialSeed ~= 0 then
   print(string.format(_pokeluaText("Initial Seed: %08X", "初始种子：%08X"), initialSeed))
  end

  gui.text(2, 145, string.format(_pokeluaText("Loaded State %s", "已读取即时存档 %s"), stateSlot))
 end
end

local prevStateKey = {}

function getSaveStateInput()
 local Fbuttons = {"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10"}
 local key = input.get()

 for slotNumber = 1, table.getn(Fbuttons) do
  if (key[Fbuttons[slotNumber]] and not prevStateKey[Fbuttons[slotNumber]]) then
   local statesFileName = string.format("states/%s_%s_states_values.txt", gameVersion, string.gsub(gameLanguage, "/", "_"))

   if (key["shift"]) then  -- Check if a save state is being created
    writeSaveStateValues(statesFileName, slotNumber)
   else  -- Loading a state
    setSaveStateValues(statesFileName, slotNumber)
   end

   break
  end
 end

 prevStateKey = key
end

function main()
 if not wrongGameVersion then
  getSaveStateInput()
  setBackgroundBoxes()
  setDateTime()
  getTabInput()
  showRngInfo()
  local pidAddr = read32Bit(pidPointerAddr)

  if mode[index] ~= _pokeluaText("None", "无") then
   getRngInfoInput()

   if mode[index] ~= _pokeluaText("Pokemon Info", "宝可梦信息") then
    showTrainerIDs()
   end
  end

  if mode[index] == _pokeluaText("Capture", "捕获") then
   local enemyAddr = pidAddr + 0x5C048 + koreanOffset
   showInfo(enemyAddr + (0xEC * getSlotInput()))
   showEncounterMissingSteps(pidAddr)
  elseif mode[index] == _pokeluaText("Breeding", "培育") then
   showPartyEggInfo(pidAddr)
  elseif mode[index] == _pokeluaText("Roamer", "游走宝可梦") then
   local roamerAddr = pidAddr + 0x138A4
   showRoamerInfo(roamerAddr + (0x14 * getRoamerSlotInput()))
  elseif mode[index] == _pokeluaText("Pokemon Info", "宝可梦信息") then
   getInfoInput()
   showPokemonInfo(pidAddr)
  end
 end
end

gui.register(main)