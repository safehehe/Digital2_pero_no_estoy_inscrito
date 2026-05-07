`ifndef SCREEN_CONSTANTS_VH
`define SCREEN_CONSTANTS_VH

parameter SCREEN_WIDTH   = 16;
parameter SCREEN_HEIGHT  = 16;
parameter LED_COUNT      = SCREEN_WIDTH * SCREEN_HEIGHT;
parameter COLOR_BITS     = 24;

parameter WS2812_T0H     = 400;
parameter WS2812_T1H     = 850;
parameter WS2812_T0L     = 850;
parameter WS2812_T1L     = 400;
parameter WS2812_PERIOD  = 1250;
parameter RESET_PULSE_NS = 51000;

parameter CLK_FREQ_MHZ   = 25;
parameter CLK_PERIOD_NS  = 1000 / CLK_FREQ_MHZ;

`endif
