module lsrQA (
    clk,
    load,
    shift,
    add,
    in_Q,
    in_RR,
    out_Q
);
  input clk;
  input load;
  input shift;
  input add;
  input [15:0] in_Q;
  input [15:0] in_RR;
  output reg [15:0] out_Q;
  reg [15:0] reg_A;
  reg [31:0] tmp;
  always @(negedge clk) begin
    if (load) begin
      out_Q = 16'b0;
      reg_A = in_RR;
    end else begin
      if (shift) begin
        tmp   = {out_Q[13:0], reg_A[15:0], 2'b00};
        out_Q = tmp[31:16];
        reg_A = tmp[15:0];
      end else begin
        if (add) out_Q = in_Q;
        else begin
          out_Q = out_Q;
          reg_A = reg_A;
        end
      end
    end
  end
endmodule
