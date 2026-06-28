module aux (
    clk,
    load,
    in_R,
    out_AUX
);

  input clk;
  input load;
  input [15:0] in_R;
  output reg [15:0] out_AUX;

  always @(negedge clk) begin
    if (load) out_AUX = {in_R[14:0],1'b1};
    else begin
      out_AUX = out_AUX;
    end
  end
endmodule
