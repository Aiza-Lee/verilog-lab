`timescale 1ns/1ps
module counter_tb;

reg clk;
reg rst;
reg button;
wire [3:0] cnt;

// 实例化待测试模块
counter uut (
    .clk(clk),
    .rst(rst),
    .button(button),
    .cnt(cnt)
);

// 生成时钟信号
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns周期
end

initial begin
    // 初始化
    rst = 1;
    button = 0;
    #12;
    rst = 0;
    #10;
    // 按下button，计数开始
    button = 1;
    #20;
    button = 0;
    // 观察计数
    #200;
    // 再次复位
    rst = 1;
    #10;
    rst = 0;
    #50;
    $finish;
end

// 波形输出
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, counter_tb);
end

endmodule
