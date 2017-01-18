# Each HashTable specifies the HashFunction used for its objects
# during its creation.

###############################
# Operation HashTableCreate
# Input:
#   tupleDimensions
#   opt - Options record
# Filters:
#   IsObject, IsRecord
#
# Output:
#   A hashTable
###############################
InstallMethod( HashTableCreate,
"for an object and an options record",
[ IsObject, IsRecord ],
function( tupleDimensions, opt )
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
    # Each HashTable specifies the HashFunction used for its objects
    # during its creation.
    hashTable.hashFunction :=
        CreateEncodeFunction(
            tupleDimensions[1],
            tupleDimensions[2]
        );
    Objectify( type, hashTable );
    return hashTable;
end );

###############################
# Operation ListHashTable
# Input:
#   hashTable 
# Filters:
#   IsMyHashTable
#
# Output:
#   A list containing all entries of hashTable
###############################
InstallMethod( ListHashTable,
"for a hashTable",
[ IsMyHashTable ],
function( hashTable )
  local list;
  list := ShallowCopy( hashTable!.elements );
  Unbind( list[ hashTable!.length + 1 ] );
  list := Concatenation( Compacted( hashTable!.elements ) );
  return list;
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
function( ht, x )
    local hashValue;
    hashValue := ht.hashFunction( x ) mod ht!.length + 1;
    if not IsBound( ht!.elements[ hashValue ] ) then
        ht!.elements[ hashValue ] := [ x ];
        return true;
    elif not x in ht!.elements[ hashValue ] then
        AddSet( ht!.elements[ hashValue ], x );
        return true;
    fi;
    return false;
end );
