-- Optional display language: "en" or "zh-Hans". Reload after changing.
-- 可选显示语言：英文 "en"／简体中文 "zh-Hans"。修改后重新加载脚本。
local POKELUA_LANGUAGE = "en"
local function _pokeluaText(english, chinese)
 if POKELUA_LANGUAGE == "zh-Hans" then return chinese end
 return english
end
-- END POKELUA LOCALIZATION

read32Bit = ReadValue32
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

function LCRNG(s, mul, sum)
 local a = (mul >> 16) * (s % 0x10000) + (s >> 16) * (mul % 0x10000)
 local b = (mul % 0x10000) * (s % 0x10000) + (a % 0x10000) * 0x10000 + sum

 return b % 0x100000000
end

local tempCurrentSeed
 
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

function getIVs(seed)
 local ivs = {0, 0, 0, 0, 0, 0}
 seed = LCRNG(seed, 0x45C82BE5, 0xD2F65B55)  -- 3 cycle

 for i = 1, 6 do
  seed = LCRNG(seed, 0x343FD, 0x269EC3)
  ivs[i == 4 and 6 or i == 5 and 4 or i == 6 and 5 or i] = string.format("%02d", (seed >> 16) >> 11)
 end

 return ivs
end

function shinyCheck(highPID, lowPID, trainerID, trainerSID)
 local shinyTypeValue = trainerID ~ trainerSID ~ highPID ~ lowPID

 if shinyTypeValue < 8 then
  return shinyTypeValue == 0 and _pokeluaText(" (Square Shiny)", "（方块异色）") or _pokeluaText(" (Star Shiny)", "（星星异色）")
 end

 return ""
end

function getHPTypeAndPower(hpIV, atkIV, defIV, spAtkIV, spDefIV, spdIV)
 local hpType = (((hpIV & 1) + (2 * (atkIV & 1)) + (4 * (defIV & 1)) + (8 * (spdIV & 1)) + (16 * (spAtkIV & 1))
                + (32 * (spDefIV & 1))) * 15) // 63
 local hpPower = (((((hpIV >> 1) & 1) + (2 * ((atkIV >> 1) & 1)) + (4 * ((defIV >> 1) & 1)) + (8 * ((spdIV >> 1) & 1))
                 + (16 * ((spAtkIV >> 1) & 1)) + (32 * ((spDefIV >> 1) & 1))) * 40) // 63) + 30

 return string.format(_pokeluaText("HPower: %s %02d", "觉醒力量：%s %02d"), HPTypeNamesList[hpType + 1], hpPower)
end

function getJirachiInfo(seed)
 local OTID = 40122
 seed = LCRNG(seed, 0x343FD, 0x269EC3)
 local OTSID = seed >> 16
 seed = LCRNG(seed, 0x343FD, 0x269EC3)
 local pokemonHighPID = seed >> 16
 seed = LCRNG(seed, 0x343FD, 0x269EC3)
 local pokemonLowPID = seed >> 16

 if (pokemonLowPID < 8 and 1 or 0) ~= (pokemonHighPID ~ OTID ~ OTSID) then
  pokemonHighPID = pokemonHighPID ~ 0x8000
 end

 local ivs = getIVs(seed)
 local pokemonPID = (pokemonHighPID << 16) + pokemonLowPID
 local shinyType = shinyCheck(pokemonHighPID, pokemonLowPID, OTID, OTSID)
 local natureIndex = pokemonPID % 25
 local info = string.format(_pokeluaText("PID: %08X %s\nNature: %s\nIVs: %s", "PID：%08X %s\n性格：%s\n个体值：%s"), pokemonPID, shinyType, natureNamesList[natureIndex + 1], table.concat(ivs, "/"))
 local hpTypeAndPower = getHPTypeAndPower(ivs[1], ivs[2], ivs[3], ivs[4], ivs[5], ivs[6])
 info = info.."\n"..hpTypeAndPower

 return info
end

local currentSeedAddr, initialSeed, advances

function onScriptStart()
 local gameLang = read8Bit(0x3)

 if gameLang == 0x45 then  -- U
  currentSeedAddr = 0x3502C8
 elseif gameLang == 0x4A then  -- J
  currentSeedAddr = read8Bit(0x0) == 0x47 and 0x387C18 or 0x387C38  -- Japan has two editions of the game
 elseif gameLang == 0x50 then  -- E
  currentSeedAddr = 0x33D888
 else  -- A
  currentSeedAddr = 0x337568
 end

 initialSeed = read32Bit(currentSeedAddr)
 tempCurrentSeed = initialSeed
 advances = 0
end

function onScriptUpdate()
 local currentSeed = read32Bit(currentSeedAddr)
 advances = advances + LCRNGDistance(tempCurrentSeed, currentSeed)
 local jirachiInfo = getJirachiInfo(currentSeed)
 local text = string.format(_pokeluaText("Initial Seed: %08X\nCurrent Seed: %08X\nAdvances: %d\n\nJirachi Info:\n%s", "初始种子：%08X\n当前种子：%08X\n推进数：%d\n\n基拉祈信息：\n%s"),
                            initialSeed, currentSeed, advances, jirachiInfo)
 SetScreenText(text)
end

function onScriptCancel()
 SetScreenText("")
end

function onStateLoaded()
end

function onStateSaved()
end