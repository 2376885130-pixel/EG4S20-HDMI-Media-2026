# AGENTS.md

## Project

2026 全国大学生嵌入式芯片与系统设计竞赛
FPGA 赛道 · 安路科技 · 选题一

Target Board: HX4S20C
FPGA: EG4S20

本仓库用于开发 HDMI 多媒体播放系统。

---

## 1. Mandatory Reading

任何 AI 在分析、Review、生成或修改 RTL 前，必须优先阅读：

- README.md
- docs/ai/AI_REVIEW_GUIDE.md
- docs/architecture/01_system_overview.md
- docs/architecture/02_layer_map.md
- docs/architecture/03_data_flow.md
- docs/architecture/04_clock_domains.md
- docs/architecture/05_buffer_and_cdc.md
- docs/architecture/06_module_risk_map.md

如果这些文档尚未根据真实 RTL 完成：

AI 必须明确说明证据不足。

禁止自行假定工程内部实现。

---

## 2. Official Golden Reference

official/ 用于保存官方参考工程。

在用户没有明确要求的情况下：

- 不重构 official/
- 不移动官方文件
- 不重命名官方文件
- 不修改官方加密 IP
- 不修改 PLL 参数
- 不修改 SDRAM 加密 IP
- 不修改 HDMI 加密 IP
- 不修改 HDMI PHY
- 不重写官方异步 FIFO
- 不随意修改视频时序

官方工程只有在真实开发板验证成功之后，
才能标记为 Golden Reference。

---

## 3. Architecture First

修改 RTL 之前必须确定：

- Requirement
- Layer
- Affected Modules
- Clock Domain
- CDC
- FIFO Impact
- SDRAM Impact
- Framebuffer Impact
- Video Timing Impact
- Audio Impact
- Pipeline Latency Impact
- Resource Impact
- Risk Level

AI 必须先解释：

为什么应该修改这一层？

为什么不需要修改其他层？

然后才能提出代码修改方案。

---

## 4. One Change At A Time

一次实验尽量只改变一个主要变量。

禁止无充分理由同时修改多个高风险子系统：

- Clock / PLL
- CDC
- FIFO
- SDRAM
- Framebuffer
- Video Timing
- HDMI PHY

优先采用最小修改面。

---

## 5. Clock Domain Rule

任何新增寄存器必须明确：

Which clock owns this register?

任何信号跨时钟域时必须进行 CDC Review。

两个时钟频率相同，
不代表它们属于同一个时钟域。

---

## 6. CDC Rule

Single-bit state:

    Synchronizer

Event:

    Toggle
      ↓
    Synchronizer
      ↓
    Edge Detection

Streaming Data:

    Asynchronous FIFO

禁止直接将异步 pulse 跨时钟域使用。

---

## 7. Framebuffer Rule

必须区分：

- source_done
- fifo_empty
- sdram_write_done
- frame_ready
- frame_committed
- display_buffer
- write_buffer

这些状态不能互相替代。

安全流程：

    Load Image
        ↓
    Write Non-Display Buffer
        ↓
    Complete SDRAM Writes
        ↓
    Frame Ready
        ↓
    Wait Safe Video Boundary
        ↓
    Buffer Swap

禁止后台写入当前正在显示的 Buffer。

---

## 8. Pipeline Rule

新增图像处理 Pipeline 时必须检查：

- RGB latency
- DE latency
- HSYNC latency
- VSYNC latency
- X coordinate latency
- Y coordinate latency

如果 RGB 延迟 N 个 Clock，

与该 Pixel 对应的控制信息必须保持相同延迟。

---

## 9. Debug Rule

发生：

- 黑屏
- 花屏
- 撕裂
- 卡顿
- FIFO underflow
- FIFO overflow
- 长时间运行死机

时，不允许直接重写整个数据链。

优先按照责任边界隔离：

    HDMI Test Pattern
          ↓
    Local Video Pattern
          ↓
    Video Timing
          ↓
    FIFO / CDC
          ↓
    SDRAM
          ↓
    BMP
          ↓
    TF

---

## 10. Experiment Rule

每次重要实验记录：

Problem:

Hypothesis:

Unique Variable:

Kept Constant:

Expected Result A:

Expected Result B:

Actual Result:

Conclusion:

---

## 11. Verification Rule

必须区分：

Compilation Passed
!=
Simulation Passed
!=
Hardware Verified
!=
Long-term Stable

重要功能至少考虑：

- Normal Case
- Boundary Case
- Error Case
- Repeated Operation
- Long-run Behavior
- Reset
- Cold Boot

---

## 12. Core Engineering Principle

Understand First.

Modify Minimally.

Verify Independently.

Keep Rollback Possible.

Do Not Guess.
