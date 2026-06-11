from migen import *

from litex.soc.interconnect.csr import *
import os
src_dir = os.path.dirname(os.path.abspath(__file__))

class ScreenController(Module,AutoCSR):
    def __init__(self,platform,out_pin,clk_Mhz = 60, qty_pixels = 64 ,n_frames = 1):
        self.init = init = CSRStorage(1)
        self.d_in = d_in = CSRStorage(24)
        self.w_addr = w_addr = CSRStorage(log2_int(qty_pixels*n_frames))
        self.we = we = CSRConstant(1)
        self.specials += Instance("peripheral_screen_controller",
                p_CLK_FREQ_MHZ = clk_Mhz,
                p_QTY_PIXELS = qty_pixels,
                p_N_FRAMES = n_frames,
                i_sys_clk = ClockSignal("sys"),
                i_rst_n = ResetSignal("sys"),
                i_d_in = d_in.storage,
                i_addr = w_addr.storage,
                i_wr = we.constant,
                i_init_cmd = init.storage,
                o_out_to_screen = out_pin.out)
        
        for src in [
            "peripheral_screen_controller.v",
            "screen_controller.v",
            "screen_fsm/screen_fsm.v",
            "frame_buffer/frame_buffer.v",
            "shift_register/shift_register.v",
            "pulse_generator/pulse_generator.v"
        ]:
            platform.add_source(os.path.join(src_dir,src))
