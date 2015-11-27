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
  hashTable := ShallowCopy(opt);
  hashTable := rec();
  if IsBound(opt.length) then
    type := HashTableType;
    hashTable.length := NextPrimeInt(opt.length);
  else
    type := HashTableType;
    hashTable.length := 100003;
  fi;
  hashTable.elements := [];
    hashTable.elements[ hashTable.length+1 ] := fail;
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
#   Returns 1 if x was not in ht. Otherwise returns 0.
###############################
InstallMethod( HashTableAdd, "for an object",
[ IsMyHashTable, IsObject ],
function( ht, x )
  local hashValue;
  hashValue := PARORB_HashFunction( x ) mod ht!.length + 1;
  if not IsBound( ht!.elements[ hashValue ] ) then
    ht!.elements[ hashValue ] := [ x ];
    return 1;
  elif not x in ht!.elements[ hashValue ] then
    AddSet( ht!.elements[ hashValue ], x );
    return 1;
  fi;
  return 0;
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


