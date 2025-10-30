`timescale 1ns/1ps
// 计时器模块
// 当使能信号en有效时，计时器开始计数，直到计数值达到target_time，
// 此时产生一个tick信号，并将计数器清零，重新开始计数。
module timer #(
	parameter integer WIDTH = 24 // 计时器位宽
) (
	input wire clk,
	input wire rst_n,
	input wire en,
	input wire [WIDTH-1:0] target_time, // 目标计时值，单位为一个时钟周期
	output reg tick
);

	reg [WIDTH - 1:0] cnt;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			cnt <= {WIDTH{1'b0}};
			tick <= 1'b0;
		end else begin
			if (en) begin
				if (cnt >= target_time) begin
					cnt <= {WIDTH{1'b0}};
					tick <= 1'b1;
				end else begin
					cnt <= cnt + 1'b1;
					tick <= 1'b0;
				end
			end else begin
				cnt <= {WIDTH{1'b0}};
				tick <= 1'b0;
			end
		end
	end

endmodule