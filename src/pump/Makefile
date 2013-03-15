ENTITY_FILES = pump_control_register.vhd               \
               pump_flow_syncronizer.vhd               \
               pump_controller.vhd                     \
               pump_operation_processor.vhd            \
               ${ENDLIST}

pump_components.vhd : ${ENTITY_FILES}
	../../tools/MakeComponentPackage.rb --verbose \
            --brief   'PIPEWORK PUMP COMPONENTS LIBRARY DESCRIPTION' \
            --version 1.4.0 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library PIPEWORK \
            --package PUMP_COMPONENTS \
            --output  pump_components.vhd \
            ${ENTITY_FILES}

clean:
	-rm pump_components.vhd
