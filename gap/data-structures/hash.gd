#############################################################################
##
##                             parorb package
##  hash.gd
##                                                          Sergio Siccha
##
##  Copyright...
##
##  Declaring for hash.gi
##
#############################################################################

DeclareCategory( "IsMyHashTable", IsComponentObjectRep );
BindGlobal( "HashTableFamily", NewFamily( "HashTableFamily" ) );
BindGlobal( "HashTableType", NewType( HashTableFamily, IsMyHashTable ) );

DeclareOperation( "HashTableCreate", [ IsObject ] );
DeclareOperation( "HashTableCreate", [ IsObject, IsRecord ] );
DeclareOperation( "HashTableAdd", [ IsMyHashTable, IsObject ]);
DeclareOperation( "ListHashTable", [ IsMyHashTable ]);
