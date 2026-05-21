`timescale 1ns / 1ps

module pulse_generator_tb;

localparam FREQ_MHZ = 25;
localparam CLK_PERIOD_NS = 1000/FREQ_MHZ;
localparam HALF_PERIOD_NS = CLK_PERIOD_NS/2;

reg sys_clk;
reg rst_n;

reg start;
reg bit_in;
reg send_reset;

wire pulse_out;
wire high_done;
wire reset_done;
wire pulse_done;

pulse_generator #(
    .CLK_FREQ_MHZ(FREQ_MHZ)
) uut (
    .sys_clk(sys_clk),
    .rst_n(rst_n),
    .in_start(start),
    .in_bit_in(bit_in),
    .in_send_reset(send_reset),
    .out_pulse_out(pulse_out),
    .out_high_done(high_done),
    .out_reset_done(reset_done),
    .out_pulse_done(pulse_done)
);

always #HALF_PERIOD_NS sys_clk = ~sys_clk;


initial begin
    $dumpfile("pulse_generator_tb.vcd");
    $dumpvars(0, pulse_generator_tb);
    $timeformat(-9, 0, "ns", 5);
    
    sys_clk = 0;
    rst_n = 0;
    start = 0;
    bit_in = 0;
    send_reset = 0;
    
    #50 rst_n = 1;
    
    #100;
    $display("Testing bit 0 (T0H = 400ns, T0L = 850ns)");
    @(posedge sys_clk);
    bit_in = 0;
    start = 1;
    #40 start = 0;
    wait(high_done);
    @(posedge sys_clk);
    bit_in = !bit_in;
    wait(pulse_done);
    #HALF_PERIOD_NS;
    
    $display("Testing bit 1 (T1H = 850ns, T1L = 400ns)");
    bit_in = 1;
    start = 1;
    #40 start = 0;
    wait(high_done);
    @(posedge sys_clk);
    bit_in = !bit_in;
    wait(pulse_done);

    $display("Testing bit 0 (T0H = 400ns, T0L = 850ns)");
    @(posedge sys_clk);
    bit_in = 0;
    start = 1;
    #40 start = 0;
    wait(high_done);
    @(posedge sys_clk);
    bit_in = !bit_in;
    wait(pulse_done);
    #HALF_PERIOD_NS;
    $display("Testing reset pulse (>50us)");
    bit_in = 1;
    send_reset = 1;
    #40 send_reset = 0;

    wait(reset_done);
    #100;
    
    $display("All tests completed");
    $finish;
end

endmodule
