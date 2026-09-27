# System Overview

## Status

PRE-OFFICIAL-BASELINE

Evidence Level:

DOCUMENTED — 来自课程/官方资料描述
CODE-CONFIRMED — 尚未完成
BOARD-VERIFIED — 尚未完成

---

## 1. Project Goal

2026 全国大学生嵌入式芯片与系统设计竞赛
FPGA赛道 · 安路科技 · 选题一

Target Board:

HX4S20C

FPGA:

EG4S20

目标是实现基于 FPGA 的 HDMI 多媒体播放系统。

---

## 2. Baseline System Concept

根据当前课程资料，官方例程的主要视频数据链为：

    TF Card
       ↓
    SD / SPI
       ↓
    BMP Parser
       ↓
    RGB Pixel Stream
       ↓
    Write FIFO
       ↓
    SDRAM Frame Buffer
       ↓
    Read FIFO
       ↓
    Video Timing / Pixel Path
       ↓
    HDMI TX
       ↓
    HDMI PHY
       ↓
    Display

音频链路为：

    Test Tone
       ↓
    I2S
       ↓
    PCM
       ↓
    HDMI Audio
       ↓
    HDMI TX

---

## 3. Architectural Principle

系统按责任划分为：

    Application / Control
             ↓
          Buffer
             ↓
          Protocol
             ↓
           Driver

进一步的完赛工程规划为：

    integration
    control
    storage
    filesystem
    image
    memory
    display
    audio
    io
    config
    recovery
    metrics
    diag

---

## 4. Current Verification State

目前：

- 官方 lab_ex_4 尚未导入
- 官方 lab_ex_5 尚未导入
- 官方 RTL 尚未逐文件分析
- 官方工程尚未编译
- HX4S20C 尚未上板验证

因此当前架构描述只能作为：

DOCUMENTED ARCHITECTURE

不能视为：

CODE-CONFIRMED ARCHITECTURE

更不能视为：

BOARD-VERIFIED ARCHITECTURE

---

## 5. Next Verification Step

导入官方例程后需要确认：

1. 顶层模块真实名称
2. 实际模块实例树
3. PLL 与真实 Clock Net
4. 每个 always block 所属时钟域
5. FIFO 实际读写时钟
6. SDRAM 数据宽度与地址组织
7. Framebuffer 实际地址映射
8. Buffer Swap 实际触发条件
9. HDMI TX 接口
10. Audio 接口

所有确认结果必须来自真实 RTL / 工程配置，而不是仅根据课程描述推断。
