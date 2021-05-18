ENTITY_FILES = chopper.vhd                             \
               reducer.vhd                             \
               queue_arbiter.vhd                       \
               queue_tree_arbiter.vhd                  \
               delay_register.vhd                      \
               delay_adjuster.vhd                      \
               queue_register.vhd                      \
               queue_receiver.vhd                      \
               least_recently_used_selector.vhd        \
               syncronizer.vhd                         \
               syncronizer_input_pending_register.vhd  \
               sdpram.vhd                              \
               count_down_register.vhd                 \
               count_up_register.vhd                   \
               pipeline_register.vhd                   \
               pipeline_register_controller.vhd        \
               pool_intake_port.vhd                    \
               pool_outlet_port.vhd                    \
               float_intake_valve.vhd                  \
               float_intake_manifold_valve.vhd         \
               float_outlet_valve.vhd                  \
               float_outlet_manifold_valve.vhd         \
               register_access_decoder.vhd             \
               register_access_syncronizer.vhd         \
               register_access_adapter.vhd             \
               unrolled_loop_counter.vhd               \
               ${ENDLIST}

components.vhd : ${ENTITY_FILES}
	../../tools/MakeComponentPackage.rb --verbose \
            --brief   'PIPEWORK COMPONENT LIBRARY DESCRIPTION' \
            --version 1.8.5 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library PIPEWORK \
            --package COMPONENTS \
            --output  components.vhd \
            ${ENTITY_FILES}

clean:
	-rm components.vhd
