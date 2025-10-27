`timescale 1ns/1ps
module led_8 (
	input wire clk,				// 100MHz时钟
	input wire rst,				// 异步复位，高有效
	input wire button,			// 启停切换
	input wire [1:0] freq_set,	// 频率设置
	input wire dir_set,			// 方向设置
	output reg [7:0] led		// 8位LED输出
);

	// 分频参数
	reg [31:0] cnt;
	reg [31:0] cnt_max;
	wire tick;

	// 启停状态
	reg running;
	reg button_sync_0, button_sync_1, button_sync_2;

	// 分频系数
	always @(*) begin
		case(freq_set)
			2'b00: cnt_max =    100_000 - 1;	// 0.001s, 1000Hz
			2'b01: cnt_max =  1_000_000 - 1;	// 0.01s,   100Hz
			2'b10: cnt_max =  5_000_000 - 1;	// 0.05s,    20Hz
			2'b11: cnt_max = 20_000_000 - 1;	// 0.2s,      5Hz
			default: cnt_max =  100_000 - 1;
		endcase
	end

	// 分频计数器
	always @(posedge clk or posedge rst) begin
		if (rst)					cnt <= 0;
		else if (cnt >= cnt_max)	cnt <= 0;
		else						cnt <= cnt + 1;
	end
	assign tick = (cnt == cnt_max);

	// 按键同步与上升沿检测（三级寄存器）
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			button_sync_0 <= 1'b0;
			button_sync_1 <= 1'b0;
			button_sync_2 <= 1'b0;
			running <= 1'b0;
		end else begin
			button_sync_0 <= button;
			button_sync_1 <= button_sync_0;
			button_sync_2 <= button_sync_1;
			if (~button_sync_2 & button_sync_1) // 检测同步后上升沿
				running <= ~running;
		end
	end

	// 流水灯逻辑
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			led <= 8'b0000_0001;
		end else if (tick && running) begin
			if (dir_set) begin // 左移
				if (led == 8'b1000_0000)
					led <= 8'b0000_0001;
				else
					led <= led << 1;
			end else begin // 右移
				if (led == 8'b0000_0001)
					led <= 8'b1000_0000;
				else
					led <= led >> 1;
			end
		end
	end

endmodule