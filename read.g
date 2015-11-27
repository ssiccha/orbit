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

if not IsBound( HashTableType ) then
  Read("hash.gd");
fi;
Read("hash.gi");
##  ReadPackage("parorb","hash.gi");
