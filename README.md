# LifeRetart4ProjectMoon2Godot

基于GodotEngine的“人生重开模拟器 月计版”
<!-- 
> [!CAUTION]
> 项目尚未完工，前面的区域，以后再来探索吧 -->

此版本实现了对原项目[Clouds-Heath/PM-life-restart](https://github.com/Clouds-Heath/PM-life-restart)的重构，使其灵活性更高，初学者也能快速参与开发。

## 怎么玩？

- https://life-restart4project-moon.netlify.app/
- 但可能加载会很慢（之后会尝试优化）

- 同时支持Android/Windows、macOS/Linux四端。在 **Release 页面**下载。

### 警告

- macOS端由于禁用公证，从网站下载的程序可能会被Gatekeeper阻止运行。
- macOS端代码签名仅用临时签名，程序会被Gatekeeper阻止。

暂不支持的功能：

- 存档转移。
- 名人模式。
- 排行榜功能。
- 设置功能、存档/读档功能

这些功能会在之后慢慢实现。

## 参与开发？

此项目作为个人项目，难免会有bug/游戏数据未及时同步的情况。你可以参与开发，无论是构建UI，修改Bug，还是修改事件。

### 先决条件

- 一个懂月计都市概念的大脑
- Godot Engine(v4.6)
  - 可前往[官网](www.godotengine.org)下载

### 数据目录

注意：这个数据目录比较旧，还没来得及跟进！

```
├── assets
│   ├── ChineseFont.ttf            # 字体文件：AkinoKaede/Sarasa-Gothic-Term-SC-Nerd
│   └── custom_style.tres          # 按钮的自定义样式
├── data                           # 用来存放数据的目录
│   ├── achievement.json           # 成就
│   ├── age.json                   # 年龄
│   ├── character.json             # 人物（现在没用，将来会重构）
│   ├── events.json                # 事件系统
│   ├── example                    # 模板（脑子抽了忘记templete了）
│   │   └── user_data.json         # 用户的数据
│   └── talents.json               # 天赋
├── icon.svg                       # Godot 的图标
├── project.godot                  # Godot 项目配置文件
├── README.md                      # README
├── scenes                         # 场景，目前只有主页完工了
│   └── Menu.tscn                  # 主页
└── scripts                        # 脚本核心，主要用于解析事件数据
    ├── event_manager.gd           # 事件管理
    ├── parser                     # 解析器，主要用于解析DSL
    │   ├── condition_parser.gd    # 主要解析条件判断
    │   ├── talent_parser.gd       # 主要解析天赋
    │   └── weight_parser.gd       # 主要负责权重重构和判断
    ├── property_data.gd           # 属性数据枚举，我现在也不知道能干什么，但确实是实打实的用上了
    └── util                       # 工具
        └── data_util.gd           # 存档工具，用于存档
```

## 其他

### 之后的计划

~~现在写计划未免有点太早了（~~

- 完成基本游戏
- 添加排行榜
- 制作基本数据修改程序
- 添加DLC（名人模式）
- 优化UI

### 特别鸣谢

- 原版：事件数据实现格式
- 修改版：事件修改
