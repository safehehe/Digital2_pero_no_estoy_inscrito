module raiz_16 (
    clk,
    rst,
    init,
    in_RR,
    out_Q,
    out_R,
    out_DONE
);
  input rst;
  input clk;
  input init;
  input [15:0] in_RR;

  output [15:0] out_R;
  output [15:0] out_Q;
  output out_DONE;

  wire w_SHIFTQ;
  wire w_ADD;
  wire w_CONT;
  wire w_SHIFTR;
  wire w_K;
  wire w_RST;
  wire [15:0] w_Q;
  wire [15:0] w_AUX;

  lsrR lsrR (
      .clk  (clk),
      .rst  (w_RST),
      .shift(w_SHIFTR),
      .lsb  (w_ADD),
      .out_R(out_R)
  );

  aux aux (
      .clk    (clk),
      .load   (w_SHIFTQ),
      .in_R   (out_R),
      .out_AUX(w_AUX)
  );

  sumador #(
      .N_BITS(16),
      .CP2(1)
  ) comp (
      .A(out_Q),
      .B(w_AUX),
      .out_SUM(w_Q)
  );

  lsrQA lsrQA (
      .clk  (clk),
      .load (w_RST),
      .shift(w_SHIFTQ),
      .add  (w_ADD),
      .in_Q (w_Q),
      .in_RR(in_RR),
      .out_Q(out_Q)
  );
  acumulador_restando #(
      .REG_WIDTH (5),
      .RST_VALUE (16),
      .LESS_VALUE(2)
  ) acc (
      .rst  (w_RST),
      .clk  (clk),
      .less (w_CONT),
      .out_K(w_K)
  );
  control_raiz control_raiz (
      .clk       (clk),
      .rst       (rst),
      .in_init   (init),
      .in_Q      (w_Q),
      .in_K      (w_K),
      .out_SHIFTQ(w_SHIFTQ),
      .out_ADD   (w_ADD),
      .out_CONT  (w_CONT),
      .out_SHIFTR(w_SHIFTR),
      .out_RST   (w_RST),
      .out_DONE  (out_DONE)
  );

endmodule

