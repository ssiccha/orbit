test := function()
    local AutKPN, AutArch, D, f, g, action;
    AutKPN := Group( (2,3) );
    AutArch := DirectProduct(
        SymmetricGroup(4),
        SymmetricGroup(8)
    );
    D := DirectProduct( AutKPN, AutArch );
    f := Projection( D, 1 );
    g := Projection( D, 2 );
    action := function( alpha, s )
        local sTask, sArch;
        sTask := Image( f, s );
        sArch := Image( g, s );
        alpha := Permuted( alpha, sTask );
        alpha := OnTuples( alpha, sArch );
        return alpha;
    end;
    return rec( group := D, action := action );
end;
