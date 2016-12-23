#############################################################################
##
##                             AutSemi package
##  ./autsemi-backtrack.g
##                                                          Sergio Siccha
##
##  Copyright...
##
##  Compute the AutomorphismSemigroup via backtrack
##
#############################################################################
Read("./autsemi-compute.g");
LoadPackage( "Semigroups" );

computeAutSemigroup := function( args... )
  local graph, gens, allVertices, idempotents, G, countAdded, AddToG, root, accept,
    getChild, getNext, getParent, backtrack;
  if Length( args ) = 1 then
    graph := args[1];
  elif Length( args ) = 2 then
    graph := args[1];
    gens := args[2];
  fi;

  allVertices := Vertices( graph );
  # Initialise fullDistances of graph
  graph.fullDistances := computeDistances( graph );

  if IsBound( gens ) then
    G := InverseSemigroup( gens );
  else
    # If no generators were specified, G starts containing all idempotents
    idempotents := List( allVertices, x -> Difference( allVertices, [x] ) );
    idempotents := List( idempotents, x -> PartialPerm( x, x ) );
    G := InverseSemigroup( idempotents );
  fi;

  countAdded := 0; ##TODO heuristic for when to compute smaller generating set
  AddToG := function( x )
    local gens;
    if not x in G then
      if countAdded mod 3 = 2 then
        gens := ShallowCopy( SmallInverseSemigroupGeneratingSet( G ) );
        G := InverseSemigroup( gens );
      fi;
      gens := ShallowCopy( GeneratorsOfInverseSemigroup( G ) );
      Add( gens, x );
      G := InverseSemigroup( gens );
      Print("--- size: ", Size( G ), ", gens: ", Length(gens), " ---\n");
      countAdded := countAdded + 1;
    fi;
  end;

  root := function()
    return EmptyPartialPerm();
  end;

  accept := function( x )
    return IsPartialAut( graph, x );
  end;

  # Add smallest possible point to domain of x
  getChild := function( x )
    local maxDomain, newPoint, newImage;
    if allVertices = DomainOfPartialPerm( x ) then
      return fail;
    fi;
    # always only add bigger points to domain
    if x = EmptyPartialPerm() then
      maxDomain := 0;
    else
      maxDomain := Maximum( DomainOfPartialPerm( x ) );
    fi;
    if maxDomain = Maximum( allVertices ) then
      return fail;
    fi;
    newPoint := Minimum( Filtered( allVertices, x -> (x > maxDomain) ) );
    newImage := Minimum( Difference( allVertices, ImageListOfPartialPerm( x ) ) );
    x := JoinOfPartialPerms(
      x,
      PartialPerm( [ newPoint ], [ newImage ] )
    );
    return x;
  end;

  # Map the biggest point of domain to the next point
  getNext := function( x )
    local maxDomain, possibleImages, img, posImg, nextImg;
    # x already permutes all points, there is no 'next'
    if allVertices = DomainOfPartialPerm( x ) then
      return fail;
    fi;
    maxDomain := Maximum( DomainOfPartialPerm( x ) );
    img := maxDomain ^ x;
    # restrict to parent
    x := RestrictedPartialPerm(
      x,
      Difference( DomainOfPartialPerm( x ), [ maxDomain ] )
    );
    possibleImages := Difference( allVertices, ImageSetOfPartialPerm( x ) );
    posImg := PositionSet( possibleImages, img );
    # Image of maxDomain can be increased
    if posImg < Size( possibleImages ) then
      nextImg := possibleImages[ posImg+1 ];
    # Image of maxDomain can not be increased anymore
    else
      # Try to increase maxDomain
      if maxDomain < Maximum( allVertices ) then
        maxDomain := maxDomain + 1;
        nextImg := Minimum( possibleImages );
      else
        return fail;
      fi;
    fi;
    # Assign image of maxDomain to the next point
    x := JoinOfPartialPerms(
      x,
      PartialPerm( [ maxDomain ], [ nextImg ] )
    );
    return x;
  end;

  getParent := function( x )
    local maxDomain;
    maxDomain := Maximum( DomainOfPartialPerm( x ) );
    x := RestrictedPartialPerm(
      x,
      Difference( DomainOfPartialPerm( x ), [ maxDomain ] )
    );
    return x;
  end;

  backtrack := function( x )
    local child;
    # If x is not a partial automorphism, its parent can be added to the semigroup
    if not accept( x ) then
      AddToG( getParent( x ) );
      return;
    fi;
    # Add x, if it is a leaf, i.e. a permutation of the whole graph
    if DomainOfPartialPerm( x ) = allVertices then
      AddToG( x );
    fi;
    child := getChild( x );
    while not child = fail do
      backtrack( child );
      child := getNext( child );
    od;
  end;

  backtrack( root() );
  return G;
end;
