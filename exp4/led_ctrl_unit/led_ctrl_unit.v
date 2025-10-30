`timescale 1ns/1ps
module led_ctrl_unit (
	input wire clk,
	input wire rst_n,			// 异步复位，低有效
	input wire en,
	input wire [31:0] display,	// 待显示的8个十六进制字符
	output reg [7:0] led_en,	// 位选信号
	output reg [7:0] led_cx		// 段选信号
);

	localparam ZERO  = 8'h03;
	localparam ONE   = 8'h9F;
	localparam TWO   = 8'h25;
	localparam THREE = 8'h0D;
	localparam FOUR  = 8'h99;
	localparam FIVE  = 8'h49;
	localparam SIX   = 8'h41;
	localparam SEVEN = 8'h1F;
	localparam EIGHT = 8'h01;
	localparam NINE  = 8'h19;

	parameter [15:0] TICKS_PER_DIGIT = 16'd25000;
	parameter integer CNT_WIDTH = 16;
	wire tick_digit;

	// 计时器：每 TICKS_PER_DIGIT 个时钟周期产生一个 tick，用于扫描下一个数字
	timer #(
		.WIDTH(CNT_WIDTH)
	) u_timer (
		.clk(clk),
		.rst_n(rst_n),
		.en(en),
		.target_time(TICKS_PER_DIGIT - 16'd1),
		.tick(tick_digit)
	);

	reg [2:0] scan_cnt;
	reg [3:0] curr_digit;

	// 逐4位扫描待显示的8个十六进制字符
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			led_en <= 8'b1111_1110;
			led_cx <= 8'b1111_1111; // 全灭
			scan_cnt <= 3'd0;
			curr_digit <= 4'd0;
		end else begin
			if (en) begin
				// 更新当前扫描的4位数字
				if (tick_digit) begin
					scan_cnt <= scan_cnt + 1'b1;
					// 位选信号循环左移
					led_en <= {led_en[6:0], led_en[7]};
					curr_digit <= display[scan_cnt*4 +: 4];
				end
				// 根据当前数字设置段选信号
				case (curr_digit)
					4'h0: led_cx <= ZERO;
					4'h1: led_cx <= ONE;
					4'h2: led_cx <= TWO;
					4'h3: led_cx <= THREE;
					4'h4: led_cx <= FOUR;
					4'h5: led_cx <= FIVE;
					4'h6: led_cx <= SIX;
					4'h7: led_cx <= SEVEN;
					4'h8: led_cx <= EIGHT;
					4'h9: led_cx <= NINE;
					default: led_cx <= 8'b1111_1111; // 非法输入，全灭
				endcase
			end else begin
				led_en <= 8'b1111_1110;
				led_cx <= 8'b1111_1111; // 全灭
				scan_cnt <= 3'd0;
				curr_digit <= 4'd0;				
			end
		end
	end

endmodule