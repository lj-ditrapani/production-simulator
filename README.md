Production Simulator
========================================================================

Author: Lyall Jonathan Di Trapani

To use the production simulator, go to http://ditrapani.info/sim.html.
You may download the sim.html file for offline use.

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

produces `sim.html`, `js/out.js`, `sim_js.html`, and `sim_coffee.html`

The final, self-contained product:  `sim.html`
Open `sim.html` in a web-browser to run simulations (ensure you allow
blocked content if prompted) or host on a web-server to allow online
access.


Test CoffeeSript code
------------------------------------------------------------------------
To test the CoffeeSript code, open `spec_runner.html` in a web-browser
(ensure you allow blocked content if prompted).


Directories
------------------------------------------------------------------------
- **coffee**:   production CoffeeSript code
- **compile**:  tools to compile coffee -> js and
                generate final, integrated html
- **js**:       production JavaScript code--out.js compiled from coffee
- **lib**:      3rd party libraries for testing (JavaScript, css)
                qunit.css qunit.js coffee-script.js
- **spec**:     specification code, (CoffeeScript)


Depenencies (only needed for compiling and testing)
------------------------------------------------------------------------
**rhino.jar**: JavaScript interpreter written in Java from Mozilla
https://developer.mozilla.org/en-US/docs/Rhino .
Expected to be in
`compile/rhino.jar`
(you could replace this dependency with node.js)


Create a folder called lib and add the following 3 files

    $ mkdir lib

- **CoffeeSript** compiler from http://coffeescript.org/
  `lib/coffee-script.js`
- **qUnit** unit testing framework from http://qunitjs.com/
  `lib/qunit.css` and `lib/qunit.js`

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
- `spec_runner.html`:    runs all CoffeeSript qUnit unit-tests


TODO:
------------------------------------------------------------------------
- New build process using only node
  - Lock versions in package.json (coffeescript 1.9.3, ect)
  - Update readme to use new build steps
  - Delete everything and clone repo, test readme steps
- Config --- add drop down:
  Round 3 & 4 constraint for S1 capacity:
    - a) Capacity of S1 matches number produced at S3 of previous step.
    - b) Capacity of S1 matches number produced at last station of
      previous step.
    - In both cases, capacity of S1 for step 1 is 4.
      data-model for R3 & R4.
    - Changes rule in Documentation to S3 or last round depending on
      selection

Nice-to-haves
- Add second data model for rounds 3 & 4 for:
  "Capacity of S1 matches number produced at last station".
    - The drop down causes the 'Run' page to display one or the other
- Rename Summary page to "Summary with S1 & S3 linked"
- Add second summary page:  "Summary with S1 & last station linked"
- Add Comparison page:  Avg WIP & produced for both data models
  (from second table in Summary)
- Provide a back button.  This is a big change and probably not really
  important.  Requires simulating/generating all data up front for
  rounds 1-5 and then the UI provides views into each round and step of
  the simulation according to how it is configured.  Need to let user
  set "MAX inducted WIP" for round 6 separately.  Then simulate/generate
  data for round 6.
- Auto-fetch dependencies?  qunit, rhino, CoffeeScript.
  Assume python, java and sh.  Or use rake or jake instead?
- Create functional tests
    Although we have unit tests for the internal logic,
    it would be nice to have user-level functional tests to verify that
    the sim.html is working as required instead of doing manual tests.
    - Tests would provide user input
    - setup static mock random objects
      (closure on array & index, move index along).  Known values.
    - Run simulation
    - Check data output from simulation matches expectations

Ideas
- Use angularjs?  Number of teams and number of stations become ng-model
  and create the table dimensions which are bound in the HTML template
  variables using ng-repeat.
- Compile Using node.js
  Provide alternate build (compile) via node.js.
  Compiles CoffeeScript -> JavaScript and inserts final JavaScript and
  CSS into `sim_template.html` to produce standalone sim.html
  (currently uses rhino, shell, & python to accomplish this).
  First attempt: `compile_node.sh` is not correct because it does not
  use one module per file.
  Need to compile each file separately and then join them together.

Other ideas (testing only?)
- "Show all panels" button (make config, run, results & summary visible
  at same time).  If you click on config, run, results, or summary
  buttons, it hides the other panels automatically
  Only useful in `sim_coffee.html` for quick testing
- Simulate all rounds:  run simulation for rounds 1-6 in sequence for
  current config (is this useful outside of testing?)
    setup()
    for round_num in [1..6]
        sim.round_num = round_num
