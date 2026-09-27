# Clock Domain Map

## Status

PRE-OFFICIAL-BASELINE

以下频率来自课程资料。

实际 Clock Net / PLL / Module Ownership
必须在官方 RTL 导入后确认。

---

## Documented Clocks

| Clock | Frequency | Planned / Documented Responsibility |
|---|---:|---|
| sd_card_clk | 100 MHz | TF / SD / Control |
| ext_mem_clk | 100 MHz | SDRAM |
| ext_mem_clk_sft | 100 MHz shifted | SDRAM sampling |
| video_clk | 25 MHz | 640x480 video domain |
| hdmi_5x_clk | 125 MHz | HDMI serialization |
| audio_mclk | 12.288 MHz | Audio |

---

## Important Rule

Same Frequency != Same Clock Domain

例如：

    sd_card_clk = 100 MHz

和：

    ext_mem_clk = 100 MHz

即使频率相同，

也不能在没有确认相位关系和时钟来源的情况下
假设它们同步。

---

## CDC Classification

### State

    source state
        ↓
    synchronizer
        ↓
    destination state

### Event

    event
      ↓
    toggle
      ↓
    synchronizer
      ↓
    edge detect

### Streaming Data

    producer
       ↓
    asynchronous FIFO
       ↓
    consumer

---

## RTL Verification TODO

导入官方工程以后：

[ ] 找到所有 PLL

[ ] 记录 PLL 输入时钟

[ ] 记录所有 PLL 输出

[ ] 搜索所有 always @(posedge ...)

[ ] 为每个 sequential module 标记 Clock Domain

[ ] 搜索跨域单 bit signal

[ ] 搜索 toggle synchronizer

[ ] 搜索 Async FIFO

[ ] 检查 Reset Domain Crossing

---

## Rule For Future RTL

任何新寄存器都必须回答：

    Which clock owns this register?

任何新模块都必须在文档中声明：

    CLOCK DOMAIN:
