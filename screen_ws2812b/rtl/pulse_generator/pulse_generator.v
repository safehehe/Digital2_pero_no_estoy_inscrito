module pulse_generator #(
    parameter CLK_FREQ_MHZ   = 25,
    parameter T0H_NS         = 400,
    parameter T1H_NS         = 850,
    parameter PULSE_NS       = 1250,
    parameter RESET_PULSE_NS = 200_000
) (
    input  sys_clk,
    input  rst_n,

    input  in_start,
    input  in_bit_in,
    input  in_send_reset,

    output reg out_pulse_out,
    output wire out_high_done,
    output wire out_reset_done,
    output wire out_pulse_done
);

    localparam T0H_CYCLES = (T0H_NS * CLK_FREQ_MHZ)/1000;
    localparam T1H_CYCLES = (T1H_NS * CLK_FREQ_MHZ)/1000;
    localparam PULSE_CYCLES = (PULSE_NS * CLK_FREQ_MHZ)/1000 - 1;
    localparam RESET_CYCLES = (RESET_PULSE_NS * CLK_FREQ_MHZ)/1000;

    localparam IDLE = 3'd0;
    localparam WAIT_HIGH = 3'd1;
    localparam WAIT_PULSE = 3'd2;
    localparam RESET_PHASE = 3'd3;

    reg [2:0] state;
    reg  [31:0] counter;
    reg [15:0] high_cycles;

    assign out_high_done = (counter == high_cycles) & !(state == RESET_PHASE);
    assign out_reset_done = counter == RESET_CYCLES;
    assign out_pulse_done = (counter == PULSE_CYCLES) & !(state == RESET_PHASE);

    always @(negedge sys_clk) begin
        if (!rst_n) begin
            state <= IDLE;
            counter <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    counter <= 32'd0;
                    if (in_start) begin
                        high_cycles = in_bit_in ? T1H_CYCLES : T0H_CYCLES;
                        state <= WAIT_HIGH;
                    end else if (in_send_reset) begin
                        state <= RESET_PHASE;
                    end else state <= IDLE;
                end

                WAIT_HIGH: begin
                    if (out_high_done) begin
                        state   <= WAIT_PULSE;
                    end else begin
                        state   <= WAIT_HIGH;
                    end
                    counter <= counter + 32'd1;
                end

                WAIT_PULSE: begin
                    if (out_pulse_done) begin
                        counter <= 32'd0;
                        if (in_start) begin
                            high_cycles = in_bit_in ? T1H_CYCLES : T0H_CYCLES;
                            state <= WAIT_HIGH;
                        end else if (in_send_reset) begin
                            state <= RESET_PHASE;
                        end else state <= IDLE;
                    end else begin
                        counter <= counter + 32'd1;
                        state   <= WAIT_PULSE;
                    end
                end

                RESET_PHASE: begin
                    if (out_reset_done) begin
                        state <= IDLE;
                    end else begin
                        counter <= counter + 32'd1;
                        state   <= RESET_PHASE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                out_pulse_out <= 1'b0;
            end
            WAIT_HIGH: begin
                out_pulse_out <= 1'b1;
            end
            WAIT_PULSE: begin
                out_pulse_out <= 1'b0;
            end
            RESET_PHASE: begin
                out_pulse_out <= 1'b0;
            end
            default: begin
                out_pulse_out <= 1'b0;
            end
        endcase
    end



`ifdef BENCH
    reg [8*40:1] state_name;
    always @(*) begin
        case (state)
            IDLE:        state_name = "IDLE";
            WAIT_HIGH:  state_name = "WAIT_HIGH";
            WAIT_PULSE:   state_name = "WAIT_PULSE";
            RESET_PHASE: state_name = "RESET_PHASE";
        endcase
    end
`endif

endmodule
