###############################
# function IsPartialAut3
# Input:
#   x
#
# Output:
#   whether x is a partial automorphism of the 3-mesh
###############################
IsPartialAut3 := function( x )
  if x = EmptyPartialPerm() then
    return true;
  fi;
  return
    lookupDistances( mesh3, DomainOfPartialPerm(x) )
    =
    lookupDistances( mesh3, ImageListOfPartialPerm(x) );
end;

###############################
# function IsPartialAut4
# Input:
#   x
#
# Output:
#   whether x is a partial automorphism of the 4-mesh
###############################
IsPartialAut4 := function( x )
  if x = EmptyPartialPerm() then
    return true;
  fi;
  return
    lookupDistances( mesh4, DomainOfPartialPerm(x) )
    =
    lookupDistances( mesh4, ImageListOfPartialPerm(x) );
end;

###############################
# function ComputeAutSemigroup3
# Input:
#   startGens - known generators for AutSemiGroup
#
# Output:
#   the full Automorphism-Semigroup of the 3x3-mesh
###############################
ComputeAutSemigroup3 := function( startGens )
  local i, x, G, gens, hasGrown;
  hasGrown := false;
  gens := ShallowCopy( startGens );
  G := Semigroup( gens );
  i := 0;
  for x in SymmetricInverseSemigroup(9) do
    i := i+1;
    ## for every 100k checked partial perms, we look for a smaller generating set of G
    ## if a new generator was added to gens
    if i mod 100000 = 0 then
      Print( i, " " );
      if hasGrown then
        gens := ShallowCopy( SmallInverseSemigroupGeneratingSet( G ) );
        G := InverseSemigroup( gens );
        hasGrown := false;
      fi;
    fi;
    if IsPartialAut3(x) then
      if not x in G then
        Add( gens, x );
        G := InverseSemigroup( gens );
        Print("\n--- size: ", Size(G), ", gens: ", Length(gens), " --- ");
        hasGrown := true;
      fi;
    fi;
  od;
  return rec( G := G, gens := gens );
end;

###############################
# function ComputeAutSemigroup4
# Input:
#   startGens - known generators for AutSemiGroup
#
# Output:
#   the full Automorphism-Semigroup of the 4x4-mesh
###############################
ComputeAutSemigroup4 := function( startGens )
  local i, x, G, gens, hasGrown;
  hasGrown := false;
  gens := ShallowCopy( startGens );
  G := InverseSemigroup( gens );
  i := 0;
  for x in SymmetricInverseSemigroup(16) do
    i := i+1;
    ## for every 100k checked partial perms, we look for a smaller generating set of G
    ## if a new generator was added to gens
    if i mod 100000 = 0 then
      Print( i, " " );
      if hasGrown then
        gens := ShallowCopy( SmallInverseSemigroupGeneratingSet( G ) );
        G := InverseSemigroup( gens );
        hasGrown := false;
      fi;
    fi;
    if IsPartialAut4(x) then
      if not x in G then
        Add( gens, x );
        G := InverseSemigroup( gens );
        Print("\n--- size: ", Size(G), ", gens: ", Length(gens), " --- ");
        hasGrown := true;
      fi;
    fi;
  od;
  return rec( G := G, gens := gens );
end;


###############################
# function MCAutSemigroup3
# Monte Carlo Version
# Input:
#   trials
#
# Output:
#   rec( G := G, gens := gens )
###############################
MCAutSemigroup3 := function( startGens, trials )
  local i, gens, G, x, S;
  S := SymmetricInverseSemigroup( 9 );
  gens := ShallowCopy( startGens );
  G := InverseSemigroup( gens );
  for i in [1..trials] do
    x := Random( S );
    if IsPartialAut3(x) then
      if not x in G then
        Add( gens, x );
        G := InverseSemigroup( gens );
      fi;
    fi;
  od;
  return rec( G := G, gens := gens );
end;

###############################
# function MCAutSemigroup4
# Monte Carlo Version
# Input:
#   trials
#
# Output:
#   rec( G := G, gens := gens )
###############################
MCAutSemigroup4 := function( startGens, trials )
  local i, gens, G, x, S;
  S := SymmetricInverseSemigroup( 16 );
  gens := ShallowCopy( startGens );
  G := InverseSemigroup( gens );
  for i in [ 1 .. trials ] do
    x := Random( S );
    if IsPartialAut4(x) then
      if not x in G then
        Print( "Found new partial aut! " );
        Add( gens, x );
        G := InverseSemigroup( gens );
        return rec( G := G, gens := gens );
      fi;
    fi;
  od;
  return rec( G := G, gens := gens );
end;
