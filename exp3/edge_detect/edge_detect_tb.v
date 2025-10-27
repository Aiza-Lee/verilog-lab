`timescale 1ns/1ps
module edge_detect_tb;
    reg clk;
    reg rst;
    reg signal;
    wire pos_edge;

    // 实例化待测模块
    edge_detect dut (
        .clk(clk),
        .rst(rst),
        .signal(signal),
        .pos_edge(pos_edge)
    );

    // 生成时钟
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns周期
    end

    // 激励信号
    initial begin
        rst = 1;
        signal = 0;
        #12;
        rst = 0;
        #10;
        signal = 1; // 上升沿
        #10;
        signal = 0; // 下降沿
        #10;
        signal = 1; // 上升沿
        #10;
        signal = 1; // 保持高
        #10;
        signal = 0; // 下降沿
        #10;
        $finish;
    end

    // 监视信号
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, edge_detect_tb);
        $display("time\tclk\trst\tsignal\tpos_edge");
        $monitor("%4t\t%b\t%b\t%b\t%b", $time, clk, rst, signal, pos_edge);
    end
endmodule
