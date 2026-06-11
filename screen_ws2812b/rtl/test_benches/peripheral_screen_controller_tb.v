`timescale 1ns / 1ps

module peripheral_screen_controller_tb;

  localparam QTY_PIXELS = 64;
  localparam N_FRAMES = 1;
  reg sys_clk;
  reg rst_n;
  reg [31:0] data_in = 0;
  reg [31:0] addr_line = 0;
  reg cs = 0;
  reg wr = 0;
  wire screen_wire;


  peripheral_screen_controller u_peripheral_screen_controller (
      .sys_clk      (sys_clk),
      .rst_n        (rst_n),
      .d_in         (data_in),
      .cs           (cs),
      .addr         (addr_line),
      .wr           (wr),
      .out_to_screen(screen_wire)
  );
  always #20 sys_clk = ~sys_clk;

  initial begin
    $dumpfile("peripheral_screen_controller_tb.vcd");
    $dumpvars(0, peripheral_screen_controller_tb);
    $timeformat(-9, 0, "ns", 5);

    sys_clk = 0;
    rst_n   = 1;
    #50 rst_n = 0;
    #40 rst_n = 1;
    @(negedge sys_clk);
    cs = 1;
    addr_line = 32'h50000;
    @(negedge sys_clk);
    wr = 1;
    data_in = 32'hFFFFFF;
    @(negedge sys_clk);
    addr_line = addr_line + (1<<2);
    @(negedge sys_clk);
    addr_line = 32'h50000 + (63<<2);
    @(negedge sys_clk);
    wr = 0;
    addr_line = 32'h50000 + (1<<($clog2(QTY_PIXELS*N_FRAMES)+2));
    data_in = 31'd1;
    @(negedge sys_clk);
    wr = 1;
    @(negedge sys_clk);
    data_in = 31'd0;
    @(negedge sys_clk);
    wr = 0;
    cs = 0;
    addr_line = 32'h20000;
    @(negedge sys_clk);
    #1_950_000;
    $finish;
  end
endmodule
