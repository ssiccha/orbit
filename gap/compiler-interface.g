#############################################################################
##
##                         KPN-Architecture-Mappings
##  compiler-interface.g
##                                                          Sergio Siccha
##
##  Copyright...
##
##  Provides a means to communicate with another process
##  via a named pipe.
##
#############################################################################

### Proof of Concept code ###
## TODO test this in HPCGAP non-main thread
LoadPackage("IO");
## Use `mkfifo pipe-test` to create named pipe
pipe := IO_open( "pipe-test", IO.O_RDWR, 0 );
## 2^16 corresponds to the default buffer size
pipe := IO_WrapFD( pipe, 2^16, 2^16 );
IO_ReadLine( pipe );
