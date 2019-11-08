ENTITY_FILES = axi4_master_address_channel_controller.vhd \
               axi4_master_transfer_queue.vhd             \
               axi4_master_read_interface.vhd             \
               axi4_master_write_interface.vhd            \
               axi4_slave_read_interface.vhd              \
               axi4_slave_write_interface.vhd             \
               axi4_register_write_interface.vhd          \
               axi4_register_read_interface.vhd           \
               axi4_register_interface.vhd                \
               axi4_data_port.vhd                         \
               axi4_data_outlet_port.vhd                  \
               ${ENDLIST}

axi4_components.vhd : ${ENTITY_FILES}
	../../tools/MakeComponentPackage.rb --verbose \
            --brief   'PIPEWORK AXI4 LIBRARY DESCRIPTION' \
            --version 1.8.1 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library PIPEWORK \
            --package AXI4_COMPONENTS \
            --output  axi4_components.vhd \
            ${ENTITY_FILES}

clean:
	-rm axi4_components.vhd
