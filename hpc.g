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
testHashTableOrbit := function( x, n, NUMBER_THREADS, NUMBER_GRAB_NEW )
  local G, res1, res2, task;
  G := SymmetricGroup( n );
  task := RunTask(
    hashTableOrbitMaster,
    G,
    x,
    rec(
      NUMBER_THREADS := NUMBER_THREADS,
      NUMBER_GRAB_NEW := NUMBER_GRAB_NEW
    )
  );
  res1 := Size( TaskResult( task ) );
  Print( res1, "\n" );
#  res2 := Size( x ^ G );
#  Print( res2, "\n" );
#  return (res1 = res2 );
end;

testHashTableOrbit( (1,2,3), 100, 8, 200 );
testHashTableOrbit( (1,2,3), 130, 8,  20 );  # faster than 200
# BUG: sometimes yields values bigger than 715520
