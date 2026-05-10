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
 "无", "妙蛙种子", "妙蛙草", "妙蛙花", "小火龙", "火恐龙", "喷火龙", "杰尼龟", "卡咪龟", "水箭龟",
 "绿毛虫", "铁甲蛹", "巴大蝶", "独角虫", "铁壳蛹", "大针蜂", "波波", "比比鸟", "大比鸟", "小拉达", "拉达",
 "烈雀", "大嘴雀", "阿柏蛇", "阿柏怪", "皮卡丘", "雷丘", "穿山鼠", "穿山王", "尼多兰", "尼多娜", "尼多后",
 "尼多朗", "尼多力诺", "尼多王", "皮皮", "皮可西", "六尾", "九尾", "胖丁", "胖可丁", "超音蝠", "大嘴蝠",
 "走路草", "臭臭花", "霸王花", "派拉斯", "派拉斯特", "毛球", "摩鲁蛾", "地鼠", "三地鼠", "喵喵", "猫老大", "可达鸭",
 "哥达鸭", "猴怪", "火暴猴", "卡蒂狗", "风速狗", "蚊香蝌蚪", "蚊香君", "蚊香泳士", "凯西", "勇基拉", "胡地",
 "腕力", "豪力", "怪力", "喇叭芽", "口呆花", "大食花", "玛瑙水母", "毒刺水母", "小拳石", "隆隆石",
 "隆隆岩", "小火马", "烈焰马", "呆呆兽", "呆壳兽", "小磁怪", "三合一磁怪", "大葱鸭", "嘟嘟", "嘟嘟利", "小海狮", "白海狮",
 "臭泥", "臭臭泥", "大舌贝", "刺甲贝", "鬼斯", "鬼斯通", "耿鬼", "大岩蛇", "催眠貘", "引梦貘人", "大钳蟹", "巨钳蟹", "霹雳电球",
 "顽皮雷弹", "蛋蛋", "椰蛋树", "卡拉卡拉", "嘎啦嘎啦", "飞腿郎", "快拳郎", "大舌头", "瓦斯弹", "双弹瓦斯", "独角犀牛",
 "钻角犀兽", "吉利蛋", "蔓藤怪", "袋兽", "墨海马", "海刺龙", "角金鱼", "金鱼王", "海星星", "宝石海星", "魔墙人偶", "飞天螳螂",
 "迷唇姐", "电击兽", "鸭嘴火兽", "凯罗斯", "肯泰罗", "鲤鱼王", "暴鲤龙", "拉普拉斯", "百变怪", "伊布", "水伊布", "雷伊布",
 "火伊布", "多边兽", "菊石兽", "多刺菊石兽", "化石盔", "镰刀盔", "化石翼龙", "卡比兽", "急冻鸟", "闪电鸟", "火焰鸟",
 "迷你龙", "哈克龙", "快龙", "超梦", "梦幻",
 -- 第二世代
 "菊草叶", "月桂叶", "大竺葵", "火球鼠", "火岩鼠", "火暴兽", "小锯鳄", "蓝鳄", "大力鳄", "尾立", "大尾立",
 "咕咕", "猫头夜鹰", "芭瓢虫", "安瓢虫", "圆丝蛛", "阿利多斯", "叉字蝠", "灯笼鱼", "电灯怪", "皮丘", "皮宝宝", "宝宝丁",
 "波克比", "波克基古", "天然雀", "天然鸟", "咩利羊", "茸茸羊", "电龙", "美丽花", "玛力露", "玛力露丽", "树才怪", "蚊香蛙皇",
 "毽子草", "毽子花", "毽子棉", "长尾怪手", "向日种子", "向日花怪", "蜻蜻蜓", "乌波", "沼王", "太阳伊布", "月亮伊布", "黑暗鸦",
 "呆呆王", "梦妖", "未知图腾", "果然翁", "麒麟奇", "榛果球", "佛烈托斯", "土龙弟弟", "天蝎", "大钢蛇", "布鲁",
 "布鲁皇", "千针鱼", "巨钳螳螂", "壶壶", "赫拉克罗斯", "狃拉", "熊宝宝", "圈圈熊", "熔岩虫", "熔岩蜗牛", "小山猪",
 "长毛猪", "太阳珊瑚", "铁炮鱼", "章鱼桶", "信使鸟", "巨翅飞鱼", "盔甲鸟", "戴鲁比", "黑鲁加", "刺龙王", "小小象",
 "顿甲", "多边兽Ⅱ", "惊角鹿", "图图犬", "无畏小子", "战舞郎", "迷唇娃", "电击怪", "鸭嘴宝宝", "大奶罐", "幸福蛋", "雷公",
 "炎帝", "水君", "幼基拉斯", "沙基拉斯", "班基拉斯", "洛奇亚", "凤王", "时拉比",
 -- 第三世代
 "木守宫", "森林蜥蜴", "蜥蜴王", "火稚鸡", "力壮鸡", "火焰鸡", "水跃鱼", "沼跃鱼", "巨沼怪", "土狼犬", "大狼犬",
 "蛇纹熊", "直冲熊", "刺尾虫", "甲壳茧", "狩猎凤蝶", "盾甲茧", "毒粉蛾", "莲叶童子", "莲帽小童", "乐天河童", "橡实果", "长鼻叶",
 "狡猾天狗", "傲骨燕", "大王燕", "长翅鸥", "大嘴鸥", "拉鲁拉丝", "奇鲁莉安", "沙奈朵", "溜溜糖球", "雨翅蛾", "蘑蘑菇", "斗笠菇",
 "懒人獭", "过动猿", "请假王", "土居忍士", "铁面忍者", "脱壳忍者", "咕妞妞", "吼爆弹", "爆音怪", "幕下力士", "铁掌力士", "露力丽",
 "朝北鼻", "向尾喵", "优雅猫", "勾魂眼", "大嘴娃", "可可多拉", "可多拉", "波士可多拉", "玛沙那", "恰雷姆", "落雷兽", "雷电兽",
 "正电拍拍", "负电拍拍", "电萤虫", "甜甜萤", "毒蔷薇", "溶食兽", "吞食兽", "利牙鱼", "巨牙鲨", "吼吼鲸", "吼鲸王", "呆火驼",
 "喷火驼", "煤炭龟", "跳跳猪", "噗噗猪", "晃晃斑", "大颚蚁", "超音波幼虫", "沙漠蜻蜓", "刺球仙人掌", "梦歌仙人掌", "青绵鸟", "七夕青鸟",
 "猫鼬斩", "饭匙蛇", "月石", "太阳岩", "泥泥鳅", "鲶鱼王", "龙虾小兵", "铁螯龙虾", "天秤偶", "念力土偶", "触手百合", "摇篮百合",
 "太古羽虫", "太古盔甲", "丑丑鱼", "美纳斯", "飘浮泡泡", "变隐龙", "怨影娃娃", "诅咒娃娃", "夜巡灵", "彷徨夜灵", "热带龙", "风铃铃",
 "阿勃梭鲁", "小果然", "雪童子", "冰鬼护", "海豹球", "海魔狮", "帝牙海狮", "珍珠贝", "猎斑鱼", "樱花鱼", "古空棘鱼", "爱心鱼", "宝贝龙",
 "甲壳龙", "暴飞龙", "铁哑铃", "金属怪", "巨金怪", "雷吉洛克", "雷吉艾斯", "雷吉斯奇鲁", "拉帝亚斯", "拉帝欧斯", "盖欧卡", "固拉多",
 "烈空坐", "基拉祈", "代欧奇希斯"}

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
 -- 第一世代
 0, 45, 45, 45, 45, 45, 45, 45, 45, 45, 255, 120, 90, 255, 120, 90, 255, 120,
 45, 255, 127, 255, 90, 255, 90, 190, 75, 255, 90, 235, 120, 45, 235, 120,
 45, 150, 25, 190, 75, 170, 50, 255, 90, 255, 120, 45, 190, 75, 190, 120,
 255, 100, 255, 90, 190, 120, 190, 80, 190, 75, 255, 120, 90, 200, 100, 50,
 180, 90, 45, 255, 120, 45, 190, 60, 255, 120, 45, 190, 110, 190, 75, 190,
 110, 80, 190, 90, 190, 75, 190, 75, 190, 60, 190, 90, 45, 45, 190, 80, 225,
 60, 190, 60, 90, 80, 190, 110, 90, 90, 90, 190, 60, 120, 100, 70, 90, 90,
 225, 75, 225, 60, 225, 110, 90, 90, 45, 90, 90, 90, 80, 255, 45, 80, 35, 45,
 45, 45, 45, 45, 45, 45, 45, 45, 45, 70, 25, 25, 25, 45, 45, 45, 3, 45,
 -- 第二世代
 45, 180, 45, 45, 180, 45, 45, 180, 45, 255, 90, 255, 90, 255, 90, 255, 90,
 90, 190, 75, 190, 150, 170, 190, 45, 190, 75, 235, 120, 45, 45, 190, 75, 65,
 45, 255, 120, 45, 45, 235, 120, 75, 255, 90, 45, 45, 30, 70, 90, 225, 45, 60,
 190, 75, 190, 60, 25, 190, 75, 45, 25, 190, 45, 60, 120, 60, 190, 120, 225,
 75, 60, 190, 75, 45, 90, 15, 225, 45, 45, 120, 60, 45, 45, 45, 75, 45, 45, 45,
 45, 45, 30, 15, 15, 15, 45, 45, 10, 3, 3, 45,
 -- 第三世代
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

local partySelectedSlotIndexAddr, boxSelectedPokemonAddr, enemyAddr, boxFlagAddr, currentSeedAddr, boxPointerAddr, pointerAddr, initialSeed, advances

function onScriptStart()
 local gameLang = read8Bit(0x3)

 if gameLang == 0x45 then -- U
  partySelectedSlotIndexAddr = 0x3A1D46
  boxSelectedPokemonAddr = 0x3A95EC
  enemyAddr = 0x473070
  boxFlagAddr = 0x478B1A
  currentSeedAddr = 0x478C90
  boxPointerAddr = 0x47ADB8
  pointerAddr = 0x7EFDCC
 elseif gameLang == 0x4A then -- J
  partySelectedSlotIndexAddr = 0x38E4C6
  boxSelectedPokemonAddr = 0x395CBC
  enemyAddr = 0x45E750
  boxFlagAddr = 0x4641EA
  currentSeedAddr = 0x464360
  boxPointerAddr = 0x466468
  pointerAddr = 0x75E088
 else -- E
  partySelectedSlotIndexAddr = 0x3EF1C6
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

 local shadowID = read8Bit(addr + 0xD5)

 local speciesDexNumber = nationalDexList[((speciesDexIndex > 411 or speciesDexIndex < 1) and 0 or speciesDexIndex) + 1] + 1
 local speciesName = speciesNamesList[speciesDexNumber]
 local natureName = natureNamesList[(pokemonPID % 25) + 1]

 local hpType = (((hpIV & 1) + (2 * (atkIV & 1)) + (4 * (defIV & 1)) + (8 * (spdIV & 1)) + (16 * (spAtkIV & 1))
                + (32 * (spDefIV & 1))) * 15) // 63
 local hpPower = (((((hpIV >> 1) & 1) + (2 * ((atkIV >> 1) & 1)) + (4 * ((defIV >> 1) & 1)) + (8 * ((spdIV >> 1) & 1))
                 + (16 * ((spAtkIV >> 1) & 1)) + (32 * ((spDefIV >> 1) & 1))) * 40) // 63) + 30

 local catchRateValue = calcCatchRate(read16Bit(addr + 0x86), 1, catchRatesList[speciesDexNumber])

 return pokemonPID, OTSID, OTID, speciesName, natureName, hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV, hpType, hpPower, catchRateValue, shadowID
end

function isBoxOpened()
 return read16Bit(boxFlagAddr) == 0x391
end

function shinyCheck(PID, trainerID, trainerSID)
 local lowPID = PID & 0xFFFF
 local highPID = PID >> 16
 local shinyTypeValue = trainerID ~ trainerSID ~ lowPID ~ highPID

 if shinyTypeValue < 8 then
  return shinyTypeValue == 0 and "（方块）   " or "（星星）     "
 end

 return "            "
end

function getFormattedText(pokemonPID, OTSID, OTID, speciesName, natureName, hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV, hpType, hpPower, catchRateValue)
 catchRateValue = catchRateValue or nil

 local speciesText = string.format("种类：%s", speciesName)
 local PIDText = string.format("\nPID：%08X%s", pokemonPID, shinyCheck(pokemonPID, OTID, OTSID))
 local natureText = string.format("\n性格：%s", natureName)
 local ivsText = string.format("\n个体值：%02d/%02d/%02d/%02d/%02d/%02d", hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV)
 local HPText = string.format("\n觉醒力量：%s %02d", HPTypeNamesList[hpType + 1], hpPower)
 local catchRngText = catchRateValue and string.format("\n捕获率值：%d", catchRateValue) or ""

 return speciesText..PIDText..natureText..ivsText..HPText..catchRngText
end

function getPokemonInfoText(pointer, trainerTID, trainerSID)
 local text = ""

local enemyPID, enemyOTID, enemyOTSID, enemySpeciesName, enemyNatureName, enemyHpIV, enemyAtkIV, enemyDefIV, enemySpAtkIV, enemySpDefIV,
      enemySpdIV, enemyHpType, enemyHpPower, enemyCatchRateValue, enemyShadowID

 for i = 0, 5 do
  enemyPID, enemyOTID, enemyOTSID, enemySpeciesName, enemyNatureName, enemyHpIV, enemyAtkIV, enemyDefIV, enemySpAtkIV, enemySpDefIV,
  enemySpdIV, enemyHpType, enemyHpPower, enemyCatchRateValue, enemyShadowID = getPokemonInfo(enemyAddr + (0x138 * i), trainerTID, trainerSID)

  if enemyShadowID ~= 0 then
   break
  end
 end

 text = text.."\n\n对手\n\n"..getFormattedText(enemyPID, enemyOTID, enemyOTSID, enemySpeciesName, enemyNatureName, enemyHpIV, enemyAtkIV, enemyDefIV, enemySpAtkIV, enemySpDefIV,
                               enemySpdIV, enemyHpType, enemyHpPower, enemyCatchRateValue)

 local partyAddr = pointer + 0x7FFE42E8
 local partySelectedSlotIndex = read8Bit(partySelectedSlotIndexAddr)
 local partyPID, partyOTID, partyOTSID, partySpeciesName, partyNatureName, partyHpIV, partyAtkIV, partyDefIV, partySpAtkIV, partySpDefIV,
       partySpdIV, partyHpType, partyHpPower, partyCatchRateValue, partyShadowID = getPokemonInfo(partyAddr + (0x138 *
                                                                    ((partySelectedSlotIndex >= 0 and partySelectedSlotIndex <= 5) and partySelectedSlotIndex or 0)))

 text = text.."\n\n\n同行\n\n"..getFormattedText(partyPID, partyOTID, partyOTSID, partySpeciesName, partyNatureName, partyHpIV, partyAtkIV, partyDefIV, partySpAtkIV, partySpDefIV,
                               partySpdIV, partyHpType, partyHpPower)

 local boxPID, boxOTID, boxOTSID, boxSpeciesName, boxNatureName, boxHpIV, boxAtkIV, boxDefIV, boxSpAtkIV, boxSpDefIV, boxSpdIV, boxHpType,
       boxHpPower, boxCatchRateValue, boxShadowID = getPokemonInfo(isBoxOpened() and boxSelectedPokemonAddr or read32Bit(boxPointerAddr) + 0xBA0)  -- 当前选中的宝可梦或第 1 个盒子的第 1 个槽位

 text = text.."\n\n\n盒子\n\n"..getFormattedText(boxPID, boxOTID, boxOTSID, boxSpeciesName, boxNatureName, boxHpIV, boxAtkIV, boxDefIV, boxSpAtkIV, boxSpDefIV, boxSpdIV, boxHpType, boxHpPower)

 return text
end

function onScriptUpdate()
 local currentSeed = read32Bit(currentSeedAddr)
 advances = advances + LCRNGDistance(tempCurrentSeed, currentSeed)
 local pointer = read32Bit(pointerAddr)
 local trainerTID, trainerSID = 0, 0

 local RNGInfoText = string.format("初始种子：%08X\n当前种子：%08X\n推进数：%d", initialSeed, currentSeed, advances)
 local infoText = ""

 if pointer ~= 0 then
  trainerTID, trainerSID = getTrainerIDs(pointer)
  infoText = getPokemonInfoText(pointer, trainerTID, trainerSID)
 end

 local IDsInfoText = string.format("\n\n\nTID：%05d\nSID：%05d", trainerTID, trainerSID)

 SetScreenText(RNGInfoText..infoText..IDsInfoText)
end

function onScriptCancel()
 SetScreenText("")
end

function onStateLoaded()
end

function onStateSaved()
end