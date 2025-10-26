// 4位二进制计数器模块
// 每个时钟上升沿计数加一，计数到15后回到0

module counter4 (
    input wire clk,         // 时钟信号
    input wire rst_n,       // 异步复位信号，低有效
    input wire en,          // 计数使能
    input wire up_down,     // 计数方向，1为加，0为减
    output reg [3:0] cnt,   // 4位计数输出
    output wire overflow,   // 溢出标志
    output wire underflow   // 借位标志
);

assign overflow  = (cnt == 4'b1111) && en && up_down;
assign underflow = (cnt == 4'b0000) && en && !up_down;

// 在时钟上升沿或复位信号有效时触发
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // 复位时，计数器清零
        cnt <= 4'b0000;
    end else if (en) begin
        if (up_down)
            cnt <= cnt + 1'b1;
        else
            cnt <= cnt - 1'b1;
    end
end

endmodule