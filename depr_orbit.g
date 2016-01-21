###############################
# deprecated function hashTableOrbit
# Input:
#   hTable - reference to a common HashTable
#
# Output:
#   A list containg m0G
###############################
##  DEPRECATED
hashTableOrbit := function(hTable, G, m0)
  local gens, r, orbit, largestMovedPoint, bitTable, x, options, current, m,
    newPoint, i;
  Print("DEPRECATED");
  gens := GeneratorsOfGroup(G);
  r := Length( gens );
  orbit := [m0];
  ## Case: Sym(M) acting on integers
  if IsPermGroup(G) and IsInt(m0) then
    largestMovedPoint := LargestMovedPoint( gens );
    bitTable := 0 * [1..largestMovedPoint];
    bitTable[m0] := 1;
    for m in orbit do
      for i in [1..r] do
        x := m ^ gens[i];
        if not bitTable[x] = 1 then
          Add(orbit, x);
          bitTable[x] := 1;
        fi;
      od;
    od;
  fi;

  ## Standard case
  for m in orbit do
    for i in [1..r] do
      x := m ^ gens[i];
      if not x in orbit then
        Add(orbit, x);
        bitTable[x] := 1;
      fi;
    od;
  od;
  return orbit;
end;
