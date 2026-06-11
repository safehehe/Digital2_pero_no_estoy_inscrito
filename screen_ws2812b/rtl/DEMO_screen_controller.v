module DEMO_screen_controller (
  input  sys_clk,
  input  rst_n,
  output out_data_out,
  output wire [$clog2(23)-1:0] frame
);

screen_controller #(
  .CLK_FREQ_MHZ(25),
  .QTY_PIXELS(64),
  .MEM_FILE("/home/samuel/Repositories/Digital2_pero_no_estoy_inscrito/screen_ws2812b/rtl/frame_buffer/test_benches/pattern.hex"),
  .N_FRAMES(23)
  ) u_screen_controller(
    .sys_clk        (sys_clk),
    .rst_n          (rst_n),
    .in_pixel_addr  (0),
    .in_pixel_color (0),
    .in_pixel_we    (0),
    .in_init_screen (1),
    .out_data_out   (out_data_out),
    .now_frame(frame)
);


endmodule
