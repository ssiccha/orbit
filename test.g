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
Read("../utils.g");

## test hTO
testHashTableOrbit := function( x, n, NUMBER_THREADS, NUMBER_GRAB_NEW, opt... )
  local G, res1, res2, task;
  if opt = [] then
    opt := rec();
  else
    opt := opt[1];
  fi;
  opt.verbose := IsBound( opt.verbose );

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
  res1 := TaskResult( task );
  if opt.verbose then
    Print( Size( res1 ), "\n" );
  fi;
  return res1;
end;

#testHashTableOrbit( (1,2,3), 100, 8, 200 );
#testHashTableOrbit( (1,2,3), 130, 8,  20 );  # faster than 200?

_args := [ (1,2,3), 30, 8, 20 ];
