# Extension Plan

## Status

PLANNING ONLY

当前禁止因为本文件存在，
就认为这些功能已经实现。

---

# Phase 0

Repository / Documentation

Status:

IN PROGRESS

---

# Phase 1

Official lab_ex_4 Baseline

Goals:

- TF
- BMP
- SDRAM
- HDMI Video
- Manual Switching
- Auto Play
- Double Buffer

Status:

NOT STARTED

---

# Phase 2

Official lab_ex_5 Baseline

Goals:

- HDMI Video
- 48 kHz Audio Test
- Video + Audio

Status:

NOT STARTED

---

# Phase 3

Architecture Confirmation

Goals:

- Module Tree
- Clock Domain Map
- CDC Map
- Data Flow Map
- Framebuffer Map
- Risk Map

Status:

NOT STARTED

---

# Phase 4

Control Improvements

Candidates:

- Previous Image
- Configurable Auto-play Period
- Image Number Display
- Better Key Handling

Status:

PLANNED

---

# Phase 5

Display Extensions

Candidates:

- OSD
- Subtitle
- Brightness
- Contrast
- Transition
- Scaling

Rule:

Do not implement all extensions simultaneously.

Select a small number after baseline stability and resource analysis.

Status:

PLANNED

---

# Phase 6

Engineering Improvements

Candidates:

- UART diagnostics
- Internal test pattern
- Error recovery
- Timeout handling
- Long-run monitoring
- Flash auto boot verification

Status:

PLANNED

---

# Selection Rule

An extension should only enter implementation after answering:

1. What competition requirement does it support?
2. Which layer owns it?
3. Which clock domain owns it?
4. Does it introduce CDC?
5. Does it increase SDRAM bandwidth?
6. Does it require extra framebuffer?
7. Does it increase pipeline latency?
8. What resources does it consume?
9. How will it be independently verified?
10. How can it be disabled for A/B testing?
