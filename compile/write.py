import io

code = ''
line = ''
while True:
    line = raw_input()
    if line == '#-EXIT-':
        break
    code += line + '\n'
f = io.open('../js/out.js', 'w', newline='\n')
f.write(unicode(code))
f.close()
