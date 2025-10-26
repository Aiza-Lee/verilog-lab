`include "counter4.v"

module counter4_tb;
    reg clk;
    reg rst_n;
    reg en;
    reg up_down;
    wire [3:0] cnt;
    wire overflow;
    wire underflow;

    // 实例化被测模块
    counter4 uut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .up_down(up_down),
        .cnt(cnt),
        .overflow(overflow),
        .underflow(underflow)
    );

    // 产生时钟信号
    initial clk = 0;
    always #5 clk = ~clk;

    // 复位和测试过程
    initial begin
        rst_n = 0;
        en = 0;
        up_down = 1; // 先加计数
        #12 rst_n = 1;
        #10 en = 1;
        #100 up_down = 0; // 切换为减计数
        #100 en = 0;      // 停止计数
        #20  en = 1;      // 再次计数
        #1000 $finish;
    end

    // 生成波形文件
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, counter4_tb);
    end
endmodule