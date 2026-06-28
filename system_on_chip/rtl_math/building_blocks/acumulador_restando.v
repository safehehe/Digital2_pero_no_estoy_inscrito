module acumulador_restando #(
    parameter REG_WIDTH = 2,
    parameter RST_VALUE = 0,
    parameter LESS_VALUE = 1
) (
    clk,
    rst,
    less,
    out_K
);
  input rst;
  input clk;
  input less;
  output out_K;
  reg [REG_WIDTH-1:0] N;

  always @(negedge clk) begin
    if (rst) N = RST_VALUE;
    if (less) N = N - LESS_VALUE; else N = N;
  end
  assign out_K = N == 0;
endmodule
