LoadPackage("grape");

###############################
# function computeDistances
# Input:
#   gamma - graph
#
# Output:
#   distances - the distances between all combinations of vertices in gamma
###############################
computeDistances := function( gamma )
  local distances, i, j, X;
  X := Vertices( gamma );
  distances := [];
  for i in [ 1 .. Length(X) ] do
    distances[ i ] := [];
    for j in [ 1 .. Length(X) ] do
      distances[ i ][ j ] := Distance( gamma, X[i], X[j] );
    od;
  od;
  return distances;
end;

###############################
# function lookupDistances
# Input:
#   graph - a graph-record with a fullDistances component
#   X - list of vertices of graph
#
# Output:
#   distances - the distances between all combinations of vertices in X
###############################
lookupDistances := function( graph, X )
  return List( graph.fullDistances{ X }, dists -> dists{ X } );
end;

###############################
# function IsPartialAut
# Input:
#   x
#
# Output:
#   whether x is a partial automorphism of graph
###############################
IsPartialAut := function( graph, x )
  if x = EmptyPartialPerm() then
    return true;
  fi;
  return
    lookupDistances( graph, DomainOfPartialPerm(x) )
    =
    lookupDistances( graph, ImageListOfPartialPerm(x) );
end;
