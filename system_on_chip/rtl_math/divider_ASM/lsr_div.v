module lsr_div (
    clk,
    rst,
    DV_in,
    IN_A,
    INIT,
    SH,
    loadA,
    in_Q,
    DV0,
    OUT_R
);
  input clk;
  input rst;
  input [15:0] DV_in;
  input [15:0] IN_A;
  input INIT;
  input SH;
  input loadA;
  input DV0;
  output reg [15:0] in_Q;
  output reg [15:0] OUT_R;


  reg [15:0] DV;

  always @(negedge clk)
    if (INIT) begin
      in_Q     = 0;
      DV    = DV_in;
      OUT_R = 0;
    end else begin
      if (SH) begin
        {in_Q, DV} = ({in_Q, DV} << 1);
        OUT_R   = DV;
      end else if (DV0) OUT_R = DV;
      else begin
        if (loadA) begin
          in_Q     = IN_A;
          DV[0] = 1;
        end else begin
          in_Q  = in_Q;
          DV = DV;
        end
      end
    end
endmodule
