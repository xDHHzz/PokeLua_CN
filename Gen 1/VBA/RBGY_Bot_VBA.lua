read16Bit = memory.readwordunsigned
read8Bit = memory.readbyte
rshift = bit.rshift
band = bit.band

local speciesNamesList = {
 "钻角犀兽", "袋兽", "尼多朗", "皮皮", "烈雀", "霹雳电球", "尼多王", "呆壳兽",
 "妙蛙草", "椰蛋树", "大舌头", "蛋蛋", "臭泥", "耿鬼", "尼多兰", "尼多后",
 "卡拉卡拉", "独角犀牛", "拉普拉斯", "风速狗", "梦幻", "暴鲤龙", "大舌贝", "玛瑙水母", "鬼斯",
 "飞天螳螂", "海星星", "水箭龟", "凯罗斯", "蔓藤怪", "MissingNo.", "MissingNo.", "卡蒂狗",
 "大岩蛇", "大嘴雀", "波波", "呆呆兽", "勇基拉", "隆隆石", "吉利蛋", "豪力", "魔墙人偶",
 "飞腿郎", "快拳郎", "阿柏怪", "派拉斯特", "可达鸭", "催眠貘", "隆隆岩", "MissingNo.",
 "鸭嘴火兽", "MissingNo.", "电击兽", "三合一磁怪", "瓦斯弹", "MissingNo.", "猴怪", "小海狮",
 "地鼠", "肯泰罗", "MissingNo.", "MissingNo.", "MissingNo.", "大葱鸭", "毛球",
 "快龙", "MissingNo.", "MissingNo.", "MissingNo.", "嘟嘟", "蚊香蝌蚪", "迷唇姐", "火焰鸟",
 "急冻鸟", "闪电鸟", "百变怪", "喵喵", "大钳蟹", "MissingNo.", "MissingNo.", "MissingNo.",
 "六尾", "九尾", "皮卡丘", "雷丘", "MissingNo.", "MissingNo.", "迷你龙", "哈克龙",
 "化石盔", "镰刀盔", "墨海马", "海刺龙", "MissingNo.", "MissingNo.", "穿山鼠", "穿山王",
 "菊石兽", "多刺菊石兽", "胖丁", "胖可丁", "伊布", "火伊布", "雷伊布", "水伊布",
 "腕力", "超音蝠", "阿柏蛇", "派拉斯", "蚊香君", "蚊香泳士", "独角虫", "铁壳蛹", "大针蜂",
 "MissingNo.", "嘟嘟利", "火暴猴", "三地鼠", "摩鲁蛾", "白海狮", "MissingNo.", "MissingNo.",
 "绿毛虫", "铁甲蛹", "巴大蝶", "怪力", "MissingNo.", "哥达鸭", "引梦貘人", "大嘴蝠",
 "超梦", "卡比兽", "鲤鱼王", "MissingNo.", "MissingNo.", "臭臭泥", "MissingNo.", "巨钳蟹",
 "刺甲贝", "MissingNo.", "顽皮雷弹", "皮可西", "双弹瓦斯", "猫老大", "嘎啦嘎啦", "MissingNo.",
 "鬼斯通", "凯西", "胡地", "比比鸟", "大比鸟", "宝石海星", "妙蛙种子", "妙蛙花",
 "毒刺水母", "MissingNo.", "角金鱼", "金鱼王", "MissingNo.", "MissingNo.", "MissingNo.",
 "MissingNo.", "小火马", "烈焰马", "小拉达", "拉达", "尼多力诺", "尼多娜", "小拳石",
 "多边兽", "化石翼龙", "MissingNo.", "小磁怪", "MissingNo.", "MissingNo.", "小火龙",
 "杰尼龟", "火恐龙", "卡咪龟", "喷火龙", "MissingNo.", "MissingNo.", "MissingNo.",
 "MissingNo.", "走路草", "臭臭花", "霸王花", "喇叭芽", "口呆花", "大食花"}

local natureNamesList = {
 "勤奋", "怕寂寞", "勇敢", "固执", "顽皮",
 "大胆", "坦率", "悠闲", "淘气", "乐天",
 "胆小", "急躁", "认真", "爽朗", "天真",
 "内敛", "慢吞吞", "冷静", "害羞", "马虎",
 "温和", "温顺", "自大", "慎重", "浮躁"}

local versionAddr = read16Bit(0x13C)
local version
local languageAddr = read8Bit(0x14E)
local language = ""
local warning

local mode = {"无", "礼物机器人", "定点机器人", "钓鱼机器人", "游戏内交换机器人", "TID 机器人", "宝可梦信息"}
local index = 1
local prevKey = {}
local showInstructionsText = false
local leftArrowColor
local rightArrowColor

local botState = savestate.create()
local botOneTime = false

local partyAddr
local partySlotsCounterAddr
local wildDVsAddr
local shinyFound = {false, "无"}

local botTargetFishingSpecies = 27  -- 在此输入钓鱼机器人目标种类索引。可在下方链接中找到
                                    -- https://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_index_number_(Generation_I)
local fishedSpeciesAddr
local biteFlagAddr = 0xCD3D

local tidAddr
local TIDFound = false
local botTargetTIDs = {0, 1, 1337, 8453, 8411, 11233, 11111, 22222, 33333}  -- 在此输入机器人目标 TID

if versionAddr == 0x4C41 then  -- 检查游戏版本
 version = "水晶"
elseif versionAddr == 0x4C42 then
 version = "蓝"
elseif versionAddr == 0x4C47 then
 version = "金"
elseif versionAddr == 0x4552 then
 version = "红"
elseif versionAddr == 0x5247 then
 version = "绿"
elseif versionAddr == 0x4C53 then
 version = "银"
elseif versionAddr == 0x4559 then
 version = "黄"
else
 version = "未知"
end

if languageAddr == 0x04 or languageAddr == 0x91 or languageAddr == 0x9D then  -- 检查游戏语言并设置地址
 language = "USA"

 if version == "蓝" or version == "红" then
  partyAddr = 0xD16B
  partySlotsCounterAddr = 0xD163
  wildDVsAddr = 0xCFF1
  fishedSpeciesAddr = 0xD059
  tidAddr = 0xD359
 elseif version == "黄" then
  partyAddr = 0xD16A
  partySlotsCounterAddr = 0xD162
  wildDVsAddr = 0xCFF0
  fishedSpeciesAddr = 0xD058
  tidAddr = 0xD358
 end
elseif languageAddr == 0xB8 or languageAddr == 0xD9 or languageAddr == 0xDC or languageAddr == 0xF5 then
 language = "JPN"
 partyAddr = 0xD12B
 partySlotsCounterAddr = 0xD123
 wildDVsAddr = 0xCFD8
 fishedSpeciesAddr = 0xD036
 tidAddr = 0xD2D8
else
 language = "EUR"

 if version == "蓝" or version == "红" then
  partyAddr = 0xD170
  partySlotsCounterAddr = 0xD168
  wildDVsAddr = 0xCFF6
  fishedSpeciesAddr = 0xD05E
  tidAddr = 0xD35E
 elseif version == "黄" then
  partyAddr = 0xD16F
  partySlotsCounterAddr = 0xD167
  wildDVsAddr = 0xCFF5
  fishedSpeciesAddr = 0xD05D
  tidAddr = 0xD35D
 end
end

if version ~= "蓝" and version ~= "红" and version ~= "绿" and version ~= "黄" then
 warning = " - 游戏版本错误！ 请改用蓝/红/绿/黄"
else
 warning = ""
end

print("游戏版本："..version..warning)
print("语言："..language)
print()

function getInput()
 leftArrowColor = "gray"
 rightArrowColor = "gray"

 local key = input.get()

 if (key["1"] or key["numpad1"]) and (not prevKey["1"] and not prevKey["numpad1"]) then
  leftArrowColor = "orange"
  index = index - 1 < 1 and 7 or index - 1
 elseif (key["2"] or key["numpad2"]) and (not prevKey["2"] and not prevKey["numpad2"]) then
  rightArrowColor = "orange"
  index = index + 1 > 7 and 1 or index + 1
 end

 prevKey = key
 gui.text(1, 1, "模式："..mode[index])
 drawArrowLeft(100, 1, leftArrowColor)
 gui.text(110, 1, "1 - 2")
 drawArrowRight(138, 1, rightArrowColor)
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

function getDVs(DVsAddr)
 local atkDefDVs = read8Bit(DVsAddr)
 local speSpcDVs = read8Bit(DVsAddr + 0x1)
 local atkDV = rshift(atkDefDVs, 4)
 local defDV = band(atkDefDVs, 0xF)
 local speDV = rshift(speSpcDVs, 4)
 local spcDV = band(speSpcDVs, 0xF)

 return atkDV, defDV, speDV, spcDV
end

function isShiny(atkDV, defDV, speDV, spcDV)
 return {defDV == 0xA and speDV == 0xA and spcDV == 0xA and
        (atkDV == 0x2 or atkDV == 0x3 or atkDV == 0x6 or atkDV == 0x7 or
         atkDV == 0xA or atkDV == 0xB or atkDV == 0xE or atkDV == 0xF), mode[index]}
end

function shinyBotLoop(pokemonDVsAddr)
 shinyFound = {false, "无"}
 botOneTime = false

 while not shinyFound[1] do
  savestate.save(botState)
  joypad.set(1, {A = true})
  local frameLimit

  if mode[index] == "礼物机器人" or mode[index] == "定点机器人" then
   frameLimit = 35
  elseif mode[index] == "钓鱼机器人"  then
   frameLimit = 55
  elseif mode[index] == "游戏内交换机器人" then
   frameLimit = 2560
  end

  local atkDefDVs = read8Bit(pokemonDVsAddr)
  local speSpcDVs = read8Bit(pokemonDVsAddr + 1)
  local previousAtkDefDVs = atkDefDVs
  local previousSpeSpcDVs = speSpcDVs

  local i = 0
  while atkDefDVs == previousAtkDefDVs and speSpcDVs == previousSpeSpcDVs and i < frameLimit do
   atkDefDVs = read8Bit(pokemonDVsAddr)
   speSpcDVs = read8Bit(pokemonDVsAddr + 1)
   emu.frameadvance()
   i = i + 1
  end

  if atkDefDVs ~= previousAtkDefDVs or speSpcDVs ~= previousSpeSpcDVs then
   local atkDV, defDV, speDV, spcDV = getDVs(pokemonDVsAddr)
   --print(atkDV.." "..defDV.." "..speDV.." "..spcDV)
   shinyFound = isShiny(atkDV, defDV, speDV, spcDV)
  end

  if not shinyFound[1] then
   savestate.load(botState)
   emu.frameadvance()
  end
 end
end

function showFoundShiny(pokemonDVsAddr)
 if shinyFound[1] and shinyFound[2] == mode[index] then
  local atkDV, defDV, speDV, spcDV = getDVs(pokemonDVsAddr)
  local hpDV = ((atkDV % 2) * 8) + ((defDV % 2) * 4) + ((speDV % 2) * 2) + (spcDV % 2)

  gui.text(1, 91, "发现异色！")
  gui.text(1, 100, string.format("HP：%d", hpDV))
  gui.text(1, 109, string.format("攻击：%d", atkDV))
  gui.text(1, 118, string.format("防御：%d", defDV))
  gui.text(1, 127, string.format("特殊：%d", spcDV))
  gui.text(1, 136, string.format("速度：%d", speDV))

  if not botOneTime then
   print("发现异色！")
   emu.pause()
   botOneTime = true
  end
 end
end

function shinyBot(pokemonDVsAddr)
 local key = joypad.get(1)

 if key.select then
  shinyBotLoop(pokemonDVsAddr)
 end

 showFoundShiny(pokemonDVsAddr)
end

function fishingBotBiteLoop()
 local biteFlag = false

 while not biteFlag do
  savestate.save(botState)
  joypad.set(1, {A = true})

  local i = 0
  while not biteFlag and i < 110 do
   biteFlag = read8Bit(biteFlagAddr) == 0x1
   emu.frameadvance()
   i = i + 1
  end

  if not biteFlag then
   savestate.load(botState)
   emu.frameadvance()
  end
 end
end

function fishingBotLoop()
 local targetFishedSpeciesCheck = read8Bit(fishedSpeciesAddr) == botTargetFishingSpecies

 while not targetFishedSpeciesCheck do
  fishingBotBiteLoop()
  targetFishedSpeciesCheck = read8Bit(fishedSpeciesAddr) == botTargetFishingSpecies

  if not targetFishedSpeciesCheck then
   savestate.load(botState)
   emu.frameadvance()
  end
 end

 for i = 1, 240 do
  emu.frameadvance()
 end

 shinyBotLoop(wildDVsAddr)
end

function fishingBot(pokemonDVsAddr)
 local key = joypad.get(1)

 if key.select then
  fishingBotLoop()
 end

 showFoundShiny(pokemonDVsAddr)
end

function reverseWord(word)
 return band(word, 0xFF) * 0x100 + rshift(word, 8)
end

function isTIDFound()
 local TID = reverseWord(read16Bit(tidAddr))

 for i = 1, table.getn(botTargetTIDs) do
  if TID == botTargetTIDs[i] then
   return true
  end
 end

 return false
end

function TIDBotLoop()
 TIDFound = false
 botOneTime = false

 while not TIDFound do
  savestate.save(botState)
  joypad.set(1, {A = true})

  local isTIDSet = read16Bit(tidAddr + 0x4) ~= 0

  local i = 0
  while not isTIDSet and i < 35 do
   isTIDSet = read16Bit(tidAddr + 0x4) ~= 0
   emu.frameadvance()
   i = i + 1
  end

  if isTIDSet then
   --print(reverseWord(read16Bit(tidAddr)))
   TIDFound = isTIDFound()
  end

  if not TIDFound then
   savestate.load(botState)
   emu.frameadvance()
  end
 end
end

function showFoundTID()
 if TIDFound then
  local TID = reverseWord(read16Bit(tidAddr))

  gui.text(1, 100, "已找到 TID！")
  gui.text(1, 109, "TID："..TID)

  if not botOneTime then
   print("已找到 TID！")
   emu.pause()
   botOneTime = true
  end
 end
end

function TIDBot()
 local key = joypad.get(1)

 if key.select then
  TIDBotLoop()
 end

 showFoundTID()
end

function shinyText(atkDV, defDV, speDV, spcDV)
 return isShiny(atkDV, defDV, speDV, spcDV)[1] and "\t异色" or ""
end

function showPartyPokemonInfo()
 local partySlotsCounter = read8Bit(partySlotsCounterAddr) - 1

 gui.text(1, 18, "同行性格：")

 for i = 0, partySlotsCounter do
  local pokemonSpeciesName = speciesNamesList[read8Bit(partyAddr + (i * 0x2C))]
  local pokemonEXPAddr = partyAddr + 0xE + (i * 0x2C)
  local pokemonDVsAddr = partyAddr + 0x1B + (i * 0x2C)
  local atkDV, defDV, speDV, spcDV = getDVs(pokemonDVsAddr)
  local pokemonEXP =  (0x10000 * read8Bit(pokemonEXPAddr)) + (0x100 * read8Bit(pokemonEXPAddr + 0x1)) + read8Bit(pokemonEXPAddr + 0x2)
  local pokemonNatureName = natureNamesList[(pokemonEXP % 25) + 1]

  if pokemonSpeciesName ~= nil then
   gui.text(1, (i + 3) * 9, tostring(i + 1).." "..pokemonSpeciesName.."\t"..pokemonNatureName..shinyText(atkDV, defDV, speDV, spcDV))
  end
 end
end

while warning == "" do
 getInput()

 if mode[index] == "礼物机器人" or mode[index] == "游戏内交换机器人" then
  local partySlotsCounter = read8Bit(partySlotsCounterAddr) - 1
  local lastPartySlotDVsAddr = partyAddr + 0x1B + (partySlotsCounter * 0x2C)
  shinyBot(lastPartySlotDVsAddr)
 elseif mode[index] == "定点机器人" then
  shinyBot(wildDVsAddr)
 elseif mode[index] == "钓鱼机器人" then
  fishingBot(wildDVsAddr)
 elseif mode[index] == "TID 机器人" then
  TIDBot()
 elseif mode[index] == "宝可梦信息" then
  showPartyPokemonInfo()
 end

 emu.frameadvance()
end