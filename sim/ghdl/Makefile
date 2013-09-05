GHDL=ghdl
GHDLFLAGS=--mb-comments -P../../../Dummy_Plug/sim/ghdl/dummy_plug
WORK=PIPEWORK

SRC_PATH  = ../../src

analyze:
	../../tools/MakeSerializedPackageList.rb \
            --library $(WORK) \
            --use_entity 'QUEUE_ARBITER(INTEGER_ARCH)' \
            --use_entity 'SDPRAM(MODEL)' \
            --execute '$(GHDL) -a $(GHDLFLAGS) --work=#{library_name} #{file_name}' \
            $(SRC_PATH)

clean:
	rm -f *.o *.cf 

