module counter (
	input wire clk,
	input wire rst,
	input wire button,
	output reg [3:0] cnt
);

reg cnt_inc;
wire cnt_end = cnt_inc & (cnt == 4'd9);

always @(posedge clk or posedge rst) begin
	if (rst) 			cnt_inc <= 1'b0;
	else if (button) 	cnt_inc <= 1'b1;
	else if (cnt_end) 	cnt_inc <= 1'b0;
end

always @ (posedge clk or posedge rst) begin
	if (rst)  			cnt <= 4'h0;
	else if (cnt_end) 	cnt <= 4'h0;
	else if (cnt_inc) 	cnt <= cnt + 4'h1;
end

endmodule