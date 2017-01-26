###############################
# This file only serves to 
# communicate with python.
###############################
Read("read.g");
inPipe := NamedPipeHandle( "../pipes/py-to-gap-pipe" );
ReadLine(inPipe);

