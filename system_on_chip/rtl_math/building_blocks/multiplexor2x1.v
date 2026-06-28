module multiplexor2x1 #(
    parameter IN_WIDTH = 1
) (
    input [IN_WIDTH-1:0] IN1,
    input [IN_WIDTH-1:0] IN0,
    input SELECT,
    output [IN_WIDTH-1:0] MUX_OUT
);
    assign MUX_OUT = SELECT ? IN1 : IN0;
endmodule
