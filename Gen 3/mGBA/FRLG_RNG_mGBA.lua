local botTargetInitialSeeds = {}  -- 在此文本前的括号中写入你想要的机器人目标初始种子（例如 {0, 0xBAD, 0xDEAD, 0xBEEF, 0xDAD, 0x1EE7, 0xDEAF, 0xB0B, 0xFEE, 0xFADE}）
local botTargetTIDs = {}  -- 在此文本前的括号中写入你想要的机器人目标 TID（例如 {0, 1, 1337, 8453, 8411, 11233, 11111, 22222, 33333, 12345}）

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
 "勤奋", "怕寂寞", "勇敢", "固执", "顽皮",
 "大胆", "坦率", "悠闲", "淘气", "乐天",
 "胆小", "急躁", "认真", "爽朗", "天真",
 "内敛", "慢吞吞", "冷静", "害羞", "马虎",
 "温和", "温顺", "自大", "慎重", "浮躁"}

local HPTypeNamesList = {
 "格斗", "飞行", "毒", "地面",
 "岩石", "虫", "幽灵", "钢",
 "火", "水", "草", "电",
 "超能力", "冰", "龙", "恶"}

local speciesNamesList = {
 -- 第一世代
 "妙蛙种子", "妙蛙草", "妙蛙花", "小火龙", "火恐龙", "喷火龙", "杰尼龟", "卡咪龟", "水箭龟",
 "绿毛虫", "铁甲蛹", "巴大蝶", "独角虫", "铁壳蛹", "大针蜂", "波波", "比比鸟", "大比鸟", "小拉达",
 "拉达", "烈雀", "大嘴雀", "阿柏蛇", "阿柏怪", "皮卡丘", "雷丘", "穿山鼠", "穿山王", "尼多兰",
 "尼多娜", "尼多后", "尼多朗", "尼多力诺", "尼多王", "皮皮", "皮可西", "六尾", "九尾",
 "胖丁", "胖可丁", "超音蝠", "大嘴蝠", "走路草", "臭臭花", "霸王花", "派拉斯", "派拉斯特", "毛球",
 "摩鲁蛾", "地鼠", "三地鼠", "喵喵", "猫老大", "可达鸭", "哥达鸭", "猴怪", "火暴猴", "卡蒂狗",
 "风速狗", "蚊香蝌蚪", "蚊香君", "蚊香泳士", "凯西", "勇基拉", "胡地", "腕力", "豪力", "怪力",
 "喇叭芽", "口呆花", "大食花", "玛瑙水母", "毒刺水母", "小拳石", "隆隆石", "隆隆岩", "小火马",
 "烈焰马", "呆呆兽", "呆壳兽", "小磁怪", "三合一磁怪", "大葱鸭", "嘟嘟", "嘟嘟利", "小海狮", "白海狮",
 "臭泥", "臭臭泥", "大舌贝", "刺甲贝", "鬼斯", "鬼斯通", "耿鬼", "大岩蛇", "催眠貘", "引梦貘人", "大钳蟹",
 "巨钳蟹", "霹雳电球", "顽皮雷弹", "蛋蛋", "椰蛋树", "卡拉卡拉", "嘎啦嘎啦", "飞腿郎", "快拳郎",
 "大舌头", "瓦斯弹", "双弹瓦斯", "独角犀牛", "钻角犀兽", "吉利蛋", "蔓藤怪", "袋兽", "墨海马", "海刺龙",
 "角金鱼", "金鱼王", "海星星", "宝石海星", "魔墙人偶", "飞天螳螂", "迷唇姐", "电击兽", "鸭嘴火兽", "凯罗斯",
 "肯泰罗", "鲤鱼王", "暴鲤龙", "拉普拉斯", "百变怪", "伊布", "水伊布", "雷伊布", "火伊布", "多边兽",
 "菊石兽", "多刺菊石兽", "化石盔", "镰刀盔", "化石翼龙", "卡比兽", "急冻鸟", "闪电鸟", "火焰鸟", "迷你龙",
 "哈克龙", "快龙", "超梦", "梦幻",
 -- 第二世代
 "菊草叶", "月桂叶", "大竺葵", "火球鼠", "火岩鼠", "火暴兽", "小锯鳄", "蓝鳄", "大力鳄",
 "尾立", "大尾立", "咕咕", "猫头夜鹰", "芭瓢虫", "安瓢虫", "圆丝蛛", "阿利多斯", "叉字蝠", "灯笼鱼",
 "电灯怪", "皮丘", "皮宝宝", "宝宝丁", "波克比", "波克基古", "天然雀", "天然鸟", "咩利羊", "茸茸羊", "电龙",
 "美丽花", "玛力露", "玛力露丽", "树才怪", "蚊香蛙皇", "毽子草", "毽子花", "毽子棉", "长尾怪手", "向日种子",
 "向日花怪", "蜻蜻蜓", "乌波", "沼王", "太阳伊布", "月亮伊布", "黑暗鸦", "呆呆王", "梦妖", "未知图腾",
 "果然翁", "麒麟奇", "榛果球", "佛烈托斯", "土龙弟弟", "天蝎", "大钢蛇", "布鲁", "布鲁皇",
 "千针鱼", "巨钳螳螂", "壶壶", "赫拉克罗斯", "狃拉", "熊宝宝", "圈圈熊", "熔岩虫", "熔岩蜗牛", "小山猪",
 "长毛猪", "太阳珊瑚", "铁炮鱼", "章鱼桶", "信使鸟", "巨翅飞鱼", "盔甲鸟", "戴鲁比", "黑鲁加",
 "刺龙王", "小小象", "顿甲", "多边兽Ⅱ", "惊角鹿", "图图犬", "无畏小子", "战舞郎", "迷唇娃", "电击怪",
 "鸭嘴宝宝", "大奶罐", "幸福蛋", "雷公", "炎帝", "水君", "幼基拉斯", "沙基拉斯", "班基拉斯", "洛奇亚", "凤王",
 "时拉比",
 -- 第三世代
 "木守宫", "森林蜥蜴", "蜥蜴王", "火稚鸡", "力壮鸡", "火焰鸡", "水跃鱼", "沼跃鱼", "巨沼怪",
 "土狼犬", "大狼犬", "蛇纹熊", "直冲熊", "刺尾虫", "甲壳茧", "狩猎凤蝶", "盾甲茧", "毒粉蛾", "莲叶童子",
 "莲帽小童", "乐天河童", "橡实果", "长鼻叶", "狡猾天狗", "傲骨燕", "大王燕", "长翅鸥", "大嘴鸥", "拉鲁拉丝",
 "奇鲁莉安", "沙奈朵", "溜溜糖球", "雨翅蛾", "蘑蘑菇", "斗笠菇", "懒人獭", "过动猿", "请假王",
 "土居忍士", "铁面忍者", "脱壳忍者", "咕妞妞", "吼爆弹", "爆音怪", "幕下力士", "铁掌力士", "露力丽", "朝北鼻",
 "向尾喵", "优雅猫", "勾魂眼", "大嘴娃", "可可多拉", "可多拉", "波士可多拉", "玛沙那", "恰雷姆", "落雷兽",
 "雷电兽", "正电拍拍", "负电拍拍", "电萤虫", "甜甜萤", "毒蔷薇", "溶食兽", "吞食兽", "利牙鱼", "巨牙鲨",
 "吼吼鲸", "吼鲸王", "呆火驼", "喷火驼", "煤炭龟", "跳跳猪", "噗噗猪", "晃晃斑", "大颚蚁", "超音波幼虫",
 "沙漠蜻蜓", "刺球仙人掌", "梦歌仙人掌", "青绵鸟", "七夕青鸟", "猫鼬斩", "饭匙蛇", "月石", "太阳岩", "泥泥鳅",
 "鲶鱼王", "龙虾小兵", "铁螯龙虾", "天秤偶", "念力土偶", "触手百合", "摇篮百合", "太古羽虫", "太古盔甲", "丑丑鱼",
 "美纳斯", "飘浮泡泡", "变隐龙", "怨影娃娃", "诅咒娃娃", "夜巡灵", "彷徨夜灵", "热带龙", "风铃铃", "阿勃梭鲁",
 "小果然", "雪童子", "冰鬼护", "海豹球", "海魔狮", "帝牙海狮", "珍珠贝", "猎斑鱼", "樱花鱼", "古空棘鱼",
 "爱心鱼", "宝贝龙", "甲壳龙", "暴飞龙", "铁哑铃", "金属怪", "巨金怪", "雷吉洛克", "雷吉艾斯", "雷吉斯奇鲁",
 "拉帝亚斯", "拉帝欧斯",  "盖欧卡", "固拉多", "烈空坐", "基拉祈", "代欧奇希斯"}

local abilityNamesList = {
 "恶臭", "降雨", "加速", "战斗盔甲", "结实", "湿气", "柔软", "沙隐", "静电",
 "蓄电", "储水", "迟钝", "无关天气", "复眼", "不眠", "变色", "免疫",
 "引火", "鳞粉", "我行我素", "吸盘", "威吓", "踩影", "粗糙皮肤", "神奇守护",
 "飘浮", "孢子", "同步", "恒净之躯", "自然回复", "避雷针", "天恩",
 "悠游自如", "叶绿素", "发光", "复制", "大力士", "毒刺", "精神力", "熔岩铠甲",
 "水幕", "磁力", "隔音", "雨盘", "扬沙", "压迫感", "厚脂肪", "早起",
 "火焰之躯", "逃跑", "锐利目光", "怪力钳", "捡拾", "懒惰", "活力", "迷人之躯", "正电", "负电",
 "阴晴不定", "黏着", "蜕皮", "毅力", "神奇鳞片", "污泥浆", "茂盛", "猛火", "激流",
 "虫之预感", "坚硬脑袋", "日照", "沙穴", "干劲", "白色烟雾", "瑜伽之力", "硬壳盔甲",
 "杂音", "气闸"}

local moveNamesList = {
 "--" , "拍击", "空手劈", "连环巴掌", "连续拳", "百万吨重拳", "聚宝功", "火焰拳", "冰冻拳",
 "雷电拳", "抓", "夹住", "断头钳", "旋风刀", "剑舞", "居合斩", "起风", "翅膀攻击",
 "吹飞", "飞翔", "绑紧", "摔打", "藤鞭", "踩踏", "二连踢", "百万吨重踢", "飞踢", "回旋踢",
 "泼沙", "头锤", "角撞", "乱击", "角钻", "撞击", "泰山压顶", "紧束", "猛撞",
 "大闹一番", "舍身冲撞", "摇尾巴", "毒针", "双针", "飞弹针", "瞪眼", "咬住", "叫声", "吼叫",
 "唱歌", "超音波", "音爆", "定身法", "溶解液", "火花", "喷射火焰", "白雾", "水枪", "水炮",
 "冲浪", "冰冻光束", "暴风雪", "幻象光线", "泡沫光线", "极光束", "破坏光线", "啄", "啄钻",
 "地狱翻滚", "踢倒", "双倍奉还", "地球上投", "怪力", "吸取", "超级吸取", "寄生种子", "生长",
 "飞叶快刀", "日光束", "毒粉", "麻痹粉", "催眠粉", "花瓣舞", "吐丝",
 "龙之怒", "火焰旋涡", "电击", "十万伏特", "电磁波", "打雷", "落石", "地震",
 "地裂", "挖洞", "剧毒", "念力", "精神强念", "催眠术", "瑜伽姿势", "高速移动", "电光一闪", "愤怒",
 "瞬间移动", "黑夜魔影", "模仿", "刺耳声", "影子分身", "自我再生", "变硬", "变小", "烟幕",
 "奇异之光", "缩入壳中", "变圆", "屏障", "光墙", "黑雾", "反射壁", "聚气", "忍耐",
 "挥指", "鹦鹉学舌", "自爆", "炸蛋", "舌舔", "浊雾", "污泥攻击", "骨棒", "大字爆炎",
 "攀瀑", "贝壳夹击", "高速星星", "火箭头锤", "尖刺加农炮", "缠绕", "瞬间失忆", "折弯汤匙", "生蛋",
 "飞膝踢", "大蛇瞪眼", "食梦", "毒瓦斯", "投球", "吸血", "恶魔之吻", "神鸟猛击",
 "变身", "泡沫", "迷昏拳", "蘑菇孢子", "闪光", "精神波", "跃起", "溶化", "蟹钳锤",
 "大爆炸", "乱抓", "骨头回力镖", "睡觉", "岩崩", "必杀门牙", "棱角化", "纹理", "三重攻击",
 "愤怒门牙", "劈开", "替身", "挣扎", "写生", "三连踢", "小偷", "蛛网", "心之眼",
 "恶梦", "火焰轮", "打鼾", "诅咒", "抓狂", "纹理２", "气旋攻击", "棉孢子", "起死回生",
 "怨恨", "细雪", "守住", "音速拳", "鬼面", "出奇一击", "天使之吻", "腹鼓",
 "污泥炸弹", "掷泥", "章鱼桶炮", "撒菱", "电磁炮", "识破", "同命", "灭亡之歌",
 "冰冻之风", "看穿", "骨棒乱打", "锁定", "逆鳞", "沙暴", "终极吸取", "挺住", "撒娇", "滚动",
 "点到为止", "虚张声势", "喝牛奶", "电光", "连斩", "钢翼", "黑色目光", "迷人", "梦话",
 "治愈铃声", "报恩", "礼物", "迁怒", "神秘守护", "分担痛楚", "神圣之火", "震级",
 "爆裂拳", "超级角击", "龙息", "接棒", "再来一次", "追打", "高速旋转", "甜甜香气",
 "铁尾", "金属爪", "借力摔", "晨光", "光合作用", "月光", "觉醒力量", "十字劈",
 "龙卷风", "求雨", "大晴天", "咬碎", "镜面反射", "自我暗示", "神速", "原始之力",
 "暗影球", "预知未来", "碎岩", "潮旋", "围攻", "击掌奇袭", "吵闹", "蓄力", "喷出",
 "吞下", "热风", "冰雹", "无理取闹", "吹捧", "鬼火", "临别礼物", "硬撑", "真气拳",
 "清醒", "看我嘛", "自然之力", "充电", "挑衅", "帮助", "戏法", "扮演", "祈愿",
 "借助", "扎根", "蛮力", "魔法反射", "回收利用", "报复", "劈瓦", "哈欠", "拍落", "蛮干",
 "喷火", "特性互换", "封印", "焕然一新", "怨念", "抢夺", "秘密之力", "潜水", "猛推", "保护色",
 "萤火", "洁净光芒", "薄霧球", "羽毛舞", "摇晃舞", "火焰踢", "玩泥巴", "冰球",
 "尖刺臂", "偷懒", "巨声", "剧毒牙", "撕裂爪", "爆炸烈焰", "加农水炮", "彗星拳",
 "惊吓", "气象球", "芳香治疗", "假哭", "空气利刃", "过热", "气味侦测", "岩石封锁",
 "银色旋风", "金属音", "草笛", "挠痒", "宇宙力量", "喷水", "信号光束", "暗影拳",
 "神通力", "冲天拳", "流沙地狱", "绝对零度", "浊流", "种子机关枪", "燕返", "冰锥",
 "铁壁", "挡路", "长嚎", "龙爪", "疯狂植物", "健美", "弹跳", "泥巴射击", "毒尾", "渴望",
 "伏特攻击", "魔法叶", "玩水", "冥想", "叶刃", "龙之舞", "岩石爆击", "电击波",
 "水之波动", "破灭之愿", "精神突进"}

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
 "无", "大师球", "高级球", "超级球", "精灵球", "狩猎球", "捕网球", "潜水球", "巢穴球",
 "重复球", "计时球", "豪华球", "纪念球", "伤药", "解毒药", "灼伤药", "解冻药", "解眠药",
 "解麻药", "全复药", "全满药", "厉害伤药", "好伤药", "万灵药", "活力碎片", "活力块",
 "美味之水", "劲爽汽水", "果汁牛奶", "哞哞鲜奶", "元气粉", "元气根", "万能粉", "复活草",
 "ＰＰ单项小补剂", "ＰＰ单项全补剂", "ＰＰ多项小补剂", "ＰＰ多项全补剂", "釜炎仙贝", "蓝色玻璃哨", "黄色玻璃哨", "红色玻璃哨", "黑色玻璃哨",
 "白色玻璃哨", "树果汁", "圣灰", "浅滩海盐", "浅滩贝壳", "红色碎片", "蓝色碎片", "黄色碎片",
 "绿色碎片", "未知", "未知", "未知", "未知", "未知", "未知", "未知", "未知", "未知",
 "未知", "未知", "ＨＰ增强剂", "攻击增强剂", "防御增强剂", "速度增强剂", "特攻增强剂", "神奇糖果", "ＰＰ提升剂", "特防增强剂", "ＰＰ极限提升剂",
 "未知", "能力防守", "要害攻击", "力量强化", "防御强化", "速度强化", "命中强化", "特攻强化", "皮皮玩偶",
 "向尾喵的尾巴", "未知", "白银喷雾", "黄金喷雾", "离洞绳", "除虫喷雾", "未知", "未知", "未知",
 "未知", "未知", "未知", "日之石", "月之石", "火之石", "雷之石", "水之石", "叶之石",
 "未知", "未知", "未知", "未知", "小蘑菇", "大蘑菇", "未知", "珍珠", "大珍珠", "星星沙子",
 "星星碎片", "金珠", "心之鳞片", "未知", "未知", "未知", "未知", "未知", "未知", "未知",
 "未知", "未知", "橙色邮件", "港口邮件", "闪亮邮件", "机械邮件", "木纹邮件", "波涛邮件", "珠宝邮件",
 "影子邮件", "热带邮件", "梦境邮件", "奇迹邮件", "复古邮件", "樱子果", "零余果", "桃桃果",
 "莓莓果", "利木果", "苹野果", "橙橙果", "柿仔果", "木子果", "文柚果", "勿花果",
 "异奇果", "芒芒果", "乐芭果", "芭亚果", "蔓莓果", "墨莓果", "蕉香果", "西梨果",
 "凰梨果", "榴石果", "藻根果", "比巴果", "哈密果", "萄葡果", "茄番果",
 "玉黍果", "岳竹果", "茸丹果", "檬柠果", "刺角果", "椰木果", "瓜西果",
 "金枕果", "靛莓果", "枝荔果", "龙睛果", "沙鳞果", "龙火果", "杏仔果",
 "兰萨果", "星桃果", "谜芝果", "未知", "未知", "未知", "光粉", "白色香草",
 "强制锻炼器", "学习装置", "先制之爪", "安抚之铃", "心灵香草", "讲究头带", "王者之证", "银粉",
 "护符金币", "洁净之符", "心之水滴", "深海之牙", "深海鳞片", "烟雾球", "不变之石", "气势头带",
 "幸运蛋", "焦点镜", "金属膜", "吃剩的东西", "龙之鳞片", "电气球", "柔软沙子", "硬石头",
 "奇迹种子", "黑色眼镜", "黑带", "磁铁", "神秘水滴", "锐利鸟嘴", "毒针", "不融冰",
 "诅咒之符", "弯曲的汤匙", "木炭", "龙之牙", "丝绸围巾", "升级数据", "贝壳之铃", "海潮薰香",
 "悠闲薰香", "吉利拳", "金属粉", "粗骨头", "大葱", "未知", "未知", "未知", "未知",
 "未知", "未知", "未知", "未知", "未知", "未知", "未知", "未知", "未知", "未知", "未知",
 "未知", "未知", "未知", "未知", "未知", "未知", "未知", "未知", "未知", "未知", "未知",
 "未知", "未知", "红色头巾", "蓝色头巾", "粉红头巾", "绿色头巾", "黄色头巾", "音速自行车", "代币盒",
 "探宝器", "破旧钓竿", "好钓竿", "厉害钓竿", "船票", "华丽大赛参加证", "未知", "吼吼鲸喷壶", "得文的物品",
 "集灰袋", "地下钥匙", "越野自行车", "宝可方块盒", "给大吾的信", "无限船票", "朱红色宝珠", "靛蓝色宝珠", "探测器",
 "ＧＯＧＯ护目镜", "陨石", "１号客房的钥匙", "２号客房的钥匙", "４号客房的钥匙", "６号客房的钥匙", "仓库钥匙", "根状化石", "爪子化石",
 "得文侦测镜", "招式学习器01", "招式学习器02", "招式学习器03", "招式学习器04", "招式学习器05", "招式学习器06", "招式学习器07", "招式学习器08", "招式学习器09", "招式学习器10", "招式学习器11", "招式学习器12",
 "招式学习器13", "招式学习器14", "招式学习器15", "招式学习器16", "招式学习器17", "招式学习器18", "招式学习器19", "招式学习器20", "招式学习器21", "招式学习器22", "招式学习器23", "招式学习器24", "招式学习器25",
 "招式学习器26", "招式学习器27", "招式学习器28", "招式学习器29", "招式学习器30", "招式学习器31", "招式学习器32", "招式学习器33", "招式学习器34", "招式学习器35", "招式学习器36", "招式学习器37", "招式学习器38", "招式学习器39",
 "招式学习器40", "招式学习器41", "招式学习器42", "招式学习器43", "招式学习器44", "招式学习器45", "招式学习器46", "招式学习器47", "招式学习器48", "招式学习器49", "招式学习器50", "秘传学习器01", "秘传学习器02", "秘传学习器03",
 "秘传学习器04", "秘传学习器05", "秘传学习器06", "秘传学习器07", "秘传学习器08", "未知", "未知", "大木的包裹", "宝可梦之笛", "秘密钥匙", "兑换券",
 "金假牙", "秘密琥珀", "钥匙卡", "电梯钥匙", "贝壳化石", "甲壳化石", "西尔佛检视镜", "自行车", "城镇地图",
 "对战搜寻器", "声音记录器", "招式学习器盒", "树果袋", "教学电视", "三岛通行船券", "七彩通行船券", "茶", "神秘船票",
 "极光船票", "粉末瓶", "红宝石", "蓝宝石", "熔岩标志", "古航海图"}

local catchRatesList = {
 -- 第一世代
 45, 45, 45, 45, 45, 45, 45, 45, 45, 255, 120, 45, 255, 120, 45, 255, 120, 45, 255, 127, 255, 90, 255,
 90, 190, 75, 255, 90, 235, 120, 45, 235, 120, 45, 150, 25, 190, 75, 170, 50, 255, 90, 255, 120, 45,
 190, 75, 190, 75, 255, 50, 255, 90, 190, 75, 190, 75, 190, 75, 255, 120, 45, 200, 100, 50, 180, 90,
 45, 255, 120, 45, 190, 60, 255, 120, 45, 190, 60, 190, 75, 190, 60, 45, 190, 45, 190, 75, 190, 75,
 190, 60, 190, 90, 45, 45, 190, 75, 225, 60, 190, 60, 90, 45, 190, 75, 45, 45, 45, 190, 60, 120, 60,
 30, 45, 45, 225, 75, 225, 60, 225, 60, 45, 45, 45, 45, 45, 45, 45, 255, 45, 45, 35, 45, 45, 45, 45,
 45, 45, 45, 45, 45, 45, 25, 3, 3, 3, 45, 45, 45, 3, 45,
 -- 第二世代
 45, 45, 45, 45, 45, 45, 45, 45, 45, 255, 90, 255, 90, 255, 90, 255, 90, 90, 190, 75, 190, 150, 170,
 190, 75, 190, 75, 235, 120, 45, 45, 190, 75, 65, 45, 255, 120, 45, 45, 235, 120, 75, 255, 90, 45, 45,
 30, 70, 45, 225, 45, 60, 190, 75, 190, 60, 25, 190, 75, 45, 25, 190, 45, 60, 120, 60, 190, 75, 225,
 75, 60, 190, 75, 45, 25, 25, 120, 45, 45, 120, 60, 45, 45, 45, 75, 45, 45, 45, 45, 45, 30, 3, 3, 3, 45,
 45, 45, 3, 3, 45,
 -- 第三世代
 45, 45, 45, 45, 45, 45, 45, 45, 45, 255, 127, 255, 90, 255, 120, 45, 120, 45, 255, 120, 45, 255, 120,
 45, 200, 45, 190, 45, 235, 120, 45, 200, 75, 255, 90, 255, 120, 45, 255, 120, 45, 190, 120, 45, 180,
 200, 150, 255, 255, 60, 45, 45, 180, 90, 45, 180, 90, 120, 45, 200, 200, 150, 150, 150, 225, 75, 225,
 60, 125, 60, 255, 150, 90, 255, 60, 255, 255, 120, 45, 190, 60, 255, 45, 90, 90, 45, 45, 190, 75, 205,
 155, 255, 90, 45, 45, 45, 45, 255, 60, 45, 200, 225, 45, 190, 90, 200, 45, 30, 125, 190, 75, 255, 120,
 45, 255, 60, 60, 25, 225, 45, 45, 45, 3, 3, 3, 3, 3, 3, 3, 3, 5, 5, 3, 3, 3}

local locationNamesList = {
 "真新镇", "常青市", "深灰市", "华蓝市", "紫苑镇", "枯叶市",
 "玉虹市", "浅红市", "红莲镇", "石英高原外部", "金黄市",
 "金黄市连接通道", "第１岛", "第２岛", "第３岛", "第４岛", "第５岛",
 "第７岛", "第６岛", "1号道路", "2号道路", "3号道路", "4号道路", "5号道路", "6号道路", "7号道路",
 "8号道路", "9号道路", "10号道路", "11号道路", "12号道路", "13号道路", "14号道路", "15号道路", "16号道路",
 "17号道路", "18号道路", "19号道路", "20号道路", "21号道路北部", "21号道路南部", "22号道路", "23号道路",
 "24号道路", "25号道路", "第１岛 热气之路", "第１岛 宝物海滩", "第２岛 边缘海岬",
 "第３岛 索桥", "第３岛 港口", "七岛原型6", "七岛原型7",
 "七岛原型8", "七岛原型9", "豪华度假区",
 "水之迷宫", "第５岛空地", "回忆之塔",
 "第６岛 外岛", "第６岛 绿之步道", "第６岛 水之步道", "第６岛 遗迹山谷",
 "第７岛 训练家塔", "第７岛 七宝溪谷入口", "第７岛 七宝溪谷",
 "第７岛 阿斯卡纳遗迹"}

local statusConditionNamesList = {"无", "睡眠", "中毒", "灼伤", "冰冻", "麻痹", "中毒"}

local pokemonStatsScreen2Addr, pokemonStatsScreenAddr, pokemonBattleStatsScreenAddr, speciesDexIndexAddr, wildTypeAddr, partySlotsCounterAddr,
      enemyAddr, partyAddr, safariCatchFactorPointerAddr, playerWalkRunStateAddr, wildEncounterDataAddr, boxSelectedSlotIndexAddr, eggLowPIDPointerAddr,
      safariZoneStepsCounterAddr, selectedItemAddr, partySelectedSlotIndexAddr, roamerMapGroupAndNumAddr, battleTurnsCounterAddr, currentSeedAddr,
      saveBlock1PointerAddr, saveBlock2PointerAddr, currBoxIndexPointerAddr

local GameInfo, CaptureInfo, RoamerInfo, BreedingInfo, PandoraInfo, InitialSeedBotInfo, PokemonInfo

function initializeBuffers()
 GameInfo = console:createBuffer("游戏信息")
 GameInfo:setSize(100, 100)
 CaptureInfo = console:createBuffer("捕获")
 CaptureInfo:setSize(100, 100)
 BreedingInfo = console:createBuffer("培育")
 BreedingInfo:setSize(100, 100)
 RoamerInfo = console:createBuffer("游走宝可梦")
 RoamerInfo:setSize(100, 100)
 PandoraInfo = console:createBuffer("潘多拉")
 PandoraInfo:setSize(100, 100)
 InitialSeedBotInfo = console:createBuffer("初始种子机器人")
 InitialSeedBotInfo:setSize(100, 100)
 TIDBotInfo = console:createBuffer("TID 机器人")
 TIDBotInfo:setSize(100, 100)
 PokemonInfo = console:createBuffer("宝可梦信息")
 PokemonInfo:setSize(100, 100)
end

local gameVersion, gameLanguage = "", ""
local wrongGameVersion

function setGameVersion()
 local gameVersionCode = emu:read8(0x80000AE)
 local gameLanguageCode = emu:read8(0x80000AF)
 local gameRev = emu:read8(0x80000BC) == 0x1

 if gameVersionCode == 0x45 then  -- 检查游戏版本
  gameVersion = "绿宝石"
 elseif gameVersionCode == 0x47 then
  gameVersion = "叶绿"
 elseif gameVersionCode == 0x50 then
  gameVersion = "蓝宝石"
 elseif gameVersionCode == 0x52 then
  gameVersion = "火红"
 elseif gameVersionCode == 0x56 then
  gameVersion = "红宝石"
 end

 if gameLanguageCode == 0x45 then  -- 检查游戏语言并设置地址
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

 if gameVersion == "" then  -- 打印游戏信息
  GameInfo:print("版本：未知游戏")
 elseif gameVersion ~= "火红" and gameVersion ~= "叶绿" then
  GameInfo:print(string.format("版本：%s - 游戏版本错误！请改用火红／叶绿\n", gameVersion))
 elseif gameLanguage == "" then
  GameInfo:print("版本："..gameVersion.."\n".."语言：未知语言\n")
 else
  wrongGameVersion = false
  GameInfo:print("版本："..gameVersion.."\n"..string.format("语言：%s\n", gameLanguage))
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

 if initial == current or tempInitialSeed ~= initial then  -- 初始种子生成检查
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
 buffer:print(string.format("初始种子：%04X\n当前种子：%08X\n推进数：%d\n\n\n", initialSeed, currentSeed, currentAdvances))
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
 buffer:print(string.format("距离野生遭遇的步数：%d\n", encounterMissingSteps))
end

function showStepCounter(buffer)
 local stepCounterAddr = emu:read32(saveBlock1PointerAddr) + 0x309A
 local stepCounter = 255 - emu:read8(stepCounterAddr)
 buffer:print(string.format("步数计数器 (亲密度/蛋周期)：%d\n\n\n", stepCounter))
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
  return shinyTypeValue == 0 and "（方块）" or "（星星）"
 end

 return ""
end

function getOffset(offsetType, orderIndex)
 local offsets = {["成长"] = {0,0,0,0,0,0, 1,1,2,3,2,3, 1,1,2,3,2,3, 1,1,2,3,2,3},
                  ["攻击"] = {1,1,2,3,2,3, 0,0,0,0,0,0, 2,3,1,1,3,2, 2,3,1,1,3,2},
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
 buffer:print(string.format("个体值：%02d/%02d/%02d/%02d/%02d/%02d\n觉醒力量：%s %d\n",
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
 buffer:print(string.format("招式：%sPP：%d\n", strPadding(moveNamesList[move1Index <= 354 and move1Index + 1 or 1], 15), PPmove1))
 buffer:print(string.format("招式：%sPP：%d\n", strPadding(moveNamesList[move2Index <= 354 and move2Index + 1 or 1], 15), PPmove2))
 buffer:print(string.format("招式：%sPP：%d\n", strPadding(moveNamesList[move3Index <= 354 and move3Index + 1 or 1], 15), PPmove3))
 buffer:print(string.format("招式：%sPP：%d\n\n\n", strPadding(moveNamesList[move4Index <= 354 and move4Index + 1 or 1], 15), PPmove4))
end

function showInfo(pidAddr, buffer)
 local pokemonPID = emu:read32(pidAddr)
 local shinyType = shinyCheck(pokemonPID, pidAddr)
 local natureIndex = pokemonPID % 25
 local pokemonIDs = emu:read32(pidAddr + 0x4)
 local orderIndex = (pokemonPID % 24) + 1
 local decryptionKey = pokemonPID ~ pokemonIDs
 local growthOffset = getOffset("成长", orderIndex)
 local attacksOffset = getOffset("攻击", orderIndex)
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

 buffer:print(string.format("种类：%s\n", speciesName ~= nil and speciesName or "--"))
 buffer:print(string.format("PID：%08X%s\n", pokemonPID, shinyType))
 buffer:print(string.format("性格：%s\n", natureNamesList[natureIndex + 1]))
 buffer:print(string.format("特性：%s (%d)\n", abilityName == nil and "--" or abilityName, abilityNumber))
 showIVsAndHP(ivsAndAbilityValue, buffer)
 buffer:print(string.format(isEgg(pidAddr) and "蛋周期：%d\n" or "亲密度：%d\n", friendship))
 buffer:print(string.format("携带道具：%s\n\n", itemName ~= nil and itemName or "--"))
 showMovesAndPP(movesValue1, movesValue2, PPValue, buffer)
end

function showTrainerIDs(buffer)
 local trainerTID, trainerSID = getTrainerIDs()
 buffer:print(string.format("TID：%d\nSID：%d", trainerTID, trainerSID))
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
  buffer:print(string.format("步数计数器：%d\n蛋尚未准备好\n", eggStepsCounter))
 end

 if isEggReady then
  local eggLowPid = emu:read16(eggLowPIDAddr)
  buffer:print(string.format("蛋已生成，去领取吧！\n蛋低位 PID：%04X\n\n\n", eggLowPid))
 elseif eggStepsCounter == 1 then
  buffer:print("下一步可能生成蛋！\n\n\n")
 elseif eggStepsCounter == 0 then
  buffer:print("已走第 255 步\n\n\n")
 else
  buffer:print("继续走动\n\n\n")
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
 local roamerIVsValue = emu:read32(roamerAddr) & 0xFF  -- 游走宝可梦 IV 错误（仅 RS/FRLG）
 local roamerPID = emu:read32(roamerAddr + 0x4)
 local roamerShinyType = shinyCheck(roamerPID)
 local roamerNatureIndex = roamerPID % 25
 local roamerSpeciesIndex = emu:read16(roamerAddr + 0x8)
 local roamerDexIndex = nationalDexList[roamerSpeciesIndex + 1]
 local roamerSpeciesName = speciesNamesList[roamerDexIndex]
 local roamerHP = emu:read16(roamerAddr + 0xA)
 local roamerLevel = emu:read8(roamerAddr + 0xC)
 local roamerStatusIndex = emu:read8(roamerAddr + 0xD)
 local roamerStatus = statusConditionNamesList[1]  -- 无异常状态

 local roamerMapGroupAndNum = emu:read16(roamerMapGroupAndNumAddr)
 local roamerMapIndex = roamerMapGroupAndNum >> 8
 local playerMapGroupAndNumAddr = emu:read32(saveBlock1PointerAddr) + 0x4
 local playerMapGroupAndNum = emu:read16(playerMapGroupAndNumAddr)

 if roamerStatusIndex > 0 and roamerStatusIndex < 0x8 then  -- 睡眠
  roamerStatus = statusConditionNamesList[2]
 elseif roamerStatusIndex == 0x8 then  -- 中毒
  roamerStatus = statusConditionNamesList[3]
 elseif roamerStatusIndex == 0x10 then  -- 灼伤
  roamerStatus = statusConditionNamesList[4]
 elseif roamerStatusIndex == 0x20 then  -- 冰冻
  roamerStatus = statusConditionNamesList[5]
 elseif roamerStatusIndex == 0x40 then  -- 麻痹
  roamerStatus = statusConditionNamesList[6]
 elseif roamerStatusIndex == 0x80 then  -- 剧毒
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
  buffer:print("存在活跃游走宝可梦？ 是\n")
  buffer:print(string.format("种类：%s\n", roamerSpeciesName))
  buffer:print(string.format("PID：%08X%s\n", roamerPID, roamerShinyType))
  buffer:print(string.format("性格：%s\n", natureNamesList[roamerNatureIndex + 1]))
  showIVsAndHP(roamerIVsValue, buffer)
  buffer:print(string.format("等级：%d\n", roamerLevel))
  buffer:print(string.format("HP：%d\n", roamerHP))
  buffer:print(string.format("异常状态：%s\n", roamerStatus))
  buffer:print(string.format("当前位置：%s%s\n\n\n", locationNamesList[roamerMapIndex + 1],
                              roamerMapGroupAndNum == playerMapGroupAndNum and " (!!!)" or ""))
 else
  buffer:print("存在活跃游走宝可梦？ 否\n\n\n")
 end
end

local prevKeyInfo, infoIndex, infoMode = {}, 1, {
      "礼物", "同行", "同行状态", "对战队伍状态", "盒子", "1 楼盒子状态", "2 楼盒子状态", "寄放屋盒子状态"}

function getInfoInput(buffer)
 local key = emu:getKeys()

 if key == 0x120 and prevKeyInfo ~= key then
  infoIndex = infoIndex - 1 < 1 and 8 or infoIndex - 1
 elseif key == 0x110 and prevKeyInfo ~= key then
  infoIndex = infoIndex + 1 > 8 and 1 or infoIndex + 1
 end

 prevKeyInfo = key
 buffer:print(string.format("模式：%s（按 R+右/R+左切换模式）\n\n", strPadding(infoMode[infoIndex], 20)))
end

function showPokemonIDs(addr, buffer)
 local pokemonTID, pokemonSID = getPokemonIDs(addr)
 buffer:print(string.format("TID：%d\nSID：%d", pokemonTID, pokemonSID))
end

function showPokemonInfo(buffer)
 getInfoInput(buffer)

 if infoMode[infoIndex] == "礼物" then
  local partySlotsCounter = emu:read8(partySlotsCounterAddr) - 1
  local lastPartySlotAddr = partyAddr + (partySlotsCounter * 0x64)

  showInfo(lastPartySlotAddr, buffer)
  showPokemonIDs(lastPartySlotAddr, buffer)
 elseif infoMode[infoIndex] == "同行" then
  local partySelectedSlotIndex = emu:read8(partySelectedSlotIndexAddr)
  local partySelectedPokemonAddr = partyAddr + (partySelectedSlotIndex * 0x64)

  showInfo(partySelectedPokemonAddr, buffer)
  showPokemonIDs(partySelectedPokemonAddr, buffer)
 elseif infoMode[infoIndex] == "盒子" then
  local currBoxIndexAddr = emu:read32(currBoxIndexPointerAddr)
  local currBoxIndex = emu:read8(currBoxIndexAddr)
  local boxAddr = currBoxIndexAddr + 0x4
  local boxSelectedSlotIndex = emu:read8(boxSelectedSlotIndexAddr)
  local boxSelectedPokemonAddr = boxAddr + (0x1E * currBoxIndex * 0x50) + (boxSelectedSlotIndex * 0x50)

  showInfo(boxSelectedPokemonAddr, buffer)
  showPokemonIDs(boxSelectedPokemonAddr, buffer)
 elseif infoMode[infoIndex] == "对战队伍状态" then
  showInfo(pokemonBattleStatsScreenAddr, buffer)
  showPokemonIDs(pokemonBattleStatsScreenAddr, buffer)
 elseif infoMode[infoIndex] == "1 楼盒子状态" then
  showInfo(pokemonStatsScreenAddr, buffer)
  showPokemonIDs(pokemonStatsScreenAddr, buffer)
 elseif infoMode[infoIndex] == "同行状态" or infoMode[infoIndex] == "2 楼盒子状态"
        or infoMode[infoIndex] == "寄放屋盒子状态"
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
 PandoraInfo:print(string.format("临时 TID：%d\n\n\n", emu:read16(initialSeedAddr)))
 showTrainerIDs(PandoraInfo)
end

function printInitialSeedBotInstructions()
 InitialSeedBotInfo:clear()
 InitialSeedBotInfo:print("1）编辑此脚本第一行\n")
 InitialSeedBotInfo:print("2）进入继续游戏画面\n")
 InitialSeedBotInfo:print("3）按 Shift + SELECT\n\n\n")
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
 if currentEmuFrame == emu:currentFrame() - 1 then  -- 保存临时状态并在起始帧后一帧按 B
  continueScreen = emu:saveStateBuffer()
  emu:addKey(C.GBA_KEY.B)
 end

 if currentEmuFrame == emu:currentFrame() - 35 then  -- 起始帧后第 35 帧按 A
  emu:addKey(C.GBA_KEY.A)
 end

 if emu:getKey(C.GBA_KEY.A) == 1 and currentEmuFrame == emu:currentFrame() - 36 then  -- 按下 A 键后一帧清除 A 键输入
  emu:clearKey(C.GBA_KEY.A)
 end

 if currentEmuFrame == emu:currentFrame() - 40 then  -- 起始帧后第 40 帧按 A
  emu:addKey(C.GBA_KEY.A)
 end

 if emu:getKey(C.GBA_KEY.A) == 1 and currentEmuFrame == emu:currentFrame() - 41 then  -- 按下 A 键后一帧清除 A 键输入
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
  InitialSeedBotInfo:print(string.format("初始种子：%04X", tempInitialSeed))
 end
end

function updateInitialSeedBotBuffer()
 if not initialSeedBotStartedFlag then
  printInitialSeedBotInstructions()
 end

 if input:isKeyActive(8388658) and emu:getKey(C.GBA_KEY.SELECT) == 1 and not initialSeedBotStartedFlag then  -- 检查是否正在按下 Shift + SELECT
  initialSeedBotStartedFlag = true
  initialSeedFoundFlag = false
  initialSeedWrittenFlag = false
  currentEmuFrame = emu:currentFrame()
 end

 if initialSeedBotStartedFlag then
  initialSeedBotLoop()
 end

 if initialSeedFoundFlag then
  InitialSeedBotInfo:print(string.format("已找到初始种子！\n初始种子：%04X", emu:read16(initialSeedAddr)))
 end
end

function printTIDBotInstructions()
 TIDBotInfo:clear()
 TIDBotInfo:print("1）编辑此脚本第二行\n")
 TIDBotInfo:print("2）进入名字输入画面\n")
 TIDBotInfo:print("3）输入你喜欢的名字\n")
 TIDBotInfo:print("4）将选择光标放在 OK 按钮上\n")
 TIDBotInfo:print("5）按 Shift + START\n\n\n")
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
 if currentEmuFrame == emu:currentFrame() - 1 then  -- 保存临时状态并在起始帧后一帧按 A
  insertionNameState = emu:saveStateBuffer()
  emu:addKey(C.GBA_KEY.A)
 end

 if emu:getKey(C.GBA_KEY.A) == 1 and currentEmuFrame == emu:currentFrame() - 2 then  -- 按下 A 键后一帧清除 A 键输入
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
  TIDBotInfo:print(string.format("TID：%d", tempTID))
 end
end

function updateTIDBotBuffer()
 if not TIDBotStartedFlag then
  printTIDBotInstructions()
 end

 if input:isKeyActive(8388658) and emu:getKey(C.GBA_KEY.START) == 1 and not TIDBotStartedFlag then  -- 检查是否正在按下 Shift + START
  TIDBotStartedFlag = true
  TIDFoundFlag = false
  initialSeedWrittenFlag = false
  currentEmuFrame = emu:currentFrame()
 end

 if TIDBotStartedFlag then
  TIDBotLoop()
 end

 if TIDFoundFlag then
  TIDBotInfo:print(string.format("已找到 TID！\nTID：%d", emu:read16(initialSeedAddr)))
 end
end

function updatePokemonInfoBuffer()
 showRngInfo(PokemonInfo)
 showPokemonInfo(PokemonInfo)
end

function createStateFile(statesFileName, stateSlot)
 os.execute("mkdir states")
 local statesFile = io.open(statesFileName, "w")

 if statesFile then  -- 检查状态文件是否已正确创建
  for slotNumber = 1, 9 do
   if slotNumber == stateSlot then  -- 只写入已保存槽位所在行
    statesFile:write(string.format("%08X %08X %d\n", tempInitialSeed, tempCurrentSeed, advances))
   else  -- 用空数据填充未保存状态的行
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
  if line_num == stateSlot then  -- 仅覆盖已保存槽位所在行
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

 if not statesFileCheck then  -- 检查状态文件是否不存在
  createStateFile(statesFileName, stateSlot)
 else  -- 状态文件已存在
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
   if line_num == stateSlot then  -- 仅从已读取槽位所在行加载值
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

 if input:isKeyActive(49) or input:isKeyActive(33) then  -- 检查是否正在按下 (n)
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
  local savingStateFlag = input:isKeyActive(8388658)  -- 检查是否正在按下 Shift
  local statesFileName = string.format("states/%s_%s_states_values.txt", gameVersion, string.gsub(gameLanguage, "/", "_"))

  if savingStateFlag then  -- 正在保存状态
   emu:saveStateSlot(slotNumber)
   writeSaveStateValues(statesFileName, slotNumber)
  else  -- 正在读取状态
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