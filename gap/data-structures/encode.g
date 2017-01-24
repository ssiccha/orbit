## Creates bit-encoding function and returns it.
## Encodes tuples with m entries, each in 1..n.
## n = numberProcessors;
## m = numberTasks;
CreateEncodeFunction := function( n, m )
  local encode;
  encode := function( tuple )
    return
      (
        List( [ 1 .. m ], i -> n^(m-i) )
        *
        ( tuple - 1 )
      )
      + 1;
  end;
  return encode;
end;

## creates bit-decoding function and returns it.
CreateDecodeFunction := function( numberProcessors, numberTasks )
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
  return decode;
end;
