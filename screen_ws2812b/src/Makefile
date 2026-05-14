BUILD_DIR = build
BIT_DIR = bitstream
SIM_DIR = simulation
SIMPLE_SIM_DIR = $(SIM_DIR)/simple
POST_SYNTH_SIM_DIR = $(SIM_DIR)/post_synth
SCRIPTS_DIR = ../scripts
IMAGES_DIR = ../images
TARGET ?= screen_controller
TOP = DEMO_screen_controller
BIT_NAME = $(TOP)
OBJS = DEMO_screen_controller.v\
	   screen_controller.v \
       screen_fsm/screen_fsm.v \
       frame_buffer/frame_buffer.v \
       shift_register/shift_register.v \
       pulse_generator/pulse_generator.v

ifeq ($(TARGET),screen_controller)
	TEST_BENCH = test_benches/$(TARGET)_tb.v
else
	TEST_BENCH = $(TARGET)/test_benches/$(TARGET)_tb.v
endif

ECP5_SIM_CELLS=$(shell yosys-config --datdir/ecp5/cells_sim.v 2>/dev/null)

.PHONY : all simple_sim re_simple_sim sim_post_synth re_sim_post_synth clean

all : simple_sim

simple_sim : $(SIMPLE_SIM_DIR)
	@mkdir -p $(SIMPLE_SIM_DIR)/$(TARGET)
	@echo "Building simulation for $(TARGET)..."
	iverilog -o $(SIMPLE_SIM_DIR)/$(TARGET)/$(TARGET)_tb.vvp \
		-DBENCH -DSIM -DBOARD_FREQ=25 -DCPU_FREQ=25 \
		$(TEST_BENCH) $(OBJS)
	vvp $(SIMPLE_SIM_DIR)/$(TARGET)/$(TARGET)_tb.vvp
	mv $(TARGET)_tb.vcd $(SIMPLE_SIM_DIR)/$(TARGET)/ 2>/dev/null || true
	gtkwave $(SIMPLE_SIM_DIR)/$(TARGET)/$(TARGET)_tb.vcd $(SIMPLE_SIM_DIR)/$(TARGET)/signals_$(TARGET).gtkw &

re_simple_sim : $(SIMPLE_SIM_DIR)
	@echo "Rebuilding simulation for $(TARGET)..."
	iverilog -o $(SIMPLE_SIM_DIR)/$(TARGET)/$(TARGET)_tb.vvp \
		-DBENCH -DSIM -DBOARD_FREQ=25 -DCPU_FREQ=25 \
		$(TEST_BENCH) $(OBJS)
	vvp $(SIMPLE_SIM_DIR)/$(TARGET)/$(TARGET)_tb.vvp
	mv $(TARGET)_tb.vcd $(SIMPLE_SIM_DIR)/$(TARGET)/ 2>/dev/null || true

#LATTICE COLORLIGHT 5A
$(BUILD_DIR)/$(TOP).json : $(BUILD_DIR) $(BIT_DIR)
	yosys -v3 -l $(BUILD_DIR)/synth.log -p 'attrmap -tocase keep -imap keep="true" keep=1; synth_ecp5 -top $(TOP) -json $(BUILD_DIR)/$(TOP).json; write_verilog -attr2comment $(BUILD_DIR)/$(TOP)_synth.v ' $(OBJS) -l $(BUILD_DIR)/$(TOP).rpt
$(BUILD_DIR)/$(TARGET)_out.config : build/$(TOP).json
	nextpnr-ecp5 --json build/$(TOP).json --lpf pin_assignment.lpf --textcfg build/$(TARGET)_out.config --25k --package CABGA256 --speed 6 --timing-allow-fail --seed 1 --lpf-allow-unconstrained --log $(BUILD_DIR)/$(TOP)_pnr.log
$(BIT_DIR)/$(BIT_NAME).bit : $(BIT_DIR) build/$(TARGET)_out.config
	ecppack --bootaddr 0 --compress $(BUILD_DIR)/$(TARGET)_out.config --svf $(BUILD_DIR)/$(TARGET).svf --bit $@

bit_gen : $(BIT_DIR)/$(BIT_NAME).bit

configure_lattice : $(BIT_DIR)/$(BIT_NAME).bit
	sudo openFPGALoader -c ft232RL --pins=0:3:4:1 -m $(BIT_DIR)/$(BIT_NAME).bit
#                                    UART=TXD:CTS:DTR:RXD
#                                    JTAG=TDI:TDO:TCK:TMS 
#                                     PDB=J32:J30:J27:J31     
#                                 FT232RL=0:3:4:1

detect :
	openFPGALoader -c ft232RL --pins=0:3:4:1 --verbose 30000000 --detect

IMAGE ?=

update_image: $(SCRIPTS_DIR)
	python $(SCRIPTS_DIR)/image_to_memory.py $(IMAGES_DIR)/$(IMAGE) -o ./frame_buffer/test_benches/imagen.hex



$(SIMPLE_SIM_DIR) :
	mkdir -p $(SIMPLE_SIM_DIR)

$(POST_SYNTH_SIM_DIR) :
	mkdir -p $(POST_SYNTH_SIM_DIR)

$(BUILD_DIR) :
	mkdir -p $(BUILD_DIR)

$(BIT_DIR) : 
	mkdir -p $(BIT_DIR)

clean :
	find $(SIMPLE_SIM_DIR) -type f ! -name "*.gtkw" -delete
	find $(POST_SYNTH_SIM_DIR) -type f ! -name "*.gtkw" -delete
	rm -rf $(BUILD_DIR)
	rm -rf $(BIT_DIR)