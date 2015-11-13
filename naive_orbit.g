###############################
# function naiveOrbit
# Input:
#   m - Elem of M
#   G - Group acting on M
#
# Output:
#   A list containg mG
###############################
naiveOrbit := function(m, G)
  local L, r, i, x;
  r := Length( GeneratorsOfGroup(G) );
  L := [ m ];
  for m in L do
    for i in [1..r] do
      x := m*gens[i];
      if not x in L then
        Add(L, x);
##  TODO: Performance? (sergio / Fr 13 Nov 2015 16:40:18 UTC)
##          AddSet(L, x);
##  Is AddSet or Add faster?
##  Does Add use AddSet since from the start L is a set?
      fi;
    od;
  od;
end;
