# PokeLua

用于宝可梦 RNG 操作的实用 Lua 脚本。

本项目由 xDHHzz 进行简体中文翻译。原项目是：[Real96/PokeLua](https://github.com/Real96/PokeLua)。

加入 [Pokemon RNG](https://www.pokemonrng.com) 或 [Devon Studios](https://devonstudios.it) 的 Discord 服务器讨论 RNG 或获取帮助！

[![PokemonRNG](https://discordapp.com/assets/07dca80a102d4149e9736d4b162cff6f.ico)](https://discord.gg/d8JuAvg)
[![Devon Studios](https://discordapp.com/assets/07dca80a102d4149e9736d4b162cff6f.ico)](https://discord.gg/7gNVdkdBwA)

## 第一世代功能
### RBG/Y
* 礼物机器人
* 定点机器人
* 钓鱼机器人
* 游戏内交换机器人
* TID 机器人
* 同行宝可梦信息查看

## 第二世代功能 - _即将推出_
### GS/C

## 第三世代功能
### RS/FRLG/E
* RNG 信息查看
* 野生宝可梦信息查看
* 培育信息查看
* 游走宝可梦信息查看
* 训练家信息查看
* 初始种子机器人（仅 FRLG）
* TID 机器人（仅 FRLG/E）
* 同行宝可梦信息查看
* 盒子宝可梦信息查看
* 校验和信息查看（仅限美版/欧版 RS）

### C/XD
* RNG 信息查看
* 敌方宝可梦信息查看
* 同行宝可梦信息查看
* 盒子宝可梦信息查看
* 训练家信息查看

## 第四世代功能
### DP/Pt/HGSS
* RNG 信息查看
* 野生宝可梦信息查看
* 培育信息查看
* 游走宝可梦信息查看
* 训练家信息查看
* 同行宝可梦信息查看
* 盒子宝可梦信息查看

## 第五世代功能
### BW/B2W2
* RNG 信息查看
* 野生宝可梦信息查看
* 培育信息查看
* 游走宝可梦信息查看（BW）
* C-Gear 宝可梦信息查看
* 训练家信息查看
* 同行宝可梦信息查看
* 盒子宝可梦信息查看

## 支持的模拟器
### mGBA
使用最新开发版：[链接](https://mgba.io/downloads.html#desktop-os-1)

### Dolphin
使用这个支持 Lua 核心的构建：[链接](https://github.com/Real96/Dolphin-Lua-Core/releases)

### DeSmuMe
使用版本 `0.9.11_x86_dev+`：[链接](https://sourceforge.net/projects/desmume/files/desmume/0.9.11/desmume-0.9.11-win32-dev.zip/download)

1. 下载 [lua5.1.dll](https://sourceforge.net/projects/luabinaries/files/5.1.5/Windows%20Libraries/Dynamic/lua-5.1.5_Win32_dll17_lib.zip/download) 文件
2. 将其移动到 DeSmuMe 文件夹
3. 将其重命名为 `lua51.dll`

#### 最终文件夹：
![image](https://github.com/Real96/PokeLua/assets/20956021/e6a21f63-ba96-4cc6-82fa-e9fba93537c6)

### BizHawk
使用最新发布版：[链接](https://github.com/TASEmulators/BizHawk/releases)

## mGBA 脚本说明
* 请确保将 Lua 窗口放大到足够大小，避免文字闪烁或模拟变慢
* 每次需要保存或读取即时存档时，在游戏未暂停的情况下按住 `Shift` + `(n)`/`(n)`（例如 `Shift` + `1` 保存到槽位 1，`1` 读取槽位 1）

## DeSmuMe 脚本说明
* 每次需要重启游戏时，按 Lua 窗口中的 `Restart` 按钮
* 每次需要保存或读取即时存档时，先暂停游戏并按住 `Shift` + `F(n)`/`F(n)` 数秒（例如 `Shift` + `F1` 保存到槽位 1，`F1` 读取槽位 1），直到下屏短暂显示 `Saved State (n)`/`Loaded State (n)`

## 鸣谢：
* 感谢 [Kaphotics](https://github.com/kwsch) 的研究以及他的[第三世代](https://projectpokemon.org/home/forums/topic/15187-gen-3-lua-scripts)和[第五世代](https://projectpokemon.org/home/forums/topic/15140-pokemon-bw-lua-scripts)脚本
* 感谢 [Admiral_Fish](https://github.com/Admiral-Fish)、[bumba](https://github.com/pkmnbumba) 和 [EzPzStreamz](https://github.com/SteveCookTU) 的研究，以及他们持续更新的优秀应用 [PokeFinder](https://github.com/Admiral-Fish/PokeFinder)
* 感谢 [zep715](https://github.com/zep715) 的[第一世代](https://github.com/zep715/rbylua)脚本
* 感谢 [wwwwwwzx](https://github.com/wwwwwwzx) 的[第二世代](https://github.com/wwwwwwzx/gsclua)脚本
* 感谢 [zaksabeast](https://github.com/zaksabeast) 的基拉祈许愿星[脚本](https://www.reddit.com/r/pokemonrng/comments/5ny1el/scripts_and_guide_to_help_automate_rnging_a_shiny)和[许愿星计算器](https://gist.github.com/zaksabeast/600fdd9579aaa4dde5b93f7207ea6550)
* 感谢 [SciresM](https://github.com/SciresM)、Zari、[amab](https://github.com/AskMeAboutBirds)、[OmegaDonut](https://github.com/OmegaDonut)、[Bond697](https://github.com/Bond697)、[Lincoln-LM](https://github.com/Lincoln-LM)、[StarfBerry](https://github.com/StarfBerry)、[Shao](https://github.com/c-poole) 以及所有其他宝可梦研究者！
* 感谢 [MKDasher](https://github.com/mkdasher) 的[第四、第五世代](https://www.dropbox.com/s/qx2fo1zc44p1jr7/Pokemon%20Gen%204-5%20Lua%20script.rar)脚本
* 感谢 [BizHawk](https://github.com/TASEmulators/BizHawk)、[DeSmuMe](https://github.com/TASEmulators/desmume)、[mGBA](https://github.com/mgba-emu/mgba)、[VBA-ReRecording](https://github.com/TASEmulators/vba-rerecording) 的开发者
* 感谢 [SwareJonge](https://github.com/SwareJonge) 提供支持 Lua 脚本的 [Dolphin 版本](https://github.com/SwareJonge/Dolphin-Lua-Core)
