###############################
# function hashTableOrbit
# Input:
#   G  - Group acting on M
#   m0 - Elem of M
#
# Output:
#   A list containg m0G
###############################
##  HPC-GAP
##  TODO: hashTable SharedObject
##  TODO: hashTable MakeReadOnlyObj
##  (sergio / Mi 18 Nov 2015 10:24:32 UTC)
hashTableOrbit := function(G, m0)
  local gens, r, L, largestMovedPoint, bitTable, x, options, hTable, current, m, newPoint, i;
  gens := GeneratorsOfGroup(G);
  r := Length( gens );
  L := [m0];
  ## Case: Sym(M) acting on integers
  if IsPermGroup(G) and IsInt(m0) then
    largestMovedPoint := LargestMovedPoint( gens );
    bitTable := 0 * [1..largestMovedPoint];
    bitTable[m0] := 1;
    for m in L do
      for i in [1..r] do
        x := m ^ gens[i];
        if not bitTable[x] = 1 then
          Add(L, x);
          bitTable[x] := 1;
        fi;
      od;
    od;

  ## Case: Sym(M) acting on Permutations
  ##        using a hash table
  elif IsPermGroup(G) and IsPerm(m0) then
    largestMovedPoint := LargestMovedPoint( gens );
    options := rec( length := 10^8 );
##      options := rec( length := Int(Sqrt(Float(Factorial(largestMovedPoint)))) );
    hTable := HashTableCreate( m0, options );
    ## current: new elements are added to and taken away from the end
    current := [ m0 ];
    while not IsEmpty( current ) do
      m := current[ Size(current) ];
      Unbind( current[ Size(current) ] );
      for i in [1..r] do
        x := m ^ gens[i];
        newPoint := HashTableAdd( hTable, x );
        if newPoint = 1 then
          current[ Size(current) + 1 ] := x;
        fi;
      od;
    od;
    Unbind( hTable!.elements[ hTable!.length+1 ] );
    L := Concatenation( 
      Compacted( hTable!.elements ) 
    );
    return L;
  fi;

  ## Standard case
  for m in L do
    for i in [1..r] do
      x := m ^ gens[i];
      if not x in L then
        Add(L, x);
        bitTable[x] := 1;
      fi;
    od;
  od;
  return L;
end;

