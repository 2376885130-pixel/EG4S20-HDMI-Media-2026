# EG4S20 HDMI Media Player 2026

2026 全国大学生嵌入式芯片与系统设计竞赛
FPGA赛道 · 安路科技 · 选题一

基于 HX4S20C / EG4S20 的 HDMI 多媒体播放系统。

## Current Stage

当前阶段：Phase 0 — Official Baseline Preparation

当前尚未修改官方 RTL，也尚未导入官方例程。

第一阶段目标：

1. 导入官方 lab_ex_4
2. 编译官方工程
3. HX4S20C 上板验证
4. 验证 TF 卡 BMP 读取
5. 验证 SDRAM Frame Buffer
6. 验证 HDMI 显示
7. 验证手动切图与自动轮播
8. 建立可信的官方 Golden Reference
9. 再导入并验证 lab_ex_5 音频链路

## Development Principle

Official Baseline -> Understand -> Document -> One Change -> Verify -> Commit

核心原则：One change at a time.

官方工程尚未跑通前，不进行大规模 RTL 重构。

## Repository Structure

- official/ : 官方原始参考工程，原则上保持不修改
- fpga/     : 自主开发的比赛工程
- docs/     : 架构、设计、验证与 AI 审核规范
- sim/      : 仿真环境与测试数据
- reports/  : 综合、时序与资源报告
- scripts/  : 辅助脚本

## Planned RTL Architecture

- integration
- control
- storage
- filesystem
- image
- memory
- display
- audio
- io
- config
- recovery
- metrics
- diag

## Main Data Path

TF Card -> SPI/SD -> BMP Decoder -> Write FIFO -> SDRAM Frame Buffer -> Read FIFO -> Video Pipeline -> HDMI -> Display

## Status

- Official lab_ex_4: NOT IMPORTED
- Official lab_ex_5: NOT IMPORTED
- Hardware verification: NOT STARTED
- Custom RTL: NOT STARTED
