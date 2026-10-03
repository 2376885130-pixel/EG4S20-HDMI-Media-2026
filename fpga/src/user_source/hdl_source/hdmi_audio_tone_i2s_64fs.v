// ============================================================================
// 文件：hdmi_audio_tone_i2s_64fs_optimized.v
// 说明：官方例程 hdmi_audio_tone_i2s_64fs.v 的优化版（第3课：HDMI音频输出基础）
//
// 本文件为“只新增、不改动原工程任何文件”的独立优化文件。
// 模块名、端口名、参数默认值均与原 hdmi_audio_tone_i2s_64fs 完全一致，因此
// 可直接替换原文件（或把本文件加入工程并移除原 hdmi_audio_tone_i2s_64fs.v），
// 顶层 top_tf_hdmi_audio.v 无需做任何改动即可无缝兼容。
//
// 优化点（对应课程“从官方方波到正弦波”的核心升级）：
//   官方例程用 32 位相位累加器的最高位 S_phase_acc[31] 直接决定输出 ±AMP，
//   生成的是方波，含大量高频谐波，听感生硬。本优化改为 16 点正弦波查找表
//   （DDS）：取相位累加器高 4 位 S_phase_acc[31:28] 作为 LUT 地址查正弦表，
//   再按 AMP 缩放得到 24 位正弦样本，从而输出音质更好的正弦波。
//
//   其余部分（8 音符循环、64fs I2S 发送时序、移位寄存器、接口时序）均与
//   官方例程保持完全一致，不触碰 HDMI 发射器 / I2S 接收等底层模块。
// ============================================================================

module hdmi_audio_tone_i2s_64fs #(
    parameter [31:0] PHASE_INC = 32'd39370534,   // 兼容旧顶层，实际本版内部不用它
    parameter signed [23:0] AMP = 24'sd2000000,
    parameter integer NOTE_HOLD_FRAMES = 24000   // 每个音持续 0.5s @ 48kHz
)(
    input  wire I_mclk,      // 12.288MHz
    input  wire I_rst,
    output reg  O_i2s_BCLK,
    output reg  O_i2s_LRCK,
    output reg  O_i2s_DOUT
);

// do/re/mi/fa/so/la/si/do  （C4 D4 E4 F4 G4 A4 B4 C5）
// 相位增量按 48kHz 采样率计算
function [31:0] note_inc_lut;
    input [2:0] idx;
    begin
        case (idx)
            3'd0: note_inc_lut = 32'd23409862; // do  C4 261.63Hz
            3'd1: note_inc_lut = 32'd26276681; // re  D4 293.66Hz
            3'd2: note_inc_lut = 32'd29494578; // mi  E4 329.63Hz
            3'd3: note_inc_lut = 32'd31248410; // fa  F4 349.23Hz
            3'd4: note_inc_lut = 32'd35075155; // so  G4 392.00Hz
            3'd5: note_inc_lut = 32'd39370534; // la  A4 440.00Hz
            3'd6: note_inc_lut = 32'd44191930; // si  B4 493.88Hz
            default: note_inc_lut = 32'd46819716; // do  C5 523.25Hz
        endcase
    end
endfunction

// === 新增：16 点正弦波 LUT（DDS）===
// 归一化到峰值 2^14=16384 表示满幅，配合 AMP 做移位缩放，避免除法、资源极小。
// 相位累加器高 4 位 [31:28] 作为地址，一个相位周期恰好遍历 16 点。
function signed [15:0] sine_lut;
    input [3:0] idx;
    begin
        case (idx)
            4'd0:  sine_lut = 16'sd0;       // sin(0°)
            4'd1:  sine_lut = 16'sd6270;    // sin(22.5°)
            4'd2:  sine_lut = 16'sd11585;   // sin(45°)
            4'd3:  sine_lut = 16'sd15137;   // sin(67.5°)
            4'd4:  sine_lut = 16'sd16384;   // sin(90°)
            4'd5:  sine_lut = 16'sd15137;   // sin(112.5°)
            4'd6:  sine_lut = 16'sd11585;   // sin(135°)
            4'd7:  sine_lut = 16'sd6270;    // sin(157.5°)
            4'd8:  sine_lut = 16'sd0;       // sin(180°)
            4'd9:  sine_lut = -16'sd6270;   // sin(202.5°)
            4'd10: sine_lut = -16'sd11585;  // sin(225°)
            4'd11: sine_lut = -16'sd15137;  // sin(247.5°)
            4'd12: sine_lut = -16'sd16384;  // sin(270°)
            4'd13: sine_lut = -16'sd15137;  // sin(292.5°)
            4'd14: sine_lut = -16'sd11585;  // sin(315°)
            default: sine_lut = -16'sd6270; // sin(337.5°)
        endcase
    end
endfunction

reg  [5:0]  S_bit_cnt;
reg  [63:0] S_shift_reg;
reg  [31:0] S_phase_acc;
reg signed [23:0] S_sample_word;
reg signed [23:0] S_sample_next;
reg  [2:0]  S_note_idx;
reg [15:0]  S_note_frame_cnt;

wire [31:0] W_note_inc = note_inc_lut(S_note_idx);

// === 新增：正弦查表 + 按 AMP 缩放（峰值 = AMP，算术右移 14 即除以 2^14）===
wire signed [15:0] W_sine_raw    = sine_lut(S_phase_acc[31:28]);
wire signed [39:0] W_sine_scaled = W_sine_raw * AMP;
wire signed [23:0] W_sine_sample = W_sine_scaled >>> 14;

always @(posedge I_mclk or posedge I_rst) begin
    if (I_rst) begin
        O_i2s_BCLK      <= 1'b0;
        O_i2s_LRCK      <= 1'b0;
        O_i2s_DOUT      <= 1'b0;
        S_bit_cnt       <= 6'd0;
        S_shift_reg     <= 64'd0;
        S_phase_acc     <= 32'd0;
        S_sample_word   <= 24'sd0;
        S_sample_next   <= 24'sd0;
        S_note_idx      <= 3'd0;
        S_note_frame_cnt<= 16'd0;
    end
    else begin
        // 保持和你现有接收端兼容的 64fs 发送时序
        O_i2s_BCLK <= ~O_i2s_BCLK;

        if (O_i2s_BCLK == 1'b1) begin
            O_i2s_DOUT  <= S_shift_reg[63];
            S_shift_reg <= {S_shift_reg[62:0], 1'b0};

            if (S_bit_cnt == 6'd63) begin
                S_bit_cnt <= 6'd0;

                if (O_i2s_LRCK == 1'b0) begin
                    // 左声道发完，右声道复用同一个样本
                    O_i2s_LRCK  <= 1'b1;
                    S_shift_reg <= {S_sample_word[23:0], 40'd0};
                end
                else begin
                    // 右声道发完，进入下一帧样本
                    O_i2s_LRCK  <= 1'b0;

                    S_phase_acc <= S_phase_acc + W_note_inc;
                    // === 优化：正弦波（16 点 LUT）替代方波 ===
                    S_sample_next <= W_sine_sample;

                    S_sample_word <= S_sample_next;
                    S_shift_reg   <= {S_sample_next[23:0], 40'd0};

                    if (S_note_frame_cnt == NOTE_HOLD_FRAMES - 1) begin
                        S_note_frame_cnt <= 16'd0;
                        if (S_note_idx == 3'd7)
                            S_note_idx <= 3'd0;
                        else
                            S_note_idx <= S_note_idx + 3'd1;
                    end
                    else begin
                        S_note_frame_cnt <= S_note_frame_cnt + 16'd1;
                    end
                end
            end
            else begin
                S_bit_cnt <= S_bit_cnt + 6'd1;
            end
        end
    end
end

endmodule
