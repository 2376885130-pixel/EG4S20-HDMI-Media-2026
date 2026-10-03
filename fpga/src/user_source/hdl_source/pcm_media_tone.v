`timescale 1ns/1ps

// ============================================================================
// 文件：pcm_media_tone.v
// 模块：pcm_media_tone —— 媒体音调联动音源（第3课：HDMI音频输出基础 2.7节）
//
// 功能：
//   1) 每张图片(media_id=0..3)对应一个六音符琶音循环：
//        media_id=0: C大调上行  C5-E5-G5-C6-G5-E5
//        media_id=1: A小调      A4-C5-E5-A5-E5-C5
//        media_id=2: 五声音阶   C5-D5-E5-G5-A5-C6
//        media_id=3: 低-高摇摆  C5-G4-E5-C5-G4-E5
//   2) 切换图片时先播放 1.5kHz 提示音(blip)，持续 100ms；
//   3) 然后循环播放该图片对应的琶音，每个音符持续 250ms；
//   4) 音量由持久化配置的 volume 参数缩放(0~255)。
//
// 输出为标准 valid/ready PCM 契约(16位有符号立体声)，内部用 8 深度 FIFO
// 缓存样本，可与 hdmi_audio_symbol_core 的采样包封装链路直接对接。
// ============================================================================

module pcm_media_tone #(
    parameter integer CLOCK_HZ     = 25000000,   // 驱动时钟 25MHz(复用像素时钟)
    parameter integer SAMPLE_HZ    = 48000,      // 采样率 48kHz
    parameter [19:0] BLIP_INC      = 20'd32768,  // 1.5kHz 提示音相位增量
    parameter integer BLIP_SAMPLES = 4800,       // 提示音时长 100ms @48kHz
    parameter integer NOTE_SAMPLES = 12000       // 每音符时长 250ms @48kHz
) (
    input  wire               clk,
    input  wire               rst_n,
    input  wire [1:0]         media_id,         // 当前图片ID 0..3
    input  wire [7:0]         volume,           // 音量 0..255(持久化配置)
    output wire               sample_valid,
    input  wire               sample_ready,
    output wire signed [15:0] sample_left,
    output wire signed [15:0] sample_right,
    output reg                overflow,         // FIFO溢出标志
    output wire               blip_active       // 提示音激活标志
);

    reg [24:0] rate_accumulator;    // 分数分频累加器(产生48kHz采样使能)
    reg [19:0] phase;               // 20位DDS相位累加器
    reg [1:0]  media_id_q;          // media_id打一拍(用于检测切换沿)
    reg [12:0] blip_countdown;      // 提示音剩余样本数(0=无提示音)
    reg [2:0]  note_index;          // 当前琶音音符序号 0..5
    reg [14:0] note_sample_count;   // 当前音符已输出样本数
    reg signed [15:0] fifo [0:7];   // 8深度样本FIFO
    reg [2:0]  write_pointer;
    reg [2:0]  read_pointer;
    reg [3:0]  fifo_count;

    wire sample_pop;
    wire sample_tick;
    wire sample_push;

    assign sample_valid = fifo_count != 0;
    assign sample_left  = fifo[read_pointer];
    assign sample_right = fifo[read_pointer];
    assign sample_pop   = sample_valid && sample_ready;
    assign sample_tick  = rate_accumulator >= CLOCK_HZ - SAMPLE_HZ;
    assign sample_push  = sample_tick && (fifo_count != 8 || sample_pop);
    assign blip_active  = blip_countdown != 0;

    // phase_inc = freq * 2^20 / SAMPLE_HZ (freq * 21.8453)
    function [19:0] melody_inc;
        input [1:0] melody;
        input [2:0] note;
        begin
            case ({melody, note})
                // media_id=0: C大调上行 C5 E5 G5 C6 G5 E5
                5'b00_000: melody_inc = 20'd11426;  // C5 523Hz
                5'b00_001: melody_inc = 20'd14396;  // E5 659Hz
                5'b00_010: melody_inc = 20'd17127;  // G5 784Hz
                5'b00_011: melody_inc = 20'd22860;  // C6 1046Hz
                5'b00_100: melody_inc = 20'd17127;  // G5
                5'b00_101: melody_inc = 20'd14396;  // E5
                // media_id=1: A小调 A4 C5 E5 A5 E5 C5
                5'b01_000: melody_inc = 20'd9634;   // A4 440Hz
                5'b01_001: melody_inc = 20'd11426;  // C5
                5'b01_010: melody_inc = 20'd14396;  // E5
                5'b01_011: melody_inc = 20'd19269;  // A5 880Hz
                5'b01_100: melody_inc = 20'd14396;  // E5
                5'b01_101: melody_inc = 20'd11426;  // C5
                // media_id=2: 五声音阶 C5 D5 E5 G5 A5 C6
                5'b10_000: melody_inc = 20'd11426;  // C5
                5'b10_001: melody_inc = 20'd12833;  // D5 587Hz
                5'b10_010: melody_inc = 20'd14396;  // E5
                5'b10_011: melody_inc = 20'd17127;  // G5
                5'b10_100: melody_inc = 20'd19269;  // A5
                5'b10_101: melody_inc = 20'd22860;  // C6
                // media_id=3: 低-高摇摆 C5 G4 E5 C5 G4 E5
                5'b11_000: melody_inc = 20'd11426;  // C5
                5'b11_001: melody_inc = 20'd8566;   // G4 392Hz
                5'b11_010: melody_inc = 20'd14396;  // E5
                5'b11_011: melody_inc = 20'd11426;  // C5
                5'b11_100: melody_inc = 20'd8566;   // G4
                5'b11_101: melody_inc = 20'd14396;  // E5
                default:   melody_inc = 20'd11426;
            endcase
        end
    endfunction

    // 16点正弦波LUT(峰值12000,约为16位有符号最大值的1/3,避免爆音)
    function signed [15:0] sine_sample;
        input [3:0] index;
        begin
            case (index)
                4'd0:  sine_sample = 16'sd0;
                4'd1:  sine_sample = 16'sd4592;
                4'd2:  sine_sample = 16'sd8485;
                4'd3:  sine_sample = 16'sd11087;
                4'd4:  sine_sample = 16'sd12000;
                4'd5:  sine_sample = 16'sd11087;
                4'd6:  sine_sample = 16'sd8485;
                4'd7:  sine_sample = 16'sd4592;
                4'd8:  sine_sample = 16'sd0;
                4'd9:  sine_sample = -16'sd4592;
                4'd10: sine_sample = -16'sd8485;
                4'd11: sine_sample = -16'sd11087;
                4'd12: sine_sample = -16'sd12000;
                4'd13: sine_sample = -16'sd11087;
                4'd14: sine_sample = -16'sd8485;
                default: sine_sample = -16'sd4592;
            endcase
        end
    endfunction

    wire [19:0] melody_note_inc = melody_inc(media_id_q, note_index);
    wire [19:0] phase_inc = (blip_countdown != 0) ? BLIP_INC : melody_note_inc;

    wire signed [15:0] raw_sample = sine_sample(phase[19:16]);
    wire signed [23:0] scaled = raw_sample * $signed({1'b0, volume});
    wire signed [15:0] scaled_clamped =
        (scaled > 24'sd8388352)  ? 16'sd32767 :
        (scaled < -24'sd8388608) ? -16'sd32768 : scaled >>> 8;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rate_accumulator <= 25'd0;
            phase            <= 20'd0;
            media_id_q       <= 2'd0;
            blip_countdown   <= 13'd0;
            note_index       <= 3'd0;
            note_sample_count<= 14'd0;
            write_pointer    <= 3'd0;
            read_pointer     <= 3'd0;
            fifo_count       <= 4'd0;
            overflow         <= 1'b0;
        end else begin
            media_id_q <= media_id;

            // 分数分频:rate_accumulator 每次加 SAMPLE_HZ,达到 CLOCK_HZ 产生一次采样脉冲
            if (sample_tick)
                rate_accumulator <= rate_accumulator + SAMPLE_HZ - CLOCK_HZ;
            else
                rate_accumulator <= rate_accumulator + SAMPLE_HZ;

            // 采样脉冲到来且FIFO有空位时,生成并压入一个新样本
            if (sample_push) begin
                fifo[write_pointer] <= scaled_clamped;
                write_pointer <= write_pointer + 1'b1;
                phase <= phase + phase_inc;
                if (blip_countdown != 0) begin
                    blip_countdown <= blip_countdown - 1'b1;
                end else if (note_sample_count >= NOTE_SAMPLES - 1) begin
                    note_sample_count <= 14'd0;
                    note_index <= (note_index == 3'd5) ? 3'd0 : note_index + 1'b1;
                end else begin
                    note_sample_count <= note_sample_count + 1'b1;
                end
            end else if (sample_tick) begin
                overflow <= 1'b1;  // 采样脉冲到来但FIFO满,报告溢出
            end

            if (sample_pop)
                read_pointer <= read_pointer + 1'b1;

            case ({sample_push, sample_pop})
                2'b10: fifo_count <= fifo_count + 1'b1;
                2'b01: fifo_count <= fifo_count - 1'b1;
                default: fifo_count <= fifo_count;
            endcase

            // 检测到图片切换:重新装载提示音,琶音从头开始
            if (media_id != media_id_q) begin
                blip_countdown    <= BLIP_SAMPLES[12:0];
                note_index        <= 3'd0;
                note_sample_count <= 14'd0;
            end
        end
    end

endmodule
