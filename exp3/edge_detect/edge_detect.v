module edge_detect (
	input wire clk,			// 时钟信号
	input wire rst,			// 异步复位信号，高电平有效
	input wire signal,			// 待检测信号
	output wire pos_edge	// 上升沿检测输出
);

	reg sig_r1, sig_r2, sig_r3;

	always @(posedge clk or negedge rst) begin
		if (rst) begin
			sig_r1 <= 1'b0;
			sig_r2 <= 1'b0;
			sig_r3 <= 1'b0;
		end else begin
			sig_r1 <= signal;
			sig_r2 <= sig_r1;
			sig_r3 <= sig_r2;
		end
	end

	assign pos_edge = (~sig_r3) & sig_r2;

endmodule