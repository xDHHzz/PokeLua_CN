local targetSeed = 0xD517  -- 在此写入目标种子
local targetHour = 0  -- 在此写入目标小时
local targetMinute = 9  -- 在此写入目标分钟
local targetSecond = 24  -- 在此写入目标秒
local targetSixtiethSecond = 22  -- 在此写入目标六十分之一秒
local savePath = "D:\\Desktop\\mGBA\\battery\\Pokemon - Ruby Version (USA, Europe) (Rev 2).sav"  -- 在此写入红宝石/蓝宝石存档文件路径

local charMap = {
 " ", "À", "Á", "Â", "Ç", "È", "É", "Ê", "Ë", "Ì", "こ", "Î", "Ï", "Ò", "Ó", "Ô",
 "Œ", "Ù", "Ú", "Û", "Ñ", "ß", "à", "á", "ね", "ç", "è", "é", "ê", "ë", "ì", "ま",
 "î", "ï", "ò", "ó", "ô", "œ", "ù", "ú", "û", "ñ", "º", "ª", "�", "&", "+", "あ",
 "ぃ", "ぅ", "ぇ", "ぉ", "v", "=", "ょ", "が", "ぎ", "ぐ", "げ", "ご", "ざ", "じ", "ず", "ぜ",
 "ぞ", "だ", "ぢ", "づ", "で", "ど", "ば", "び", "ぶ", "べ", "ぼ", "ぱ", "ぴ", "ぷ", "ぺ", "ぽ",
 "っ", "¿", "¡", "P\u{200d}k", "M\u{200d}n", "P\u{200d}o", "K\u{200d}é", "�", "�", "�", "Í",
 "%", "(", ")", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト", "ナ", "ニ", "ヌ", "â", "ノ", "ハ", "ヒ",
 "フ", "ヘ", "ホ", "í", "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", "⬆", "⬇", "⬅",
 "➡", "ヲ", "ン", "ァ", "ィ", "ゥ", "ェ", "ォ", "ャ", "ュ", "ョ", "ガ", "ギ", "グ", "ゲ", "ゴ",
 "ザ", "ジ", "ズ", "ゼ", "ゾ", "ダ", "ヂ", "ヅ", "デ", "ド", "バ", "ビ", "ブ", "ベ", "ボ", "パ",
 "ピ", "プ", "ペ", "ポ", "ッ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "!", "?", ".",
 "-", "・", "…", "“", "”", "‘", "’", "♂", "♀", "$", ",", "×", "/", "A", "B", "C", "D", "E",
 "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
 "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
 "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "▶",
 ":", "Ä", "Ö", "Ü", "ä", "ö", "ü", "⬆", "⬇", "⬅", "�", "�", "�", "�", "�", ""
}

local GameInfo, Jirachi, TENANNIV, TrainerInfo, Option, SaveInfo, Checksums

function initializeBuffers()
 GameInfo = console:createBuffer("游戏信息")
 GameInfo:setSize(100, 100)
 Jirachi = console:createBuffer("基拉祈")
 Jirachi:setSize(100, 100)
 TENANNIV = console:createBuffer("10ANNIV / Aura Mew")
 TENANNIV:setSize(100, 100)
 TrainerInfo = console:createBuffer("训练家信息")
 TrainerInfo:setSize(100, 100)
 Option = console:createBuffer("选项")
 Option:setSize(100, 100)
 SaveInfo = console:createBuffer("存档信息")
 SaveInfo:setSize(100, 100)
 --Checksums = console:createBuffer("Checksums")
 --Checksums:setSize(100, 100)
end

local gameVersion, gameRegion = "", ""
local wrongGameVersion, wrongGameRegion, currentSeedAddr
local saveBlock2Addr = 0x2024EA4
local saveBlock1Addr = 0x2025734
local starterPokemonIndexAddr = 0x2026ABA
local startingChecksumBlockAddr = 0xE000FF4

function setGameVersion()
 local gameVersionCode = emu:read8(0x80000AE)
 local gameRegionCode = emu:read8(0x80000AF)

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

 if gameRegionCode == 0x45 then  -- 检查游戏地区并设置地址
  gameRegion = "USA"
  currentSeedAddr = 0x3004818
 elseif gameRegionCode == 0x4A then
  gameRegion = "JPN"
 elseif gameRegionCode == 0x44 or gameRegionCode == 0x46 or gameRegionCode == 0x49 or gameRegionCode == 0x53 then
  gameRegion = "EUR"
  currentSeedAddr = 0x3004828
 end
end

function printGameInfo()
 setGameVersion()
 wrongGameVersion = true
 wrongGameRegion = true
 GameInfo:clear()

 if gameVersion == "" then  -- 打印游戏信息
  GameInfo:print("版本：未知游戏")
 elseif gameVersion ~= "红宝石" and gameVersion ~= "蓝宝石" then
  GameInfo:print(string.format("版本：%s - 游戏版本错误！请改用红宝石／蓝宝石\n", gameVersion))
 elseif gameRegion == "JPN" then
  GameInfo:print(string.format("地区：%s - 游戏地区错误！ 请改用美版/欧版\n", gameRegion))
 elseif gameRegion == "" then
  GameInfo:print("版本："..gameVersion.."\n".."地区：未知地区\n")
 else
  wrongGameVersion = false
  wrongGameRegion = false
  GameInfo:print("版本："..gameVersion.."\n"..string.format("地区：%s\n", gameRegion))
 end
end

function calculateBaseTargetTime(textSpeedOptionIndex)
 local targetTotalSixtiethSeconds = (targetHour * 3600 * 60) + (targetMinute * 60 * 60) + (targetSecond * 60) + targetSixtiethSecond
 local delaySeconds = textSpeedOptionIndex == 0 and 3 or textSpeedOptionIndex == 1 and 1 or textSpeedOptionIndex == 2 and 0
 local delaySixtiethSeconds = textSpeedOptionIndex == 0 and 29 or textSpeedOptionIndex == 1 and 47 or textSpeedOptionIndex == 2 and 39
 local delayTotalSixtiethSeconds = (delaySeconds * 60) + delaySixtiethSeconds
 local resultSixtiethSeconds = targetTotalSixtiethSeconds - delayTotalSixtiethSeconds

 local resultHour = resultSixtiethSeconds // (3600 * 60)
 local resultMinute = (resultSixtiethSeconds % (3600 * 60)) // (60 * 60)
 local resultSecond = (resultSixtiethSeconds % (60 * 60)) // 60

 return resultHour, resultMinute, resultSecond, resultSixtiethSeconds % 60
end

function showCurrentTime(buffer)
 local hour = emu:read16(saveBlock2Addr + 0xE)
 local minute = emu:read8(saveBlock2Addr + 0x10)
 local second = emu:read8(saveBlock2Addr + 0x11)
 local sixtiethSecond = emu:read8(saveBlock2Addr + 0x12)
 buffer:print(string.format("当前时间：%02d：%02d：%02d：%02d\n", hour, minute, second, sixtiethSecond))
end

function getChecksumSeed()
 local startingCheckSumSegmentIndex = emu:read8(startingChecksumBlockAddr)
 local firstSegmentChecksumAddr = startingChecksumBlockAddr + ((0xE - startingCheckSumSegmentIndex) * 0x1000)
 local firstSegmentChecksumHigh = emu:read8(firstSegmentChecksumAddr + 0x3)
 local firstSegmentChecksumLow = emu:read8(firstSegmentChecksumAddr + 0x2)

 return (firstSegmentChecksumHigh << 8) + firstSegmentChecksumLow
end

function showTargetInfo(buffer, textSpeedOptionIndex, checksum)
 local targetBaseHour, targetBaseMinute, targetBaseSecond, targetBaseSixtiethSecond = calculateBaseTargetTime(textSpeedOptionIndex)
 buffer:clear()
 buffer:print(string.format("目标校验和种子：%04X\n", targetSeed))
 buffer:print(string.format("目标最终时间：%02d：%02d：%02d：%02d\n", targetHour, targetMinute, targetSecond, targetSixtiethSecond))
 buffer:print(string.format("目标基础存档时间：%02d：%02d：%02d：%02d\n\n", targetBaseHour, targetBaseMinute, targetBaseSecond, targetBaseSixtiethSecond))
 showCurrentTime(buffer)
 buffer:print(string.format("区段 0 校验和种子：%04X\n", checksum))
end

function getChecksumsList()
 local saveFile = assert(io.open(savePath, "rb"))
 local bytes = saveFile:read(0x20000)
 local startingChecksumBlockSaveAddr = 0xFF7
 local checksumsList = {}
 saveFile:close()

 for i = 0, 0x1B do
  local segmentChecksumAddr = startingChecksumBlockSaveAddr + (i * 0x1000)
  local checksum = string.format("%02X%02X\n", bytes:byte(segmentChecksumAddr + 1), bytes:byte(segmentChecksumAddr))
  table.insert(checksumsList, checksum)
 end

 return checksumsList
end

function getCurrentXORChecksumSeed(checksumsList)
 local xorChecksumSeed = 0

 for _, checksum in ipairs(checksumsList) do
  xorChecksumSeed = xorChecksumSeed ~ tonumber(checksum, 16)
 end

 return xorChecksumSeed
end

function getTrainerIDs()
 local trainerIDsAddr = saveBlock2Addr + 0xA
 local TID = emu:read16(trainerIDsAddr)
 local SID = emu:read16(trainerIDsAddr + 0x2)

 return TID, SID
end

function getPlayerNameString(rawString)
 local string = ""

 for _, char in ipairs({rawString:byte(1, #rawString)}) do
  if char == 0xFF then  -- 终止字符检查
   break
  end

  string = string..charMap[char + 1]
 end

 return string
end

function showRNGInfo(buffer)
 local currentSeed = emu:read32(currentSeedAddr)
 buffer:print(string.format("画面帧：%d\n", emu:currentFrame() - 4))
 buffer:print(string.format("当前种子：%08X", currentSeed))
end

function showTrainerInfo(buffer)
 local playerGenderSymbols = {"M", "F"}
 local playerGenderIndex = emu:read8(saveBlock2Addr + 0x8)
 local trainerTID, trainerSID = getTrainerIDs()
 local playerName = getPlayerNameString(emu:readRange(saveBlock2Addr, 8))
 buffer:clear()
 buffer:print(string.format("性别：%s\n", playerGenderSymbols[playerGenderIndex + 1]))
 buffer:print(string.format("TID：%d\nSID：%d\n", trainerTID, trainerSID))
 buffer:print(string.format("名字：%s\n\n", playerName))
 showRNGInfo(buffer)
end

function showCurrentOptions(buffer, textSpeedOptionIndex)
 local speedTextOptions = {"慢", "中", "快"}
 local battleSceneOptions = {"开", "关"}
 local battleStyleOptions = {"Shift", "固定"}
 local soundOptions = {"单声道", "立体声"}
 local buttonModeOptions = {"普通", "LR", "L=A"}
 local buttonModeOptionIndex = emu:read8(saveBlock2Addr + 0x13)
 local optionsValue = emu:read32(saveBlock2Addr + 0x14)
 local frameTypeOptionIndex = (optionsValue >> 3) & 0x1F
 local soundOptionIndex = (optionsValue >> 8) & 0x1
 local battleStyleOptionIndex = (optionsValue >> 9) & 0x1
 local battleSceneOptionIndex = (optionsValue >> 10) & 0x1
 buffer:clear()
 buffer:print(string.format("文字速度：%s\n", speedTextOptions[textSpeedOptionIndex + 1]))
 buffer:print(string.format("战斗动画：%s\n", battleSceneOptions[battleSceneOptionIndex + 1]))
 buffer:print(string.format("战斗风格：%s\n", battleStyleOptions[battleStyleOptionIndex + 1]))
 buffer:print(string.format("声音：%s\n", soundOptions[soundOptionIndex + 1]))
 buffer:print(string.format("按键模式：%s\n", buttonModeOptions[buttonModeOptionIndex + 1]))
 buffer:print(string.format("边框样式：%d", frameTypeOptionIndex + 1))
end

function getCurrentTextSpeedOptionIndex()
 return emu:read16(saveBlock2Addr + 0x14) & 0x7
end

function pokemonSeenFlag(speciesDexNumber)
 local dexIndex = (speciesDexNumber - 1) // 8
 local dexMask = 1 << (speciesDexNumber - 1) % 8
 local dexSeenFlag = emu:read8(saveBlock2Addr + 0x5C + dexIndex) & dexMask
 local dexSeen1Flag = emu:read8(saveBlock1Addr + 0x938 + dexIndex) & dexMask
 local dexSeen2Flag = emu:read8(saveBlock1Addr + 0x3A8C + dexIndex) & dexMask

 return dexSeenFlag ~= 0 and dexSeenFlag == dexSeen1Flag and dexSeenFlag == dexSeen2Flag
end

function showSaveInfo(buffer)
 local starterPokemonNames = {"木守宫", "火稚鸡", "水跃鱼"}
 local currentClockHour = emu:read8(saveBlock2Addr + 0xA2)
 local currentClockMinute = emu:read8(saveBlock2Addr + 0xA3)
 local starterPokemonIndex = emu:read8(starterPokemonIndexAddr)
 buffer:clear()
 buffer:print(string.format("时钟：%02d：%02d (%s：%s)\n", currentClockHour, currentClockMinute, currentClockHour ~= 0 and "XX" or "00", currentClockMinute ~= 0 and "XX" or "00"))
 buffer:print(string.format("最初的伙伴：%s\n", starterPokemonNames[starterPokemonIndex + 1]))
 buffer:print(string.format("Zigzagoon seen? %s\n", pokemonSeenFlag(263) == true and "是" or "否"))
 buffer:print(string.format("Wurmple seen? %s\n", pokemonSeenFlag(265) == true and "是" or "否"))
 buffer:print(string.format("Wingull seen? %s\n", pokemonSeenFlag(278) == true and "是" or "否"))
 showCurrentTime(buffer)
end

function showAllChecksums(buffer, checksumsList)
 buffer:clear()

 for _, checksum in ipairs(checksumsList) do
  buffer:print(checksum)
 end
end

function updateJirachiBuffer(buffer, textSpeedIndex, checksumSeed)
 showTargetInfo(buffer, textSpeedIndex, checksumSeed)
end

function updateTENANNIVBuffer(buffer, textSpeedIndex, checksumSeed)
 showTargetInfo(buffer, textSpeedIndex, checksumSeed)
 local checksums = getChecksumsList()
 local currectXORChecksumSeed = getCurrentXORChecksumSeed(checksums)
 local segment0TargetSeed = currectXORChecksumSeed ~ checksumSeed ~ targetSeed
 buffer:print(string.format("当前校验和种子：%04X\n\n", currectXORChecksumSeed))
 buffer:print(string.format("目标区段 0 校验和种子：%04X", segment0TargetSeed))
end

function updateTrainerInfoBuffer(buffer)
 showTrainerInfo(buffer)
end

function updateOptionBuffer(buffer, textSpeedIndex)
 showCurrentOptions(buffer, textSpeedIndex)
end

function updateSaveInfoBuffer(buffer)
 showSaveInfo(buffer)
end

function updateChecksumsBuffer(buffer)
 showAllChecksums(buffer, getChecksumsList())
end

function updateBuffers()
 if (not wrongGameVersion) then
  local textSpeedIndex = getCurrentTextSpeedOptionIndex()
  local checksumSeed = getChecksumSeed()
  updateJirachiBuffer(Jirachi, textSpeedIndex, checksumSeed)
  updateTENANNIVBuffer(TENANNIV, textSpeedIndex, checksumSeed)
  updateTrainerInfoBuffer(TrainerInfo)
  updateOptionBuffer(Option, textSpeedIndex)
  updateSaveInfoBuffer(SaveInfo)
  --updateChecksumsBuffer(Checksums)
 end
end

initializeBuffers()
printGameInfo()
callbacks:add("frame", updateBuffers)
callbacks:add("reset", printGameInfo)
