## TODO trace bug: hpc.g
## TODO make access to hashTable parallel

## _SERSI stores GLOBAL variables and constants
if not IsBound( _SERSI ) then
  BindGlobal( "_SERSI", rec() );
fi;

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
          NUMBER_GRAB_NEW := "",
          NUMBER_THREADS := "",
          HASH_TABLE_SIZE := "",
          gens := "",
          largestMovedPoint := ""
        ),
        hashTable := "",
        ctrl := "",
        sema := CreateSemaphore()
      )
  );
  MakeReadOnlyObj( _SERSI );

  ## set options, global variables and constants
  _SERSI.C.gens := GeneratorsOfGroup(G);
  _SERSI.C.largestMovedPoint := LargestMovedPoint( _SERSI.C.gens );
  if IsBound( options.NUMBER_THREADS ) then
    _SERSI.C.NUMBER_THREADS := options.NUMBER_THREADS;
  else
    _SERSI.C.NUMBER_THREADS := 4;
  fi;
  if IsBound( options.NUMBER_GRAB_NEW ) then
    _SERSI.C.NUMBER_GRAB_NEW := options.NUMBER_GRAB_NEW;
  else
    _SERSI.C.NUMBER_GRAB_NEW := 200;
  fi;
  if IsBound( options.HASH_TABLE_SIZE ) then
    _SERSI.C.HASH_TABLE_SIZE := options.HASH_TABLE_SIZE;
  else
    _SERSI.C.HASH_TABLE_SIZE := 10^6;
  fi;
  _SERSI.C := Immutable( _SERSI.C );

  ## initialize objects in shared region
  _SERSI.hashTable := ShareObj(
    HashTableCreate( m0, rec( length := _SERSI.C.HASH_TABLE_SIZE ) )
  );
  HashTableAdd( _SERSI.hashTable, m0 );
  ## newPoints = [], since m0 will be passed to
  ## the first call of findNewPoints
  _SERSI.ctrl := ShareObj( rec() );
  atomic _SERSI.ctrl do
    IncorporateObj(_SERSI.ctrl, "newPoints", [] );
    IncorporateObj(_SERSI.ctrl, "numberWaiting", 0 );
    IncorporateObj(_SERSI.ctrl, "done", false );
  od;
  Print( "Initialization done.\n" ); #DEBUG

  ## fill newPoints first
  findNewPoints( [ m0 ] );

  ## spawn slaves, each worker takes a chunk of new points
  for i in [ 1 .. _SERSI.C.NUMBER_THREADS ] do
    listOfThreads[ i ] :=
      CreateThread(
        hashTableOrbitSlave
      );
    Print( "hTOSlave started.\n" ); #DEBUG
  od;
  for i in listOfThreads do
    WaitThread( i );
    Print( "Thread ", i, " finished!\n" ); #DEBUG
  od;

  ## return result
  atomic readonly _SERSI.hashTable!.elements do
    # Print( hashTable!.elements, "\n" ); #DEBUG
    # for previous version
    # Unbind( _SERSI.hashTable!.elements[ _SERSI.hashTable!.length+1 ] );
    return Concatenation(
      _SERSI.hashTable!.elements
      #Compacted( _SERSI.hashTable!.elements )
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
  local res, localNewPoints, done;
  done := false;
  while not done do
    res := accessControlVariableAndFetch();
    localNewPoints := res[1];
    done := res[2];
    Print(
      #"Thread ", ThreadID( CurrentThread() ),
      "Fetched ", Size( localNewPoints ), "\n"
      #" new Points.\n"
    );
    findNewPoints( localNewPoints );
  od;
  ## we are done. Wake up another thread
  SignalSemaphore( _SERSI.sema );
  Print( "Sending DONE.\n" ); #DEBUG
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
  localNewPoints := [];
  while not ( done or localNewPoints <> [] ) do
    atomic _SERSI.ctrl do
      ## done stores whether we are completely finished
      if _SERSI.ctrl.done then
        done := _SERSI.ctrl.done;
      else
        # pop from gnp
        localNewPoints := fetchNewPoints();
        # if there are waiting threads and there is still something to do,
        # wake up another thread
        if ( _SERSI.ctrl.numberWaiting > 0 and _SERSI.ctrl.newPoints <> [] ) then
          SignalSemaphore( _SERSI.sema );
          Print( "--- send Wake up --- " ); #DEBUG
        fi;
        # if there is nothing to do, update the invariant
        # and wait on the semaphore after leaving the atomic statement
        if localNewPoints = [] then
          if not iWasIdle then
            _SERSI.ctrl.numberWaiting := _SERSI.ctrl.numberWaiting + 1;
          fi;
          # check if we are done completely:
          # if all threads, including this one, signalled that they are idle
          if _SERSI.ctrl.numberWaiting = _SERSI.C.NUMBER_THREADS then
            Print( #DEBUG
              "\nDone!\n"
            );
            _SERSI.ctrl.done := true;
            done := true;
          fi;
          # and there are no new Points to check.
          iWasIdle := true;
        # if this thread was idle and resumes work,
        # update the corresponding invariant
        elif iWasIdle then
          _SERSI.ctrl.numberWaiting := _SERSI.ctrl.numberWaiting - 1;
          iWasIdle := false;
        fi;
      fi;
    od;
    # go idle if there is nothing to do
    if localNewPoints = [] and not done then
      Print( "Waiting.\n" ); #DEBUG
      WaitSemaphore( _SERSI.sema );
      Print( "Woken up.\n" ); #DEBUG
    fi;
  od;
  return [ localNewPoints, done ];
end;

###############################
# function fetchNewPoints
# Input:
#
# Output:
#   localNewPoints
###############################
fetchNewPoints := function()
  ## must be called having RW access to _SERSI.ctrl
  ## grab and delete NUMBER_GRAB_NEW many new points from newPoints
  local i, n, localNewPoints;
  localNewPoints := [];
  Print( #DEBUG
    "gNP: ",
    Size( _SERSI.ctrl.newPoints ), ". \n"
    #Size( localNewPoints )
  );
  # TODO maybe make two copies of each 'half' instead
  n := Maximum(
    Int( 1.0 / _SERSI.C.NUMBER_THREADS * Size( _SERSI.ctrl.newPoints ) ),
    _SERSI.C.NUMBER_GRAB_NEW
  );
  n := Minimum( n, Size( _SERSI.ctrl.newPoints ) );
  for i in [1 .. n ] do
    Add( localNewPoints, Remove( _SERSI.ctrl.newPoints ) );
  od;
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
  local current, last, foundNew,
    gen, x, m, i,
    count, numberFetched;
  current := 1;
  last := Length( localNewPoints );
  numberFetched := last;
  ## Increase lNP list size so that #lNP * #gens many new elements can be stored
  localNewPoints[ ( Length( _SERSI.C.gens ) + 1 ) * last + 1 ] := fail;
  ## apply generators onto localNewPoints using FIFO
  while not (
    current > last
    or
    last = Length(localNewPoints)
  )
  do
    m := localNewPoints[ current ];
    current := current + 1;
    for gen in _SERSI.C.gens do
      x := m ^ gen;
      foundNew := HashTableAdd( _SERSI.hashTable, x );
      if foundNew = true then
        localNewPoints[ last + 1 ] := x;
        last := last + 1;
      fi;
    od;
  od;
  localNewPoints := localNewPoints{ [ current .. last ] }; ## current > last returns empty list
  Print(
    ", found ",
    last - numberFetched,
    ".\n"
    #,
    #"  >> lNP: ",
    #Size( localNewPoints )
  );

  ## add to newPoints
  atomic _SERSI.ctrl do
    Append( _SERSI.ctrl.newPoints, localNewPoints );
    #Print(
    #  ", new gNP: ",
    #  Size( _SERSI.ctrl.newPoints ),
    #  ", wait ", _SERSI.ctrl.numberWaiting,
    #  ", ",
    #  _SERSI.sema, "\n"
    #);
  od;
  return;
end;
