#############################################################################
##
##                             parorb package
##  read.g
##                                                          Sergio Siccha
##
##  Copyright...
##
##  Read all *.g, *.gi and *.gd files.
##
#############################################################################

LoadPackage("IO");
Read("init.g");
if not IsBound( HashTableType ) then
  Read("data-structures/hash.gd");
fi;
Read("data-structures/hash.gi");
if not IsBound( StackType ) then
  Read("data-structures/stack.gd");
fi;
Read("data-structures/stack.gi");

Read("orbit.g");
Read("parse.g");
Read("examples.g");
