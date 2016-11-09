Read("./autsemi-examples.g");

## How to get reps for orbits
partition4 := function()
  local G, orb, scc, repsPositions, reps;
  G := InverseSemigroup( autGens4 );
  orb := Orb( G, [1..16], OnSets, rec( orbitgraph := true ) );
  scc := OrbSCC( orb );
  repsPositions := List( scc, x -> x[1] );
  reps := orb{ repsPositions };
  return rec(
    orb := orb,
    scc := scc,
    repsPositions := repsPositions,
    reps := reps
  );
end;

partition8 := function( subgraph )
  local G, orb;
  G := InverseSemigroup( autGens8 );
  orb := Orb( G, subgraph, OnSets, rec( orbitgraph := true ) );
  return rec( orb := orb, scc := OrbSCC( orb ) );
end;
