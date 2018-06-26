# SubRISC
Simple Instruction-Set Computer for IoT edge devices
We have developed a small and energy-efficient RISC processor, called SubRISC, which has the limited number of simple instructions extended from Subtract and branch on NeGative with 4 operands (SNG4).
The processor is described in synthesizable Verilog HDL by Synopsys Design Compiler. 

## Directory Hierarchy
| Directory | Explanation |
----|---- 
| hdl | HDL description of SubRISC and memory initialization files for quick sort and motion detection |
| lib | Memory characteristics library |
| saif_rtl | Simulation files for switching activity estimation by Synopsys VCS |
| syn | Synthesis script by Synopsys Design Compiler |
| inf | Area/power results of evaluation |
| eval.sh | Shell-script to obtain evaluation power/area/performance. |

## To Evaluate Performance/Power/Area
### Check dependencies
To evaluate them, Synopsys Design Compiler and VCS are required to be installed.
### Prepare Standard Cell Library
In order to synthesize HDL descriptions, place a standard cell library file (\*.db) in lib directory.
We utilized 'typical_conditional_ccs' liberty file of Nangate 45nm Standard Cell Library (refer http://www.nangate.com/?p=1599).
After you prepare the files, compile them (\*.lib) to Design Compiler Database file (\*.db) like the following:
```
$ dc_shell
dc_shell > read_lib NangateOpenCellLibrary_typical_conditional_ccs.lib
dc_shell > write_lib -f db NangateOpenCellLibrary -o lib/nangate45-typ-ccs.db
```
### Prepare SubRISC Memory Initialization Files
It means assembling SubRISC programs and placing them at hdl/hex/ directory.
OiscSim provides assembling SubRISC programs and generates two hex files (\*_h.hex and \*_l.hex).
Place them at hdl/hex/ directory, and modify hdl/memory_45nm.v by names of two files.
### Run eval.sh
By executing the following commands, you will obtain the number of executed cycles, circuit area, and power consumption about synthesized SubRISC.
```
sh eval.sh
```

## Published Paper
K. Saso and Y. Hara-Azumi, "Simple Instruction-Set Computer for Area and Energy-Sensitive IoT Edge Devices," In Proceeding of 29th IEEE International Conference on Application-specific Systems, Architectures and Processors (ASAP), Milan, Italy, Jul. 2018.

## License
All files under this project are licensed by GPLv3 or later.
