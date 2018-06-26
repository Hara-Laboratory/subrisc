saif: simv
	./simv
	vcd2saif -64 -input vcdplus.vpd -output activity.saif

simv:
	vcs -debug_all -full64 +v2k -top testbench ../hdl/testbench.v ../hdl/*.v
		
clean:
	rm -f simv
	rm -f activity.saif
	rm -f ucli.key
	rm -f vcdplus.vpd
	rm -rf csrc/
	rm -rf simv.daidir/
	
