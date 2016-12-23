#############################################################################
##
##                             parorb package
##  read.g
##                                                          Sergio Siccha
##
##  Copyright...
##
##  Read all *.g and *.gi files.
##
#############################################################################

LoadPackage("IO");
Read("init.g");
if not IsBound( HashTableType ) then
  Read("hash.gd");
fi;
Read("hash.gi");
if not IsBound( StackType ) then
  Read("stack.gd");
fi;
Read("stack.gi");
Read("canonization.g");
Read("orbit.g");
Read("parse.g");
Read("examples.g");

Read("../utils.g");
