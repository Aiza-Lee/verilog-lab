`timescale 1ns/1ps

module top_tb;
	// Clock and control signals
	reg clk;                      // removed inline init (set in initial block)
	reg button_reset;              // removed inline init
	reg button_start_stop;         // removed inline init
	reg button_count;              // removed inline init
	reg global_led_en;             // removed inline init

	// Add module-scope integers to avoid declarations inside unnamed blocks/tasks
	integer i;
	integer cycles;

	wire [7:0] led_en;
	// led_cx from DUT (8-bit segment signals)
	wire [7:0] led_cx;

	// Instantiate DUT
	top uut (
		.clk(clk),
		.button_reset(button_reset),
		.button_start_stop(button_start_stop),
		.button_count(button_count),
		.global_led_en(global_led_en),
		.led_en(led_en),
		.led_cx(led_cx)
	);

	// 100MHz clock generation
	always #5 clk = ~clk;

	initial begin
		// Set initial values here (compatible with Verilog)
		clk = 0;
		button_reset = 1;
		button_start_stop = 1;
		button_count = 0;
		global_led_en = 1;

		$dumpfile("dump.vcd");
		$dumpvars(0, top_tb);
		$display("%0t: simulation start", $time);

		// Hold reset for a short time (200 ns), then release
		#200;
		button_reset = 0;
		#100;

		// Pulse button_count twice (非去抖/去抖路径检查)
		// Use ms-length pulses so they pass the 20 ms debouncer in DUT
		pulse_button_count_ms(25);
		#100;
		pulse_button_count_ms(25);
		#200;

			// Pulse start/stop -> 让计数器运行一段缩短时间以便观察多个步进（缩短）
		pulse_start_stop_ms(25);  // start (25 ms to pass debouncer)
		#60_000_000;            // 60 ms (shortened)
		pulse_start_stop_ms(25);  // pause
		#200;

		// Disable display then enable again（观察全局使能切换），时间缩短为 2 ms
		global_led_en = 0;
		#2_000_000; // 2 ms
		global_led_en = 1;
		#2_000_000;

		// 周期性按键脉冲（每 5 ms 点击一次，原为 50 ms）
		// Reduce repeats to limit total sim time; use ms-length pulses
		repeat (3) begin
			pulse_button_count_ms(25);
			#5_000_000; // 5 ms
		end

		// 再次让十进制计数器运行一段较短时间以观察更多步进
		pulse_start_stop_ms(25); // resume
		#30_000_000;        // 30 ms（短ened）
		pulse_start_stop_ms(25); // pause
			#200;

			// Assert asynchronous reset briefly，时间缩短
			button_reset = 1;
			#40;
			button_reset = 0;
			#20_000_000; // 20 ms（原 200 ms）

			$display("%0t: simulation end", $time);
			#100 $finish;
	end

	// Helper: pulse the count button for one clock cycle (edge-aligned)
	task pulse_button_count; begin
		@(posedge clk);
		button_count = 1;
		@(posedge clk);
		button_count = 0;
	end endtask

	// Helper: pulse the start/stop button for one clock cycle
	task pulse_start_stop; begin
		@(posedge clk);
		button_start_stop = 1;
		@(posedge clk);
		button_start_stop = 0;
	end endtask

	// Helper: pulse the count button for N milliseconds (ms) - suitable for debounced buttons
	// At 100 MHz clock: 1 ms = 100_000 clock cycles
	task pulse_button_count_ms(input integer ms); begin
		cycles = ms * 100_000; // 100 MHz
		@(posedge clk);
		button_count = 1;
		for (i = 0; i < cycles; i = i + 1) begin
			@(posedge clk);
		end
		button_count = 0;
	end endtask

	// Helper: pulse the start/stop button for N milliseconds (ms)
	task pulse_start_stop_ms(input integer ms); begin
		cycles = ms * 100_000; // 100 MHz
		@(posedge clk);
		button_start_stop = 1;
		for (i = 0; i < cycles; i = i + 1) begin
			@(posedge clk);
		end
		button_start_stop = 0;
	end endtask

endmodule

