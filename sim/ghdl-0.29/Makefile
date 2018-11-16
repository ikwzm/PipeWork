GHDL=ghdl
GHDLFLAGS=--mb-comments
WORK=PIPEWORK

SRC_PATH  = ../../src


pipework-obj93.cf : pipework.vhd
	$(GHDL) -a $(GHDLFLAGS) --work=$(WORK) pipework.vhd

pipework.vhd : 
	../../tools/vhdl-archiver.rb \
            --library $(WORK) \
            --use_entity 'QUEUE_ARBITER(INTEGER_ARCH)' \
            --use_entity 'SDPRAM(MODEL)' \
            --archive    pipework.vhd \
            $(SRC_PATH)

analyze:
	../../tools/vhdl-archiver.rb \
            --library $(WORK) \
            --use_entity 'QUEUE_ARBITER(INTEGER_ARCH)' \
            --use_entity 'SDPRAM(MODEL)' \
            --execute '$(GHDL) -a $(GHDLFLAGS) --work=#{library_name} #{file_name}' \
            $(SRC_PATH)

clean:
	rm -f pipework.vhd *.o *.cf 

