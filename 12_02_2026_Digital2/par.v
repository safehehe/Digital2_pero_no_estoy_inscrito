module par (
    input  clk,
    input  rst,
    input  in_ADD,
    output reg out_PAR
);

  always @(posedge clk) begin
    if (rst) out_PAR = 1'b0;
    else if (in_ADD) out_PAR = out_PAR + 1'b1;
  end

endmodule
