`timescale 1ns / 1ps

module screen_controller_tb;

localparam RST_VALUE_PC = 8'd254;

reg sys_clk;
reg rst_n;

reg [7:0] pixel_addr;
reg [23:0] pixel_color;
reg       pixel_we;
reg run_screen;
wire data_out;
reg _frame = 0;

screen_controller #(
    //.CLK_FREQ_MHZ(25),
    //.QTY_PIXELS(64)
) uut (
    .sys_clk(sys_clk),
    .rst_n(rst_n),
    .in_pixel_addr(pixel_addr),
    .in_pixel_color(pixel_color),
    .in_pixel_we(pixel_we),
    .in_init_screen(run_screen),
    .out_data_out(data_out),
    .in_frame(_frame)
);

always #20 sys_clk = ~sys_clk;

always #10_000 _frame = ~_frame;

integer i;

initial begin
    $dumpfile("screen_controller_tb.vcd");
    $dumpvars(0, screen_controller_tb);
    $timeformat(-9, 0, "ns", 5);
    
    sys_clk = 0;
    rst_n = 1;
    pixel_addr = 0;
    pixel_color = 0;
    pixel_we = 0;
    run_screen = 0;
    #50 rst_n = 0;
    #40 rst_n = 1;
    // $display("Writing pixel data...");
    
    // for (i = RST_VALUE_PC; i < 3+RST_VALUE_PC; i = i + 1) begin
    //     @(posedge sys_clk);
    //     pixel_addr = i;
    //     pixel_color = 24'h0000AA >> i-RST_VALUE_PC;
    //     pixel_we = 1;
    //     @(posedge sys_clk);
    //     pixel_we = 0;
    //     #100;
    // end
    
    $display("Starting frame transmission...");
    @(negedge sys_clk);
    run_screen = 1;
    @(negedge sys_clk);
    run_screen = 0;
    $display("Watching first few bits...");
    
    #1_950_000;
    
    $display("Controller test completed - check waveform");
    $finish;
end

endmodule
