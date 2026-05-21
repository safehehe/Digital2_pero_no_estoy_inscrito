module DEMO_screen_controller (
  input  sys_clk,
  input  rst_n,
  output out_data_out,
  output reg frame
);
assign frame = 1'b0;

screen_controller #(
  .CLK_FREQ_MHZ(25),
  .QTY_PIXELS(64)
  ) u_screen_controller(
    .sys_clk        (sys_clk        ),
    .rst_n          (rst_n          ),
    .in_pixel_addr  (0),
    .in_pixel_color (0),
    .in_pixel_we    (0),
    .in_init_screen (1),
    .out_data_out   (out_data_out)
);


endmodule
