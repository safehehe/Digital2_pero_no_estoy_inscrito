module rsr (
    input clk,
    input in_LOAD,
    input [7:0] in_DATA,
    input in_SHIFT,
    output reg [7:0] out_DATA
);

always @(posedge clk ) begin
  if (in_LOAD) out_DATA = in_DATA;
  else if (in_SHIFT) out_DATA = {1'b0,out_DATA[6:0]};
end


endmodule
