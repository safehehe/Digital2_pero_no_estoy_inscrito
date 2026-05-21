`timescale 1ns / 1ps

module shift_register_tb;

reg sys_clk;
reg rst_n;

reg       load;
reg [23:0] data_in;
reg       shift;
wire [23:0] data_out;

shift_register #(
    .DATA_WIDTH(24)
) uut (
    .sys_clk(sys_clk),
    .rst_n(rst_n),
    .load(load),
    .data_in(data_in),
    .shift(shift),
    .data_out(data_out)
);

always #20 sys_clk = ~sys_clk;

reg [23:0] expected;

initial begin
    $dumpfile("shift_register_tb.vcd");
    $dumpvars(0, shift_register_tb);
    $timeformat(-9, 0, "ns", 5);
    
    sys_clk = 0;
    rst_n = 0;
    load = 0;
    data_in = 0;
    shift = 0;
    
    #50 rst_n = 1;
    
    #40;
    data_in = 24'hABCDEF;
    load = 1;
    #40 load = 0;
    
    $display("Loaded: %h", data_in);
    $display("First LSB should be 1 (data: %b)", data_out[0]);
    
    #40 shift = 1;
    #40 shift = 0;
    $display("After shift 1: LSB=%b", data_out[0]);
    
    #40 shift = 1;
    #40 shift = 0;
    $display("After shift 2: LSB=%b", data_out[0]);
    
    #40 shift = 1;
    #40 shift = 0;
    $display("After shift 3: LSB=%b", data_out[0]);
    
    #100;
    
    $display("Shift register test completed");
    $finish;
end

endmodule
