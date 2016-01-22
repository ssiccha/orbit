## GLOBAL variables
## constants are stored in _SERSI.C
## variables are stored in _SERSI
## parameter-dependant constants will be filled upon entry
if IsBound( _SERSI ) then
  MakeReadWriteGlobal( "_SERSI" );
  Unbind( _SERSI );
fi;
BindGlobal( "_SERSI",
    rec(
      C := rec(
        NUMBER_GRAB_NEW := 100,
        NUMBER_THREADS := 1,
        gens := "",
        largestMovedPoint := ""
      ),
      hashTable := "",
      ctrl := "",
      sema := CreateSemaphore()
    )
);
## necessary to let _SERSI be adopted by the master thread
ShareObj( _SERSI );


## definition of functions
# hashTableOrbit := function(hashTable, G, m0) end;  ## TODO keep as wrapper?
hashTableOrbitMaster := function( G, m0, options ) end;
hashTableOrbitSlave := function() end;
accessControlVariableAndFetch := function() end;
fetchNewPoints := function() end;
findNewPoints := function() end;


###############################
# function hashTableOrbitMaster
# Input:
#   G  - Group acting on M
#   m0 - Elem of M
#   options - e.g. number of threads
#
# Output:
#   orbit
###############################
hashTableOrbitMaster := function( G, m0, options )
  ## INITIALIZE ##
  local listOfThreads, i;
  listOfThreads := [];

  atomic _SERSI do
    AdoptObj( _SERSI );
    MakeReadOnlyObj( _SERSI );
  od;

  ## init and/or set global variables and constants
  #_SERSI.C.NUMBER_THREADS := 2;
  #_SERSI.C.NUMBER_GRAB_NEW := 100;
  _SERSI.C.gens := GeneratorsOfGroup(G);
  _SERSI.C.largestMovedPoint := LargestMovedPoint( _SERSI.C.gens );
  _SERSI.C := Immutable( _SERSI.C );

  ## initialize objects in shared region
  _SERSI.hashTable := ShareObj(
    HashTableCreate( m0, rec( length := 10^8 ) )
  );
  _SERSI.ctrl := ShareObj( rec() );
  ## newPoints = [], since m0 will be passed to
  ## the first call of findNewPoints
  atomic _SERSI.ctrl do
    IncorporateObj(_SERSI.ctrl, "newPoints", [] );
    IncorporateObj(_SERSI.ctrl, "numberWaiting", 0 );
    IncorporateObj(_SERSI.ctrl, "done", false );
  od;

  ## fill newPoints first
  findNewPoints( [ m0 ] );

  ## spawn findNewPoints tasks, each worker takes a chunk of new points
  for i in [ 1 .. _SERSI.C.NUMBER_THREADS ] do
    listOfThreads[ i ] :=
      CreateThread(
        hashTableOrbitSlave
      );
    Print( "hTOSlave started.\n" );
  od;
  for i in listOfThreads do
    WaitThread( i );
    Print( "Thread ", i, " finished!\n" );
  od;

  ## return result
  atomic _SERSI.hashTable!.elements do
    # Print( hashTable!.elements, "\n" );
    Unbind( _SERSI.hashTable!.elements[ _SERSI.hashTable!.length+1 ] );
    return Concatenation(
      Compacted( _SERSI.hashTable!.elements )
    );
  od;
end;

###############################
# function hashTableOrbitSlave
# Input:
#
# Output:
#
###############################
hashTableOrbitSlave := function()
  local localNewPoints, done;
  done := false;
  while not done do
    localNewPoints := accessControlVariableAndFetch();
    Print( "Thread ", ThreadID( CurrentThread() ),
      " fetched ", Size( localNewPoints ),
      " new Points.\n"
    );
    findNewPoints( localNewPoints );
  od;
  return;
end;

###############################
# function accessControlVariableAndFetch
# Input:
#
# Output:
#   localNewPoints
###############################
accessControlVariableAndFetch := function()
  local localNewPoints, done, iWasIdle;
  done := false;
  iWasIdle := false;
  while not done do
    atomic _SERSI.ctrl do
      ## done stores whether we are completely finished
      if _SERSI.ctrl.done then
        done := _SERSI.ctrl.done;
      fi;
      # pop from gnp
      localNewPoints := fetchNewPoints();
      # if there are waiting threads and there is still something to do,
      # wake up another thread
      if ( _SERSI.ctrl.numberWaiting > 0 and _SERSI.ctrl.newPoints <> [] ) then
        SignalSemaphore( _SERSI.sema );
      fi;
      # if there is nothing to do, update the invariant
      # and wait on the semaphore after leaving the atomic statement
      if localNewPoints = [] then
        _SERSI.ctrl.numberWaiting := _SERSI.ctrl.numberWaiting + 1;
        # check if we are done completely:
        # if all threads, including this one, signalled that they are idle
        if _SERSI.ctrl.numberWaiting = _SERSI.C.NUMBER_THREADS then
          _SERSI.ctrl.done := true;
        fi;
        # and there are no new Points to check.
        iWasIdle := true;
      # if this thread was idle and resumes work,
      # update the corresponding invariant
      elif iWasIdle then
        _SERSI.ctrl.numberWaiting := _SERSI.ctrl.numberWaiting - 1;
        iWasIdle := false;
      fi;
    od;
    # go idle if there is nothing to do
    if localNewPoints = [] and not done then
      WaitSemaphore( _SERSI.sema );
    fi;
  od;
  ## we are done. Wake up another thread
  SignalSemaphore( _SERSI.sema );
  return localNewPoints;
end;

###############################
# function fetchNewPoints
# Input:
#
# Output:
#   localNewPoints
###############################
fetchNewPoints := function()
  ## grab and delete NUMBER_GRAB_NEW many new points from newPoints
  ## must be called having RW access to _SERSI.ctrl
  local i, n, localNewPoints;
  localNewPoints := [];
  # TODO maybe make two copies of each 'half' instead
  n := Minimum( Size( _SERSI.ctrl.newPoints ), _SERSI.C.NUMBER_GRAB_NEW );
  for i in [1 .. n ] do
    Add( localNewPoints, Remove( _SERSI.ctrl.newPoints ) );
  od;
  Print( #DEBUG
    Size( _SERSI.ctrl.newPoints ), ", ",
    Size( localNewPoints ), "\n"
  );
  return localNewPoints;
end;

###############################
# function findNewPoints
# Input:
#   localNewPoints
#
# Output:
#
###############################
## Case: Sym(M) acting on Permutations
##        using a hash table
findNewPoints := function( localNewPoints )
  local foundNew,
    gen, x, m, i, n;
  ## fill localNewPoints
  ## new elements are added to and taken away from the end
  while not ( IsEmpty( localNewPoints ) or Length( localNewPoints ) >= 1000 ) do
    m := localNewPoints[ Size(localNewPoints) ];
    Unbind( localNewPoints[ Size(localNewPoints) ] );
    for gen in _SERSI.C.gens do
      x := m ^ gen;
      foundNew := HashTableAdd( _SERSI.hashTable, x );
      if foundNew = true then
        localNewPoints[ Size(localNewPoints) + 1 ] := x;
      fi;
    od;
  od;
  Print(
    "lNP: ", Size( localNewPoints), "\n"
  );

  ## add to newPoints
  atomic _SERSI.ctrl do
    Append( _SERSI.ctrl.newPoints, localNewPoints );
  od;
  return;
end;
