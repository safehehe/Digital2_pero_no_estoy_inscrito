#
# This file is part of LiteX-Boards.
#
# Copyright (c) 2026 Gwenhael Goavec-Merou <gwenhael.goavec-merou@trabucayre.com>
# SPDX-License-Identifier: BSD-2-Clause
#
# PZ-Starlite :
# - PZ7010-Starlite (xc7z010): https://www.puzhitech.com/en/detail/373.html
# - PZ7010-Starlite (xc7z010): https://www.puzhitech.com/en/detail/374.html

from litex.build.generic_platform import *
from litex.build.xilinx import Xilinx7SeriesPlatform
from litex.build.openfpgaloader import OpenFPGALoader

#TODO
# IOs ----------------------------------------------------------------------------------------------

_io = [
    # Clk / Rst
    ("clk200", 0,
        Subsignal("p", Pins("R4"), IOStandard("DIFF_SSTL135")),
        Subsignal("n", Pins("T4"), IOStandard("DIFF_SSTL135"))
    ),
    ("global_rst_n", 0, Pins("R14"), IOStandard("LVCMOS33")), 

    # Leds
    ("user_led", 0, Pins("W22"), IOStandard("LVCMOS33")),
    ("user_led", 1, Pins("Y22"), IOStandard("LVCMOS33")),

    # Buttons
    ("user_btn", 0, Pins("W21"), IOStandard("LVCMOS33")),#External Pullup
    ("user_btn", 1, Pins("Y21"), IOStandard("LVCMOS33")),

    # Serial UART to USB via CH340E
    ("serial", 0,
        Subsignal("tx", Pins("P15")),
        Subsignal("rx", Pins("P14")),
        IOStandard("LVCMOS33")
    ),

    # EEPROM (AT24C64D)
    # Read Addr: 0xA1
    # Write Addr: 0xA0
    ("eeprom", 0,
        Subsignal("sda", Pins("N14")),#External pullup
        Subsignal("scl", Pins("N13")),
        IOStandard("LVCMOS33"),
    ),

    # RGMII Ethernet (RTL8211F) on board
    # 25 MHz crystal
    ("eth_clocks", 0,
        Subsignal("tx", Pins("P17")),
        Subsignal("rx", Pins("W19")),
        IOStandard("LVCMOS33")
    ),
    ("eth", 0,
        Subsignal("rst_n",   Pins("W21")),
        Subsignal("mdio",    Pins("N15")),
        Subsignal("mdc",     Pins("T18")),
        Subsignal("rx_ctl",  Pins("W20")),
        Subsignal("rx_data", Pins("U18 R19 R18 P20")),
        Subsignal("tx_ctl",  Pins("R16")),
        Subsignal("tx_data", Pins("P19 P16 N17 R17")),
        IOStandard("LVCMOS33")
    ),

    # HDMI
    ("hdmi", 0,
        Subsignal("clk_p",       Pins("Y18"), IOStandard("TMDS_33")),
        Subsignal("clk_n",       Pins("Y19"), IOStandard("TMDS_33")),
        Subsignal("data0_p",     Pins("V18"), IOStandard("TMDS_33")),
        Subsignal("data0_n",     Pins("V19"), IOStandard("TMDS_33")),
        Subsignal("data1_p",     Pins("AA19"), IOStandard("TMDS_33")),
        Subsignal("data1_n",     Pins("AB20"), IOStandard("TMDS_33")),
        Subsignal("data2_p",     Pins("V17"), IOStandard("TMDS_33")),
        Subsignal("data2_n",     Pins("W17"), IOStandard("TMDS_33")),
        Subsignal("scl",         Pins("T21"), IOStandard("LVCMOS33")),
        Subsignal("sda",         Pins("U20"), IOStandard("LVCMOS33")),
        Subsignal("hdp",         Pins("V20"), IOStandard("LVCMOS33")),
        Subsignal("hdmi_out_en", Pins("V22"), IOStandard("LVCMOS33")),
        Subsignal("cec",         Pins("W22"), IOStandard("LVCMOS33")),
    ),
    # DDR3 SDRAM MT41K256M16
    # MT41K256M16 -107
    ("ddram", 0,
        Subsignal("a", Pins(
            "AA4 AB2 AA5 AB5 AB1 U3 W1 T1",
            "V2  U2  Y1  W2  Y2  U1 W5"),
            IOStandard("SSTL135")),
        Subsignal("ba",    Pins("AA3 Y3 Y4"), IOStandard("SSTL135")),
        Subsignal("ras_n", Pins("V4"), IOStandard("SSTL135")),
        Subsignal("cas_n", Pins("W4"), IOStandard("SSTL135")),
        Subsignal("we_n",  Pins("AA1"), IOStandard("SSTL135")),
        Subsignal("cs_n",  Pins("AB3"), IOStandard("SSTL135")),
        Subsignal("dm",    Pins("D2 G2 M2 M5"),IOStandard("SSTL135")),
        Subsignal("dq",    Pins(
            "C2 G1 A1 F3 B2 F1 B1 E2",
            "H3 G3 H2 H5 J1 J5 K1 H4",
            "L4 M3 L3 J6 K3 K6 J4 L5",
            "P1 N4 R1 N2 M6 N5 P6 P2"),
            IOStandard("SSTL135"),
            Misc("IN_TERM=UNTUNED_SPLIT_40")),
        Subsignal("dqs_n", Pins("D1 J2 L1 P4"),
            IOStandard("DIFF_SSTL135"),
            Misc("IN_TERM=UNTUNED_SPLIT_40")),
        Subsignal("dqs_p", Pins("E1 K2 M1 P5"),
            IOStandard("DIFF_SSTL135"),
            Misc("IN_TERM=UNTUNED_SPLIT_40")),
        Subsignal("clk_p", Pins("R3"), IOStandard("DIFF_SSTL135")),
        Subsignal("clk_n", Pins("R2"), IOStandard("DIFF_SSTL135")),
        Subsignal("cke",   Pins("T5"), IOStandard("SSTL135")),
        Subsignal("odt",   Pins("U5"), IOStandard("SSTL135")),
        Subsignal("reset_n", Pins("W6"), IOStandard("SSTL135")),
        Misc("SLEW=FAST")
    ),
    # SPIFlash
    ("flash_cs_n", 0, Pins("T19"), IOStandard("LVCMOS33")),
    ("flash", 0,
        Subsignal("mosi", Pins("P22")),
        Subsignal("miso", Pins("R22")),
        Subsignal("wp",   Pins("P21")),
        Subsignal("hold", Pins("R21")),
        IOStandard("LVCMOS33"),
    ),
    # SDCard
    ("spisdcard", 0,
        Subsignal("clk",  Pins("AA20")),
        Subsignal("cs_n", Pins("AA21")),
        Subsignal("mosi", Pins("AB21"), Misc("PULLUP")),
        Subsignal("miso", Pins("AB18"), Misc("PULLUP")),
        Misc("SLEW=FAST"),
        IOStandard("LVCMOS33")
    ),
    ("sdcard", 0,
        Subsignal("clk",  Pins("AA20")),
        Subsignal("cmd",  Pins("AB21"), Misc("PULLUP True")),
        Subsignal("data", Pins("AB18 AA18 AB22 AA21"), Misc("PULLUP True")),
        Misc("SLEW=FAST"),
        IOStandard("LVCMOS33")
    ),
]

_connectors = [
    ("JM1", {
          1: "5V",   2: "3V3",
          3: "GND",  4: "GND",
          5: "E16",  6: "F13",
          7: "D17",  8: "F14",
          9: "C13", 10: "D14",
         11: "B13", 12: "D15",
         13: "A13", 14: "C14",
         15: "A14", 16: "C15",
         17: "A15", 18: "E13",
         19: "A16", 20: "E14",
         21: "B17", 22: "B15",
         23: "B18", 24: "B16",
         25: "D17", 26: "F16",
         27: "C17", 28: "E17",
         29: "C18", 30: "F18",
         31: "C19", 32: "E18",
         33: "GND", 34: "GND",
         35: "GND", 36: "GND",
         37: "E19", 38: "B20",
         39: "D19", 40: "A20",
    }),
    ("JM2", {
          1: "5V",   2: "3V3",
          3: "GND",  4: "GND",
          5: "G17",  6: "N22",
          7: "G18",  8: "M22",
          9: "G15", 10: "H17",
         11: "G16", 12: "H18",
         13: "J14", 14: "J15",
         15: "H14", 16: "H15",
         17: "H13", 18: "M21",
         19: "G13", 20: "L21",
         21: "J20", 22: "H20",
         23: "J21", 24: "G20",
         25: "J19", 26: "K21",
         27: "H19", 28: "K22",
         29: "K18", 30: "J22",
         31: "K19", 32: "H22",
         33: "GND", 34: "GND",
         35: "GND", 36: "GND",
         37: "L19", 38: "M18",
         39: "L20", 40: "Y18",
    })
]


# Platform -----------------------------------------------------------------------------------------

class Platform(Xilinx7SeriesPlatform):
    default_clk_name   = "clk200"
    default_clk_period = 1e9/200e6

    def __init__(self, variant="xc7a35t", toolchain="vivado"):
        assert variant in ["xc7a35t"]
        #xc7a35tfgg484
        self.part = part = f"{variant}fgg484"
        device     = f"{part}-2"
        io         = _io
        connectors = _connectors
        Xilinx7SeriesPlatform.__init__(self, device, io, connectors, toolchain=toolchain)
        self.toolchain.bitstream_commands = [
            "set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]",
            "set_property BITSTREAM.CONFIG.CONFIGRATE 16 [current_design]",
            "set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]",
            "set_property CFGBVS VCCO [current_design]",
            "set_property CONFIG_VOLTAGE 3.3 [current_design]",
        ]
    def create_programmer(self):
        return OpenFPGALoader(cable="ft232", fpga_part=self.part)

    def do_finalize(self, fragment):
        Xilinx7SeriesPlatform.do_finalize(self, fragment)
        self.add_period_constraint(self.lookup_request("clk200", loose=True), 1e9/200e6)
        self.add_period_constraint(self.lookup_request("eth_clocks:rx", 0, loose=True), 1e9/25e6)
        self.add_period_constraint(self.lookup_request("eth_clocks:tx", 0, loose=True), 1e9/25e6)
