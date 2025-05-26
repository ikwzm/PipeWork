ENTITY_FILES = pump_control_register.vhd               \
               pump_flow_syncronizer.vhd               \
               pump_controller_intake_side.vhd         \
               pump_controller_outlet_side.vhd         \
               pump_controller.vhd                     \
               pump_stream_intake_controller.vhd       \
               pump_stream_outlet_controller.vhd       \
               pump_operation_processor.vhd            \
               pump_request_controller.vhd             \
               pipe_requester_interface.vhd            \
               pipe_responder_interface.vhd            \
               pipe_controller.vhd                     \
               ${ENDLIST}

pump_components.vhd : ${ENTITY_FILES}
	../../tools/MakeComponentPackage.rb --verbose \
            --brief   'PIPEWORK PUMP COMPONENTS LIBRARY DESCRIPTION' \
            --version 2.3.0 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library PIPEWORK \
            --package PUMP_COMPONENTS \
            --output  pump_components.vhd \
            ${ENTITY_FILES}

clean:
	-rm pump_components.vhd
