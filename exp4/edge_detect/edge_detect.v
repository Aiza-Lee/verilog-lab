`timescale 1ns/1ps
module edge_detect (
	input  wire clk,
	input  wire rst_n,		// 异步复位，低有效
	input  wire in_btn,
	output wire pulse
);
	reg sync_0, sync_1;
	reg prev;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			sync_0 <= 1'b0;
			sync_1 <= 1'b0;
			prev   <= 1'b0;
		end else begin
			sync_0 <= in_btn;
			sync_1 <= sync_0;
			prev   <= sync_1;
		end
	end

	assign pulse = (sync_1 & ~prev);

endmodule
