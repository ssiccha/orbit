#############################################################################
##
##                              package
##  parse-mappings.g
##                                                          Sergio Siccha
##
##  Copyright...
##
##  parse a P to PE mapping
##
#############################################################################

##################################################
# function ParseMapping
# Input:
#   rawMapping - a string
#   truncateAt - false, or the position the mapping should be truncated at
#   startsWithZero - true iff the mapping counts PEs starting at zero
#
# Output:
#   fail iff rawMapping started with a '#',
#   a mapping (list of integers) otherwise
##################################################
ParseMapping := function( rawMapping, truncateAt, startsWithZero )
    local mapping;
    rawMapping := Chomp( rawMapping );
    ## Get rid of comments
    if not rawMapping[1] = '#' then
        if not Position( rawMapping, '#' ) = fail then
            rawMapping := rawMapping{ [ 1 .. Position( rawMapping, '#' ) - 1 ] };
        fi;
        mapping := EvalString(rawMapping);
        if IsInt( truncateAt ) then
            mapping := mapping{ [ 1 .. truncateAt ] };
        fi;
        if startsWithZero then
            mapping := mapping + 1;
        fi;
        return mapping;
    fi;
    return fail;
end;

## DEPRECATED ##
ParseMappings := function( data, opt... )
    local truncateAt, buf, folder, startsWithZero, inStream, mappings, m;
    if Length(opt) = 1 then
        truncateAt := opt[1];
    else
        truncateAt := false;
    fi;
    folder := "../data/";
    startsWithZero := true;

    inStream := InputTextFile( Concatenation( folder, data ) );
    mappings := [];

    buf := ReadLine( inStream );
    while not IsEndOfStream( inStream ) do
        ParseMapping( buf );
    od;
    CloseStream( inStream );
    mappings := Set( mappings );
    return mappings;
end;
