ENTITY_FILES = relay_controller.vhd             \
               relay_outlet_valve.vhd           \
               relay_requester_interface.vhd    \
               relay_responder_interface.vhd    \
               relay_request_syncronizer.vhd    \
               relay_response_syncronizer.vhd   \
               ${ENDLIST}

relay_components.vhd : ${ENTITY_FILES}
	../../tools/MakeComponentPackage.rb --verbose \
            --brief   'PIPEWORK RELAY COMPONENTS LIBRARY DESCRIPTION' \
            --version 0.0.1 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library PIPEWORK \
            --package RELAY_COMPONENTS \
            --output  relay_components.vhd \
            ${ENTITY_FILES}

clean:
	-rm relay_components.vhd
