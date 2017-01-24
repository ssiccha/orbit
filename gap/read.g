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

Read("canonization.g");
Read("orbit.g");
Read("parse-KPN-architecture.g");
Read("parse-mappings.g");
Read("mappings-cache-lookup.g");
