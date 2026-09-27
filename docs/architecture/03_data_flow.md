# Data Flow

## Status

PRE-OFFICIAL-BASELINE

当前数据流来自课程资料。

真实 RTL 导入后必须逐端口验证。

---

# Video Data Path

DOCUMENTED:

    TF Card
       ↓
    sd_card_top
       ↓
    SPI / Sector Data
       ↓
    bmp_read
       ↓
    RGB24 Pixel
       ↓
    frame_fifo_write
       ↓
    Async FIFO
       ↓
    frame_read_write
       ↓
    SDRAM Frame Buffer
       ↓
    frame_read_write
       ↓
    Async FIFO
       ↓
    video_timing_data
       ↓
    video_delay
       ↓
    video_rgb_to_axis
       ↓
    HDMI TX Core
       ↓
    HDMI PHY
       ↓
    Display

---

# Audio Data Path

DOCUMENTED:

    hdmi_audio_tone_i2s_64fs
       ↓
    I2S
       ↓
    I2S_receiver
       ↓
    PCM
       ↓
    audio_arc_calculate
       ↓
    HDMI TX Core

---

# Future Video Processing Insertion Point

规划：

    SDRAM
       ↓
    Read FIFO
       ↓
    Pixel Stream
       ↓
    [Video Processing Pipeline]
       │
       ├── Brightness
       ├── Contrast
       ├── OSD
       ├── Transition
       └── Scaling
       ↓
    HDMI

注意：

该插入位置当前属于 DESIGN PLAN。

不是 CODE-CONFIRMED。

---

# Important Semantic Boundaries

不得混淆：

    BMP source done

与：

    FIFO drained

与：

    SDRAM write complete

与：

    frame ready

与：

    frame displayed

它们表示不同阶段。

---

# Verification TODO

官方 RTL 导入后确认：

[ ] TF -> BMP handshake

[ ] BMP -> Write FIFO handshake

[ ] FIFO -> SDRAM handshake

[ ] SDRAM write completion semantics

[ ] SDRAM -> Read FIFO request mechanism

[ ] FIFO -> Video consumption semantics

[ ] DE / RGB relationship

[ ] HDMI AXIS handshake

[ ] Audio sample handshake
