Nonterminals path step group indices.
Terminals var int '[' ']' ',' ':'.
Rootsymbol path.

path -> step : '$1'.
path -> path step : '$1' ++ '$2'.

step -> group : '$1'.
step -> var : [list_to_binary(lists:delete($., unwrap('$1')))].

group -> '[' ']' : [].
group -> '[' indices ']' : ['$2'].

indices -> int : [unwrap('$1')].
indices -> ':' int : [{nil, unwrap('$2')}].
indices -> int ':' : [{unwrap('$1'), nil}].
indices -> int ':' int : [{unwrap('$1'), unwrap('$3')}].
indices -> indices ',' indices : '$1' ++ '$3'.

Erlang code.

unwrap(Value) ->
  case Value of
    {_Token, _Line, Value1} -> 
      Value1;
    _ ->
      Value
  end.
