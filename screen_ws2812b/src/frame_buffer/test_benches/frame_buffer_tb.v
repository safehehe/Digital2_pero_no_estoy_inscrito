`timescale 1ns / 1ps

module frame_buffer_tb;

reg sys_clk;
reg rst_n;

reg [7:0] write_addr;
reg       write_enable;
reg [23:0] color_in;

reg [7:0] read_addr;
reg       read_enable;
wire [23:0] color_out;

frame_buffer #(
    .ADDR_WIDTH(8),
    .DATA_WIDTH(24)
) uut (
    .sys_clk(sys_clk),
    .rst_n(rst_n),
    .write_addr(write_addr),
    .write_enable(write_enable),
    .color_in(color_in),
    .read_addr(read_addr),
    .read_enable(read_enable),
    .color_out(color_out)
);

always #20 sys_clk = ~sys_clk;

initial begin
    $dumpfile("frame_buffer_tb.vcd");
    $dumpvars(0, frame_buffer_tb);
    $timeformat(-9, 0, "ns", 5);
    
    sys_clk = 0;
    rst_n = 0;
    write_addr = 0;
    write_enable = 0;
    color_in = 0;
    read_addr = 0;
    read_enable = 0;
    
    #50 rst_n = 1;
    
    #40;
    write_addr = 8'd0;
    color_in = 24'hFF0000;
    write_enable = 1;
    #40 write_enable = 0;
    
    write_addr = 8'd1;
    color_in = 24'h00FF00;
    write_enable = 1;
    #40 write_enable = 0;
    
    write_addr = 8'd2;
    color_in = 24'h0000FF;
    write_enable = 1;
    #40 write_enable = 0;
    
    #40;
    read_addr = 8'd0;
    read_enable = 1;
    #40 read_enable = 0;
    
    #40;
    read_addr = 8'd1;
    read_enable = 1;
    #40 read_enable = 0;
    
    #40;
    read_addr = 8'd2;
    read_enable = 1;
    #40 read_enable = 0;
    
    #100;
    
    if (color_out === 24'h0000FF) begin
        $display("PASS: Read address 2 = FF0000");
    end else begin
        $display("FAIL: Expected FF0000, got %h", color_out);
    end
    
    $finish;
end

endmodule
