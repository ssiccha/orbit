#!/usr/bin/env python

from subprocess import Popen, PIPE, STDOUT
from threading import Thread

try:
    from Queue import Queue, Empty
except ImportError:
    from queue import Queue, Empty  # python 3.x

import os

from settings import *

# http://stackoverflow.com/questions/375427/non-blocking-read-on-a-subprocess-pipe-in-python
# def enque_output(out, queue):
#     for line in iter(out.readline, b''):
#         queue.put(line)
#     out.close()

class GapHandle:
    def __init__(self, binary_name = GAP_BINARY, options = ['-b']):
        if options == ['-b']:
            if os.path.exists("~/.gap/emptyWorkspace"):
                options = options + ["-L","~/.gap/emptyWorkspace"]
            if os.path.exists(os.path.join(GAP_DIR,"python-readmode.g")):
                options = options + [os.path.join(GAP_DIR,"python-readmode.g")]
            
        popen_args = [binary_name] + options
        self.gap_handle = Popen(popen_args, stdin=PIPE,stderr=PIPE,stdout=PIPE, cwd=GAP_DIR)
        # self.stdout_queue = Queue()
        # self.stderr_queue = Queue()
        # self.stdout_thread = Thread(target=enque_output, args=(self.gap_handle.stdout, self.stdout_queue))
        # self.stderr_thread = Thread(target=enque_output, args=(self.gap_handle.stdout, self.stderr_queue))

    def communicate(self, msg, echo = False):
        self.gap_handle.stdin.write(msg)

        # while True:
        #     try:
        #         line = self.stderr_queue.get_nowait()
        #         if line != "\n":
        #             print("GAP Errors: " + line)
        #     except Empty:
        #         break

        # while True:
        #     try:
        #         line = self.stdout_queue.get_nowait()
        #         if line != "\n":
        #             print("GAP Says: " + line)
        #     except Empty:
        #         break

    def terminate(self):
        self.gap_handle.terminate()

    
