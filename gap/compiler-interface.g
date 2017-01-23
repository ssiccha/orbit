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
LoadPackage("IO");
## HPCGAP: Transfer IO record to the public region.
MakeImmutable( IO );
OpenPipe := function( pipeFilename )
    local pipe;
    ## Use `mkfifo pipe-test` to create named pipe
    pipe := IO_open( "pipe-test", IO.O_RDWR, 0 );
    ## 2^16 corresponds to the default buffer size
    pipe := IO_WrapFD( pipe, 2^16, 2^16 );
    return pipe;
end;
#IO_ReadLine( pipe );
