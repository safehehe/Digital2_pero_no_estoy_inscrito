module sumador #(
    parameter N_BITS = 4,
    parameter CP2 = 0
) (
    A,
    B,
    out_SUM
);
  input [N_BITS-1:0] A;
  input [N_BITS-1:0] B;
  output [N_BITS-1:0] out_SUM;
  assign out_SUM = CP2 ? A + (~B+1) : A + B;
endmodule
