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
    local numberTasks, lastPos, numberProcessors,
      AutKPN, AutSemiArch, canonization,
      KPNArchGroup, projection1, projection2, action,
      KPNArchitectureData;
    ## Unused code went to ./deprecated/examples.g
    ########## DECIDE KPN ##########
    if KPNString = "audio_filter_3" then
        numberTasks := 8;
        AutKPN := Group([
            (1,2)(3,4)(5,6)
        ]);
    elif KPNString = "jpeg" then
        numberTasks := 13;
        AutKPN := Group([
            (1,2)(4,5)(7,8),
            (1,2,3)(4,5,6)(7,8,9)
        ]);
    elif KPNString = "jpeg_enc_no_multiread" then
        Error("MISSING");
    elif KPNString = "matmult" then
        numberTasks := 5;
        AutKPN := Group([]);
    elif KPNString = "mjpeg_compaan" then
        numberTasks := 12;
        AutKPN := Group([
            (3,5,7,9)(4,6,8,10),
            (3,5)(4,6)
        ]);
    elif KPNString = "sobel" then
        numberTasks := 5;
        AutKPN := Group([ (2,3) ]);
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
        AutKPN := Group([]);
    else
        Error("Wrong KPN string!");
    fi;

    ########## DECIDE Architecture ##########
    if ArchitectureString = "s4xs8" then
        numberProcessors := 12;
        AutSemiArch := Group([
            (1,2,3,4),
            (1,2),
            (5,6,7),
            (7,8,9),
            (9,10,11),
            (11,12)
        ]);
    elif ArchitectureString = "s4" then
        numberProcessors := 4;
        AutSemiArch := Group([
            (1,2,3,4),
            (1,2)
        ]);
    fi;

    ## TODO Pass action to orbit function instead of canonization etc
    canonization := CreateCanonizationFunction(
        KPNString,
        numberTasks,
        ArchitectureString
    );
    KPNArchGroup := DirectProduct( AutKPN, AutSemiArch );
    projection1 := Projection( KPNArchGroup, 1 );
    projection2 := Projection( KPNArchGroup, 2 );
    action := function( alpha, s )
        local sTask, sArch;
        sTask := Image( projection1, s );
        sArch := Image( projection2, s );
        alpha := Permuted( alpha, sTask );
        alpha := OnTuples( alpha, sArch );
        return alpha;
    end;
    KPNArchitectureData := rec(
        numberProcessors := numberProcessors,
        numberTasks := numberTasks,
        KPNArchGroup := KPNArchGroup,
        action := action,
        canonization := canonization
    );
    return KPNArchitectureData;
end;
