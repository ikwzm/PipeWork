ENTITY_FILES = convolution_int_adder.vhd               \
               convolution_int_adder_tree.vhd          \
               convolution_int_accumulator.vhd         \
               convolution_int_multiplier.vhd          \
               convolution_int_core.vhd                \
               convolution_parameter_buffer_writer.vhd \
               convolution_parameter_buffer_reader.vhd \
               convolution_parameter_buffer.vhd        \
               ${ENDLIST}

convolution_components.vhd : ${ENTITY_FILES}
	../../tools/MakeComponentPackage.rb --verbose \
            --brief   'PIPEWORK CONVOLUTION COMPONENT LIBRARY DESCRIPTION' \
            --version 1.8.0 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library PIPEWORK \
            --package CONVOLUTION_COMPONENTS \
            --output  convolution_components.vhd \
            ${ENTITY_FILES}

clean:
	-rm convolution_components.vhd
