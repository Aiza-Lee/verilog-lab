`timescale 1ns/1ps
module ex1tb;
    reg clk=0;  
    reg rst;       
    reg A;        
    reg B;        
    wire C;       
    wire D;       

    ex1_block u_ex1_block (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .C(C),
        .D(D)
    );

    always #5  clk = ! clk ;

    // Use monitor to track changes in signals A, B, C, and D
    initial begin
        $monitor("Time: %0t | A = %b, B = %b | C = %b, D = %b", $time, A, B, C, D);
    end

    initial begin
        rst = 1; A = 0; B = 0; 
        # 10 rst = 0;
        #10 A = 0; B = 0;        // Test case 1
        #10 A = 0; B = 1;        // Test case 2
        #10 A = 1; B = 0;        // Test case 3
        #10 A = 1; B = 1;        // Test case 4
        #10;
        $finish;  
    end

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, ex1tb);
	end
endmodule