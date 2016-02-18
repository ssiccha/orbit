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
seeds := List( [1..200], x -> omega[ Random([1..9^6]) ] );;

#hashTableOrbit( TrivialGroup(), [1..6], rec( andres := "" ) );;
#res := MyOrbits( seeds );;
