ENTITY_FILES = pipe_flow_syncronizer.vhd               \
               pipe_requester_interface.vhd            \
               pipe_responder_interface.vhd            \
               pipe_core_unit.vhd                      \
               ${ENDLIST}

pipe_components.vhd : ${ENTITY_FILES}
	../../tools/MakeComponentPackage.rb --verbose \
            --brief   'PIPEWORK PIPE COMPONENTS LIBRARY DESCRIPTION' \
            --version 1.5.4 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library PIPEWORK \
            --package PIPE_COMPONENTS \
            --output  pipe_components.vhd \
            ${ENTITY_FILES}

clean:
	-rm pipe_components.vhd
