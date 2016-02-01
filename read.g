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

Read("../utils.g");
if not IsBound( HashTableType ) then
  Read("hash.gd");
fi;
Read("hash.gi");
Read("orbit.g");
##  ReadPackage("parorb","hash.gi");
