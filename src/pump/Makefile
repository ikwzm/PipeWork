ENTITY_FILES = pump_count_up_register.vhd              \
               pump_count_down_register.vhd            \
               pump_control_register.vhd               \
               pump_intake_valve.vhd                   \
               pump_outlet_valve.vhd                   \
               pump_flow_syncronizer.vhd               \
               pump_controller.vhd                     \
               pump_operation_processor.vhd            \
               ${ENDLIST}

pump_components.vhd : ${ENTITY_FILES}
	../../tools/MakeComponentPackage.rb --verbose \
            --brief   'PIPEWORK PUMP COMPONENTS LIBRARY DESCRIPTION' \
            --version 1.3.0 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library PIPEWORK \
            --package PUMP_COMPONENTS \
            --output  pump_components.vhd \
            ${ENTITY_FILES}

clean:
	-rm pump_components.vhd
