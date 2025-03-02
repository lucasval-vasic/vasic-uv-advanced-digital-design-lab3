# clocks

# inputs

# outputs

# leave these untouched. they are used to ensure that clocks defined above are propagated through the design and to add a slight overconstraint to both setup and hold timing
set_propagated_clock [all_clocks]
set_clock_uncertainty -hold 0.1 [all_clocks]
set_clock_uncertainty -setup 0.1 [all_clocks]
