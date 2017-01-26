#!/usr/bin/env python

import os
import os.path
from distutils.spawn import find_executable

#Set everything up
MAPPINGS_PKG_ROOT = os.path.dirname(os.path.split(os.path.abspath(__file__))[0])
GAP_DIR= os.path.join(MAPPINGS_PKG_ROOT, 'gap')
PIPES_DIR= os.path.join(MAPPINGS_PKG_ROOT, 'pipes')
if not os.path.exists(PIPES_DIR):
    os.makedirs(PIPES_DIR)
GAP_BINARY=None

try:
    from mysettings import *
except ImportError:
    pass

#GAP_WRAPPER=os.path.join(MAPPINGS_PKG_ROOT,'scripts','test-suite.sh')
if GAP_BINARY == None:
    GAP_BINARY=find_executable('gap',path=os.environ['PATH'])

