LoadPackage("semigroup");
LoadPackage("grape");

#### generators for automorphism semigroup of 3x3 ####
phi := PartialPermOp( (1,7,9,3)(2,4,8,6), [1..9] );   ## rotation 90 degrees
r := PartialPermOp( (1,3)(4,6)(7,9), [1..9] );        ## reflection at vertical axis
p := PartialPerm( [ 4, 5, 6, 7, 8, 9, 0, 0, 0 ] );    ## move all lines downwards

S := SymmetricInverseSemigroup( 9 );
I := IdempotentGeneratedSubsemigroup( S );
autGens3 := [ phi, r, p ];
Append( autGens3, GeneratorsOfSemigroup( I ) );
autGens3 := IrredundantGeneratingSubset( InverseSemigroup( autGens3 ) );
fullAutGens3 := [   # the new generators
  PartialPerm( [1,2,4,5,6,7], [2,1,5,4,7,6] ),
  PartialPerm( [1,2,3,4,5,7], [5,2,1,6,3,9] ),
  PartialPerm( [2,3,4,5,6,7,8], [2,1,8,5,4,9,6] )
];
Append( fullAutGens3, autGens3 );

#### construct 3x3 mesh with grape ####
D8onMesh3 := Group( (1,7,9,3)(2,4,8,6), (1,3)(4,6)(7,9) );
edgeGens3 := [ [1,2],[2,1], [2,5],[5,2] ];
mesh3 := Graph( D8onMesh3, [1..9], OnPoints, function(x,y) return [x,y] in edgeGens3; end, true );


#### generators for automorphism semigroup of 4x4 ####
phi := PartialPermOp( (1,4,16,13)(2,8,15,9)(3,12,14,5)(6,7,11,10), [1..16] );
## rotation 90 degrees
r := PartialPermOp( (1,4)(2,3)(5,8)(6,7)(9,12)(10,11)(13,16)(14,15), [1..16] );
## reflection at vertical axis
p := PartialPerm( [ 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 0, 0, 0, 0 ] );
## move all lines downwards

## Idempotents have to be defined manually
## first define the domains
## it suffices to remove representatives of the D8 orbits on the 4x4 mesh
## thus we get all identity partial perms on [1..16]\[i] for all i
idemGens := [
  [1..16],
  Difference( [1..16], [1] ),
  Difference( [1..16], [2] ),
  Difference( [1..16], [6] )
];
idemGens := List( idemGens, x -> PartialPerm( x, x ) );

autGens4 := [ phi, r, p ];
Append( autGens4, idemGens );
G := InverseSemigroup( autGens4 );

#### construct 4x4 mesh with grape ####
D8onMesh4 := Group( (1,4,16,13)(2,8,15,9)(3,12,14,5)(6,7,11,10),
  (1,4)(2,3)(5,8)(6,7)(9,12)(10,11)(13,16)(14,15)  );
edgeGens4 := [ [1,2],[2,1], [2,3],[3,2], [2,6],[6,2], [6,7],[7,6] ];
mesh4 := Graph( D8onMesh4, [1..16], OnPoints, function(x,y) return [x,y] in edgeGens4; end, true );


#### generators for automorphism semigroup of 8x8 ####
## rotation 90 degrees
phi := PartialPermOp(
  (1,8,64,57)(2,16,63,49)(3,24,62,41)(4,32,61,33)(5,40,60,25)(6,48,59,17)(7,56,58,9)(10,15,55,50)(11,23,54,42)(12,31,53,34)(13,39,52,26)(14,47,51,18)(19,22,46,43)(20,30,45,35)(21,38,44,27)(28,29,37,36),
  [1..64]
);
## reflection at vertical axis
r := PartialPermOp(
  (1,8)(2,7)(3,6)(4,5)(9,16)(10,15)(11,14)(12,13)(17,24)(18,23)(19,22)(20,21)(25,32)(26,31)(27,30)(28,29)(33,40)(34,39)(35,38)(36,37)(41,48)(42,47)(43,46)(44,45)(49,56)(50,55)(51,54)(52,53)(57,64)(58,63)(59,62)(60,61),
  [1..16]
);
## move all lines downwards
p := PartialPerm(
  [ 9,10,11,12,13,14,15,16, 17,18,19,20,21,22,23,24, 25,26,27,28,29,30,31,32, 33,34,35,36,37,38,39,40, 41,42,43,44,45,46,47,48, 49,50,51,52,53,54,55,56, 57,58,59,60,61,62,63,64 ]
);

## Idempotents have to be defined manually
## first define the domains
## it suffices to remove representatives of the D8 orbits on the 8x8 mesh
## thus we get all identity partial perms on [1..16]\[i] for all i
idemGens := [
  [1..64],
  Difference( [1..64], [1] ),
  Difference( [1..64], [2] ),
  Difference( [1..64], [3] ),
  Difference( [1..64], [4] ),
  Difference( [1..64], [5] ),
  Difference( [1..64], [6] ),
  Difference( [1..64], [7] ),
  Difference( [1..64], [10] ),
  Difference( [1..64], [11] ),
  Difference( [1..64], [12] ),
  Difference( [1..64], [13] ),
  Difference( [1..64], [14] ),
  Difference( [1..64], [19] ),
  Difference( [1..64], [20] ),
  Difference( [1..64], [21] ),
  Difference( [1..64], [28] )
];
idemGens := List( idemGens, x -> PartialPerm( x, x ) );

autGens8 := [ phi, r, p ];
Append( autGens8, idemGens );

#### construct 8x8 mesh with grape ####
D8onMesh4 := Group( (1,4,16,13)(2,8,15,9)(3,12,14,5)(6,7,11,10),
  (1,4)(2,3)(5,8)(6,7)(9,12)(10,11)(13,16)(14,15)  );
edgeGens4 := [ [1,2],[2,1], [2,3],[3,2], [2,6],[6,2], [6,7],[7,6] ];
mesh4 := Graph( D8onMesh4, [1..16], OnPoints, function(x,y) return [x,y] in edgeGens4; end, true );
