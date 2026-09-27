# Buffer and CDC Architecture

## Status

PRE-OFFICIAL-BASELINE

---

# 1. Why FIFO Exists

FIFO 不等于 Framebuffer。

FIFO 主要承担：

- temporary buffering
- rate decoupling
- clock-domain crossing

SDRAM Framebuffer 主要承担：

- complete frame storage
- display/read decoupling
- double buffering

---

# 2. Baseline Concept

Documented architecture:

    BMP Pixel Stream
          ↓
    Write Async FIFO
          ↓
    SDRAM Writer
          ↓
    Frame Buffer
          ↓
    SDRAM Reader
          ↓
    Read Async FIFO
          ↓
    Video Consumer

---

# 3. Double Buffer Concept

Documented baseline concept:

    Buffer A
    Buffer B

当：

    Display = A

则后台：

    Write = B

下一帧完整准备好后：

    A -> old
    B -> display

然后下一轮交换角色。

---

# 4. Safety Invariant

必须始终满足：

    write_buffer != display_buffer

在正常双缓冲运行状态下，
Writer 不得覆盖当前显示 Buffer。

---

# 5. Frame Commit

逻辑概念：

    Source Complete
          ↓
    Remaining FIFO Data
          ↓
    SDRAM Writes Complete
          ↓
    Frame Ready
          ↓
    Safe Display Boundary
          ↓
    Commit

具体官方实现是否完全遵循上述阶段：

UNKNOWN

必须通过真实 RTL 确认。

---

# 6. CDC

课程资料描述存在：

    write_finish_toggle

并通过多级寄存器同步后检测变化。

真实实现需要在 RTL 中确认：

[ ] source domain

[ ] destination domain

[ ] synchronizer depth

[ ] edge detection

[ ] reset behavior

[ ] event loss possibility

---

# 7. Future Extensions

OSD：

通常不需要额外完整 Framebuffer，
可考虑 Pixel Pipeline Overlay。

Brightness / Contrast：

可考虑 Pixel Pipeline。

Transition：

可能增加 Framebuffer / bandwidth requirements。

Scaling：

可能增加 line buffer / memory bandwidth / DSP requirements。

以上均属于 DESIGN PLAN，
不能视为当前实现。
