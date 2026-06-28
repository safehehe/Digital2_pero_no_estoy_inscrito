module control_raiz (
    clk,
    rst,
    in_init,
    in_Q,
    in_K,
    out_SHIFTQ,
    out_ADD,
    out_CONT,
    out_SHIFTR,
    out_RST,
    out_DONE
);
  input clk;
  input rst;
  input in_init;
  input [15:0] in_Q;
  input in_K;
  output reg out_SHIFTQ;
  output reg out_ADD;
  output reg out_CONT;
  output reg out_SHIFTR;
  output reg out_RST;
  output reg out_DONE;
  parameter START = 4'b0000;
  parameter STEP1 = 4'b0001;
  parameter CHECK = 4'b0010;
  parameter OPERATE = 4'b0011;
  parameter ITERATE = 4'b0100;
  parameter DONE = 4'b0101;
  parameter STEP2 = 4'b0110;

  reg [3:0] state;
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
          state = in_init ? STEP1 : START;
        end
        STEP1:   state = CHECK;
        CHECK: begin
          state = in_Q[15] ? ITERATE : OPERATE;
        end
        OPERATE: state = ITERATE;
        ITERATE: begin
          state = in_K ? DONE : STEP2;
        end
        STEP2:   state = STEP1;
        DONE: begin
          if (timer_done == 0) state = START;
          else begin
            timer_done = timer_done - 1;
            state = DONE;
          end
        end
      endcase
    end
  end

  always @(*) begin
    case (state)
      START: begin
        out_RST = 1;
        out_SHIFTQ = 0;
        out_ADD = 0;
        out_CONT = 0;
        out_SHIFTR = 0;
        out_DONE = 0;
      end
      STEP1: begin
        out_RST = 0;
        out_SHIFTQ = 1;
        out_ADD = 0;
        out_CONT = 0;
        out_SHIFTR = 0;
        out_DONE = 0;
      end
      CHECK: begin
        out_RST = 0;
        out_SHIFTQ = 0;
        out_ADD = 0;
        out_CONT = 0;
        out_SHIFTR = 0;
        out_DONE = 0;
      end
      OPERATE: begin
        out_RST = 0;
        out_SHIFTQ = 0;
        out_ADD = 1;
        out_CONT = 0;
        out_SHIFTR = 0;
        out_DONE = 0;
      end
      ITERATE: begin
        out_RST = 0;
        out_SHIFTQ = 0;
        out_ADD = 0;
        out_CONT = 1;
        out_SHIFTR = 0;
        out_DONE = 0;
      end
      STEP2: begin
        out_RST = 0;
        out_SHIFTQ = 0;
        out_ADD = 0;
        out_CONT = 0;
        out_SHIFTR = 1;
        out_DONE = 0;
      end
      DONE: begin
        out_RST = 0;
        out_SHIFTQ = 0;
        out_ADD = 0;
        out_CONT = 0;
        out_SHIFTR = 0;
        out_DONE = 1;
      end
      default: begin
        out_RST = 1;
        out_SHIFTQ = 0;
        out_ADD = 0;
        out_CONT = 0;
        out_SHIFTR = 0;
        out_DONE = 0;
      end
    endcase
  end

`ifdef BENCH
  reg [8*40:1] state_name;
  always @(*) begin
    case (state)
      START:   state_name    = "START";
      STEP1:   state_name    = "STEP1";
      CHECK:   state_name    = "CHECK";
      OPERATE: state_name    = "OPERATE";
      ITERATE: state_name    = "ITERATE";
      STEP2:   state_name    = "STEP2";
      DONE:    state_name    = "DONE";
    endcase

  end
`endif

endmodule
