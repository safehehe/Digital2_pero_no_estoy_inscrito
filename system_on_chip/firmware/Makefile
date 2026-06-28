#from https://github.com/enjoy-digital/litex/blob/master/litex/soc/software/demo/Makefile
BUILD_DIR?=../build/
LINKER?=linker_main_ram.ld
include $(BUILD_DIR)/software/include/generated/variables.mak
include $(SOC_DIRECTORY)/software/common.mak

OBJECTS   = crt0.o main.o
#NO QUITAR crt0.o
COMMA = ,
REGULAR_LIBS = $(filter-out $(ALWAYS_LINK_LIBS),$(LIBS))
ALWAYS_LINK_LIBFLAGS = $(if $(ALWAYS_LINK_LIBS),-Wl$(COMMA)--whole-archive $(ALWAYS_LINK_LIBS:lib%=-l%) -Wl$(COMMA)--no-whole-archive)
OBJDUMP = $(TRIPLE)-objdump


all: firmware.bin


%.bin: %.elf %.lst
	$(LITEX_PYTHON) -m litex.soc.software.memusage firmware.elf $(BUILD_DIR)/software/include/generated/regions.ld $(TRIPLE)
	$(OBJCOPY) -O binary $< $@
	chmod -x $@

vpath %.a $(PACKAGES:%=../%)

firmware.lst: firmware.elf
	$(OBJDUMP) -d -S $< > $@

firmware.elf: $(OBJECTS)
	@echo "Compilando Firmware"
	$(CC) $(LDFLAGS) -T ./$(LINKER) -N -o $@ \
		$(OBJECTS) \
		$(PACKAGES:%=-L$(BUILD_DIR)/software/%) \
		-Wl,--start-group \
		$(REGULAR_LIBS:lib%=-l%) \
		$(ALWAYS_LINK_LIBFLAGS) \
		-Wl,--end-group \
		-Wl,--gc-sections \
		-Wl,-Map,$@.map
	chmod -x $@
# pull in dependency info for *existing* .o files
-include $(OBJECTS:.o=.d)

VPATH = $(BIOS_DIRECTORY):$(BIOS_DIRECTORY)/cmds:$(CPU_DIRECTORY)

%.o: %.c
	$(compile)

%.o: %.S
	$(assemble)

clean:
	$(RM) $(OBJECTS) firmware.elf firmware.bin .*~ *~

.PHONY: all clean
