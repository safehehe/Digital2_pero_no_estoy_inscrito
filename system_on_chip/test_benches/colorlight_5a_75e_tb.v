`timescale 1ns/1ps
`ifdef NO_INCLUDES
`include "cells_ff.vh"
`include "cells_io.vh"
`endif
module colorlight_5a_75e_tb;
reg clk;
reg rst_n;
wire screen_out;
wire TX;
colorlight_5a_75e uut(
    .clk25           (clk),
    .led_matrix0_out (screen_out),
    .serial_rx       (1'b1),
    .serial_tx       (TX),
    .user_btn_n0     (rst_n)
);


localparam CLK_PERIOD = 40;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
  $dumpfile("colorlight_5a_75e_tb.vcd");
  $dumpvars(0, colorlight_5a_75e_tb);
end

initial begin
  #1 rst_n<=1'bx;clk<=1'bx;
  #(CLK_PERIOD*3) rst_n<=1;
  #(CLK_PERIOD*3) rst_n<=0;clk<=0;
  repeat(5) @(posedge clk);
  rst_n<=1;
  @(posedge clk);
  repeat(10_000) @(posedge clk);
  $finish;
end

endmodule