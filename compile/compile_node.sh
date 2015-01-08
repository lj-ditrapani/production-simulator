# Depends on node.js with the coffee-script npm module
# sudo npm install -g coffee-script
# Depends on python to run integrate.py 
# (could be rewritten in JavaScript to eliminate the python dependency)
coffee -cj ../js/out.js ../coffee/sim.coffee ../coffee/station.coffee ../coffee/team.coffee ../coffee/summary.coffee && python integrate.py
# There could be a problem with joining all the coffee files.  It may be
# that combining them first is changing the meaning of the code.  They
# are no longer separate modules, but one great big module.  This could
# cause namespace conflicts.

# could compile each .js individually and dump them in the js/ folder,
# then use a .js script to concatenate the files into out.js.  Would
# have to add generated .js files to .gitignore
# If I write a .js file to concatenate the files, I should just instead
# write the file to load each coffee file and use the coffee API to
# compile each one as in the rhino script, then concatenate the code
# together and print to a file.


# fs = require 'fs'
# coffee = require 'coffee-script'

# fs.readFile 'source.coffee', 'utf8', (err, data) ->
#   compiled = coffee.compile data
#   fs.writeFile 'source.js', compiled, (err) ->
#       console.log "Done."

# use jake (or cake)??
# Define a Jakefile with a build task, all code can go in this file.
# Compile all coffee files, join code together, write to js/out.js
# Simply jake build at command line (jake [task])
