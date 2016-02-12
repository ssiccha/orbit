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
  hashTable.elements := [];
    ## allocates the correct amount of memory (each entry is a pointer)
    ## and prevents GAP from shrinking the list
    hashTable.elements[ hashTable.length+1 ] := fail;
  #hashTable.elements := ShareObj( hashTable.elements );
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
function( ht, x ) ## TODO should x be readonly?
  local hashValue;
  hashValue := PARORB_HashFunction( x ) mod ht!.length + 1;
  atomic ht!.elements do
    if not IsBound( ht!.elements[ hashValue ] ) then
      ht!.elements[ hashValue ] := [ x ];
      return true;
    elif not x in ht!.elements[ hashValue ] then
      AddSet( ht!.elements[ hashValue ], x );
      return true;
    fi;
  od;
  return false;
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
InstallMethod( PARORB_HashFunction, "for storing permutaions",
[ IsPerm ],
function( p )
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
end );

###############################
# Operation PARORB_HashFunction
# Input:
#   tup -
# Filters:
#   IsList
#
# Output:
#   An integer hash value
###############################
InstallMethod( PARORB_HashFunction, "for tuples represented as lists",
[ IsList ],
function( tup )
  return ( Product( tup^5 mod 1009 ) + Sum( tup^3 ) mod 100003 ) ^7 mod 100003;
end );
