GHDL=ghdl
GHDLFLAGS=--mb-comments
WORK=PIPEWORK

SRC_PATH  = ../../src

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
             pump_flow_syncronizer                  \
             pump_controller                        \
             pump_operation_processor               \
             relay_components                       \
             relay_request_controller               \
             relay_request_syncronizer              \
             relay_response_syncronizer             \
             axi4_types                             \
             axi4_components                        \
             axi4_master_address_channel_controller \
             axi4_master_read_interface             \
             axi4_master_write_interface            \
             axi4_register_write_interface          \
             axi4_register_read_interface           \
             axi4_register_interface                \
             pci_target_select                      \
             pcie_tlp_types                         \
             pcie_tlp_components                    \
             pcie_tlp_rx_stream_interface           \
             pcie_tlp_tx_stream_interface           \
             pcie_tlp_tx_arbiter                    \
             pcie_tlp_rx_routing                    \
             pcie_tlp_rx_router                     \
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

pump_flow_syncronizer.o                  : $(SRC_PATH)/pump/pump_flow_syncronizer.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pump_controller.o                        : $(SRC_PATH)/pump/pump_controller.vhd pump_components.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pump_operation_processor.o               : $(SRC_PATH)/pump/pump_operation_processor.vhd  pump_components.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

relay_components.o                       : $(SRC_PATH)/relay/relay_components.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

relay_request_syncronizer.o              : $(SRC_PATH)/relay/relay_request_syncronizer.vhd  components.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

relay_request_controller.o               : $(SRC_PATH)/relay/relay_request_controller.vhd   components.o pump_components.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

relay_response_syncronizer.o             : $(SRC_PATH)/relay/relay_response_syncronizer.vhd components.o
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

pcie_tlp_types.o                         : $(SRC_PATH)/pcie/pcie_tlp_types.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pcie_tlp_components.o                    : $(SRC_PATH)/pcie/pcie_tlp_components.vhd pcie_tlp_types.o pcie_tlp_rx_routing.o pci_target_select.o 
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pcie_tlp_rx_stream_interface.o           : $(SRC_PATH)/pcie/pcie_tlp_rx_stream_interface.vhd pcie_tlp_types.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pcie_tlp_tx_stream_interface.o           : $(SRC_PATH)/pcie/pcie_tlp_tx_stream_interface.vhd pcie_tlp_types.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pcie_tlp_tx_arbiter.o                    : $(SRC_PATH)/pcie/pcie_tlp_tx_arbiter.vhd          pcie_tlp_types.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pcie_tlp_rx_routing.o                    : $(SRC_PATH)/pcie/pcie_tlp_rx_routing.vhd          pcie_tlp_types.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pcie_tlp_rx_router.o                     : $(SRC_PATH)/pcie/pcie_tlp_rx_router.vhd           pcie_tlp_types.o pcie_tlp_rx_routing.o pci_target_select.o
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<

pci_target_select.o                      : $(SRC_PATH)/pcie/pci_target_select.vhd            
	 $(GHDL) -a $(GHDLFLAGS) --work=$(WORK) $<
