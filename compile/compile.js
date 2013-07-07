/*
Author:  Lyall Jonathan Di Trapani -------------------------------------
Usage:
java -jar rhino.jar -f compile.js
*/

// List of files to compile
file_names = ['sim', 'station', 'team', 'summary'];
load("../lib/coffee-script.js");
code = '';
for (i in file_names) {
    text = readFile('../coffee/' + file_names[i] + '.coffee');
    code += '\n\n' + CoffeeScript.compile(text);
}
// Write code to file
options = {};
options.input = code + '\n#-EXIT-';
runCommand('python', 'write.py', options);
