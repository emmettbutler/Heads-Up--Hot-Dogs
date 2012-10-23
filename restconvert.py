# coding: utf-8
#https://github.com/jedie/python-creole
#convert a rest file to HTML (for blog)

import sys
import os.path
import re

from creole.rest2html.clean_writer import rest2html

if len(sys.argv) < 2:
    print "Usage: %s [filename]" % __file__
    sys.exit()

try:
    with open(sys.argv[1], "r") as text:
        path,name = os.path.split(sys.argv[1])
        name = "%s.html" % name.split('.')[0]
        f = open(name, "w+")
        text = re.sub("tt>", "code>", rest2html(text.read()))
        f.write(text)
        f.close()
        print "Wrote new file %s" % name
except IOError as e:
    print "File not found!"
    sys.exit()

