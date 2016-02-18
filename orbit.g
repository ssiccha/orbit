###############################
# function hashTableOrbit
# Input:
#   G  - Group acting on M
#   m0 - Elem of M
#   action - optional argument
#     if provided action(m, g) will be called for a point m and a groupelement g
#
# Output:
#   A list containg m0G
###############################
hashTableOrbit := function(G, m0, options...)
  local gens, r, L, largestMovedPoint, bitTable, bitList, x, opt, hTable, current, m, newPoint, i, action,
    todo, domainSize, words, posx;
  gens := GeneratorsOfGroup(G);
  r := Length( gens );
  if Length( options ) = 1 then
    options := options[1];
  fi;

  ## Case: test for groupoid action
  ##         using a bit list
  if IsBound( options.domainSize ) then
    gens := [
      (1,7,9,3)(2,4,8,6),
      (1,3)(4,6)(7,9),
      (1,4,7)(2,5,8)(3,6,9),   ## move two upper lines down by one
      (7,4,1)(8,5,2)(9,6,3),   ## move two lower lines up by one
      (1,2,4,5),
      (1,2,3,6,9,8,7,4)
    ];
    L := [ m0 ];
    domainSize := options.domainSize;
    words := [ [] ];

    bitList := BlistList( [ 1 .. domainSize ], [] );
    bitList[ PARORB_HashFunction( m0 ) ] := true;
    for m in L do
      posx := Position( L, m );
      for i in [ 1 .. Length(gens) + 1 ] do
        x := fail;
        if i = 3 then
          if IsSubset( [1..6], m ) then
            x := OnTuples( m, gens[3] );
          fi;
        elif i = 4 then
          if IsSubset( [4..9], m ) then
            x := OnTuples( m, gens[4] );
          fi;
        elif i = 5 then
          if IsSubset( [1,2,4,5], m ) then
            x := OnTuples( m, gens[5] );
          fi;
        elif i = 6 then
          if IsSubset( [1,2,3,4, 6,7,8,9], m ) then
            x := OnTuples( m, gens[6] );
          fi;
        elif i = 7 then
          x := Permuted( m, (2,6)(3,5) );
        else
          x := OnTuples( m, gens[i] );
        fi;
        if not x = fail then
          if not bitList[ PARORB_HashFunction( x ) ] then
            Add( L, x );
            bitList[ PARORB_HashFunction( x ) ] := true;
            Add( words, Concatenation( words[posx], [ i ] ) );
          fi;
        fi;
      od;
    od;
    return rec( bitList := bitList, orb := L, words := words );
  fi;

  ## Case: test for diagonal product action
  ##         using hash table
  if IsBound( options.andres ) then
    gens := [
      (1,7,9,3)(2,4,8,6),
      (1,3)(4,6)(7,9),
      (1,4,7)(2,5,8)(3,6,9),
      (1,2,4,5),
      (1,2,3,6,9,8,7,4)
    ];
    opt := rec( length := 10^5 );
    hTable := HashTableCreate( m0, opt );
    ## current: new elements are added to and taken away from the end
    current := [ m0 ];
    HashTableAdd( hTable, m0 );
    ## if false in List( m, x -> IsSubset( [1,2,4,5], x ) ) then
    while not IsEmpty( current ) do
      m := current[ Size(current) ];
      Unbind( current[ Size(current) ] );
      for i in [ 1 .. Length(gens)+1 ] do
        x := fail;
        if i = 3 then
          if IsSubset( [1..6], m ) then
            x := OnTuples( m, gens[3] );
          fi;
        elif i = 4 then
          if IsSubset( [1,2,4,5], m ) then
            x := OnTuples( m, gens[4] );
          fi;
        elif i = 5 then
          if IsSubset( [1,2,3,4, 6,7,8,9], m ) then
            x := OnTuples( m, gens[4] );
          fi;
        elif i = 6 then
          x := Permuted( m, (2,6)(3,5) );
        else
          x := OnTuples( m, gens[i] );
        fi;
        if not x = fail then
          newPoint := HashTableAdd( hTable, x );
          if newPoint then
            current[ Size(current) + 1 ] := x;
          fi;
        fi;
        #Print(x, "\n");
      od;
    od;
    Unbind( hTable!.elements[ hTable!.length+1 ] );
    L := Concatenation(
      Compacted( hTable!.elements )
    );
    return L;
  fi;

  ## Case: action was provided
  if IsBound( options.action ) then
    action := options.action;
    largestMovedPoint := LargestMovedPoint( gens );
    options := rec( length := 10^8 );
    hTable := HashTableCreate( m0, options );
    ## current: new elements are added to and taken away from the end
    current := [ m0 ];
    while not IsEmpty( current ) do
      m := current[ Size(current) ];
      Unbind( current[ Size(current) ] );
      for i in [1..r] do
        x := action( m, gens[i] );
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

  ## Case: Sym(M) acting on integers
  if IsPermGroup(G) and IsInt(m0) then
    L := [m0];
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
    return L;
  fi;

  ## Case: Sym(M) acting on Permutations
  ##        using a hash table
  if IsPermGroup(G) and IsPerm(m0) then
    largestMovedPoint := LargestMovedPoint( gens );
    options := rec( length := 10^8 );
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

  Error( "operation not yet supported!\n" );
end;

