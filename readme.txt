========================================================================
coffee:     user production coffeescript code
compile:    tools and user code to compile coffee -> js and 
            generate final, integrated html
js:         user production javascript code (some compiled from coffee)
lib:        3rd party libraries for testing (javascript, css)
spec:       user specification code, (coffeescript, javascript, & html)
unused:     stuff not needed, may deleted later
========================================================================
The final, self-contained sim.html can be written to the kuwik directory
above the code directory, so no accidental erasures


Create functional tests
give user input
set static mock random objects (closure on array & index, move index along).  Know values.
Check data output from simulation matches expectations


Round 5 WIP seems messed up
WIP does not go to zero for S2 on round 5

Must add tests
    station.update() for S1 on round >= 5 causes correct state
    station.update() when inactive causes capacity & produced = 0
