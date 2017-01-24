#############################################################################
##
##                             orbit package
##  parse-KPN-architecture.g
##                                                          Sergio Siccha
##
##  Copyright...
##
##  tests for groupoid orbit
##
#############################################################################
## Benchmarking and testing of hashTableOrbit

ParseKPNArchitecture := function( KPNString, ArchitectureString )
    local numberTasks, gensOfAutKPN, lastPos, truncateAt,
        numberProcessors, gensOfAutSemiArch, domains, canonization,
        KPNArchitectureData;
    ## Unused code went to ./deprecated/examples.g
    ########## DECIDE KPN ##########
    if KPNString = "audio_filter_3" then
        numberTasks := 8;
        gensOfAutKPN := [
            (1,2)(3,4)(5,6)
        ];
    elif KPNString = "jpeg" then
        numberTasks := 13;
        gensOfAutKPN := [
            (1,2)(4,5)(7,8),
            (1,2,3)(4,5,6)(7,8,9)
        ];
    elif KPNString = "jpeg_enc_no_multiread" then
        Error("MISSING");
    elif KPNString = "matmult" then
        numberTasks := 5;
        gensOfAutKPN := [];
    elif KPNString = "mjpeg_compaan" then
        numberTasks := 12;
        gensOfAutKPN := [
            (3,5,7,9)(4,6,8,10),
            (3,5)(4,6)
    ];
    elif KPNString = "sobel" then
        numberTasks := 5;
        gensOfAutKPN := [ (2,3) ];
    elif Size( KPNString ) >= 10
    and KPNString{ [ 1 .. 10 ] } = "mandelbrot" then
        ## "mandelbrot_njobs"
        lastPos := Position( KPNString, 'j' ) - 1;
        numberTasks := Int( KPNString{ [ 12 .. lastPos ] } ) + 2;
        ## Symmetric Group on the first numberTasks - 2 points
        ##gensOfAutKPN := List( [ 1 .. numberTasks-3 ], i -> (i,i+1) );
        ## The action on the KPN will be handled completely
        ## by the canonization function
        #### TODO: Does that work correctly? ####
        gensOfAutKPN := [];
    else
        Error("Wrong KPN string!");
    fi;

    ########## DECIDE Architecture ##########
    if ArchitectureString = "s4xs8" then
        numberProcessors := 12;
        gensOfAutSemiArch := [
            (1,2,3,4),
            (1,2),
            (5,6,7),
            (7,8,9),
            (9,10,11),
            (11,12)
        ];
        domains := [
            [1..12],
            [1..12],
            [1..12],
            [1..12],
            [1..12],
            [1..12]
        ];
    elif ArchitectureString = "s4" then
        numberProcessors := 4;
        gensOfAutSemiArch := [
            (1,2,3,4),
            (1,2)
        ];
        domains := [
            [1..4],
            [1..4]
        ];
    fi;

    ## TODO Pass action to orbit function instead of canonization etc
    canonization := CreateCanonizationFunction(
        KPNString,
        numberTasks,
        ArchitectureString
    );
    KPNArchitectureData := rec(
        numberProcessors := numberProcessors,
        numberTasks := numberTasks,
        gensOfAutKPN := gensOfAutKPN,
        gensOfAutSemiArch := gensOfAutSemiArch,
        domains := domains,
        canonization := canonization
    );
    return KPNArchitectureData;
end;
