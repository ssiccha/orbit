Read("read.g");
x := (1,2,3);

## Test HashTable adding
ht := HashTableCreate( x, rec() );
HashTableAdd( ht, x );
