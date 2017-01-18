## creates bit-encoding function and stores it in _SERSI.C.encode
_SERSI.encodeFunction := function( numberProcessors, numberTasks )
  local encode, n, m;
  n := ShallowCopy( numberProcessors );
  m := ShallowCopy( numberTasks );
  encode := function( tup )
    return
      (
        List( [ 1 .. m ], i -> n^(m-i) )
        *
        ( tup - 1 )
      )
      + 1;
  end;
  _SERSI.C.encode := encode;
end;

## creates bit-decoding function and stores it in _SERSI.C.decode
_SERSI.decodeFunction := function( numberProcessors, numberTasks )
  local decode, i, n, m;
  n := ShallowCopy( numberProcessors );
  m := ShallowCopy( numberTasks );
  decode := function( code )
    local tup;
    tup := [];

    code := code - 1;
    for i in [ 0 .. m-1 ] do
      tup[ m-i ] := code mod n;
      code := ( code - ( code mod n ) ) / n;
    od;
    tup := tup + 1;
    return tup;
  end;
  _SERSI.C.decode := decode;
end;
