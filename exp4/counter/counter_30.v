`timescale 1ns/1ps
module counter_30 #(
	parameter [23:0] TICKS_PER_COUNT = 24'd10_000_000 // 0.1s at 100MHz
) (
	input wire clk,
	input wire rst_n,				// 异步复位，低有效
	input wire start_stop_pulse,	// 计数启动/停止控制信号
	output reg [7:0] count
);

	reg start_stop; // 计数启动/停止状态寄存器 高电平表示计数启动
	wire tick;

	timer #(
		.WIDTH(24)
	) u_timer (
		.clk(clk),
		.rst_n(rst_n),
		.en(1'b1),
		.target_time(TICKS_PER_COUNT - 24'd1),
		.tick(tick)
	);

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			start_stop <= 1'b0; // 复位后默认关闭计数
		end else if (start_stop_pulse) begin
			start_stop <= ~start_stop;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			count <= 8'd0;
		end else if (tick && start_stop) begin
			if (count >= 8'd30) begin
				count <= 8'd0;
			end else begin
				count <= count + 8'd1;
			end
		end
	end

endmodule