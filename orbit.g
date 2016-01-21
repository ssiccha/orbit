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
        NUMBER_THREADS := 2,
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
findNewPoints := function() end;
fetchNewPoints := function() end;


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
  atomic _SERSI do
    AdoptObj( _SERSI );
    MakeReadOnlyObj( _SERSI );
  od;

  ## init and/or set global variables and constants
  _SERSI.C.NUMBER_THREADS := 2;
  _SERSI.C.NUMBER_GRAB_NEW := 100;
  _SERSI.C.gens := GeneratorsOfGroup(G);
  _SERSI.C.largestMovedPoint := LargestMovedPoint( _SERSI.C.gens );
  _SERSI.C := Immutable( _SERSI.C );

  ## initialize objects in shared region
  _SERSI.hashTable := ShareObj(
    HashTableCreate( m0, rec( length := 10^8 ) )
  );
  _SERSI.ctrl := ShareObj( rec() );
  atomic _SERSI.ctrl do
    IncorporateObj(_SERSI.ctrl, "newPoints", [ m0 ] );
    IncorporateObj(_SERSI.ctrl, "numberWaiting", 0 );
    IncorporateObj(_SERSI.ctrl, "done", false );
  od;

  ## fill newPoints first
  findNewPoints();

  ## spawn findNewPoints tasks, each worker takes a chunk of new points
    ## TODO

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
  ## TODO make done threadlocal
  while not done do
    localNewPoints := fetchNewPoints();
    findNewPoints( localNewPoints );
  od;
  return;
end;
###############################
# function findNewPoints
# Input:
#   newPoints -
#   hashTable -
#   G -
#
# Output:
#   newPoints
###############################
## Case: Sym(M) acting on Permutations
##        using a hash table
findNewPoints := function()
  local localNewPoints, foundNew,
    gen, x, m, i, n;
  localNewPoints := [];

  ## grab and delete NUMBER_GRAB_NEW many new points from newPoints
  atomic _SERSI.ctrl do
    # TODO maybe make two copies of each 'half' instead
    n := Minimum( Size( _SERSI.ctrl.newPoints ), _SERSI.C.NUMBER_GRAB_NEW );
    for i in [1 .. n ] do
      Add( localNewPoints, Remove( _SERSI.ctrl.newPoints ) );
    od;
  od;

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

  ## add to newPoints
  atomic _SERSI.ctrl do
    Append( _SERSI.ctrl.newPoints, localNewPoints );
  od;
end;
