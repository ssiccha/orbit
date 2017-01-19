  #if Length( omega ) = 0 then
  #  omega := [];
  #elif Length( omega ) = 1 then
  #  omega := omega[1];
  #else
  #  Error( "omega should be a list! " );
  #fi;

  ## mandelbrot + S4 x S8
  if false then
    if omega = [] then
      omega := Tuples( [1..12], 8 );
    fi;
    numberProcessors := 12;
    gensOfGroupoid := [
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
  fi;

  ## 3x3 mesh
  if false then
    omega := Tuples( [1..9], 6 );
    numberProcessors := 9;
    numberTasks := 6;
    gensOfAutKPN := [ (2,6)(3,5) ];
    gensOfGroupoid := [
      (1,7,9,3)(2,4,8,6),     ## rotation 90 degrees
      (1,3)(4,6)(7,9),        ## reflection at vertical axis
      (1,4,7)(2,5,8)(3,6,9),   ## move two upper lines down by one
      (7,4,1)(8,5,2)(9,6,3),   ## move two lower lines up by one
      (1,2,5,4),
      (1,2,5,4)(3,6)(8,7),
      (4,5,2,1)(6,3)(7,8),
      (1,5),
      (2,4)(3,7),
      (4,1,2,3,6),
      (6,3,2,1,4)
      #(1,2,3,6,9,8,7,4), #TODO
    ];
    domains := [
      [1..9],
      [1..9],
      [1..6],
      [4..9],
      [1,2,4,5,9],
      [1,2,3,4,5,8],
      [1,2,4,5,6,7],
      [1,2,3,4,5,7,9],
      [1,2,3,4,5,7,9],
      [1,2,3,4],
      [1,2,3,6]
      #[1,2,3,4,6,7,8,9], #TODO
    ];
  fi;

  ## 3x3 Mesh - old groupoid generators
  if false then
    omega := Tuples( [1..9], 6 );
    numberTasks := 6;
    numberProcessors := 9;
    gensOfAutKPN := [ (2,6)(3,5) ];
    gensOfGroupoid := [
      (1,7,9,3)(2,4,8,6),     ## rotation 90 degrees
      (1,3)(4,6)(7,9),        ## reflection at vertical axis
      (1,4,7)(2,5,8)(3,6,9),   ## move two upper lines down by one
      (7,4,1)(8,5,2)(9,6,3),   ## move two lower lines up by one
      (1,2,5,4)(3,7),
      (1,5),
      (2,4)(3,7),
      (4,1,2,3,6),
      (6,3,2,1,4)
      #(5,3),
      #(3,5)
      #(1,2,3,6,9,8,7,4), #TODO
      #(1,2,4)   ## WRONG ##!!
    ];
    domains := [
      [1..9],
      [1..9],
      [1..6],
      [4..9],
      [1,2,3,4,5,7,9],
      [1,2,3,4,5,7,9],
      [1,2,3,4,5,7,9],
      [1,2,3,6],
      [1,2,3,6]
      #[1,5,9],
      #[1,3,9]
      #[1,2,3,4,6,7,8,9], #TODO
      #[1,2,4,5],
    ];
  fi;

