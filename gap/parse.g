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

parse := function( data )
  local simulatedMappings, folder, startsWithZero, inStream, buf, m;
  folder := "data/";
  startsWithZero := true;

  inStream := InputTextFile( Concatenation( folder, data ) );
  simulatedMappings := [];

  buf := ReadLine( inStream );
  while not IsEndOfStream( inStream ) do
    buf := Chomp( buf );
    if not buf[1] = '#' then
      if not Position( buf, '#' ) = fail then
        m := m{ [ 1 .. Position( buf, '#' ) - 1 ] };
      fi;
      m := EvalString(buf);
        if IsInt( _SERSI.C.truncateAt ) then
        m := m{ [ 1 .. _SERSI.C.truncateAt ] };
      fi;
      if startsWithZero then
        m := m + 1;
      fi;
      simulatedMappings[ Length( simulatedMappings ) + 1 ] := m;
    fi;
    buf := ReadLine( inStream );
  od;
  CloseStream( inStream );
  simulatedMappings := Set( simulatedMappings );
  return simulatedMappings;
end;
