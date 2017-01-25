#############################################################################
##
##                         KPN-Architecture-Mappings
##  named-pipes.gd
##                                                          Sergio Siccha
##
##  Copyright...
##
##  Declarations for named-pipes.gi
##
#############################################################################

DeclareCategory( "IsNamedPipeHandle", IsComponentObjectRep );
BindGlobal(
    "NamedPipeHandleFamily",
    NewFamily( "NamedPipeHandleFamily" )
);
BindGlobal(
    "NamedPipeHandleType",
    NewType( NamedPipeHandleFamily, IsNamedPipeHandle )
);

DeclareOperation( "NamedPipeHandle", [ IsString ] );
DeclareOperation( "NamedPipeHandle", [ IsString, IsRecord ] );
DeclareOperation( "ReadLine", [ IsNamedPipeHandle ] );
