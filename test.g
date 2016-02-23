#############################################################################
##
##                             orbit package
##  test.g
##                                                          Sergio Siccha
##
##  Copyright...
##
##  tests for groupoid orbit
##
#############################################################################
## Benchmarking and testing of hashTableOrbit
#Read("init.g");


omega := Tuples( [1..9], 6 );;

#hashTableOrbit( TrivialGroup(), [1..6], rec( andres := "" ) );;  ## using a hash table
#hashTableOrbit( TrivialGroup(), [1..6], rec( domainSize := 9^6 ) );; ## using a bitList

## using seeds
seeds := List( [1..200], x -> omega[ Random([1..9^6]) ] );;
#res := MyOrbits( seeds );;

## computing a partition of the whole domain into orbits
#res := MyOrbits( omega );;
#Length( res );
#Sum( List( res, Length ) );
#res := MyOrbits( omega );; Print( "--- ", Length(res), " ---", 9^6 = Sum( List( res, Length ) ), ", time = ", time, "\n");
