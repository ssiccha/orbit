###############################
# function hashTableGroupoidOnMappingsOrbit
# Input:
#   partialIsos
#   domains
#   omega
#
# Uses a hash table to keep track of the orbit
#
# Output:
#   A record with
#     bitlist for m0 * G
#     list m0 * G
#     words in generators for debugging
###############################
hashTableGroupoidOnMappingsOrbit := function( m0, numberProcessors, numberTasks, gensOfAutKPN, gensOfGroupoid, domains, options... )
  local encode, canonization, r, s, stack, hashTable, m, i, posx, x, bench_stack;
  if Length( options ) = 1 then
    options := options[1];
  fi;

  canonization := _SERSI.C.canonization;
  m0 := canonization( m0 );
  stack := StackCreate( 10^6 );
  StackPush( stack, m0 );
  hashTable := HashTableCreate( m0, rec( length := 10^5 ) );
  bench_stack := false;

  #DEBUG words := [ [] ];

  while not StackIsEmpty( stack ) do
    #BENCH
    if not bench_stack then
      if stack!.last > 10^5 then
        Print( "stacksize > 10^5 " );
        bench_stack := true;
      fi;
    fi;
    m := canonization( StackPop( stack ) );
    for i in [ 1 .. Length( gensOfAutKPN ) ] do
      ## KPN automorphisms
      x := canonization( Permuted( m, gensOfAutKPN[ i ] ) );
      if HashTableAdd( hashTable, x ) then
        StackPush( stack, x );
      fi;
    od;
    for i in [ 1 .. Length( gensOfGroupoid ) ] do
      ## Architecture partial Isomorphisms
      if IsSubset( domains[i], m ) then
        x := canonization( OnTuples( m, gensOfGroupoid[i] ) );
        if HashTableAdd( hashTable, x ) then
          StackPush( stack, x );
        fi;
      fi;
    od;
  od;
  Unbind( hashTable!.elements[ hashTable!.length + 1 ] );
  return Concatenation( Compacted( hashTable!.elements ) );
end;

###############################
# function bitListGroupoidOnMappingsOrbit
# Input:
#   partialIsos
#   domains
#   omega
#
# Uses a Bitlist to keep track of the orbit
#
# Output:
#   A record with
#     bitlist for m0 * G
#     list m0 * G
#     words in generators for debugging
###############################
bitListGroupoidOnMappingsOrbit := function( m0, numberProcessors, numberTasks, gensOfAutKPN, gensOfGroupoid, domains, options... )
  local encode, r, s, orbit, domainSize, words, bitList, m, i, posx, x;
  if Length( options ) = 1 then
    options := options[1];
  fi;

  # function that determines a mapping's position in the bitList
  encode := _SERSI.C.encode;

  orbit := [ m0 ];
  domainSize := numberProcessors ^ numberTasks;
  words := [ [] ];

  bitList := BlistList( [ 1 .. domainSize ], [] );
  bitList[ encode( m0 ) ] := true;
  for m in orbit do
    posx := Position( orbit, m );
    for i in [ 1 .. Length( gensOfAutKPN ) ] do
      ## KPN automorphisms
      x := Permuted( m, gensOfAutKPN[ i ] );
      if not bitList[ encode( x ) ] then
        Add( orbit, x );
        bitList[ encode( x ) ] := true;
        #Add( words, Concatenation( words[posx], [ i ] ) );
      fi;
    od;
    for i in [ 1 .. Length( gensOfGroupoid ) ] do
      ## Architecture partial Isomorphisms
      x := fail;
      if IsSubset( domains[i], m ) then
        x := OnTuples( m, gensOfGroupoid[i] );
        if not bitList[ encode( x ) ] then
          Add( orbit, x );
          bitList[ encode( x ) ] := true;
          Add( words, Concatenation( words[posx], [ i ] ) );
        fi;
      fi;
    od;
  od;
  return rec( bitList := bitList, orb := orbit, words := words );
end;


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
  local gens, domains, r, L, largestMovedPoint, bitTable, bitList, x, opt, hTable, current, m, newPoint, i, action,
    unprocessed, domainSize, words, posx;
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
      (1,2,5,4)(3,7),

      (1,5),
      (2,4)(3,7),
      (4,1,2,3,6),
      (6,3,2,1,4)
      #(5,3),

      #(3,5)
    ];

    domains := [
      [1..9],
      [1..9],
      [1..6],
      [4..9],
      [1,2,3,4,5,7,9],

      [1,2,3,4,5,7,9],
      [1,2,3,4,5,7,9],
      [1,2,3,6],
      [1,2,3,6],
      [1,5,9],

      [1,3,9]
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
        if i = Length(gens) + 1 then
          x := Permuted( m, (2,6)(3,5) );
        elif IsSubset( domains[i], m ) then
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

###############################
# function bitListMyOrbits
# Input:
#   D -
#
# Output:
#   res
###############################
bitListMyOrbits := function( omega, numberProcessors, numberTasks, gensOfAutKPN, gensOfGroupoid, domains )
  local   encode, decode, unprocessed, domainSize, orbs, args,
    m0, code, orb, pos, res, tmp;
  _SERSI.encodeFunction( numberProcessors, numberTasks );
  _SERSI.decodeFunction( numberProcessors, numberTasks );
  encode := _SERSI.C.encode;
  decode := _SERSI.C.decode;

  domainSize := numberProcessors ^ numberTasks;
  unprocessed := List( omega, encode );
  #Print( Size( unprocessed ), " " );
  unprocessed := BlistList( [ 1 .. domainSize ], unprocessed );
  Print( "maps ", SizeBlist( unprocessed ), " \n" );
  orbs := [];
  args := [  , numberProcessors, numberTasks, gensOfAutKPN, gensOfGroupoid, domains ];
  while SizeBlist( unprocessed ) > 0 do
    code := Position( unprocessed, true );
    args[1] := decode( code );
    res := CallFuncList( bitListGroupoidOnMappingsOrbit, args );
    #Print( SizeBlist( unprocessed ), " " );
    tmp := SizeBlist( unprocessed );
    SubtractBlist( unprocessed, res.bitList );
    tmp := tmp - SizeBlist( unprocessed );
    Print( "-", tmp, ", \n" );
    Add( orbs, res.orb );
    #Print( SizeBlist( unprocessed ), " " ); #DEBUG
  od;
  Print( "orbs ", Length( orbs ), "\n" );
  return orbs;
end;

#   DEBUG
#   for orb in orbs do
#      if not Intersection( orb, res.orb ) = [] then
#        Error( "orbits are not disjoint" );
#      fi;
#   od;

###############################
# function hashTableMyOrbits
# Input:
#   D -
#
# Output:
#   res
###############################
hashTableMyOrbits := function( omega, numberProcessors, numberTasks, gensOfAutKPN, gensOfGroupoid, domains )
  local   encode, decode, unprocessed, domainSize, orbs, args,
    m0, code, orbit, pos, res, tmp;
  _SERSI.encodeFunction( numberProcessors, numberTasks );
  _SERSI.decodeFunction( numberProcessors, numberTasks );
  encode := _SERSI.C.encode;
  decode := _SERSI.C.decode;

  InstallMethod( PARORB_HashFunction, "for tuples represented as lists",
  [ IsList ],
  _SERSI.C.encode );

  domainSize := numberProcessors ^ numberTasks;
  unprocessed := ShallowCopy( omega );
  if not IsSet( unprocessed ) then
    Error( "omega must be a set!" );
  fi;
  Print( "maps ", Size( unprocessed ), " \n" );
  orbs := [];
  args := [  , numberProcessors, numberTasks, gensOfAutKPN, gensOfGroupoid, domains ];
  while Size( unprocessed ) > 0 do
    args[1] := unprocessed[1];
    orbit := Set( CallFuncList( hashTableGroupoidOnMappingsOrbit, args ) );
    tmp := Size( unprocessed );
    SubtractSet( unprocessed, orbit );
    tmp := tmp - Size( unprocessed );
    Print( "-", tmp, ", " );
    Add( orbs, orbit );
    #Print( Size( unprocessed ), " " ); #DEBUG
  od;
  Print( "orbs ", Length( orbs ), "\n" );
  return orbs;
end;

###############################
# function hashTableNumberOfOrbits
# Input:
#   D -
#
# Output:
#   res
###############################
hashTableNumberOfOrbits := function( omega, numberProcessors, numberTasks, gensOfAutKPN, gensOfGroupoid, domains )
  local   encode, decode, canonization, unprocessed, domainSize, numberOrbits, orbitLengths,
    args, debug, bench_oldSize, res,
    m0, code, orbit, pos;
  _SERSI.encodeFunction( numberProcessors, numberTasks );
  _SERSI.decodeFunction( numberProcessors, numberTasks );
  encode := _SERSI.C.encode;
  decode := _SERSI.C.decode;
  canonization := _SERSI.C.canonization;
  InstallMethod( PARORB_HashFunction, "for tuples represented as lists",
  [ IsList ],
  _SERSI.C.encode );
  unprocessed := ShallowCopy( omega );
  if not IsSet( unprocessed ) then
    Error( "omega must be a set!" );
  fi;
  unprocessed := Set( List( unprocessed, canonization ) );
  Sort( unprocessed );
  Print( "maps ", Size( unprocessed ), " \n" );
  numberOrbits := 0;
  orbitLengths := [];
  args := [  , numberProcessors, numberTasks, gensOfAutKPN, gensOfGroupoid, domains ];

  while Size( unprocessed ) > 0 do
    args[1] := unprocessed[1];
    orbit := Set( CallFuncList( hashTableGroupoidOnMappingsOrbit, args ) );
    numberOrbits := numberOrbits + 1;
    Add( orbitLengths, Length( orbit ) );
    debug := Size( unprocessed );
    bench_oldSize := Size( unprocessed );
    SubtractSet( unprocessed, orbit );
    debug := debug - Size( unprocessed );
    #unprocessed use Info
    #Print( "-", debug, ", " );
    if bench_oldSize mod 5 < Size( unprocessed ) mod 5 then
      #Print( "\n" );
    fi;
  od;
  res := rec(
    sizeOmega    := Length( omega ),
    numberOrbits := numberOrbits,
    orbitLengths := SortedList( orbitLengths ),
    percentageSimulated := Sum( orbitLengths ) / numberProcessors ^ numberTasks * 100.
  );
  Print( "orbs ", res.numberOrbits, "\n" ); #DEBUG
  #unprocessed use Info
  #Print( res, "\n" ); #DEBUG
  return res;
end;
