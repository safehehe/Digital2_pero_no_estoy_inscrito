module peripheral_screen_controller #(
    parameter CLK_FREQ_MHZ = 25,
    parameter QTY_PIXELS = 64,
    parameter MEM_FILE = "/home/samuel/Repositories/Digital2_pero_no_estoy_inscrito/screen_ws2812b/rtl/frame_buffer/test_benches/frame2.hex",
    parameter N_FRAMES = 1,
    parameter INTERNAL_CS = 0
) (
    input sys_clk,
    input rst_n,
    input [23:0] d_in,
    //input [$clog2(QTY_PIXELS*N_FRAMES)-1:0] addr,//verify 32 bits address
    //|0|           |00000        | |000000            | |00     | = 14bits
    //|internal_cs| |frame(5bits) | |pixel(6bits)      | |padding| 
    // vram BASE+0x0000
    // init BASE+(1<<($clog2(QTY_PIXELS*N_FRAMES)+2)
    // frame value << $clog2(QTY_PIXELS)+2
    // pixel value << 2
    // BASE 0x500000
    //Now litex implementation
    input [$clog2(QTY_PIXELS*N_FRAMES)-1:0] addr,  //verify 32 bits address
    input wr,
    input init_cmd,
    output wire out_to_screen
);
  //-------------------------------inputs-------------------------------
  wire [$clog2(QTY_PIXELS)-1:0] to_px_addr;
  wire [$clog2(N_FRAMES)-1:0] to_frame;
  //wire internal_cs;
  //reg init_command;
  generate
    if (N_FRAMES == 1) begin
        assign to_frame = 0;
        assign to_px_addr = addr[$clog2(QTY_PIXELS*N_FRAMES)-1:2];
      end else begin
        assign {to_frame, to_px_addr} = addr[$clog2(QTY_PIXELS*N_FRAMES)-1:2];
      end
  endgenerate
  /*generate
    if (INTERNAL_CS) begin
      if (N_FRAMES == 1) begin
        assign to_frame = 0;
        assign {internal_cs, to_px_addr} = addr[3+$clog2(QTY_PIXELS*N_FRAMES)-1:2];
      end else begin
        assign {internal_cs, to_frame, to_px_addr} = addr[3+$clog2(QTY_PIXELS*N_FRAMES)-1:2];
      end
    end else begin
      assign internal_cs = 0;
      if (N_FRAMES == 1) begin
        assign to_frame = 0;
        assign to_px_addr = addr[2+$clog2(QTY_PIXELS*N_FRAMES)-1:2];
      end else begin
        assign {to_frame, to_px_addr} = addr[2+$clog2(QTY_PIXELS*N_FRAMES)-1:2];
      end
    end
  endgenerate

  always @(posedge sys_clk) begin
    if (!rst_n) begin
      init_command <= 1'b0;
    end else begin
      if (internal_cs & wr) begin
        init_command <= d_in[0];
      end
    end
  end
*/
  screen_controller #(
      .CLK_FREQ_MHZ(CLK_FREQ_MHZ),
      .QTY_PIXELS(QTY_PIXELS),
      .MEM_FILE(MEM_FILE),
      .N_FRAMES(N_FRAMES)
  ) u_screen_controller (
      .sys_clk       (sys_clk),
      .rst_n         (rst_n),
      .in_pixel_addr (to_px_addr),
      .in_pixel_color(d_in),
      .in_pixel_we   (wr),//wr & !internal_cs
      .in_frame_write(to_frame),
      .in_init_screen(init_cmd),//init_command | init_cmd
      .out_data_out  (out_to_screen),
      .now_frame     ()
  );


endmodule
