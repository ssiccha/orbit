#!/usr/bin/env python
from __future__ import print_function

#imports
import os
import os.path
import gap 
import sys
from settings import *

#Set-up GAP communication
out_pipe_filename = os.path.join(PIPES_DIR,'py-to-gap-pipe')
if os.path.exists(out_pipe_filename):
    os.remove(out_pipe_filename)
os.mkfifo(out_pipe_filename)

gap_read_string = 'Read("' + os.path.join(GAP_DIR,'read.g') + '");'
gap_in_pipe_string = 'inPipe := NamedPipeHandle( "' + out_pipe_filename + '");'
gap_readline_string = "ReadLine(inPipe);"

#Start GAP
print("Starting GAP..." , end="")
gap_handle = gap.GapHandle()
print("Done.")
print("Initializing GAP Mappings Package...", end="")
sys.stdout.flush()
gap_handle.communicate(gap_read_string, echo=True)
print("Done.")
print("Initializing GAP PIPE...", end="")
sys.stdout.flush()
gap_handle.communicate(gap_in_pipe_string, echo=True)
print("Done.")
print("Sending message to GAP PIPE...", end="")
sys.stdout.flush()
gap_handle.communicate(gap_readline_string, echo=True)

# from subprocess import Popen, PIPE, STDOUT
# Popen(["/Users/goens/Development/orbit/python/cat_test.sh"])


#Write something to gap
out_pipe = os.open(out_pipe_filename,os.O_WRONLY) 
os.write(out_pipe,"Hello, GAP!\n")

print("Done.")

#Clean-up 
gap_handle.terminate()
os.remove(out_pipe_filename)
