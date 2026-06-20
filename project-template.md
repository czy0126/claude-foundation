# CLAUDE.md — 项目模板

> 复制到项目根目录，将所有 `[...]` 替换为实际值。
> 全局元规则（对所有项目生效）在 `~/.claude/CLAUDE.md`。

---

## 一、项目资源注册表

```
Python：[绝对路径，如 D:\Anaconda_envs\envs\myenv\python.exe]  # Python [版本]
```

| 包名 | 版本 | 用途 |
|------|------|------|
| | | |

### GPU 环境（如适用）

| 硬件 | 型号 | 显存 |
|------|------|------|
| GPU | [model] | [VRAM GB] |

CUDA 版本：[version]
注意哪些模块需要 GPU：[list]

### 工具链

| 工具 | 路径 / 命令 | 用途 |
|------|------------|------|
| | | |

### 数据库 / API

| 名称 | 连接方式 | 备注 |
|------|---------|------|
| | | |

### 关键目录

```
project/
├── src/               # [源码]
│   ├── [module]/      #   [职责]
├── tests/             # 测试
├── data/              # 数据文件
├── outputs/           # 输出
├── scripts/           # 脚本
├── .claude/           # Claude Code 配置
│   ├── settings.json
│   ├── settings.local.json  # (gitignore)
│   ├── hooks/
│   └── rules/
├── CLAUDE.md          # 本文件
└── README.md
```

## 二、关键命令

```bash
# 测试全部：[exact command with flags]
# 测试单个：[exact command with placeholder]
# Lint：[exact command]
# 构建：[exact command]
# 运行：[exact command]
```

## 三、架构

| 模块 | 路径 | 职责 | 依赖 |
|------|------|------|------|
| | | | |

数据流：`[Input] → [Step A] → [Step B] → [Output]`

## 四、设计规则

1. [具体约束]
2. ...

### 不要做
1. [X] — [为什么]

## 五、已知陷阱

1. [描述] (YYYY-MM-DD) — 现象：[what] — 修复：[how]

## 六、当前状态
- 进行中：[ ]
- 阻塞于：[ ]
- 下一步：[ ]

## 七、压缩指令

项目级压缩指令与全局一致（见 `~/.claude/CLAUDE.md` §六），如需覆盖，在此改写。
