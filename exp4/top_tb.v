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
        $dumpfile("dump.vcd");
        $dumpvars(0, top_tb);
        $display("%0t: simulation start", $time);

        // Hold reset for a short time (200 ns), then release
        #200;
        button_reset = 0;
        #100;

        // Pulse button_count twice (非去抖/去抖路径检查)
        pulse_button_count();
        #100;
        pulse_button_count();
        #200;

        // Pulse start/stop -> 让计数器运行一段缩短时间以便观察多个步进（缩短）
        pulse_start_stop();      // start
        #120_000_000;            // 120 ms（原 500 ms，缩短）
        pulse_start_stop();      // pause
        #200;

        // Disable display then enable again（观察全局使能切换），时间缩短为 2 ms
        global_led_en = 0;
        #2_000_000; // 2 ms
        global_led_en = 1;
        #2_000_000;

        // 周期性按键脉冲（每 5 ms 点击一次，原为 50 ms）
        repeat (5) begin
            pulse_button_count();
            #5_000_000; // 5 ms
        end

        // 再次让十进制计数器运行一段较短时间以观察更多步进
        pulse_start_stop(); // resume
        #60_000_000;        // 60 ms（原 300 ms）
        pulse_start_stop(); // pause
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

    // Simple monitor to print important signals（修正为使用 led_cx）
    initial begin
        $monitor("%0t rst=%b start_stop=%b count_btn=%b led_en=%b led_cx=%b global_en=%b",
                 $time, button_reset, button_start_stop, button_count, led_en, led_cx, global_led_en);
    end

endmodule

