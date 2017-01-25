###############################
# function SemigroupOnMappings
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
SemigroupOnMappings := function( m0, KPNArchitectureData, options... )
  local numberProcessors, numberTasks, gensOfAutKPN,
  gensOfAutSemiArch, domains, canonization,
  stack, hashTable, bench_stack, m, x, i;

  numberProcessors := KPNArchitectureData.numberProcessors;
  numberTasks := KPNArchitectureData.numberTasks;
  gensOfAutKPN := KPNArchitectureData.gensOfAutKPN;
  gensOfAutSemiArch := KPNArchitectureData.gensOfAutSemiArch;
  domains := KPNArchitectureData.domains;
  canonization := KPNArchitectureData.canonization;

  if Length( options ) = 1 then
    options := options[1];
  fi;

  m0 := canonization( m0 );
  stack := StackCreate( 10^6 );
  StackPush( stack, m0 );
  ## There are p^t many mappings, t = #tasks, p = #processors
  hashTable := HashTableCreate(
    rec( base := numberProcessors, exp := numberTasks )
  );
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
    for i in [ 1 .. Length( gensOfAutSemiArch ) ] do
      ## Architecture partial Isomorphisms
      if IsSubset( domains[i], m ) then
        x := canonization( OnTuples( m, gensOfAutSemiArch[i] ) );
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
# function NumberOfOrbits
# Input:
#   mappingsStream -
#   KPNArchitectureData - contains:
#       numberProcessors -
#       numberTasks -
#       gensOfAutKPN -
#       gensOfAutSemiArch -
#       domains -
#       canonization -
# Output:
#   res
###############################
## TODO CLEANUP !! ##
## TODO When and how is HashTableCreate called?
##  Only in the single orbit calculations
ManageOrbits := function( mappingsStream, KPNArchitectureData )
  local numberProcessors, numberTasks, gensOfAutKPN, gensOfAutSemiArch,
  domains, canonization, encode,
  pipe, newMapping, allMappings,
  numberOrbits, orbitLengths, orbit, debug, bench_oldSize,
  res, percentageSimulated;

  numberProcessors := KPNArchitectureData.numberProcessors;
  numberTasks := KPNArchitectureData.numberTasks;
  gensOfAutKPN := KPNArchitectureData.gensOfAutKPN;
  gensOfAutSemiArch := KPNArchitectureData.gensOfAutSemiArch;
  domains := KPNArchitectureData.domains;
  canonization := KPNArchitectureData.canonization;

  encode := CreateEncodeFunction( numberProcessors, numberTasks );
  numberOrbits := 0;
  orbitLengths := [];

  ## TODO Put communication here?
  #unprocessed := ShallowCopy( mappingsStream );
  #if not IsSet( unprocessed ) then
  #  Error( "mappingsStream must be a set!" );
  #fi;
  #unprocessed := SortedList( Set( List( unprocessed, canonization ) ) );
  #Print( "number maps ", Size( unprocessed ), "\n" );
  ## Communication via a stream
  pipe := NamedPipeHandle( mappingsStream );

  ## TODO NOW implement IsNamedPipe part to make V this V work
  allMappings := [];
  newMapping := ReadLine( pipe );
  while newMapping = fail do
    Add( allMappings, newMapping );
    orbit := Set( SemigroupOnMappings( newMapping, KPNArchitectureData ) );
    numberOrbits := numberOrbits + 1;
    Add( orbitLengths, Length( orbit ) );
    debug := Size( allMappings );
    bench_oldSize := Size( allMappings );
    SubtractSet( allMappings, orbit );
    debug := debug - Size( allMappings );
    #TODO use Info
    #Print( "-", debug, ", " );
    if bench_oldSize mod 5 < Size( allMappings ) mod 5 then
      #Print( "\n" );
    fi;
    newMapping := ReadLine( pipe );
  od;
  res := rec(
    sizeSimulatedMappings    := Length( mappingsStream ),
    numberOrbits := numberOrbits,
    orbitLengths := SortedList( orbitLengths ),
    sizeOmega := Sum( orbitLengths ),
    percentageSimulated := Sum( orbitLengths )
        / numberProcessors ^ numberTasks * 100.
  );
  #TODO use Info
  Print( "number orbits ", res.numberOrbits, "\n" );
  return res;
end;
