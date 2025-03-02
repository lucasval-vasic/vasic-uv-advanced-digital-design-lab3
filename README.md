#Lab 3 - Logical synthesis and Design for Test

## Introduction
On this lab we will get acquainted with the logical synthesis tool from Cadence: Genus.

During the lab you will first get an introduction to the TCL language used in EDA tools, then create timing constraints for synthesis and then get familiar with the different steps in the synthesis task and finally you will insert scan chains into a design.

## TCL

TCL (Tool Command Language)  is a powerful scripting language commonly used in electronic design automation (EDA) tools for automating tasks, configuring environments, and managing design flows. It is known for its simplicity, flexibility, and ease of integration with various tools.

### Basic TCL syntax

- Commands: Each line in TCL is a command. Commands are separated by either newlines or semicolons.
```
puts "puts commands prints text out to terminal"
```
- Comments: Only single line comments are supported. They are preceded by #
```
# This is a comment
```
- Variable assignment is done with command set. Syntax is "set varName value"
- Variables are automatically interpolated into strings.
- We can stop variable interpolation with backlash (\)
```
set design_name fifo
puts "The design name is $design_name"
puts "\$design_name is $design_name" 
```
- lists are TCL basic data structure. They can contain numbers, strings, whatever. Lists can be created with list element0 element1 ...
```
set first_list [list 0 1 2 3]
puts "this is my first list: $first_list"
```
- Mathematical expressions are evaluated with command expr. Wrapping the expression in curly braces ({}) will result in faster code execution.
```
set i 10
expr 2 * $i
expr {10 * $i}
```
- We can assign the output of an expression to a var using square brackets ([])
```
set res [ expr { 2 * $i } ]
puts "result is $res"
```
- Flow control. Conditionals: if, switch
```
set x 1

if {$x == 2} {puts "$x is 2"} else {puts "$x is not 2"}

set A 10
set B 20
set OP "add"

switch $OP {
    "add" { set res [expr {$A + $B}] }
    "sub" { set res [expr {$A - $B}] }
}

puts "result of $OP is $res"
```
- Flow control. Loops: while, for, foreach 
```
set x 0
set max 10

# while loop
while {$x <= $max} {
    puts "counting $x up to $max"
    set x [expr {$x + 1}]
}

# for loop
for {set x 0} {$x <= $max} {incr x} {# notice no $ on incr!
    puts "counting $x up to $max"
}

set step 2
for {set x 0} {$x <= $max} {incr x $step} {# notice no $ on incr!
    puts "counting $x up to $max in steps of $step"
}

# foreach loop used to iterate over lists
set designs [list "fifo" "cpu" "sram"]
foreach design $designs {
    puts "processing design $design"
}
```
- Methods are defined with proc. Syntax is proc name arguments body.
```
proc ten_times {x} {
    set res [expr $x * 10]
    return $res
}

set x 23
puts "ten times $x is [ten_time $x]" 
```

### Further reading

[This is a great tutorial in case you totally *loved* TCL and want to become a guru.](https://wiki.tcl-lang.org/page/Tcl+Tutorial+Lesson+0)

## Design overview

Before starting with the synthesis section we will review the first design that we will implement. This design is a synchronous FIFO with a single clock port and separate read and write ports.

[This is a high level overview of the synchronous FIFO.](sync_fifo.md) Please read it through and become familiar with the block.

You can find the RTL code for the FIFO [here](sync_fifo/rtl/sync_fifo.v). It will be useful to also become familiar with it.

## Process information

The lab uses the Cadence 45nm process as the target process for the synthesis flow. If you finish the lab early you can easily port the flow to an alternate process: the Google SkyWater 130nm process.

## Genus start

As we did on the first lab we will source the script to set up the paths for Cadence tools:

```console
> source /eda/cdsenv.sh
```

Now we can ensure that Genus works by invoking it:

```console
> genus
```

After some text output you should get the Genus prompt. If this is the case just issue the exit command to get back to the terminal.

## Synthesis flow scripts

The lab provides a complete set of synthesis scripts. The first task of the lab is to examine and get familiar with these files. The flow scripts follow a fixed structure: they are placed under the sync_fifo directory, named after the block to implement. This directory contains subdirectories for some of the implementation tasks like syn for synthesis, rtl to hold the RTL design files and tcons to hold the timing constraints.

Inside the syn/ directory you can find the run directory from which you will the synthesis, scripts to hold the synthesis flow scripts, out where synthesis output files will be created and rep where synthesis reports will be written.

Start by opening sync_fifo/syn/scripts/run.tcl script and read it through. This is the master script for synthesis, where some variables will be set to configure the synthesis run. You will find references to familiar stages like map to generic gates, map to technology gates, optimization, timing verification. For each of these tasks a separate script will be executed. This is done to simplify the main script.

Now start checking out each of the separate scripts. Notice how they are very generic scripts that could be run across many designs simply adjusting some TCL variables.

## Timing constraints

As we saw on the theory section in order to successfully run the implementation flow we must properly specify the timing conditions under which design will run. In practice this involves creating a constraints file that specifies items like the active clocks in the design and the input-output timing.

The lab provides a template for the constraints file on sync_fifo/tcons/sync_fifo.sdc. Open the file and notice how 3 sections are empty: the section for defining clocks, the one for input constraints and the one for output constraints.

On the clock section create a clock of a relatively slow 30MHz frequency. It is strongly suggested to use a TCL variable to hold the clock frequency and then perform a mathematical operation to obtain the clock period for the create_clock constraint since later on we will be modifying it.

Then create input and output constraints for the rest of input, output ports. For this lab we are not very concerned about the IO timing so simply set a 1ns delay for both inputs and outputs, relative to the clock you created before.

One last thing: asynchronous reset signals such as aclr should not be constrained with a delay relative to a clock. Instead, they should be described as completely asynchronous signals. In SDC this is accomplished setting a false path starting from the aclr port.

## Initial synthesis

Now we will run out first synthesis. Make sure you're in the sync_fifo/syn/run directory and call up Genus with the run.tcl script:

```console
> genus -files ../scripts/run.tcl
```

After some screens of text output the synthesis process should complete without errors. Now it's time to review the files written out by Genus to the out/ and rep/ directories. You will find things like the intermediate and final synthesis netlist, and different reports about timing, area, gate in each of the different synthesis stages.


## Synthesis reports

Now that our initial synthesis run has completed we will examine the multiple report files written out by Genus. Notice how many reports repeat from synthesis state to synthesis stage. This may be useful when debugging some area or timing issue. For now we will concentrate on the reports from final stage, after all the mapping and optimizations have been completed.

Check out the final_gates.rpt. Notice how it describes the total gate count, plus counter per gate type and includes an estimation of leakage power.

On report_power.rpt you will find an estimate of the complete power figure consumed by the design and the breakdown into static and dynamic power.

Now check out final_qor.rpt. Notice how it describes the TNS and WNS slacks, plus the area figures.

Then check out final_timing.rpt which has a similar structure to Tempus reports from Lab 1. Here the paths with worst timing are analyzed.

Finally check out final.rpt. This is a summary table of different metrics across the synthesis stages. It may be useful to see how each of the stages contributes to the final figures.

## Restoring design

During each of the synthesis stages a snapshot is stored in the rep folder, named STAGE_BLOCK_NAME.db, where STAGE is each of the synthesis stages. We can quickly restore any of these checkpoints with the read_db command:

```commandline
read_db ../rep/STAGE_BLOCK_NAME.db
```

Restore the snapshot for the final stage, we will use it to query the design database.

## Design database. get_db, set_db

On Cadence tools the design information is stored in an internal database that we can query with the get_db, set_db commands.

get_db is used to read data from the database. There are two ways to access objects using get_db:
1. get_db object_type pattern
2. get_db object .attribute
Wildcards can be used for attribute names.
   
- The following example retrieves the current value of the library attribute on the root directory:
```commandline
:> get_db / .library
```
- The following example assumes you are already at the root of the design hierarchy, so the object specification is omitted:
```commandline
genus:> get_db library
```
- The following example returns the area of all flip flops. get_db is nestable.:
```commandline
genus:> get_db [get_db lib_cells *DFF*] .area
```
- The following example lists all root-level attributes starting with lp (related to low power implementation). It lists the attributes along with their values:
```commandline
genus:> get_db / .lp*
```

set_db is used to write data into the database. There are two ways to modify values of objects using set_db:

1. set_db object(s) .chain value
2. set_db object(s) .attribute value

-The following example sets the information_level attribute, which controls the verbosity of the tools, to the value of 5 and assumes the current directory for the path:
```commandline
genus:> set_db information_level 5
```
-The following example shows how to set preserve attribute for instance a/b
```commandline
genus:> set_db inst:a/b .preserve true
```
-The following example shows how to set preserve attribute for all instances
```commandline
genus:> set_db [get_db insts] .preserve true
```
-The following example shows how to set max_fanout attribute for all input ports
```commandline
genus:> set_db [get_ports -filter direction==in] .max_fanout 10
```
-The following example shows how to set preserve attribute for the nets of the instance a/b
```commandline
genus: set_db inst:a/b .pins.net.preserve true
```

## Timing violations

Since you specified at relatively low frequency for the clock the design synthesized with clean timing margins and no violations. Now increase the clock frequency to be higher than the process library supports and cause violations. Compare the timing and area reports with the previous run. Make a backup copy of the /rep folder so you can compare the runs.

## Effort level
By default effort levels
are all set to medium:
```commandline
set GEN_EFF medium
set MAP_OPT_EFF medium
```
Experiment setting it to high for both GEN_EFF and MAP_OPT_EFF when over-constraining the clock frequency and notice the effect on area and timing.

## Retiming

Keep the high clock frequency. Now add this command on top of syn_generic.tcl script:

```commandline
set_db design:$BLOCK_NAME .retime true
```

Rerun synthesis and notice how the tool takes a longer time as Genus is performing retiming. Search the logfile for "retime" and notice how it describes the WNS retiming will attempt to correct.

## DFT insertion

In order to insert scan into the design we need to manually edit the RTL code and introduce the dedicated scan controls, inputs and outputs. Since the design isn't too large we can do with a single scan chain. Larger designs will require many scan chains.

Now set DO_INSERT_SCAN to true in run.tcl, so the calls to scan_define.tcl and scan_insert.tcl are executed. Add the appropriate scan control port names in scan_define.tcl. Look for the TODO comments.

After all the required edits you can rerun the synthesis and inspect the rep/dft* reports. Notice there are 2 sets of reports: dft_preview* and dft_insert*. The first ones belong to the scan rules check before scan is inserted, and the second ones are the rules checks after scan chain insertion. Also the list of flops belonging to scan chains is reported. Make a note of the chain length.

## Run ATPG

After the scan insertion Genus will produce a complete setup for the Automated Test Pattern Generation task (ATPG). We can easily invoke Modus, the Cadence ATPG tool to check the testability of the design and get some coverage figures.

Simply go to the out/ directory and invoke Modus:

```commandline
modus -f runmodus.atpg.tcl
```

Check out the out/modus.log file and notice the different Modus commands compiled by Genus.

## Scan compression

In oder to add scan compression we need to add a few more extra ports to the Verilog code: scan_compr_enable, scan_mask_enable, scan_mask_load and scan_mask_clk. The first port enables the scan compressor. The mask controls allow masking, this is, disabling some of the paths going through the compressor

Then we need to enable insertion of scan compression with the DO_SCAN_COMPRESSION switch on run.tcl.

We also need to set the compression ratio at the top of scan_define.tcl. Values between 20 and 30 are usual.

Finally, we need to add the names for the newly added ports in the scan_define.tcl script.

After re-running the synthesis and ensuring that the compressor was properly inserted (check out the rep/dft_insert_report_dft_chains_w_comp.rep report and check that the compressed chain length matches the original chain size divided by the compression ratio), re-run Modus. You will see that there are 2 ATPG vector generation stages, the first for COMPRESSION and the second one for FULLSCAN, which increases coverage with a reduced pattern count.

# Alternative manufacturing process

If you have spare time you can rerun the synthesis targeting the 130nm process. To do so simply uncomment the 130nm assignments to LIB_PATH and LEF_PATH variables at the top of run.tcl, and comment the 45nm ones. Make sure to dial back clock frequency to a normal speed and compare both runs. Notice the difference in area, power and timing.