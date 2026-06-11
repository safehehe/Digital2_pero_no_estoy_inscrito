module screen_controller #(
    parameter CLK_FREQ_MHZ = 25,
    parameter QTY_PIXELS = 64,
    parameter MEM_FILE = "/home/samuel/Repositories/Digital2_pero_no_estoy_inscrito/screen_ws2812b/rtl/frame_buffer/test_benches/frame2.hex",
    parameter N_FRAMES = 1
) (
    input                           sys_clk,
    input                           rst_n,
    input  [$clog2(QTY_PIXELS)-1:0] in_pixel_addr,
    input  [                  23:0] in_pixel_color,
    input                           in_pixel_we,
    input  [  $clog2(N_FRAMES)-1:0] in_frame_write,
    input                           in_init_screen,
    output                          out_data_out,
    output reg [  $clog2(N_FRAMES)-1:0] now_frame
);

  wire [$clog2(QTY_PIXELS)-1:0] w_fb_read_addr;
  wire                          w_fb_read_enable;
  wire [                  23:0] w_fb1_color_out;
  wire                          w_shift_load;
  wire                          w_shift_shift;
  wire                          w_shift_data_out;

  wire                          w_pulse_start;
  wire                          w_pulse_send_reset;
  wire                          w_pulse_high_done;
  wire                          w_pulse_reset_done;
  wire                          w_pulse_done_from_pulse_gen;



//reg [$clog2(N_FRAMES)-1:0] now_frame;
reg [24:0] frame_timer;

always @(posedge sys_clk) begin
  if(!rst_n) begin
    now_frame <= 1'b0;
    frame_timer <= 25'd0;
  end else begin
    if (frame_timer[20]) begin
      now_frame <= (now_frame <=N_FRAMES) ? now_frame + 1 : 0 ;
      frame_timer <= 25'd0;
    end else begin
      frame_timer <= frame_timer + 25'd1;
      now_frame <= now_frame;
    end
  end
end

  frame_buffer #(
      .ADDR_WIDTH($clog2(QTY_PIXELS * N_FRAMES)),
      .DATA_WIDTH(24),
      .FILE(MEM_FILE)
  ) u_frame_buffer1 (
      .sys_clk(sys_clk),
      .in_write_addr({in_frame_write,in_pixel_addr}),
      .in_write_enable(in_pixel_we),
      .in_color_in(in_pixel_color),
      .in_read_addr({now_frame, w_fb_read_addr}),
      .in_read_enable(w_fb_read_enable),
      .out_color_out(w_fb1_color_out)
  );

  shift_register #(
      .DATA_WIDTH(24)
  ) u_shift_register (
      .sys_clk(sys_clk),
      .rst_n(rst_n),
      .in_load(w_shift_load),
      .in_data(w_fb1_color_out),
      .in_shift(w_shift_shift),
      .out_data(w_shift_data_out)
  );

  pulse_generator #(
      .CLK_FREQ_MHZ(CLK_FREQ_MHZ)
  ) u_pulse_generator (
      .sys_clk(sys_clk),
      .rst_n(rst_n),
      .in_start(w_pulse_start),
      .in_bit_in(w_shift_data_out),
      .in_send_reset(w_pulse_send_reset),
      .out_pulse_out(out_data_out),
      .out_high_done(w_pulse_high_done),
      .out_reset_done(w_pulse_reset_done),
      .out_pulse_done(w_pulse_done_from_pulse_gen)
  );

  screen_fsm #(
      .LED_COUNT (QTY_PIXELS),
      .BITS_COUNT(24)
  ) u_fsm (
      .sys_clk(sys_clk),
      .rst_n(rst_n),
      .in_init(in_init_screen),
      .out_fb_read_addr(w_fb_read_addr),
      .out_fb_read_enable(w_fb_read_enable),
      .out_shift_load(w_shift_load),
      .out_shift_shift(w_shift_shift),
      .out_pulse_start(w_pulse_start),
      .out_pulse_send_reset(w_pulse_send_reset),
      .in_pulse_high_done(w_pulse_high_done),
      .in_pulse_reset_done(w_pulse_reset_done),
      .in_pulse_done(w_pulse_done_from_pulse_gen)
  );

endmodule
