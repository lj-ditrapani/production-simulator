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


Dependencies
------------------------------------------------------------------------
First install node.js and npm.  Then install gulp globally so it is
available at the command line.

    $ npm install -g gulp

The dependencies are only needed for building the actual sim.html
as well as running the tests.


To setup the project
------------------------------------------------------------------------

    $ npm install
    $ gulp get-dependencies


To create sim.html (the production simulator)
------------------------------------------------------------------------

    $ gulp

Produces the final, self-contained product:  `sim.html`.
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
- **js**:       production JavaScript code
- **lib**:      3rd party libraries for testing (JavaScript, css)
                qunit.css qunit.js coffee-script.js
- **spec**:     specification code, (CoffeeScript)


Understanding the different HTML files
------------------------------------------------------------------------
- `template.html`:       template used to produce `sim.html`
- `sim.html`:            actual stand-alone product
- `spec_runner.html`:    runs all CoffeeSript qUnit tests


TODO:
------------------------------------------------------------------------
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

Other ideas (for faster manual testing only)
- A testing mode "Show all panels" button
  (make config, run, results & summary visible
  at same time).  If you click on config, run, results, or summary
  buttons, it hides the other panels automatically
- Simulate all rounds:  run simulation for rounds 1-6 in sequence for
  current config (is this useful outside of testing?)
    setup()
    for round_num in [1..6]
        sim.round_num = round_num
