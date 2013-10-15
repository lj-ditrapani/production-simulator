#!/usr/bin/env python
import io

def read_files(*args):
    text_blocks = [read_file('../js/{0}.js'.format(name)) for name in args]
    return '\n'.join(text_blocks)


def read_file(file_name):
    f = open(file_name)
    text = f.read()
    f.close()
    return text

    
text = read_file('../sim_template.html')
head, text2 = text.split('//utils out main', 1)
middle, tail = text2.split('/*sim.css*/')
code = read_files('utils', 'out', 'main')
css = read_file('../sim.css')
text = ''.join([head, code, middle, css, tail])
f = io.open('../sim.html', 'w', newline='\r\n')
f.write(unicode(text))
f.close()
