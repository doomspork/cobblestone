Nonterminals path step group filters indices comparsion value.
Terminals var int cmp '[' ']' ',' ':' '.' '!'. 
Rootsymbol path.

path -> step : '$1'.
path -> path step : '$1' ++ '$2'.

step -> group : '$1'.
step -> '.' var : [{local, list_to_binary(unwrap('$2'))}].
step -> '.' '.' var : [{global, list_to_binary(unwrap('$3'))}].

group -> '[' ']' : [].
group -> '[' filters ']' : '$2'.

filters -> comparsion : [{filter, '$1'}].
filters -> indices : [{indices, '$1'}].
filters -> ':' int : [{indices, {nil, unwrap('$2')}}].
filters -> int ':' : [{indices, {unwrap('$1'), nil}}].
filters -> int ':' int : [{indices, {unwrap('$1'), unwrap('$3')}}].

comparsion -> var cmp value : {list_to_binary(unwrap('$1')), list_to_binary(unwrap('$2')), '$3'}.
comparsion -> var : list_to_binary(unwrap('$1')).
comparsion -> '!' var : {exclude, list_to_binary(unwrap('$1'))}.

indices -> int : [unwrap('$1')].
indices -> int ',' indices : [unwrap('$1')] ++ '$3'.

value -> int : unwrap('$1').
value -> var : list_to_binary(unwrap('$1')).

Erlang code.

unwrap(Value) ->
  case Value of
    {_Token, _Line, Value1} ->
      Value1;
    _ ->
      Value
  end.
