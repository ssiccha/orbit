#Read("hpc.g");

i := 1;
res := [ 1 .. 2280 ];
while Size(res) = 2280 do
  res := testHashTableOrbit( (1,2,3), 20, 2, 20, rec( verbose := true ) );
od;
tmp := ShallowCopy( res );
Sort( tmp );
for i in [ 1 .. Size(tmp)-1 ] do
  if tmp[i] = tmp[i+1] then
    break;
  fi;
od;
x := tmp[i];

ht := _SERSI.hashTable!.elements;;
filtered := Filtered( ht, x -> Size(x) <> 0 );;
filtered2 := Filtered( filtered, x -> Size(x) > 1 );;
