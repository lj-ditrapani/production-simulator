Production Simulator
========================================================================

Author: Lyall Jonathan Di Trapani

This is a browser-based, production simulator that illustrates 
constraint theory and project management concepts, specifically 
bottlenecks and variation, in AFIT course LOG 238:  Critical Chain 
Project Management Foundational Concepts.  
AFIT/LS:  School of Systems and Logistics.


To create sim.html (the production simulator)
------------------------------------------------------------------------
Ensure you have the necessary dependencies 
(see Dependencies section below)

    $ cd compile
    $ ./compile.sh

or

    $ sh compile.sh

produces `sim.html` and `js/out.js`

The final, self-contained product:  `sim.html`
Open `sim.html` in a web-browser to run simulations (ensure you allow 
blocked content if prompted) or host on a web-server to allow online 
access.


Test CoffeesSript code
------------------------------------------------------------------------
To test the CoffeesSript code, open `spec_runner.html` in a web-browser 
(ensure you allow blocked content if prompted).


Directories
------------------------------------------------------------------------
- **coffee**:   production CoffeesSript code
- **compile**:  tools to compile coffee -> js and 
                generate final, integrated html
- **js**:       production JavaScript code--out.js compiled from coffee
- **lib**:      3rd party libraries for testing (javascript, css)
                qunit.css qunit.js coffee-script.js
- **spec**:     specification code, (CoffeeScript)


Depenencies (only needed for compiling and testing)
------------------------------------------------------------------------
**rhino.jar**: JavaScript interpreter written in Java from mozilla
https://developer.mozilla.org/en-US/docs/Rhino .
Expected to be in
`compile/rhino.jar`
(you could replace this dependency with node.js)


Create a folder called lib and add the following 3 files

    $ mkdir lib

- **CoffeesSript** compiler from http://coffeescript.org/ 
`lib/coffee-script.js`
- **qUnit** unit testing framework from http://qunitjs.com/
`lib/qunit.css`
and
`lib/qunit.js`

Compiling the CoffeeScript depends on a **Bourne-compatible shell** 
(like bash or zsh) and **python** to run the `compile.sh`, `wirte.py`, 
and `integrate.py` scripts.  You could replace these dependencies with 
any scripting/shell language if you rewrote the scripts (node.js could
replace rhino, shell, and python).


Understanding the different HTML files
------------------------------------------------------------------------
- `sim_coffee.html`:     links to `coffee/*` files; used for testing
- `sim_js.html`:         links to `js/out.js`; used for testing
- `sim_template.html`:   template used to produce `sim.html`
- `sim.html`:            actual stand-alone product
- `spec_runner.html`:    runs all CoffeesSript qUnit unit-tests


TODO:
------------------------------------------------------------------------
- List round rules on cofig page
- "Show all panels" button (make config, run, results & summary visible
  at same time).  If you click on config, run, results, or summary 
  buttons, it hides the other panels automatically
  Only useful in sim\_coffee.html for quick testing
- Simulate all rounds:  run simulation for rounds 1-6 in sequence for 
  current config (is this useful outside of testing?)
    setup()
    for round_num in [1..6]
        sim.round_num = round_num
- autofetch dependencies?  qunit, rhino, CoffeeScript
  (assume python and sh)
- should qunit and rhino be added to .gitignore?
- make js/utils a seperate project and submodule?
    - write in CoffeeScript and add unit tests
- get rid of sim\_js.html?  Not used in testing anymore and broken.
- Create functional tests
    Although we have unit tests for the internal logic,
    it would be nice to have user-level functional tests to verify that 
    the sim.html is working as required instead of doing manual tests.
    - Tests would provide user input
    - setup static mock random objects 
      (closure on array & index, move index along).  Known values.
    - Run simulation
    - Check data output from simulation matches expectations
- Provide alternate build (compile) via node.js 
  Compiles CoffeeScript -> JavaScript and inserts final JavaScript and CSS
  into sim\_template.html to produce standalone sim.html
  (currently uses rhino, shell, & python to accomplish this)
- Add mark of the web?
