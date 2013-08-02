ENTITY_FILES = pcie_tlp_rx_router.vhd           \
               pcie_tlp_tx_arbiter.vhd          \
               pcie_tlp_rx_stream_interface.vhd \
               pcie_tlp_tx_stream_interface.vhd \
               ${ENDLIST}

components.vhd : ${ENTITY_FILES}
	../../tools/MakeComponentPackage.rb --verbose \
            --brief   'PIPEWORK PCI-Express LIBRARY DESCRIPTION' \
            --version 0.0.4 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library PIPEWORK \
            --package PCIe_COMPONENTS \
            --output  pcie_tlp_components.vhd \
            ${ENTITY_FILES}

clean:
	-rm pcie_tlp_components.vhd
