## _SERSI stores GLOBAL variables and constants
if not IsBound( _SERSI ) then
  BindGlobal( "_SERSI", rec() );
fi;

## GLOBAL variables
## constants are stored in _SERSI.C
## variables are stored in _SERSI
## parameter-dependant constants will be filled upon entry
if IsBound( _SERSI ) then
  MakeReadWriteGlobal( "_SERSI" );
  Unbind( _SERSI );
fi;
BindGlobal( "_SERSI",
    rec(
      C := rec(
      ),
      sema := ""
    )
);




#L := DihedralGroup(8);
#gg := WreathProductProductAction( L, G );
L := Group( (1,7,9,3)(2,4,8,6), (1,3)(4,6)(7,9) );
G := Group( (2,6)(3,5) );
LG := DirectProduct( L, G );
piL := Projection( LG, 1 );
piG := Projection( LG, 2 );
element := LG.1;
l := Image( piL, element );
element := LG.3;
g := Image( piG, element );

omega := Tuples( [1..9], 6 );

diagonalProductAction :=  function( tuple, element )
  local L, G, LG, w;
  L := Group( (1,7,9,3)(2,4,8,6), (1,3)(4,6)(7,9) );
  G := Group( (2,6)(3,5) );
  LG := DirectProduct( L, G );
  piL := Projection( LG, 1 );
  piG := Projection( LG, 2 );
  l := Image( piL, element );
  g := Image( piG, element );
  w := ShallowCopy( tuple );
  w := OnTuples( w, l );
  w := Permuted( w, g );
  return w;
end;

seeds := List( [1..100], x -> omega[ Random([1..9^6]) ] );
res := Orbits( LG, seeds, diagonalProductAction );;
