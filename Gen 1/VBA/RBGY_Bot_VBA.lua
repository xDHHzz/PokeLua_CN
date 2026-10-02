-- Optional display language: "en" or "zh-Hans". Reload after changing.
-- 可选显示语言：英文 "en"／简体中文 "zh-Hans"。修改后重新加载脚本。
local POKELUA_LANGUAGE = "en"
local function _pokeluaText(english, chinese)
 if POKELUA_LANGUAGE == "zh-Hans" then return chinese end
 return english
end
-- END POKELUA LOCALIZATION

read16Bit = memory.readwordunsigned
read8Bit = memory.readbyte
rshift = bit.rshift
band = bit.band

local speciesNamesList = {
 _pokeluaText("Rhydon", "钻角犀兽"), _pokeluaText("Kangaskhan", "袋兽"), _pokeluaText("Nidoran♂", "尼多朗"), _pokeluaText("Clefairy", "皮皮"), _pokeluaText("Spearow", "烈雀"), _pokeluaText("Voltorb", "霹雳电球"), _pokeluaText("Nidoking", "尼多王"), _pokeluaText("Slowbro", "呆壳兽"),
 _pokeluaText("Ivysaur", "妙蛙草"), _pokeluaText("Exeggutor", "椰蛋树"), _pokeluaText("Lickitung", "大舌头"), _pokeluaText("Exeggcute", "蛋蛋"), _pokeluaText("Grimer", "臭泥"), _pokeluaText("Gengar", "耿鬼"), _pokeluaText("Nidoran♀", "尼多兰"), _pokeluaText("Nidoqueen", "尼多后"),
 _pokeluaText("Cubone", "卡拉卡拉"), _pokeluaText("Rhyhorn", "独角犀牛"), _pokeluaText("Lapras", "拉普拉斯"), _pokeluaText("Arcanine", "风速狗"), _pokeluaText("Mew", "梦幻"), _pokeluaText("Gyarados", "暴鲤龙"), _pokeluaText("Shellder", "大舌贝"), _pokeluaText("Tentacool", "玛瑙水母"), _pokeluaText("Gastly", "鬼斯"),
 _pokeluaText("Scyther", "飞天螳螂"), _pokeluaText("Staryu", "海星星"), _pokeluaText("Blastoise", "水箭龟"), _pokeluaText("Pinsir", "凯罗斯"), _pokeluaText("Tangela", "蔓藤怪"), "MissingNo.", "MissingNo.", _pokeluaText("Growlithe", "卡蒂狗"),
 _pokeluaText("Onix", "大岩蛇"), _pokeluaText("Fearow", "大嘴雀"), _pokeluaText("Pidgey", "波波"), _pokeluaText("Slowpoke", "呆呆兽"), _pokeluaText("Kadabra", "勇基拉"), _pokeluaText("Graveler", "隆隆石"), _pokeluaText("Chansey", "吉利蛋"), _pokeluaText("Machoke", "豪力"), _pokeluaText("Mr. Mime", "魔墙人偶"),
 _pokeluaText("Hitmonlee", "飞腿郎"), _pokeluaText("Hitmonchan", "快拳郎"), _pokeluaText("Arbok", "阿柏怪"), _pokeluaText("Parasect", "派拉斯特"), _pokeluaText("Psyduck", "可达鸭"), _pokeluaText("Drowzee", "催眠貘"), _pokeluaText("Golem", "隆隆岩"), "MissingNo.",
 _pokeluaText("Magmar", "鸭嘴火兽"), "MissingNo.", _pokeluaText("Electabuzz", "电击兽"), _pokeluaText("Magneton", "三合一磁怪"), _pokeluaText("Koffing", "瓦斯弹"), "MissingNo.", _pokeluaText("Mankey", "猴怪"), _pokeluaText("Seel", "小海狮"),
 _pokeluaText("Diglett", "地鼠"), _pokeluaText("Tauros", "肯泰罗"), "MissingNo.", "MissingNo.", "MissingNo.", _pokeluaText("Farfetch'd", "大葱鸭"), _pokeluaText("Venonat", "毛球"),
 _pokeluaText("Dragonite", "快龙"), "MissingNo.", "MissingNo.", "MissingNo.", _pokeluaText("Doduo", "嘟嘟"), _pokeluaText("Poliwag", "蚊香蝌蚪"), _pokeluaText("Jynx", "迷唇姐"), _pokeluaText("Moltres", "火焰鸟"),
 _pokeluaText("Articuno", "急冻鸟"), _pokeluaText("Zapdos", "闪电鸟"), _pokeluaText("Ditto", "百变怪"), _pokeluaText("Meowth", "喵喵"), _pokeluaText("Krabby", "大钳蟹"), "MissingNo.", "MissingNo.", "MissingNo.",
 _pokeluaText("Vulpix", "六尾"), _pokeluaText("Ninetales", "九尾"), _pokeluaText("Pikachu", "皮卡丘"), _pokeluaText("Raichu", "雷丘"), "MissingNo.", "MissingNo.", _pokeluaText("Dratini", "迷你龙"), _pokeluaText("Dragonair", "哈克龙"),
 _pokeluaText("Kabuto", "化石盔"), _pokeluaText("Kabutops", "镰刀盔"), _pokeluaText("Horsea", "墨海马"), _pokeluaText("Seadra", "海刺龙"), "MissingNo.", "MissingNo.", _pokeluaText("Sandshrew", "穿山鼠"), _pokeluaText("Sandslash", "穿山王"),
 _pokeluaText("Omanyte", "菊石兽"), _pokeluaText("Omastar", "多刺菊石兽"), _pokeluaText("Jigglypuff", "胖丁"), _pokeluaText("Wigglytuff", "胖可丁"), _pokeluaText("Eevee", "伊布"), _pokeluaText("Flareon", "火伊布"), _pokeluaText("Jolteon", "雷伊布"), _pokeluaText("Vaporeon", "水伊布"),
 _pokeluaText("Machop", "腕力"), _pokeluaText("Zubat", "超音蝠"), _pokeluaText("Ekans", "阿柏蛇"), _pokeluaText("Paras", "派拉斯"), _pokeluaText("Poliwhirl", "蚊香君"), _pokeluaText("Poliwrath", "蚊香泳士"), _pokeluaText("Weedle", "独角虫"), _pokeluaText("Kakuna", "铁壳蛹"), _pokeluaText("Beedrill", "大针蜂"),
 "MissingNo.", _pokeluaText("Dodrio", "嘟嘟利"), _pokeluaText("Primeape", "火暴猴"), _pokeluaText("Dugtrio", "三地鼠"), _pokeluaText("Venomoth", "摩鲁蛾"), _pokeluaText("Dewgong", "白海狮"), "MissingNo.", "MissingNo.",
 _pokeluaText("Caterpie", "绿毛虫"), _pokeluaText("Metapod", "铁甲蛹"), _pokeluaText("Butterfree", "巴大蝶"), _pokeluaText("Machamp", "怪力"), "MissingNo.", _pokeluaText("Golduck", "哥达鸭"), _pokeluaText("Hypno", "引梦貘人"), _pokeluaText("Golbat", "大嘴蝠"),
 _pokeluaText("Mewtwo", "超梦"), _pokeluaText("Snorlax", "卡比兽"), _pokeluaText("Magikarp", "鲤鱼王"), "MissingNo.", "MissingNo.", _pokeluaText("Muk", "臭臭泥"), "MissingNo.", _pokeluaText("Kingler", "巨钳蟹"),
 _pokeluaText("Cloyster", "刺甲贝"), "MissingNo.", _pokeluaText("Electrode", "顽皮雷弹"), _pokeluaText("Clefable", "皮可西"), _pokeluaText("Weezing", "双弹瓦斯"), _pokeluaText("Persian", "猫老大"), _pokeluaText("Marowak", "嘎啦嘎啦"), "MissingNo.",
 _pokeluaText("Haunter", "鬼斯通"), _pokeluaText("Abra", "凯西"), _pokeluaText("Alakazam", "胡地"), _pokeluaText("Pidgeotto", "比比鸟"), _pokeluaText("Pidgeot", "大比鸟"), _pokeluaText("Starmie", "宝石海星"), _pokeluaText("Bulbasaur", "妙蛙种子"), _pokeluaText("Venusaur", "妙蛙花"),
 _pokeluaText("Tentacruel", "毒刺水母"), "MissingNo.", _pokeluaText("Goldeen", "角金鱼"), _pokeluaText("Seaking", "金鱼王"), "MissingNo.", "MissingNo.", "MissingNo.",
 "MissingNo.", _pokeluaText("Ponyta", "小火马"), _pokeluaText("Rapidash", "烈焰马"), _pokeluaText("Rattata", "小拉达"), _pokeluaText("Raticate", "拉达"), _pokeluaText("Nidorino", "尼多力诺"), _pokeluaText("Nidorina", "尼多娜"), _pokeluaText("Geodude", "小拳石"),
 _pokeluaText("Porygon", "多边兽"), _pokeluaText("Aerodactyl", "化石翼龙"), "MissingNo.", _pokeluaText("Magnemite", "小磁怪"), "MissingNo.", "MissingNo.", _pokeluaText("Charmander", "小火龙"),
 _pokeluaText("Squirtle", "杰尼龟"), _pokeluaText("Charmeleon", "火恐龙"), _pokeluaText("Wartortle", "卡咪龟"), _pokeluaText("Charizard", "喷火龙"), "MissingNo.", "MissingNo.", "MissingNo.",
 "MissingNo.", _pokeluaText("Oddish", "走路草"), _pokeluaText("Gloom", "臭臭花"), _pokeluaText("Vileplume", "霸王花"), _pokeluaText("Bellsprout", "喇叭芽"), _pokeluaText("Weepinbell", "口呆花"), _pokeluaText("Victreebel", "大食花")}

local natureNamesList = {
 _pokeluaText("Hardy", "勤奋"), _pokeluaText("Lonely", "怕寂寞"), _pokeluaText("Brave", "勇敢"), _pokeluaText("Adamant", "固执"), _pokeluaText("Naughty", "顽皮"),
 _pokeluaText("Bold", "大胆"), _pokeluaText("Docile", "坦率"), _pokeluaText("Relaxed", "悠闲"), _pokeluaText("Impish", "淘气"), _pokeluaText("Lax", "乐天"),
 _pokeluaText("Timid", "胆小"), _pokeluaText("Hasty", "急躁"), _pokeluaText("Serious", "认真"), _pokeluaText("Jolly", "爽朗"), _pokeluaText("Naive", "天真"),
 _pokeluaText("Modest", "内敛"), _pokeluaText("Mild", "慢吞吞"), _pokeluaText("Quiet", "冷静"), _pokeluaText("Bashful", "害羞"), _pokeluaText("Rash", "马虎"),
 _pokeluaText("Calm", "温和"), _pokeluaText("Gentle", "温顺"), _pokeluaText("Sassy", "自大"), _pokeluaText("Careful", "慎重"), _pokeluaText("Quirky", "浮躁")}

local versionAddr = read16Bit(0x13C)
local version
local languageAddr = read8Bit(0x14E)
local language = ""
local warning

local mode = {_pokeluaText("None", "无"), _pokeluaText("Gift Bot", "礼物机器人"), _pokeluaText("Stationary Bot", "定点机器人"), _pokeluaText("Fishing Bot", "钓鱼机器人"), _pokeluaText("In-Game Trade Bot", "游戏内交换机器人"), _pokeluaText("TID Bot", "TID 机器人"), _pokeluaText("Pokemon Info", "宝可梦信息")}
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
local shinyFound = {false, _pokeluaText("None", "无")}

local botTargetFishingSpecies = 27  -- Input here the fishing bot target species index. You can find it in the link below
                                    -- https://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_index_number_(Generation_I)
local fishedSpeciesAddr
local biteFlagAddr = 0xCD3D

local tidAddr
local TIDFound = false
local botTargetTIDs = {0, 1, 1337, 8453, 8411, 11233, 11111, 22222, 33333}  -- Input here the bot target TIDs

if versionAddr == 0x4C41 then  -- Check game version
 version = _pokeluaText("Crystal", "水晶")
elseif versionAddr == 0x4C42 then
 version = _pokeluaText("Blue", "蓝")
elseif versionAddr == 0x4C47 then
 version = _pokeluaText("Gold", "金")
elseif versionAddr == 0x4552 then
 version = _pokeluaText("Red", "红")
elseif versionAddr == 0x5247 then
 version = _pokeluaText("Green", "绿")
elseif versionAddr == 0x4C53 then
 version = _pokeluaText("Silver", "银")
elseif versionAddr == 0x4559 then
 version = _pokeluaText("Yellow", "黄")
else
 version = _pokeluaText("Unknown", "未知")
end

if languageAddr == 0x04 or languageAddr == 0x91 or languageAddr == 0x9D then  -- Check game language and set addresses
 language = "USA"

 if version == _pokeluaText("Blue", "蓝") or version == _pokeluaText("Red", "红") then
  partyAddr = 0xD16B
  partySlotsCounterAddr = 0xD163
  wildDVsAddr = 0xCFF1
  fishedSpeciesAddr = 0xD059
  tidAddr = 0xD359
 elseif version == _pokeluaText("Yellow", "黄") then
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

 if version == _pokeluaText("Blue", "蓝") or version == _pokeluaText("Red", "红") then
  partyAddr = 0xD170
  partySlotsCounterAddr = 0xD168
  wildDVsAddr = 0xCFF6
  fishedSpeciesAddr = 0xD05E
  tidAddr = 0xD35E
 elseif version == _pokeluaText("Yellow", "黄") then
  partyAddr = 0xD16F
  partySlotsCounterAddr = 0xD167
  wildDVsAddr = 0xCFF5
  fishedSpeciesAddr = 0xD05D
  tidAddr = 0xD35D
 end
end

if version ~= _pokeluaText("Blue", "蓝") and version ~= _pokeluaText("Red", "红") and version ~= _pokeluaText("Green", "绿") and version ~= _pokeluaText("Yellow", "黄") then
 warning = _pokeluaText(" - Wrong game version! Use Blue/Red/Green/Yellow instead", " - 游戏版本错误！ 请改用蓝/红/绿/黄")
else
 warning = ""
end

print(_pokeluaText("Game Version: ", "游戏版本：")..version..warning)
print(_pokeluaText("Language: ", "语言：")..language)
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
 gui.text(1, 1, _pokeluaText("Mode: ", "模式：")..mode[index])
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
 shinyFound = {false, _pokeluaText("None", "无")}
 botOneTime = false

 while not shinyFound[1] do
  savestate.save(botState)
  joypad.set(1, {A = true})
  local frameLimit

  if mode[index] == _pokeluaText("Gift Bot", "礼物机器人") or mode[index] == _pokeluaText("Stationary Bot", "定点机器人") then
   frameLimit = 35
  elseif mode[index] == _pokeluaText("Fishing Bot", "钓鱼机器人")  then
   frameLimit = 55
  elseif mode[index] == _pokeluaText("In-Game Trade Bot", "游戏内交换机器人") then
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

  gui.text(1, 91, _pokeluaText("Shiny Found!", "发现异色！"))
  gui.text(1, 100, string.format(_pokeluaText("Hp: %d", "HP：%d"), hpDV))
  gui.text(1, 109, string.format(_pokeluaText("Atk: %d", "攻击：%d"), atkDV))
  gui.text(1, 118, string.format(_pokeluaText("Def: %d", "防御：%d"), defDV))
  gui.text(1, 127, string.format(_pokeluaText("SpC: %d", "特殊：%d"), spcDV))
  gui.text(1, 136, string.format(_pokeluaText("Spe: %d", "速度：%d"), speDV))

  if not botOneTime then
   print(_pokeluaText("Shiny Found!", "发现异色！"))
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

  gui.text(1, 100, _pokeluaText("TID Found!", "已找到 TID！"))
  gui.text(1, 109, _pokeluaText("TID: ", "TID：")..TID)

  if not botOneTime then
   print(_pokeluaText("TID Found!", "已找到 TID！"))
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
 return isShiny(atkDV, defDV, speDV, spcDV)[1] and _pokeluaText("\tShiny", "\t异色") or ""
end

function showPartyPokemonInfo()
 local partySlotsCounter = read8Bit(partySlotsCounterAddr) - 1

 gui.text(1, 18, _pokeluaText("Party natures:", "同行性格："))

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

 if mode[index] == _pokeluaText("Gift Bot", "礼物机器人") or mode[index] == _pokeluaText("In-Game Trade Bot", "游戏内交换机器人") then
  local partySlotsCounter = read8Bit(partySlotsCounterAddr) - 1
  local lastPartySlotDVsAddr = partyAddr + 0x1B + (partySlotsCounter * 0x2C)
  shinyBot(lastPartySlotDVsAddr)
 elseif mode[index] == _pokeluaText("Stationary Bot", "定点机器人") then
  shinyBot(wildDVsAddr)
 elseif mode[index] == _pokeluaText("Fishing Bot", "钓鱼机器人") then
  fishingBot(wildDVsAddr)
 elseif mode[index] == _pokeluaText("TID Bot", "TID 机器人") then
  TIDBot()
 elseif mode[index] == _pokeluaText("Pokemon Info", "宝可梦信息") then
  showPartyPokemonInfo()
 end

 emu.frameadvance()
end