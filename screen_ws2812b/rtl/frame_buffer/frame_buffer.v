module frame_buffer #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 24,
    parameter FILE = "/home/samuel/Repositories/Digital2_pero_no_estoy_inscrito/screen_ws2812b/rtl/frame_buffer/test_benches/imagen.hex"
)(
    input  sys_clk,
    input      [ADDR_WIDTH-1:0] in_write_addr,
    input                       in_write_enable,
    input      [DATA_WIDTH-1:0] in_color_in,
    
    input      [ADDR_WIDTH-1:0] in_read_addr,
    input                       in_read_enable,
    output reg [DATA_WIDTH-1:0] out_color_out
);

(*ram_style = "block"*)
reg [DATA_WIDTH-1:0] memory [0:2**ADDR_WIDTH-1];
initial begin
    $readmemh(FILE,memory);
end
always @(negedge sys_clk) begin
    if (in_read_enable) begin
        out_color_out <= memory[in_read_addr];
    end
    if (in_write_enable) begin
        memory[in_write_addr] <= in_color_in;
    end
end

endmodule