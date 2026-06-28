from migen import *

from litex.soc.interconnect.csr import *
import os

src_dir = os.path.dirname(os.path.abspath(__file__))


class Mult32(Module, AutoCSR):
    def __init__(self, platform):
        self.init = init = CSRStorage(1)
        self.A = A = CSRStorage(16)
        self.B = B = CSRStorage(16)
        self.pp = pp = CSRStatus(32)
        self.done = done = CSRStatus(1)
        self.specials += Instance(
            "mult_32",
            i_clk=ClockSignal("sys"),
            i_rst=ResetSignal("sys"),
            i_init=init.storage,
            i_A=A.storage,
            i_B=B.storage,
            o_pp=pp.status,
            o_done=done.status,
        )

        for src in [
            "comp.v",
            "control_mult.v",
            "lsr.v",
            "mult_32.v",
            "pp_acc.v",
            "rsr.v",
        ]:
            platform.add_source(os.path.join(src_dir, src))
