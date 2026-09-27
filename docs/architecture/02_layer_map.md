# Layer Map

## Status

PRE-OFFICIAL-BASELINE

本文件描述目标责任分层。

实际 RTL 映射将在官方例程导入后确认。

---

## integration

Responsibility:

系统级模块连接。

Future examples:

- top
- media_ingest_pipeline
- media_video_pipeline

原则：

integration 负责连接模块，
不应该成为巨型业务逻辑文件。

---

## control

Responsibility:

播放器控制与系统策略。

Examples:

- 图片切换
- 自动轮播
- 播放状态
- Buffer 切换请求
- 用户操作调度

官方例程预计主要对应：

sd_card_bmp

STATUS:

DOCUMENTED
CODE-CONFIRMATION REQUIRED

---

## storage

Responsibility:

TF / SD 卡底层访问。

Examples:

- SPI
- SD command
- sector read

预计官方模块：

sd_card_top
spi_master

STATUS:

DOCUMENTED
CODE-CONFIRMATION REQUIRED

---

## filesystem

Responsibility:

文件系统解析。

Future:

- FAT32
- directory
- FAT chain
- filename lookup

官方 baseline 不应默认存在完整 FAT32。

STATUS:

FUTURE EXTENSION

---

## image

Responsibility:

图像格式解析。

Examples:

- BMP header
- pixel extraction
- RGB conversion

预计官方模块：

bmp_read

STATUS:

DOCUMENTED
CODE-CONFIRMATION REQUIRED

---

## memory

Responsibility:

跨速率缓存和 Framebuffer。

Examples:

- Async FIFO
- SDRAM
- Frame Read/Write
- Buffer Ownership
- Frame Commit

预计官方模块：

frame_fifo_write
frame_read_write
frame_fifo_read
sdram

STATUS:

DOCUMENTED
CODE-CONFIRMATION REQUIRED

---

## display

Responsibility:

视频消费和图像处理。

Baseline:

- video timing
- pixel output
- HDMI preparation

Future:

- OSD
- brightness
- contrast
- transition
- scaling
- waveform overlay

---

## audio

Responsibility:

音频生成、接收和 HDMI Audio。

Baseline:

Test Tone -> I2S -> PCM -> HDMI

Future:

- audio visualization
- alternative audio source

---

## io

Responsibility:

用户输入与状态输出。

Examples:

- KEY
- seven segment display
- UART

---

## config

Responsibility:

参数与配置持久化。

STATUS:

FUTURE EXTENSION

---

## recovery

Responsibility:

异常检测和恢复。

STATUS:

FUTURE EXTENSION

---

## metrics

Responsibility:

性能与运行状态监控。

STATUS:

FUTURE EXTENSION

---

## diag

Responsibility:

诊断模式与自检。

STATUS:

FUTURE EXTENSION

---

## Modification Principle

新增需求首先回答：

    Which layer owns this requirement?

然后才决定修改哪个 RTL 文件。

禁止因为某个文件“容易找到”，
就把不属于该层的功能塞进去。
