# Module Risk Map

## Status

PRE-OFFICIAL-BASELINE

本表目前依据课程资料。

官方 RTL 导入后必须确认真实文件路径和实例关系。

---

| Module / Category | Role | Modification Policy | Risk |
|---|---|---|---|
| sd_card_bmp | Application / Control | Main modification area | Medium |
| bmp_read | BMP parser | Modify carefully | Medium |
| sd_card_top | SD protocol | Avoid unless necessary | High |
| spi_master | SPI driver | Avoid unless necessary | High |
| frame_read_write | Framebuffer control | Modify very carefully | High |
| frame FIFO | Async CDC | Preserve baseline | Very High |
| video_timing_data | Video timing | Preserve baseline | Very High |
| video_delay | Timing alignment | Preserve baseline | High |
| SDRAM controller | Vendor / encrypted IP | Do not modify | Critical |
| HDMI TX Core | Vendor / encrypted IP | Do not modify | Critical |
| HDMI PHY | High-speed PHY | Preserve baseline | Critical |
| audio test tone | Audio source | Safe extension area | Low |
| seven segment | User IO | Safe extension area | Low |

---

# AI Modification Policy

## Low Risk

AI may propose localized modifications with normal review.

## Medium Risk

AI must provide:

- affected FSM
- clock domain
- state transition impact
- regression plan

## High Risk

AI must first prove that the problem belongs to this layer.

A/B comparison with official baseline is preferred.

## Critical

Default:

DO NOT MODIFY.

If a problem appears to originate here:

first verify all surrounding interfaces and integration.

---

# Important Rule

Symptom location != Root cause location.

例如：

HDMI 花屏

不代表：

HDMI IP 有问题。

根因可能位于：

    BMP
     ↓
    FIFO
     ↓
    SDRAM
     ↓
    Video Timing

因此禁止 AI 根据最终症状直接修改最底层模块。
