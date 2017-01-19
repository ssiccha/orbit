#############################################################################
##
##                             groupoid orbits package
##  canonization.g
##                                                          Sergio Siccha
##
##  Copyright...
##
##  determines a canonical representative of a suborbit
##
#############################################################################

###############################
# function canonizationFunction
# Input:
#   x -
#
# Output:
#   x
###############################
CreateCanonizationFunction := function( KPNString, numberTasks, ArchitectureString )
  local canonization, KPNCanonization, ArchitectureCanonization;

  if KPNString = "audio_filter" then
    KPNCanonization := function( x )
      if x[1] > x[2] then
          x := Permuted( x, (1,2)(3,4)(5,6) );
      fi;
      return x;
    end;
  fi;
  if Size( KPNString ) >= 10 then
    if KPNString{ [ 1 .. 10 ] } = "mandelbrot" then
      KPNCanonization := function( x )
        local permutation;
        permutation := Sortex( x{ [ 1 .. numberTasks ] } );
        return Permuted( x, permutation );
      end;
    fi;
  fi;
  if not IsBound( KPNCanonization ) then
    KPNCanonization := x -> x;
  fi;

  ArchitectureCanonization := x -> x;

  canonization := x -> KPNCanonization( ArchitectureCanonization( x ) );
  return canonization;
end;
