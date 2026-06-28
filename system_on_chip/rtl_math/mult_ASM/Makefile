DESIGN = mult
BUILD_DIR = build
SIM_DIR = simulation
SIMPLE_SIM_DIR = $(SIM_DIR)/simple
POST_SYNTH_SIM_DIR = $(SIM_DIR)/post_synth
POST_ROUTE_SIM_DIR = $(SIM_DIR)/post_route
TESTBENCH_DIR = test_benches
ECP5_SIM_CELLS=$(shell yosys-config --datdir/ecp5/cells_sim.v)

TOP = mult_32
TARGET = mult_32
OBJS = $(wildcard *.v)

.PHONY : all simple_sim re_simple_sim sim_post_synth re_sim_post_synth clean

all : simple_sim

simple_sim : $(SIMPLE_SIM_DIR) #Crea la carpeta, los archivos de simulación y lanza GTKwave
	iverilog -o $(SIMPLE_SIM_DIR)/$(TARGET)_TB.vvp -DBENCH -DSIM -DPASSTHROUGH_PLL -DBOARD_FREQ=27 -DCPU_FREQ=27 $(TESTBENCH_DIR)/$(TARGET)_TB.v $(OBJS)
	vvp $(SIMPLE_SIM_DIR)/$(TARGET)_TB.vvp
	mv $(TARGET)_TB.vcd $(SIMPLE_SIM_DIR)/
	gtkwave $(SIMPLE_SIM_DIR)/$(TARGET)_TB.vcd $(SIMPLE_SIM_DIR)/signals.gtkw &
re_simple_sim : $(SIMPLE_SIM_DIR) #Crea la carpeta y los archivos de simulación
	iverilog -o $(SIMPLE_SIM_DIR)/$(TARGET)_TB.vvp -DBENCH -DSIM -DPASSTHROUGH_PLL -DBOARD_FREQ=27 -DCPU_FREQ=27 $(TESTBENCH_DIR)/$(TARGET)_TB.v $(OBJS)
	vvp $(SIMPLE_SIM_DIR)/$(TARGET)_TB.vvp
	mv $(TARGET)_TB.vcd $(SIMPLE_SIM_DIR)/

build/$(TOP).json : $(BUILD_DIR)
	yosys -v3 -l $(BUILD_DIR)/synth.log -p 'synth_ecp5 -top $(TOP) -json $(BUILD_DIR)/$(TOP).json ; fsm ; write_verilog -attr2comment $(BUILD_DIR)/$(TOP)_synth.v ' $(OBJS)
#	yosys -v3 -l synth.log -p 'synth_ecp5              -top $(TOP) -json $(TOP).json;              write_verilog -attr2comment $(TOP)_synth.v' $(OBJS)


sim_post_synth : build/$(TOP).json $(OBJS) $(POST_SYNTH_SIM_DIR)
	iverilog -o $(POST_SYNTH_SIM_DIR)/$@_PS.vvp -s $(TOP)_TB $(TESTBENCH_DIR)/$(TARGET)_TB.v $(BUILD_DIR)/$(TOP)_synth.v $(ECP5_SIM_CELLS)
#	iverilog -o $@_PS.vpp                       -s $(TOP)_TB $(TARGET)_TB.v                  $(TOP)_synth.v              $(ECP5_SIM_CELLS) 

	vvp $(POST_SYNTH_SIM_DIR)/$@_PS.vvp
	mv $(TOP)_TB.vcd $(POST_SYNTH_SIM_DIR)/
	gtkwave $(POST_SYNTH_SIM_DIR)/$(TOP)_TB.vcd &
re_sim_post_synth : build/$(TOP).json $(OBJS) $(POST_SYNTH_SIM_DIR)
	iverilog -o $(POST_SYNTH_SIM_DIR)/$@_PS.vvp -s $(TOP)_TB $(TESTBENCH_DIR)/$(TARGET)_TB.v $(BUILD_DIR)/$(TOP)_synth.v $(ECP5_SIM_CELLS)
	vvp $(POST_SYNTH_SIM_DIR)/$@_PS.vvp
	mv $(TOP)_TB.vcd $(POST_SYNTH_SIM_DIR)/


$(SIMPLE_SIM_DIR) :
	mkdir -p $(SIMPLE_SIM_DIR)
$(POST_SYNTH_SIM_DIR) :
	mkdir -p $(POST_SYNTH_SIM_DIR)
$(BUILD_DIR) :
	mkdir -p $(BUILD_DIR)
clean :
	rm -rf $(SIM_DIR)
	rm -rf $(BUILD_DIR)
