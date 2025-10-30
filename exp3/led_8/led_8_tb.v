`timescale 1ns/1ps
module led_8_tb;
	reg clk;
	reg rst;
	reg button;
	reg [1:0] freq_set;
	reg dir_set;
	wire [7:0] led;

	// 实例化被测模块
	led_8 uut (
		.clk(clk),
		.rst(rst),
		.button(button),
		.freq_set(freq_set),
		.dir_set(dir_set),
		.led(led)
	);

	// 100MHz时钟
	initial clk = 0;
	always #5 clk = ~clk;

	initial begin
		// 初始化
		rst = 1;
		button = 0;
		freq_set = 2'b00; // 1000Hz
		dir_set = 1'b1;   // 左移
		#50;
		rst = 0;
		#100;

		// 启动流水灯（1000Hz，左移）
		button = 1; #20; button = 0;
		#10_000_000; // 10ms，能看到10次移动

		// 停止流水灯
		button = 1; #20; button = 0;
		#2_000_000; // 停止2ms

		// 再次启动
		button = 1; #20; button = 0;
		#10_000_000;

		// 切换方向（右移）
		dir_set = 0;
		#10_000_000;

		// 切换频率到100Hz
		freq_set = 2'b01;
		#100_000_000; // 100ms，能看到10次移动

		// 切换频率到20Hz
		freq_set = 2'b10;
		#400_000_000; // 400ms，能看到8次移动

		// 切换频率到5Hz
		freq_set = 2'b11;
		#1_600_000_000; // 1.6s，能看到8次移动

		// 切回左移
		dir_set = 1;
		#400_000_000; // 400ms

		// 停止流水灯
		button = 1; #20; button = 0;
		#100_000_000; // 100ms

		// 再次启动
		button = 1; #20; button = 0;
		#100_000_000; // 100ms

		// 复位
		rst = 1; #20; rst = 0;
		#1_000_000;

		$finish;
	end

	// 波形输出
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, led_8_tb);
		$finish;
	end
endmodule
