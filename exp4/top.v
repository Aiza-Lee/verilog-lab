/**
 * 设计数码管控制器，要求能够控制8个数码管（从左往右DK7-DK0）同时稳定地显示数字，要求如下：
 * - DK7-DK6显示自己学号后两位；
 * - DK5-DK4显示输入计数，读取按键开关S3，每按一次计数一次，持续按住只计数一次，不做消抖直接计数；
 * - DK3-DK2显示输入计数，读取按键开关S3，每按一次计数一次，持续按住只计数一次，要求消抖实现稳定计数；
 * - DK1-DK0显示十进制计数，实现一个计数间隔为0.1s的从0到30的十进制计数器，复位后直接开始计数，
 * 计数到30再从0开始，按键开关S2控制计数的启停，按一下暂停再按一下继续，不断重复；
 * - 按键开关S2作为十进制计数器控制信号；
 * - 拨码开关SW0作为数码管整体使能控制信号，往上拨正常显示，往下拨8个数码管灭，计数器等模块仍正常工作；
 * - 按键开关S1作为异步复位信号，当S1按下为1时，所有时序逻辑将被复位，复位状态的显示自行决定；
 */
`timescale 1ns/1ps
module top (
	input wire clk,					// 100MHz时钟
	input wire button_reset,		// 按键S1，异步复位，高有效
	input wire button_start_stop,	// 十进制计数器启停按键S2
	input wire button_count,		// 计数按键S3
	input wire global_led_en,		// 数码管整体使能开关SW0

	output wire [7:0] led_en,		// 位选信号
	output wire [7:0] led_cx		// 段选信号
);

	wire count_pulse; // button_count 的脉冲信号
	reg [7:0] count_value;
	edge_detect u_edge_detect_button_count (
		.clk(clk),
		.rst_n(~button_reset),
		.in_btn(button_count),
		.pulse(count_pulse)
	);
	// 不消抖计数
	always @(posedge clk or posedge button_reset) begin
		if (button_reset)
			count_value <= 8'd0;
		else if (count_pulse)
			count_value <= count_value + 1;
	end

	wire debounced_count_pulse;
	reg [7:0] debounced_count_value;
	debounced_button_pulse #(.LAST_CYCLES(2_000_000)) u_debounced_button_count (
		.clk(clk),
		.rst_n(~button_reset),
		.noisy_in(button_count),
		.pulse(debounced_count_pulse)
	);
	// 消抖计数
	always @(posedge clk or posedge button_reset) begin
		if (button_reset) begin
			debounced_count_value <= 8'd0;
		end else begin
			if (debounced_count_pulse)
				debounced_count_value <= debounced_count_value + 1;
		end
	end

	wire debounced_start_stop_pulse;
	debounced_button_pulse #(.LAST_CYCLES(2_000_000)) u_debounced_button_start_stop (
		.clk(clk),
		.rst_n(~button_reset),
		.noisy_in(button_start_stop),
		.pulse(debounced_start_stop_pulse)
	);
	wire [7:0] decimal_counter_value;
	counter_30 u_counter_30 (
		.clk(clk),
		.rst_n(~button_reset),
		.start_stop_pulse(debounced_start_stop_pulse),
		.count(decimal_counter_value)
	);

	// 数码管控制单元
	localparam [7:0] MY_ID = 8'h81;
	reg [31:0] display_data;
	led_ctrl_unit u_led_ctrl_unit (
		.clk(clk),
		.rst_n(~button_reset),
		.en(global_led_en),
		.display(display_data),
		.led_en(led_en),
		.led_cx(led_cx)
	);

	// 组合显示数据
	always @(*) begin
		if (global_led_en) begin
			display_data[31:24] = MY_ID;					// DK7-DK6 显示学号后两位
			display_data[23:16] = count_value;				// DK5-DK4 显示不消抖计数
			display_data[15:8]  = debounced_count_value;	// DK3-DK2 显示消抖计数
			display_data[7:0]   = decimal_counter_value;	// DK1-DK0 显示十进制计数器
		end else begin
			display_data = 32'h0000_0000; // 不使能时全灭
		end
	end

endmodule