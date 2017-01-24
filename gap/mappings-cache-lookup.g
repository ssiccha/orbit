#############################################################################
##
##                       KPN-Architecture-Mappings
##  mappings-cache-lookup.g
##                                                          Sergio Siccha
##                                                          Andres Goens
##
##  Copyright...
##
##  For a given mapping, determine whether it appears in
##  a list of previously simulated mappings.
##
##  KPN: Kahn-Process-Networks
##
#############################################################################

###############################
# function MappingsCacheLookup
# Input:
#   inStreamFilename - stream to listen to for mappings,
#       atm implemented via named pipes
#   outStreamFilename - stream to output results to,
#       atm implemented via named pipes
#   opt - optional parameters
#
# Output:
#   NOTHING - see outStream
###############################
MappingsCacheLookup := function( inStreamFilename, outStreamFilename, opt... )
    ## parse data
    ## TODO Make this work with named pipes
    simulatedMappings := ParseMappings( inStreamFilename, truncateAt );
    KPNArchitectureData := ParseKPNArchitecture(
        KPNString,
        ArchitectureString
    );
    NumberOfOrbits(
        simulatedMappings,
        KPNArchitectureData
    );
end;
