`timescale 1ns/1ps

module top_tb;
    // Clock and control signals
    reg clk = 0;
    reg button_reset = 1;           // S1, active high async reset
    reg button_start_stop = 0;      // S2
    reg button_count = 0;           // S3
    reg global_led_en = 1;          // SW0

    wire [7:0] led_en;
    // led_cx from DUT (8-bit segment signals)
    wire [7:0] led_cx;
    // alias used by this testbench
    wire [7:0] led_cx_correct = led_cx;

    // Instantiate DUT
    top uut (
        .clk(clk),
        .button_reset(button_reset),
        .button_start_stop(button_start_stop),
        .button_count(button_count),
        .global_led_en(global_led_en),
        .led_en(led_en),
        .led_cx(led_cx_correct)
    );

    // 100MHz clock generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, top_tb);
        $display("%0t: simulation start", $time);

        // Hold reset for a short time (200 ns), then release
        #200;
        button_reset = 0;
        #100;

        // Pulse button_count twice (non-debounced and debounced counters should increment)
        pulse_button_count();
        #100;
        pulse_button_count();
        #200;

        // Pulse start/stop to toggle decimal counter -> let it run long enough to see multiple 0.1s steps
        pulse_start_stop();      // start
        #500_000_000;            // 500 ms 等足够多个 0.1s 步进可见
        pulse_start_stop();      // pause
        #200;

        // Disable display (all digits off) then enable again (短时间切换以观察使能)
        global_led_en = 0;
        #10_000_000; // 10 ms
        global_led_en = 1;
        #10_000_000;

        // 生成若干周期性的按键脉冲（每 50ms 点击一次），观察计数累加
        repeat (5) begin
            pulse_button_count();
            #50_000_000; // 50 ms
        end

        // 再次让十进制计数器运行一段时间以观察更多步进
        pulse_start_stop(); // resume
        #300_000_000;       // 300 ms
        pulse_start_stop(); // pause
        #200;

        // Assert asynchronous reset briefly，观察复位行为并继续运行一段时间
        button_reset = 1;
        #40;
        button_reset = 0;
        #200_000_000; // 200 ms 观察复位后行为

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

    // Simple monitor to print important signals
    initial begin
        $monitor("%0t rst=%b start_stop=%b count_btn=%b led_en=%b led_cx=%b global_en=%b", $time, button_reset, button_start_stop, button_count, led_en, led_cx_correct, global_led_en);
    end

endmodule

