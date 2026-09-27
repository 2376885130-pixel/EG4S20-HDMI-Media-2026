# Design Decision Log

本文件记录重要架构决策。

---

# DD-001 — Preserve Official Reference

Status:

ACCEPTED

Decision:

official/lab_ex_4
official/lab_ex_5

用于保存官方原始参考工程。

原则上不直接进行比赛功能开发。

Reason:

1. 保留可信回退路径
2. 支持 A/B Debug
3. 避免误修改官方基线
4. 区分 Vendor Baseline 与 Custom Design

---

# DD-002 — Custom Development Under fpga/

Status:

ACCEPTED

Decision:

自主开发 RTL 放在：

fpga/

而不是直接覆盖：

official/

Reason:

保持官方版本与自研版本边界清晰。

---

# DD-003 — Baseline Before Optimization

Status:

ACCEPTED

Decision:

在官方 lab_ex_4 尚未完成真实上板验证前，

不进行大规模 RTL 重构。

在视频链稳定后，

再验证 lab_ex_5 音频。

---

# DD-004 — One Major Change Per Experiment

Status:

ACCEPTED

Decision:

每轮实验尽量只改变一个主要变量。

Reason:

FPGA 问题可能同时涉及：

Clock
CDC
FIFO
SDRAM
Video Timing
Control FSM

同时修改多个子系统会破坏因果定位能力。

---

# DD-005 — Evidence Classification

Status:

ACCEPTED

Use:

DOCUMENTED
CODE-CONFIRMED
SIMULATED
BOARD-VERIFIED
INFERRED
UNKNOWN

Reason:

防止文档、代码推断、仿真和真实硬件结果混为一谈。
