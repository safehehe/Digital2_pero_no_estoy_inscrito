module div_16 (
    clk,
    rst,
    init_in,
    A,
    B,
    R,
    Q,
    done
);

  input rst;
  input clk;
  input init_in;
  input [15:0] A;
  input [15:0] B;
  output [15:0] R;
  output [15:0] Q;
  output done;


  wire w_init, w_shift, w_loadA;

  wire [16:0] R_Sub;
 

  wire w_DEC, w_K, w_R, w_DV0;


  lsr_div lsr_d (
      .clk(clk),
      .rst(w_init),
      .DV_in(A),
      .IN_A(R_Sub),
      .INIT(w_init),
      .SH(w_shift),
      .loadA(w_loadA),
      .in_Q(Q),
      .DV0(w_DV0),
      .OUT_R(R)
  );

  sumador #(
      .N_BITS(17),
      .CP2(1)
  ) sb (
      .A(Q),
      .B(B),
      .out_SUM(R_Sub)
  );

  acumulador_restando #(
      .REG_WIDTH (5),
      .RST_VALUE (16),
      .LESS_VALUE(1)
  ) ctr_vd (
      .rst  (w_init),
      .clk  (clk),
      .less (w_DEC),
      .out_K(w_K)
  );

  control_div ctl_dv (
      .clk(clk),
      .rst(rst),
      .init_in(init_in),
      .MSB(R_Sub[16]),
      .in_K(w_K),
      .INIT(w_init),
      .SH(w_shift),
      .DEC(w_DEC),
      .loadA(w_loadA),
      .DONE(done),
      .DV0(w_DV0)
  );



endmodule


