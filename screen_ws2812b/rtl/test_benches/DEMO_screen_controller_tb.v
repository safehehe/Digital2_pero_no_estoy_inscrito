`timescale 1ns / 1ps

module DEMO_screen_controller_tb;


reg sys_clk;
reg rst_n;
wire data_out;
wire frame;

DEMO_screen_controller u_DEMO_screen_controller(
    .sys_clk      (sys_clk      ),
    .rst_n        (rst_n        ),
    .out_data_out (out_data_out ),
    .frame        (frame        )
);

always #20 sys_clk = ~sys_clk;

initial begin
    $dumpfile("DEMO_screen_controller_tb.vcd");
    $dumpvars(0, DEMO_screen_controller_tb);
    $timeformat(-9, 0, "ns", 5);
    
    sys_clk = 0;
    rst_n = 1;
    #50 rst_n = 0;
    #40 rst_n = 1;
    #1_950_000;
    $finish;
end

endmodule