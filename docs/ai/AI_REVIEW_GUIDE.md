# AI FPGA RTL Review Guide

## 1. Purpose

本文件规定 AI 如何分析、Review 和修改本 FPGA 工程。

AI 的目标不是尽可能多地修改代码。

AI 的目标是：

    理解问题
        ↓
    定位责任层
        ↓
    找到最小修改点
        ↓
    评估影响
        ↓
    修改
        ↓
    验证

---

## 2. Required Review Header

每次进行 RTL Review 或修改之前，必须首先输出：

Requirement:

Layer:

Affected Modules:

Unaffected Modules:

Clock Domain:

Input Clock Domain:

Output Clock Domain:

CDC:

FIFO Impact:

SDRAM Impact:

Framebuffer Impact:

Video Timing Impact:

Audio Impact:

Pipeline Latency Impact:

Resource Impact:

Risk Level:

Evidence:

如果某项未知：

必须写 UNKNOWN / TO BE VERIFIED。

禁止猜测。

---

## 3. Layer Classification

当前规划的 RTL 层：

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

修改代码前必须确定修改属于哪一层。

原则：

优先修改最高且最安全的责任层。

如果 control 层能够解决问题，
不应该首先修改 SDRAM / FIFO / HDMI 等底层。

---

## 4. Clock Review

检查每个相关 sequential block：

    always @(posedge clock)

必须明确：

- Clock Source
- Clock Frequency
- Reset
- Input Domain
- Output Domain

禁止仅因为两个 Clock 的频率相同，
就认为不存在 CDC。

---

## 5. CDC Review

### Single-bit State

使用经过验证的同步结构。

### Event

推荐：

    Source Event
         ↓
       Toggle
         ↓
    Synchronizer
         ↓
    Edge Detect
         ↓
    Destination Event

### Streaming Data

推荐：

    Producer
        ↓
    Async FIFO
        ↓
    Consumer

任何新增 CDC 必须明确说明同步方法。

---

## 6. FIFO Review

检查：

- write clock
- read clock
- write enable
- read enable
- full
- empty
- overflow possibility
- underflow possibility
- reset behavior
- data width
- valid semantics

禁止因为 FIFO empty 就直接推断整帧已经安全写入 SDRAM。

---

## 7. SDRAM / Framebuffer Review

必须明确区分：

    source_done

    fifo_empty

    sdram_write_done

    frame_ready

    frame_committed

    display_buffer

    write_buffer

安全 Frame 生命周期：

    Image Source
         ↓
    Write FIFO
         ↓
    SDRAM Write
         ↓
    Complete Frame
         ↓
    Frame Ready
         ↓
    Safe Video Boundary
         ↓
    Buffer Commit / Swap

后台 Writer 不允许覆盖当前 Display Buffer。

---

## 8. Video Pipeline Review

像素处理模块可能包括：

- brightness
- contrast
- OSD
- alpha blending
- transition
- scaling

新增处理级时必须检查 Pipeline Latency。

如果：

    RGB -> Process -> RGB

产生 N-cycle latency，

则对应的：

    DE
    HSYNC
    VSYNC
    X
    Y

必须保持正确的 Pixel 对齐关系。

---

## 9. FSM Review

检查状态机：

- Reset State
- Normal Path
- Busy Condition
- Completion
- Repeated Request
- Invalid State
- Timeout
- Recovery

禁止默认认为：

TF / SDRAM / FIFO / HDMI

永远会按预期时间响应。

---

## 10. Resource Review

新增功能必须考虑：

- LUT
- FF
- Embedded RAM
- DSP
- SDRAM Capacity
- SDRAM Bandwidth

涉及 Framebuffer 时必须说明：

- Resolution
- Pixel Format
- Bytes Per Frame
- Buffer Count
- Address Range

不得在没有确认真实 SDRAM 数据组织的情况下，
假定 Pixel Packing 方式。

---

## 11. Debug Strategy

### HDMI No Signal

优先检查：

Clock
Reset
PLL
Video Timing
HDMI PHY
Constraints

### HDMI Has Signal But Black

优先检查：

DE
RGB Valid
Framebuffer Reader
Video Timing

### Corrupted Image

优先检查：

Pixel Ordering
FIFO
SDRAM
BMP Decode

### Tearing

优先检查：

Display Buffer Ownership
Write Buffer Ownership
Frame Commit
Buffer Swap Boundary

### Periodic Stall

优先检查：

FIFO Underflow
SDRAM Scheduling
Memory Bandwidth
CDC

---

## 12. Experiment Template

Problem:

Hypothesis:

Unique Variable:

Kept Constant:

Expected Result A:

Expected Result B:

Actual Result:

Conclusion:

Next Step:

---

## 13. Evidence Levels

AI 必须明确区分：

DOCUMENTED
    官方文档明确说明

CODE-CONFIRMED
    已从真实 RTL 确认

SIMULATED
    已经过仿真

BOARD-VERIFIED
    已真实上板验证

INFERRED
    根据结构推断，尚未验证

UNKNOWN
    当前证据不足

禁止将 INFERRED 写成 BOARD-VERIFIED。

---

## 14. Modification Output

修改代码时应提供：

1. Problem
2. Root-cause hypothesis
3. Architecture layer
4. Files to modify
5. Files explicitly not modified
6. Minimal patch
7. Expected behavior
8. Verification procedure
9. Rollback procedure

---

## 15. Golden Reference

official/lab_ex_4
official/lab_ex_5

在完成真实上板验证后作为 Golden Reference。

如果自研版本出现问题：

优先与 Golden Reference 逐层 A/B 对比。

---

## 16. Final Principle

AI should help reduce uncertainty.

AI should not hide uncertainty by generating more code.
