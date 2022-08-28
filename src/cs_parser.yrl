Nonterminals path step group indices.
Terminals var int '[' ']' ',' ':'.
Rootsymbol path.

path -> step : '$1'.
path -> path step : '$1' ++ '$2'.

step -> group : '$1'.
step -> var : [unwrap_binary('$1')].

group -> '[' ']' : [].
group -> '[' indices ']' : ['$2'].

indices -> int : [unwrap('$1')].
indices -> int ':' int : unwrap_range('$1', '$3').
indices -> indices ',' indices : '$1' ++ '$3'.

Erlang code.

unwrap({_Token, _Line, Value}) -> Value.
unwrap_binary({_Token, _Line, Value}) -> list_to_binary(lists:delete($., Value)).
unwrap_range(Input1, Input2) -> lists:seq(unwrap(Input1), unwrap(Input2)).
