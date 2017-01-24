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
#   simulatedMappings -
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
NumberOfOrbits := function( simulatedMappings, KPNArchitectureData )
  local numberProcessors, numberTasks, gensOfAutKPN, gensOfAutSemiArch, domains, canonization, encode, decode, unprocessed, numberOrbits, orbitLengths, args, orbit, debug, bench_oldSize, res, percentageSimulated;

  numberProcessors := KPNArchitectureData.numberProcessors;
  numberTasks := KPNArchitectureData.numberTasks;
  gensOfAutKPN := KPNArchitectureData.gensOfAutKPN;
  gensOfAutSemiArch := KPNArchitectureData.gensOfAutSemiArch;
  domains := KPNArchitectureData.domains;
  canonization := KPNArchitectureData.canonization;

  encode := CreateEncodeFunction( numberProcessors, numberTasks );
  decode := CreateDecodeFunction( numberProcessors, numberTasks );
  ## TODO When and how is HashTableCreate called?
  unprocessed := ShallowCopy( simulatedMappings );
  if not IsSet( unprocessed ) then
    Error( "simulatedMappings must be a set!" );
  fi;
  unprocessed := Set( List( unprocessed, canonization ) );
  Sort( unprocessed );
  Print( "maps ", Size( unprocessed ), " \n" );
  numberOrbits := 0;
  orbitLengths := [];

  while Size( unprocessed ) > 0 do
    orbit := Set( SemigroupOnMappings( unprocessed[1], KPNArchitectureData ) );
    numberOrbits := numberOrbits + 1;
    Add( orbitLengths, Length( orbit ) );
    debug := Size( unprocessed );
    bench_oldSize := Size( unprocessed );
    SubtractSet( unprocessed, orbit );
    debug := debug - Size( unprocessed );
    #TODO use Info
    #Print( "-", debug, ", " );
    if bench_oldSize mod 5 < Size( unprocessed ) mod 5 then
      #Print( "\n" );
    fi;
  od;
  res := rec(
    sizeSimulatedMappings    := Length( simulatedMappings ),
    numberOrbits := numberOrbits,
    orbitLengths := SortedList( orbitLengths ),
    sizeOmega := Sum( orbitLengths ),
    percentageSimulated := Sum( orbitLengths ) / numberProcessors ^ numberTasks * 100.
  );
  Print( "orbs ", res.numberOrbits, "\n" ); #DEBUG
  #TODO use Info
  #Print( res, "\n" ); #DEBUG
  return res;
end;
