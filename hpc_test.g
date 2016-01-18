#############################################################################
##
##                             orbit package
##  hpc_test.g
##                                                          Sergio Siccha
##
##  Copyright...
##
##  tests for orbit under HPC-GAP
##
#############################################################################
## Benchmarking and testing of hashTableOrbit
Read("init.g");

## fresh HashTable
ht := HashTableCreate( 1, rec() );

## test hTO
G := SymmetricGroup(10);
task := RunTask( hashTableOrbit, G, (1,2,3) );
