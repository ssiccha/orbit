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
Read("read.g");

## test hTO
testHashTableOrbit := function( x, n, NUMBER_THREADS, NUMBER_GRAB_NEW, opt... )
  local G, res1, res2, task;
  if opt = [] then
    opt := rec();
  fi;
  if not IsBound( opt.verbose ) then
    opt.verbose := false;
  fi;
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
#testHashTableOrbit( (1,2,3), 130, 8,  20 );  # faster than 200
# BUG: sometimes yields values bigger than 715520
