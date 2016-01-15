## Benchmarking and testing of hashTableOrbit

Read("init.g");

## Benchmark HashTableAdd 
## for p in Sym(10) do HashTableAdd( ht, p ); od; time;

## fresh HashTable
ht := HashTableCreate( 1, rec() );
G := SymmetricGroup(10);
hashTableOrbit( (1,2,3), G );
