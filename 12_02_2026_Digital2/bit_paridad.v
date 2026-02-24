module bit_paridad (
    input clk,
    input rst,
    input [7:0] data_tx,
    input init,
    output wire done,
    output wire par
);

  wire w_RST;
  wire w_SH;
  wire w_ADD;
  wire w_Z;
  wire [7:0] w_DATA;

  rsr inst_rsr (
      .clk     (clk),
      .in_LOAD (w_RST),
      .in_DATA (data_tx),
      .in_SHIFT(w_SH),
      .out_DATA(w_DATA)
  );



endmodule
