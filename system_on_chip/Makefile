LITEX_DIR = ~/litex
LITEX_PYTHON = $(LITEX_DIR)/venv/bin/python
LITEX_SOC_DIR = $(LITEX_DIR)/litex/litex/soc
ECP5_SIM_CELLS_DIR=$(shell yosys-config --datdir/ecp5)
ECP5_SIM_CELLS=$(shell yosys-config --datdir/ecp5/cells_sim.v)
PLATFORM ?= colorlight_5a_75e
BUILD_DIR = build/$(PLATFORM)
FIRMWARE_DIR = firmware
FIRMWARE_BIN = firmware.bin
SIM_DIR  = sim/$(PLATFORM)
TEST_BENCH = test_benches/$(PLATFORM)_tb.v


RTL_MATH_DIR = ./rtl_math/mult_ASM
SCREEN_DIR = ../screen_ws2812b/rtl
OBJS = $(LITEX_DIR)/pythondata-cpu-vexriscv/pythondata_cpu_vexriscv/verilog/VexRiscv.v
OBJS += $(BUILD_DIR)/gateware/$(PLATFORM).v
OBJS += $(wildcard $(RTL_MATH_DIR)/*.v)
OBJS += $(shell find $(SCREEN_DIR)/ -name "*.v" -not -name "*tb.v" -not -name "DEMO*")

export LITEX_PYTHON


.PHONY : all sim re_sim clean

.ONESHELL:
all : sim

sim : $(SIM_DIR)
	. ./activate_litex.sh
	rm -rf $(BUILD_DIR) $(SIM_DIR)/*vvp $(SIM_DIR)/*vcd $(FIRMWARE_DIR)/*bin
	$(LITEX_PYTHON) $(PLATFORM).py --build --no-compile-gateware --simulation 2>/dev/null
	$(MAKE) -C $(FIRMWARE_DIR) BUILD_DIR=../$(BUILD_DIR) SOC_DIR=$(LITEX_SOC_DIR) LINKER=linker_rom.ld
	cp $(FIRMWARE_DIR)/$(FIRMWARE_BIN) .
	SIMULATION=1 $(LITEX_PYTHON) $(PLATFORM).py \
		--build --no-compile --simulation --integrated-rom-init=$(FIRMWARE_BIN) \
		--cpu-reset-address=0x00000000 2>/dev/null
	awk '/INFO:SoC:Finalized SoC:/{flag=1} /INFO:SoC:SoC Hierarchy:/{flag=0} flag' $(BUILD_DIR)/litex.log
	echo "Running Iverilog"	 
	iverilog  \
		-I$(ECP5_SIM_CELLS_DIR) -DNO_INCLUDES \
		-o $(BUILD_DIR)/gateware/$(PLATFORM).vvp \
		-s $(PLATFORM)_tb \
		$(TEST_BENCH) $(OBJS) $(ECP5_SIM_CELLS)
	echo "Entering in $(BUILD_DIR)/gateware"
	cd $(BUILD_DIR)/gateware
	vvp $(PLATFORM).vvp
	cd ../../../
	echo "Entering in:"
	@pwd
	mv $(BUILD_DIR)/gateware/$(PLATFORM)_tb.vcd $(SIM_DIR)/
	gtkwave $(SIM_DIR)/$(PLATFORM)_tb.vcd $(SIM_DIR)/signals_$(PLATFORM).gtkw &	

#build_my_firmware_rom:
#	. ./activate_litex.sh
#	rm -rf $(BUILD_DIR) $(SIM_DIR)/*vvp $(SIM_DIR)/*vcd $(FIRMWARE_DIR)/*bin
#	$(LITEX_PYTHON) $(PLATFORM).py --build --no-compile-gateware 2>/dev/null
#	$(MAKE) -C $(FIRMWARE_DIR) BUILD_DIR=../$(BUILD_DIR) SOC_DIR=$(LITEX_SOC_DIR) LINKER=linker_rom.ld
#	cp $(FIRMWARE_DIR)/$(FIRMWARE_BIN) ./rom_$(FIRMWARE_BIN)
#	$(LITEX_PYTHON) $(PLATFORM).py \
#		--build --integrated-rom-init=rom_$(FIRMWARE_BIN) \
#		--cpu-reset-address=0x0 2>/dev/null
#	awk '/INFO:SoC:Finalized SoC:/{flag=1} /INFO:SoC:SoC Hierarchy:/{flag=0} flag' $(BUILD_DIR)/litex.log

firmware_main_ram: $(BUILD_DIR)/software/bios/bios.bin
	. ./activate_litex.sh
	rm -rf $(FIRMWARE_DIR)/*bin
	$(MAKE) -C $(FIRMWARE_DIR) BUILD_DIR=../$(BUILD_DIR) clean
#	$(LITEX_PYTHON) $(PLATFORM).py --build --no-compile-gateware 2>/dev/null Ya deberia estar con la bios compilada
	$(MAKE) -C $(FIRMWARE_DIR) BUILD_DIR=../$(BUILD_DIR) SOC_DIR=$(LITEX_SOC_DIR) LINKER=linker_main_ram.ld
	cp $(FIRMWARE_DIR)/$(FIRMWARE_BIN) ./main_ram_$(FIRMWARE_BIN)

$(SIM_DIR) :
	mkdir -p $(SIM_DIR)

clean :
	rm -rf $(BUILD_DIR) ./*bin
	$(MAKE) -C $(FIRMWARE_DIR) BUILD_DIR=../$(BUILD_DIR) clean
