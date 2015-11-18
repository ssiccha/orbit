###############################
# function semiNaiveOrbit
# Input:
#   G - Group acting on M
#   m0 - Elem of M
#
# Output:
#   A list containg m0G
###############################
semiNaiveOrbit := function(G, m0)
  local gens, r, L, largestMovedPoint, bitTable, x, m, i;
  gens := GeneratorsOfGroup(G);
  r := Length( gens );
  L := [m0];
  ## Case: Sym(M) acting on integers
  if ForAll(gens, IsPerm) then
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

  ## Standard case
  else
   for m in L do
      for i in [1..r] do
        x := m ^ gens[i];
        if not x in L then
          Add(L, x);
          bitTable[x] := 1;
        fi;
      od;
    od;
  fi;
  return L;
##  TODO: Why doesn't Add use AddSet since from the start L is a set? 
##  (sergio / Mi 18 Nov 2015 10:24:32 UTC)
end;

###############################
# function naiveOrbit2
# Input:
#   G - Group acting on M
#   m0 - Elem of M
#
# Output:
#   A SET containg m0G
###############################
naiveOrbit2 := function(G, m0)
  local gens, r, L, setL, x, m, i;
  gens := GeneratorsOfGroup(G);
  r := Length( gens );
  L := [ m0 ];
  setL := ShallowCopy(L);
  for m in L do
    for i in [1..r] do
      x := m ^ gens[i];
      if not x in setL then
        Add(L, x);
        AddSet(setL, x);
      fi;
    od;
  od;
  return setL;
end;

