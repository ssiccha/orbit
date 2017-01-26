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
print("Initializing GAP PIPE...", end="")
sys.stdout.flush()

#Write something to gap
out_pipe = os.open(out_pipe_filename,os.O_WRONLY) 
os.write(out_pipe,("Hello, GAP!\n" + unichr(0004)))

print("Done.")

#Clean-up 
gap_handle.terminate()
os.remove(out_pipe_filename)
