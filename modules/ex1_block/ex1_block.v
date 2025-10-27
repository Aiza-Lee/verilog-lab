module ex1_block(
    input      clk,
    input      rst,
    input      A,
    input      B,
    output reg C,
    output reg D
);

    always @ (posedge clk or posedge rst) begin
        if(rst) begin 
            C = 0;
            D = 0;
        end else begin
            C = A & B;
            D = A | B;
        end
    end

endmodule