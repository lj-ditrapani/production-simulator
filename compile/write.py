code = ''
line = ''
while True:
    line = raw_input()
    if line == '#-EXIT-':
        break
    code += line + '\n'
f = open('../js/out.js', 'w')
f.write(code)
f.close()
