GHDL=ghdl
GHDLFLAGS=--mb-comments
WORK=PIPEWORK

SRC_PATH  = ../../src/

COMPONENTS = components                             \
             chopper                                \
             delay_adjuster                         \
             delay_register                         \
             queue_arbiter                          \
             queue_arbiter_integer_arch             \
             queue_register                         \
             reducer                                \
             sdpram                                 \
             sdpram_model                           \
             syncronizer                            \
             syncronizer_input_pending_register     \
             pump_components                        \
             pump_count_up_register                 \
             pump_count_down_register               \
             pump_control_register                  \
             pump_intake_valve                      \
             pump_outlet_valve                      \
             axi4_types                             \
             axi4_components                        \
             axi4_master_address_channel_controller \
             axi4_master_read_interface             \
             axi4_master_write_interface            \
             axi4_register_write_interface          \
             axi4_register_read_interface           \
             axi4_register_interface                \
             $(END_LINE)

OBJS      = $(addsuffix .o,$(COMPONENTS))

all  : $(OBJS)

clean:
	rm -f *.o *.cf 

components.o                             : $(SRC_PATH)/components/components.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

chopper.o                                : $(SRC_PATH)/components/chopper.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

delay_register.o                         : $(SRC_PATH)/components/delay_register.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

delay_adjuster.o                         : $(SRC_PATH)/components/delay_adjuster.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

queue_arbiter.o                          : $(SRC_PATH)/components/queue_arbiter.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

queue_arbiter_integer_arch.o             : $(SRC_PATH)/components/queue_arbiter_integer_arch.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

queue_register.o                         : $(SRC_PATH)/components/queue_register.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

reducer.o                                : $(SRC_PATH)/components/reducer.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

sdpram.o                                 : $(SRC_PATH)/components/sdpram.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

sdpram_model.o                           : $(SRC_PATH)/components/sdpram_model.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

syncronizer.o                            : $(SRC_PATH)/components/syncronizer.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

syncronizer_input_pending_register.o     : $(SRC_PATH)/components/syncronizer_input_pending_register.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pump_components.o                        : $(SRC_PATH)/pump/pump_components.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pump_count_up_register.o                 : $(SRC_PATH)/pump/pump_count_up_register.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pump_count_down_register.o               : $(SRC_PATH)/pump/pump_count_down_register.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pump_control_register.o                  : $(SRC_PATH)/pump/pump_control_register.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pump_intake_valve.o                      : $(SRC_PATH)/pump/pump_intake_valve.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pump_outlet_valve.o                      : $(SRC_PATH)/pump/pump_outlet_valve.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_types.o                             : $(SRC_PATH)/axi4/axi4_types.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_components.o                        : $(SRC_PATH)/axi4/axi4_components.vhd axi4_types.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_master_address_channel_controller.o : $(SRC_PATH)/axi4/axi4_master_address_channel_controller.vhd components.o axi4_components.o 
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_master_read_interface.o             : $(SRC_PATH)/axi4/axi4_master_read_interface.vhd    components.o axi4_components.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_master_write_interface.o            : $(SRC_PATH)/axi4/axi4_master_write_interface.vhd   components.o axi4_components.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_register_write_interface.o          : $(SRC_PATH)/axi4/axi4_register_write_interface.vhd components.o axi4_components.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_register_read_interface.o           : $(SRC_PATH)/axi4/axi4_register_read_interface.vhd  components.o axi4_components.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

axi4_register_interface.o                : $(SRC_PATH)/axi4/axi4_register_interface.vhd       components.o axi4_components.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

