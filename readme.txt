Author: Lyall Jonathan Di Trapani
========================================================================
coffee:     user production CoffeesSript code
compile:    tools and user code to compile coffee -> js and 
            generate final, integrated html
js:         user production javascript code (some compiled from coffee)
lib:        3rd party libraries for testing (javascript, css)
            qunit.css qunit.js coffee-script.js
spec:       user specification code, (CoffeeScript)
========================================================================


TODO:
Create functional tests
give user input
set static mock random objects (closure on array & index, move index along).  Know values.
Check data output from simulation matches expectations

- refactor coffee/summary.coffee
    - get_utilization/get_efficiency methods AND functions, confusing
    - duplication in code
- Round Rules listed on cofig page
- "Show all panels" button (make config, run, results & summary visible at same time).  If you click on config, run, results, or summary buttons, it hides the other panels automatically
- Simulate all rounds:  run simulate for rounds 1-6 in sequence for current config
    setup()
    for round_num in [1..6]
        sim.round_num = round_num
        
