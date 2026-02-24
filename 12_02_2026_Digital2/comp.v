module comp (
    input [7:0] in_a,
    output wire out_z
);
  always @(*) begin
    out_z = in_a == 8'b0;
  end
endmodule
