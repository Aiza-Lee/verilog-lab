`timescale 1ns/1ps
module debounced_button_pulse #(
	parameter integer LAST_CYCLES = 2_000_000 // 去抖稳定所需的时钟周期数，默认20ms at 100MHz
) (
	input wire clk,
	input wire rst_n,		// 异步复位，低有效
	input wire noisy_in,	// 按键原始输入（可能有抖动）
	output wire pulse		// 去抖后的按键脉冲输出
);

	wire stable_out; // 去抖后的稳定信号

	debounce #(.LAST_CYCLES(LAST_CYCLES)) u_debounce (
		.clk(clk),
		.rst_n(rst_n),
		.noisy_in(noisy_in),
		.stable_out(stable_out)
	);

	edge_detect u_edge_detect (
		.clk(clk),
		.rst_n(rst_n),
		.in_btn(stable_out),
		.pulse(pulse)
	);

endmodule