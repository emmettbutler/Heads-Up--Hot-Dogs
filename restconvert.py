# coding: utf-8
#https://github.com/jedie/python-creole
#convert a rest file to HTML (for blog)
from creole.rest2html.clean_writer import rest2html
text = open("README.rst", "r").read()
open("README.html", "w+").write(rest2html(text))
