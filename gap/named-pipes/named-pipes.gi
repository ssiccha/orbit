#############################################################################
##
##                         KPN-Architecture-Mappings
##  named-pipes.gi
##                                                          Sergio Siccha
##
##  Copyright...
##
##  Provides a means to communicate with another process
##  via a named pipe.
##
#############################################################################

## HPCGAP: Transfer IO record to the public region.
## TODO recognize whether we're running HPCGAP
#MakeImmutable( IO );
## Opens a pipe for both read and write access
## TODO change this later to include parameter for RDONLY or WRONLY
PipeOpen := function( pipeFilename )
    local pipe;
    ## Use `mkfifo pipe-test` to create named pipe
    pipe := IO_open( pipeFilename, IO.O_RDWR, 0 );
    if pipe = fail then
        Error( "Could not open ", pipeFilename );
    fi;
    ## 2^16 corresponds to the default buffer size
    pipe := IO_WrapFD( pipe, 2^16, 2^16 );
    return pipe;
end;

##################################################
# Operation NamedPipeHandle
# Input:
#   pipeFilename - string
#   options - an options record
# Filters:
#   IsString, IsRecord
#
# Output:
#   newPipeHandle
##################################################
InstallMethod( NamedPipeHandle,
"for a pipe-filename string",
[ IsString ],
function( pipeFilename )
    return NamedPipeHandle( pipeFilename, rec() );
end );

##################################################
# Operation NamedPipeHandle
# Input:
#   pipeFilename - string
#   options - an options record
# Filters:
#   IsString, IsRecord
#
# Output:
#   newPipeHandle
##################################################
InstallMethod( NamedPipeHandle,
"for a pipe-filename string and an options record",
[ IsString, IsRecord ],
function( pipeFilename, options )
    local pipe, newPipeHandle, type;
    pipe := PipeOpen( pipeFilename );
    newPipeHandle := rec( pipe := pipe );
    type := NamedPipeHandleType;
    Objectify( type, newPipeHandle );
    return newPipeHandle;
end );

##################################################
# Operation ReadLine
# Input:
#   namedPipeHandle
# Filters:
#   IsNamedPipeHandle
#
# Output:
#   string
##################################################
InstallMethod( ReadLine,
"for a named-pipe-handle",
[ IsNamedPipeHandle ],
function( namedPipeHandle )
    local string;
    string := IO_ReadLine( namedPipeHandle!.pipe );
    ## Ignore lines that start with a '#'
    if string[1] = '#' then
        Info( InfoWarning, 1, "Ignoring input starting with '#'." );
        return ReadLine( namedPipeHandle );
    fi;
    ## Ctrl-D character was passed into pipe
    if string[1] = '\004' and Length( string ) = 2 then
        ## TODO propagate '\004' signal?
        IO_close( namedPipeHandle!.pipe );
        return fail;
    fi;
    return string;
end );
#IO_ReadLine( pipe );
#IO_Flush
