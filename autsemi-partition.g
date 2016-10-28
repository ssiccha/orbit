Read("./autsemi-examples.g");

partition4 := function()
  local G, orb;
  G := InverseSemigroup( autGens4 );
  orb := Orb( G, [1..16], OnSets, rec( orbitgraph := true ) );
  return rec( orb := orb, scc := OrbSCC( orb ) );
end;

partition8 := function( subgraph )
  local G, orb;
  G := InverseSemigroup( autGens8 );
  orb := Orb( G, subgraph, OnSets, rec( orbitgraph := true ) );
  return rec( orb := orb, scc := OrbSCC( orb ) );
end;
