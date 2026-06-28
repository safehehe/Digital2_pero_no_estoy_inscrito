module lsrR (
    clk,
    rst,
    shift,
    lsb,
    out_R
);
  input clk;
  input rst;
  input shift;
  input lsb;
  output reg [15:0] out_R;

  always @(negedge clk) begin
    if (rst) out_R = 16'b0;
    else begin
      if (shift) out_R = out_R << 1;
      else begin
        if (lsb) out_R[0] = 1;
        else out_R = out_R;
      end
    end
  end
endmodule
