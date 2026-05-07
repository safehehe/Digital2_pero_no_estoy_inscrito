module shift_register #(
    parameter DATA_WIDTH = 24
)(
    input  sys_clk,
    input  rst_n,
    
    input                    in_load,
    input      [DATA_WIDTH-1:0] in_data,
    input                    in_shift,
    output wire              out_data
);

reg [DATA_WIDTH-1:0] buffer;

assign out_data = buffer[DATA_WIDTH-1];

always @(negedge sys_clk) begin
    if (!rst_n) begin
        buffer <= {DATA_WIDTH{1'b0}};
    end else begin
        if (in_load) begin
            buffer <= in_data;
        end else if (in_shift) begin
            buffer <= {buffer[DATA_WIDTH-2:0],1'b0};
        end
    end
end

endmodule