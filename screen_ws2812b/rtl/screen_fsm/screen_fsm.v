module screen_fsm #(
    parameter LED_COUNT  = 256,
    parameter BITS_COUNT = 24
)(
    input  sys_clk,
    input  rst_n,
    input  in_init,
    output wire [$clog2(LED_COUNT)-1:0] out_fb_read_addr,
    output reg       out_fb_read_enable,
    
    output reg       out_shift_load,
    output reg       out_shift_shift,
    
    output reg       out_pulse_start,
    output reg       out_pulse_send_reset,
    
    input  in_pulse_high_done,
    input  in_pulse_reset_done,
    input  in_pulse_done
);

localparam START         = 5'd0;
localparam READ_PIXEL    = 5'd1;
localparam LOAD_SHIFT    = 5'd2;
localparam RUN_SCREEN    = 5'd3;
localparam WAIT_HIGH     = 5'd4;
localparam SHIFT_NEXT    = 5'd5;
localparam CHECK_BITS    = 5'd6;
localparam NEXT_PIXEL    = 5'd7;
localparam SEND_RESET    = 5'd8;
localparam WAIT_RESET    = 5'd9;
localparam WAIT_PULSE    = 5'd10;

localparam RST_VALUE_PC = 
    `ifdef BENCH
        8'd0
    `else
        8'd0
    `endif; 

reg [4:0] state;
reg [7:0] pixel_counter;
reg [4:0] bit_counter;
assign out_fb_read_addr = pixel_counter;

always @(posedge sys_clk ) begin
    if (!rst_n) begin
        bit_counter <= 8'b0;
        pixel_counter <= RST_VALUE_PC;
        state <= START;
    end else begin
        case (state)
            START : begin
                bit_counter <= 8'b0;
                pixel_counter <= RST_VALUE_PC;
                state <= in_init ? READ_PIXEL : START;
            end 
            READ_PIXEL : state <= LOAD_SHIFT;
            LOAD_SHIFT : state <= RUN_SCREEN;
            RUN_SCREEN : state <= WAIT_HIGH;
            WAIT_HIGH : state <= in_pulse_high_done ? SHIFT_NEXT : WAIT_HIGH;
            SHIFT_NEXT : begin
                state <= CHECK_BITS;
                bit_counter <= bit_counter + 1;
            end
            CHECK_BITS : begin
                if (bit_counter == BITS_COUNT) begin
                    pixel_counter <= pixel_counter + 1;
                    state <= NEXT_PIXEL;
                end else state <= WAIT_HIGH;
            end
            NEXT_PIXEL : begin
                if (pixel_counter == LED_COUNT) begin
                    state <= WAIT_PULSE;
                end else begin
                    bit_counter <= 8'b0;
                    state <= READ_PIXEL;
                end
            end
            WAIT_PULSE : state <= in_pulse_done ? SEND_RESET : WAIT_PULSE;
            SEND_RESET : state <= WAIT_RESET;
            WAIT_RESET : state <= in_pulse_reset_done ? START : WAIT_RESET;
            default: state <= START;
        endcase
    end
end



always @(*) begin
    case (state)
    START:begin
        out_fb_read_enable = 1'b0;
        out_shift_load = 1'b0;
        out_shift_shift = 1'b0;
        out_pulse_start = 1'b0;
        out_pulse_send_reset = 1'b0;
    end
    READ_PIXEL : begin
        out_fb_read_enable = 1'b1;
        out_shift_load = 1'b0;
        out_shift_shift = 1'b0;
        out_pulse_start = 1'b0;
        out_pulse_send_reset = 1'b0;
    end
    LOAD_SHIFT : begin
        out_fb_read_enable = 1'b0;
        out_shift_load = 1'b1;
        out_shift_shift = 1'b0;
        out_pulse_start = 1'b0;
        out_pulse_send_reset = 1'b0;
    end
    RUN_SCREEN : begin
        out_fb_read_enable = 1'b0;
        out_shift_load = 1'b0;
        out_shift_shift = 1'b0;
        out_pulse_start = 1'b1;
        out_pulse_send_reset = 1'b0;
    end
    WAIT_HIGH : begin
        out_fb_read_enable = 1'b0;
        out_shift_load = 1'b0;
        out_shift_shift = 1'b0;
        out_pulse_start = 1'b1;
        out_pulse_send_reset = 1'b0;
    end
    SHIFT_NEXT : begin
        out_fb_read_enable = 1'b0;
        out_shift_load = 1'b0;
        out_shift_shift = 1'b1;
        out_pulse_start = 1'b1;
        out_pulse_send_reset = 1'b0;
    end
    CHECK_BITS : begin
        out_fb_read_enable = 1'b0;
        out_shift_load = 1'b0;
        out_shift_shift = 1'b0;
        out_pulse_start = 1'b1;
        out_pulse_send_reset = 1'b0;
    end
    NEXT_PIXEL : begin
        out_fb_read_enable = 1'b0;
        out_shift_load = 1'b0;
        out_shift_shift = 1'b0;
        out_pulse_start = 1'b0;
        out_pulse_send_reset = 1'b0;
    end
    WAIT_PULSE : begin
        out_fb_read_enable = 1'b0;
        out_shift_load = 1'b0;
        out_shift_shift = 1'b0;
        out_pulse_start = 1'b0;
        out_pulse_send_reset = 1'b0;
    end
    SEND_RESET : begin
        out_fb_read_enable = 1'b0;
        out_shift_load = 1'b0;
        out_shift_shift = 1'b0;
        out_pulse_start = 1'b0;
        out_pulse_send_reset = 1'b1;
    end
    WAIT_RESET : begin
        out_fb_read_enable = 1'b0;
        out_shift_load = 1'b0;
        out_shift_shift = 1'b0;
        out_pulse_start = 1'b0;
        out_pulse_send_reset = 1'b0;
    end
    default: begin
        out_fb_read_enable = 1'b0;
        out_shift_load = 1'b0;
        out_shift_shift = 1'b0;
        out_pulse_start = 1'b0;
        out_pulse_send_reset = 1'b0;
    end
endcase
end

`ifdef BENCH
    reg [8*40:1] state_name;
    always @(*) begin
        case (state)
            START:        state_name = "START";
            READ_PIXEL: state_name = "READ_PIXEL";
            LOAD_SHIFT: state_name = "LOAD_SHIFT";
            RUN_SCREEN: state_name = "RUN_SCREEN";
            WAIT_HIGH:        state_name = "WAIT_HIGH";
            SHIFT_NEXT:   state_name = "SHIFT_NEXT";
            CHECK_BITS:       state_name = "CHECK_BITS";
            NEXT_PIXEL:         state_name = "NEXT_PIXEL";
            WAIT_PULSE:    state_name = "WAIT_PULSE";
            SEND_RESET:   state_name = "SEND_RESET";
            WAIT_RESET:   state_name = "WAIT_RESET";
        endcase
    end
`endif

endmodule