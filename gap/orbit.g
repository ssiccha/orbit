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
SemigroupOnMappings := function( m0, numberProcessors, numberTasks, gensOfAutKPN, gensOfGroupoid, domains, options... )
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
# function NumberOfOrbits
# Input:
#   omega -
#   numberProcessors -
#   numberTasks -
#   gensOfAutKPN -
#   gensOfGroupoid -
#   domains -
#   canonization -
# Output:
#   res
###############################
NumberOfOrbits := function( omega, numberProcessors, numberTasks,
        gensOfAutKPN, gensOfGroupoid, domains, canonization )
  local   encode, decode, unprocessed, domainSize, numberOrbits, orbitLengths,
    args, debug, bench_oldSize, res,
    m0, code, orbit, pos;

  encode := CreateEncodeFunction( numberProcessors, numberTasks );
  decode := CreateDecodeFunction( numberProcessors, numberTasks );
  ## TODO V get rid of this V
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
    orbit := Set( CallFuncList( SemigroupOnMappings, args ) );
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
    sizeOmega    := Length( omega ),
    numberOrbits := numberOrbits,
    orbitLengths := SortedList( orbitLengths ),
    percentageSimulated := Sum( orbitLengths ) / numberProcessors ^ numberTasks * 100.
  );
  Print( "orbs ", res.numberOrbits, "\n" ); #DEBUG
  #TODO use Info
  #Print( res, "\n" ); #DEBUG
  return res;
end;

