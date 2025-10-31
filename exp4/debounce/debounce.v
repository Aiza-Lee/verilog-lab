`timescale 1ns/1ps
module debounce #(
	parameter integer LAST_CYCLES = 2_000_000	// 稳定采样周期数
)(
	input wire clk,
	input wire rst_n,		// 异步复位，低有效
	input wire noisy_in,
	output wire stable_out
);

	// 采样计数器
	reg integer sample_cnt;
	reg noisy_reg;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			sample_cnt <= 0;
			noisy_reg <= 1'b0;
		end else begin
			if (noisy_in == noisy_reg) begin
				if (sample_cnt < LAST_CYCLES) begin
					sample_cnt <= sample_cnt + 1;
				end
			end else begin
				noisy_reg <= noisy_in;
				sample_cnt <= 0;
			end
		end
	end

	assign stable_out = (sample_cnt >= LAST_CYCLES) ? noisy_reg : 1'b0;

endmodule