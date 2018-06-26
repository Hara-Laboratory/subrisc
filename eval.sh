#!/bin/bash

workdir=`pwd`

#rtl simulation
cd "${workdir}/saif_rtl/"
make clean
make
cd "${workdir}/"

#synthesize and rtl power estimation
cd "${workdir}/syn/"
dc_shell-t -f do.tcl
cp power_known.txt ../inf/rtl_pwr.txt
cp power_fwd.txt ../inf/fwd_pwr.txt
cp switching_activity.txt ../inf/rtl_sa.txt
