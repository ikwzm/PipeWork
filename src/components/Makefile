ENTITY_FILES = chopper.vhd                             \
               reducer.vhd                             \
               queue_arbiter.vhd                       \
               delay_register.vhd                      \
               delay_adjuster.vhd                      \
               queue_register.vhd                      \
               syncronizer.vhd                         \
               syncronizer_input_pending_register.vhd  \
               sdpram.vhd                              \
               ${ENDLIST}

components.vhd : ${ENTITY_FILES}
	../../../../Dummy_Plug/tools/MakeComponentPackage.rb --verbose \
            --brief   'PIPEWORK COMPONENT LIBRARY DESCRIPTION' \
            --version 1.0.8 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library PIPEWORK \
            --package COMPONENTS \
            --output  components.vhd \
            ${ENTITY_FILES}

clean:
	-rm components.vhd
