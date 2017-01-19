#############################################################################
##
##                              package
##  parse.g
##                                                          Sergio Siccha
##
##  Copyright...
##
##  parse a list of P to PE mappings
##
#############################################################################

parse := function( data, opt... )
    local mappings, folder, startsWithZero, inStream, buf, m;
    if Length(opt) = 1 then
        truncateAt := opt[1];
    else
        truncateAt := false;
    fi;
    folder := "data/";
    startsWithZero := true;

    inStream := InputTextFile( Concatenation( folder, data ) );
    mappings := [];

    buf := ReadLine( inStream );
    while not IsEndOfStream( inStream ) do
        buf := Chomp( buf );
        if not buf[1] = '#' then
            if not Position( buf, '#' ) = fail then
                m := m{ [ 1 .. Position( buf, '#' ) - 1 ] };
            fi;
            m := EvalString(buf);
            if IsInt( truncateAt ) then
                m := m{ [ 1 .. truncateAt ] };
            fi;
            if startsWithZero then
                m := m + 1;
            fi;
            mappings[ Length( mappings ) + 1 ] := m;
        fi;
        buf := ReadLine( inStream );
    od;
    CloseStream( inStream );
    mappings := Set( mappings );
    return mappings;
end;
