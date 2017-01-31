#############################################################################
##
##                        Orbits of mappings package
##  read.g
##                                                          Sergio Siccha
##
##  Copyright...
##
##  Read all *.g, *.gi and *.gd files.
##
#############################################################################

LoadPackage("IO");
Read("utils.g");
Read("data-structures/encode.g");
if not IsBound( HashTableType ) then
    Read("data-structures/hash.gd");
fi;
Read("data-structures/hash.gi");
if not IsBound( StackType ) then
    Read("data-structures/stack.gd");
fi;
Read("data-structures/stack.gi");

if not IsBound( NamedPipeHandleType ) then
    Read("named-pipes/named-pipes.gd");
fi;
Read("named-pipes/named-pipes.gi");

Read("canonization.g");
Read("parse-KPN-architecture.g");
Read("parse-mappings.g");
Read("orbit.g");
Read("mappings-cache-lookup.g");
