#!/usr/bin/env python
import io


def read_files(*args):
    format = '../js/{0}.js'.format
    text_blocks = [read_file(format(name)) for name in args]
    return '\n'.join(text_blocks)


def read_file(file_name):
    f = open(file_name)
    text = f.read()
    f.close()
    return text


def write_file(file_name, contents):
    f = io.open(file_name, 'w', newline='\r\n')
    f.write(unicode(contents))
    f.close()


def make_test_file(head_file, out_file):
    head_text = read_file(head_file)
    make_html_file(head_text, out_file)


def make_html_file(head_text, out_file)
    template_body = read_file('../template_body.html')
    write_file(out_file, insert_head(head_text, template_body))


def insert_head(head_text, template_body):
    pre_head_text, body_text = template_body.split('<head></head>')
    wrapped_head_text = '<head>\n{0}\n</head>'.format(head_text)
    return '\n'.join([pre_head_text, wrapped_head_text, body_text])


def make_sim_file():
    head_template = read_file('../template_head.html')
    head, rest = head_template.split('//utils out main', 1)
    middle, tail = rest.split('/*sim.css*/')
    code = read_files('utils', 'out', 'main')
    css = read_file('../sim.css')
    final_head_text = ''.join([head, code, middle, css, tail])
    make_html_file(final_head_text, '../sim.html')

    
if __name__ == '__main__':
    make_test_file('../js_head.html', '../sim_js.html')
    make_test_file('../coffee_head.html', '../sim_coffee.html')
    make_sim_file()
