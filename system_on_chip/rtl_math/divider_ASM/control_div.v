module control_div (
    clk,
    rst,
    init_in,
    MSB,
    in_K,
    INIT,
    SH,
    DEC,
    loadA,
    DONE,
    DV0
);

  input clk;
  input rst;
  input init_in;
  input MSB;
  input in_K;

  output reg INIT;
  output reg DV0;
  output reg SH;
  output reg DEC;
  output reg loadA;
  output reg DONE;


  parameter START = 3'b000;
  parameter SHIFT_DEC = 3'b001;
  parameter CHECK = 3'b010;
  parameter ADD = 3'b011;
  parameter END1 = 3'b100;

  reg [2:0] state;
  reg [4:0] timer_done;
  parameter ST_TIMER_DONE = 5'd24;


  always @(posedge clk) begin
    if (rst) begin
      state = START;
      timer_done = ST_TIMER_DONE;
    end else begin
      case (state)
        START: begin
          timer_done = ST_TIMER_DONE;
          state = init_in ? SHIFT_DEC : START;
        end
        SHIFT_DEC: state = CHECK;
        CHECK: begin
          if (MSB == 0) state = ADD;
          else state = SHIFT_DEC;
        end
        ADD:
        if (in_K) state = END1;
        else state = SHIFT_DEC;
        END1: begin
          if (timer_done == 0) state = START;
          else begin
            timer_done = timer_done - 1;
            state = END1;
          end
        end
        default: state = START;
      endcase
    end
  end

  always @(*) begin
    case (state)
      START: begin
        INIT = 1;
        DV0 = 0;
        SH = 0;
        DEC = 0;
        loadA = 0;
        DONE = 0;
      end
      SHIFT_DEC: begin
        INIT = 0;
        DV0 = 0;
        SH = 1;
        DEC = 1;
        loadA = 0;
        DONE = 0;
      end
      CHECK: begin
        INIT = 0;
        DV0 = 0;
        SH = 0;
        DEC = 0;
        loadA = 0;
        DONE = 0;
      end
      ADD: begin
        INIT = 0;
        DV0 = 0;
        SH = 0;
        DEC = 0;
        loadA = 1;
        DONE = 0;
      end
      END1: begin
        INIT = 0;
        DV0 = 1;
        SH = 0;
        DEC = 0;
        loadA = 0;
        DONE = 1;
      end
      default: begin
        INIT = 1;
        DV0 = 0;
        SH = 0;
        DEC = 0;
        loadA = 0;
        DONE = 0;
      end
    endcase
  end


`ifdef BENCH
  reg [8*40:1] state_name;
  always @(*) begin
    case (state)
      START:     state_name = "START";
      CHECK:     state_name = "CHECK";
      SHIFT_DEC: state_name = "SHIFT_DEC";
      ADD:       state_name = "ADD";
      END1:      state_name = "END1";
    endcase
  end
`endif




endmodule
