`timescale 1ns/1ps
module debounce (
	input wire clk,
	input wire rst_n,		// 异步复位，低有效
	input wire noisy_in,
	output wire stable_out
);

	// 采样计数器
	localparam integer SAMPLE_CNT_MAX = 100; // 100ms
	reg [6:0] sample_cnt;
	reg noisy_reg;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			sample_cnt <= 7'd0;
			noisy_reg <= 1'b0;
		end else begin
			if (noisy_in == noisy_reg) begin
				if (sample_cnt < SAMPLE_CNT_MAX) begin
					sample_cnt <= sample_cnt + 1'b1;
				end
			end else begin
				noisy_reg <= noisy_in;
				sample_cnt <= 7'd0;
			end
		end
	end

	assign stable_out = (sample_cnt == SAMPLE_CNT_MAX) ? noisy_reg : 1'b0;

endmodule