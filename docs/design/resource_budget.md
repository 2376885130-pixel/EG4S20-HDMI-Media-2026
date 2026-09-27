# Resource Budget

## Device

EG4S20

Documented device resources:

LUT:
19600

FF:
19600

Internal SDRAM:
2M x 32

PLL:
4

---

# Baseline

Actual utilization:

UNKNOWN

To be collected after official project synthesis.

---

# Custom Design Budget

| Feature | LUT | FF | RAM | DSP | SDRAM BW | Status |
|---|---:|---:|---:|---:|---|---|
| Official Baseline | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | TODO |
| Control Improvements | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | Low | TODO |
| OSD | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | TBD | TODO |
| Brightness | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | TBD | TODO |
| Contrast | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | TBD | TODO |
| Transition | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | High/TBD | TODO |
| Scaling | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | High/TBD | TODO |
| Audio Visualization | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | TBD | TODO |

---

# Framebuffer Calculation

For RGB888 640 x 480:

640 x 480 x 3

=

921600 Bytes

=

900 KiB per frame

Two RGB888 frames:

1843200 Bytes

approximately:

1.76 MiB

This is a logical capacity calculation only.

Actual SDRAM:

- addressing
- packing
- controller width
- burst organization

must be confirmed from real RTL / IP configuration.

---

# Rule

Do not use estimated resource numbers as measured synthesis results.

Measured utilization must come from actual implementation reports.
