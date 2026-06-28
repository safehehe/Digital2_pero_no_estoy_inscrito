`timescale 1ns / 1ps
`define SIMULATION

module raiz_16_TB;
  reg clk;
  reg rst;
  reg start;
  reg [15:0] RR;
  wire [15:0] result;
  wire [15:0] leftover;
  wire done;

  raiz_16 uut (
      .rst     (rst),
      .clk     (clk),
      .init    (start),
      .in_RR   (RR),
      .out_R   (result),
      .out_Q   (leftover),
      .out_DONE(done)
  );

  parameter PERIOD = 20;
  parameter real DUTY_CYCLE = 0.5;
  parameter OFFSET = 0;
  reg [20:0] i;
  event reset_trigger;
  event reset_done_trigger;

  initial begin
    forever begin
      @(reset_trigger);
      @(negedge clk);
      rst = 1;
      repeat (2) @(negedge clk);
      rst = 0;
      ->reset_done_trigger;
    end
  end
  initial begin //Initialize inputs
    clk = 0;
    rst = 1;
    start = 0;
    RR = 16'h0310;
  end
  initial begin //Process for clk
    #OFFSET;
    forever begin
      clk = 1'b0;
      #(PERIOD - (PERIOD * DUTY_CYCLE)) clk = 1'b1;
      #(PERIOD*DUTY_CYCLE);
    end
  end

  initial begin
    #10 -> reset_trigger;
    @ (reset_done_trigger);
    @ (posedge clk);
    start = 0;
    @ (posedge clk);
    start = 1;

    repeat (2) @(posedge clk);
    start = 0;

    for (i = 0;i<17; i=i+1) begin
      @ (posedge clk);
    end
  end

  initial begin : TEST_CASE
    $dumpfile("raiz_16_TB.vcd");
    $dumpvars(-1, uut);
    #((PERIOD*DUTY_CYCLE)*120) $finish;
  end

endmodule
