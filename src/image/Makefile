ENTITY_FILES = image_window_channel_reducer.vhd        \
               image_window_buffer.vhd                 \
               image_window_buffer_writer.vhd          \
               image_window_buffer_intake.vhd          \
               ${ENDLIST}

pump_components.vhd : ${ENTITY_FILES}
	../../tools/MakeComponentPackage.rb --verbose \
            --brief   'PIPEWORK IMAGE COMPONENTS LIBRARY DESCRIPTION' \
            --version 1.8.0 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library PIPEWORK \
            --package IMAGE_COMPONENTS \
            --output  image_components.vhd \
            ${ENTITY_FILES}

clean:
	-rm image_components.vhd
