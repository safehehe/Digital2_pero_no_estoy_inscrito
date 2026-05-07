`timescale 1ns / 1ps

module screen_fsm_tb;

localparam FREQ_MHZ = 25;
localparam CLK_PERIOD_NS = 1000/FREQ_MHZ;
localparam HALF_PERIOD_NS = CLK_PERIOD_NS/2;

reg sys_clk;
reg rst_n;

wire [7:0] fb_read_addr;
wire fb_read_enable;

wire shift_load;
wire shift_shift;

wire pulse_start;
wire pulse_send_reset;

reg pulse_high_done;
reg pulse_reset_done;
reg pulse_done;

integer i;

screen_fsm uut(
    .sys_clk          (sys_clk          ),
    .rst_n            (rst_n            ),
    .fb_read_addr     (fb_read_addr     ),
    .fb_read_enable   (fb_read_enable   ),
    .shift_load       (shift_load       ),
    .shift_shift      (shift_shift      ),
    .pulse_start      (pulse_start      ),
    .pulse_send_reset (pulse_send_reset ),
    .pulse_high_done  (pulse_high_done  ),
    .pulse_reset_done (pulse_reset_done ),
    .pulse_done       (pulse_done       )
);

always #HALF_PERIOD_NS sys_clk = ~sys_clk;


initial begin
  $dumpfile("screen_fsm_tb.vcd");
  $dumpvars(0, screen_fsm_tb);
  $timeformat(-9, 0, "ns", 5);

  sys_clk = 0;
  rst_n = 1;
  pulse_high_done = 0;
  pulse_reset_done = 0;
  pulse_done = 0;

  @(negedge sys_clk) rst_n = 0;
  @(negedge sys_clk) rst_n = 1;
  $display("Screen FSM Running");
  wait(fb_read_enable);
  $display("Screen FSM : Read from memory");
  wait(shift_load & pulse_start);
  $display("Screen FSM : Loading into shift register");
  $display("Screen FSM : Starting pulse");
  for (i =0 ;i<=22 ;i = i+1 ) begin
    #100;
    @(negedge sys_clk);
    pulse_high_done = 1;
    @(negedge sys_clk);
    pulse_high_done = 0;
    #100;
    @(negedge sys_clk);
    pulse_done = 1;
    @(negedge sys_clk);
    pulse_done = 0;
    $display("Screen FSM : Transmited %d bits",uut.bit_counter);
  end
  #200;
  @(negedge sys_clk);
  pulse_reset_done = 1;
  @(negedge sys_clk);
  pulse_reset_done = 0;
  #100;
  $display("Screen FSM : Done");
  $finish;
end
endmodule