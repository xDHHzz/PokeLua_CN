# PokeLua：英文／简体中文可选脚本

## 当前基线

先完整同步 [Real96/PokeLua](https://github.com/Real96/PokeLua) 的 `b76caf669872897295db5304eebbdf5e53125efb`，再增加语言配置。25 个脚本均包含最新上游内容，包括第三世代 mGBA 的 3 个携带道具 RNG 脚本。旧汉化提交仍保留在 Git 历史中。

## 使用中文

每个 Lua 脚本最上方都有：

```lua
local POKELUA_LANGUAGE = "en"
```

改成 `"zh-Hans"` 后，在模拟器中重新加载该脚本即可使用简体中文。改回 `"en"` 恢复英文。无效值回退到英文。每个脚本独立可用，无需加载额外字典、无需 Python。

先启动游戏，再加载脚本。模拟器和版本要求沿用原版 [README](README.md)。模拟器的文字渲染必须支持中文字体；若出现方框，先检查模拟器的字体／Unicode 支持，或切回英文。此次没有游戏 ROM 或实际模拟器实机验证，因此不把语法检查当成中文字体和游戏运行保证。

## 维护方式

- `localization/zh-Hans.json`：按数据表上下文区分译文，避免 Psychic（属性／招式）、Metronome（招式／道具）混淆。
- `tools/generate_localization.py`：从固定上游提交生成自包含脚本；开发时需 Python 3 与 `lupa`。
- `localization/manifest.json`：上游摘要及每个脚本的替换数量。
- 英文值、格式占位符、编号、RNG 运算和模拟器接口保留。用于存档文件名的游戏版本／地区标识不随显示语言变化。
- 专名采用 2026-10-02 宝可梦四语数据库核对结果。老游戏的中文是现代检索显示名，不表示旧 ROM 原生支持中文；未能唯一核验的历史译文继续保留作项目译文，不冒充官方。

```sh
python -m pip install lupa
python tools/generate_localization.py
python -m unittest discover -s tests -v
```

已检查全部 25 个脚本的 Lua 5.4 语法；原本支持 Lua 5.1 语法的脚本也通过对应检查。7 项测试覆盖语言选择、英文回退、格式符、稳定的存档标识，以及将英文选项还原后与完整上游源文件逐字一致（仅统一换行符）。

每次上游／汉化更新后同步 GitHub，并保留更新记录。不上传私人术语库、游戏 ROM、存档或凭证。

上游授权见 [LICENSE](LICENSE)。
