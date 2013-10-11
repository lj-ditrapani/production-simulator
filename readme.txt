Author: Lyall Jonathan Di Trapani


To create sim.html (the production simulator)
========================================================================
Ensure you have the necessary dependencies 
(see Dependencies section below)
$ cd compile
$ ./compile.sh
or
$ sh compile.sh
produces sim.html and js/out.js

The final, self-contained product:  sim.html
Open sim.html in a web-browser to run simulations (ensure you allow 
blocked content if prompted) or host on a web-server to allow online 
access.
========================================================================


To test the CoffeesSript code, open spec_runner.html in a web-browser 
(ensure you allow blocked content if prompted).


Directories
========================================================================
coffee:     production CoffeesSript code
compile:    tools to compile coffee -> js and 
            generate final, integrated html
js:         production JavaScript code--out.js compiled from coffee
lib:        3rd party libraries for testing (javascript, css)
            qunit.css qunit.js coffee-script.js
spec:       specification code, (CoffeeScript)
========================================================================


Depenencies (only needed for compiling and testing)
========================================================================
rhino.jar
JavaScript interpreter written in Java from mozilla.org 
https://developer.mozilla.org/en-US/docs/Rhino
Expected to be in
compile/rhino.jar
(you could replace this dependency with node.js)

Create a folder called lib and add the following 3 files
$ mkdir lib
CoffeesSript compiler from http://coffeescript.org/
lib/coffee-script.js
qUnit unit testing framework from http://qunitjs.com/
lib/qunit.css
lib/qunit.js

Compiling the CoffeeScript depends on a Bourne-compatible shell (like bash or zsh) and python to run the compile.sh, wirte.py, and integrate.py
scripts.  You could replace these dependencies with any scripting/shell 
language if you rewrote the scripts.
========================================================================


TODO:
Create functional tests
    Although we have unit tests for the internal logic,
    it would be nice to have user-level functional tests to verify that 
    the sim.html is working as required instead of doing manual tests.
    - Tests would provide user input
    - setup static mock random objects 
      (closure on array & index, move index along).  Known values.
    - Run simulation
    - Check data output from simulation matches expectations

- Round Rules listed on cofig page
- "Show all panels" button (make config, run, results & summary visible
  at same time).  If you click on config, run, results, or summary 
  buttons, it hides the other panels automatically
- Simulate all rounds:  run simulation for rounds 1-6 in sequence for 
  current config
    setup()
    for round_num in [1..6]
        sim.round_num = round_num

