###############################
# Operation HashTableCreate
# Input:
#   x   - Sample object
#   opt - Options record
# Filters:
#   IsObject, IsRecord
#
# Output:
#   A hashTable
###############################
InstallMethod( HashTableCreate, "for a sample object and an options record",
[ IsObject, IsRecord ],
function( x, opt )
  local hashTable, type;
  hashTable := rec();
  type := HashTableType;
  if IsBound(opt.length) then
    hashTable.length := NextPrimeInt(opt.length);
  else
    hashTable.length := 100003;
  fi;
  # old version
    ## allocates the correct amount of memory (each entry is a pointer)
    ## and prevents GAP from shrinking the list
    # hashTable.elements := [];
    # hashTable.elements[ hashTable.length+1 ] := fail;
    # hashTable.elements := ShareObj( hashTable.elements );
  # old version end
  hashTable.elements := List(
    [ 1 .. hashTable.length ],
    x -> MakeWriteOnceAtomic( AtomicList( [  ] ) )
  );
  MakeReadOnlyObj( hashTable.elements );
  hashTable.numberElements := 0;
  hashTable.collisions := 0;
  hashTable.accesses := 0;
  hashTable.hashFunction := fail;
  hashTable.eqf := fail; ## TODO what is this? equality-test?

  Objectify( type, hashTable );
  return hashTable;
end );

###############################
# Operation HashTableAdd
# Input:
#   ht -
#   x -
# Filters:
#   IsObject
#
# Output:
#   Returns true iff x was not in ht, otherwise false.
###############################
InstallMethod( HashTableAdd, "for an object",
[ IsMyHashTable, IsObject ],
function( ht, x ) ## TODO should x be readonly? I dont think so
  local hashValue, hashBag, success, last;
  hashValue := PARORB_HashFunction( x ) mod ht!.length + 1;
  hashBag := ht!.elements[ hashValue ];
  ## validity of last can change if another thread accesses the same bag!
  while true do
    last := Length( hashBag );
    if not x in hashBag then
      hashBag[ last+1 ] := x;
      ## if write was not successfull, try again in next loop if necessary
      if hashBag[ last+1 ] = x then
        return true;
      fi;
      Print("Simultaneous Access! ");
    ## x was found in hashBag
    else
      return false;
    fi;
  od;
  #TODO: do not initialize sets at the beginning
  #       instead make ht!.elements writeOnce
  #(sergio / Do 04 Feb 2016 14:26:09 CET)
  #    if not IsBound( ht!.elements[ hashValue ] ) then
  #      ht!.elements[ hashValue ] := [ x ];
  #      return true;
  #if not x in ht!.elements[ hashValue ] then
  #  Add( ht!.elements[ hashValue ], x ); ##TODO AddSet
  #  return true;
  #fi;
  #return false;
end );

###############################
# Operation PARORB_HashFunction
# Input:
#   p       - permutation
# Filters:
#   IsPerm
#
# Output:
#   An Integer < 2^64 (or 2^32)
###############################
#InstallMethod( PARORB_HashFunction, "for storing permutaions",
#[ IsPerm ],
PARORB_HashFunction := function( p )
  local largestMovedPoint;
  largestMovedPoint := LARGEST_MOVED_POINT_PERM( p );
  if IsPerm4Rep( p ) then
    if largestMovedPoint > 65536 then
      return HashKeyBag(p, 255, 0, 4*largestMovedPoint);
    else
      TRIM_PERM(p, largestMovedPoint);
    fi;
  fi;
  return HashKeyBag(p, 255, 0, 2*largestMovedPoint);
end;
#);


