Nonterminals path pipeline step group filters indices comparsion value function funcargs object objfields objfield array arrfields.
Terminals var int cmp '[' ']' ',' ':' '.' '!' '|' '(' ')' '{' '}' string. 
Rootsymbol pipeline.

pipeline -> path : '$1'.
pipeline -> path '|' pipeline : [{pipe, '$1', '$3'}].

path -> '.' : [{identity}].
path -> step : '$1'.
path -> path step : '$1' ++ '$2'.

step -> group : '$1'.
step -> function : '$1'.
step -> object : '$1'.
step -> array : '$1'.
step -> '.' var : [{local, list_to_binary(unwrap('$2'))}].
step -> '.' '.' var : [{global, list_to_binary(unwrap('$3'))}].

function -> var '(' ')' : [{function, list_to_binary(unwrap('$1')), []}].
function -> var '(' funcargs ')' : [{function, list_to_binary(unwrap('$1')), '$3'}].

funcargs -> pipeline : ['$1'].
funcargs -> pipeline ',' funcargs : ['$1'] ++ '$3'.

group -> '[' ']' : [{iterator}].
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

object -> '{' '}' : [{object, []}].
object -> '{' objfields '}' : [{object, '$2'}].

objfields -> objfield : ['$1'].
objfields -> objfield ',' objfields : ['$1'] ++ '$3'.

objfield -> string ':' pipeline : {list_to_binary(unwrap('$1')), '$3'}.
objfield -> var ':' pipeline : {list_to_binary(unwrap('$1')), '$3'}.

array -> '[' arrfields ']' : [{array, '$2'}].

arrfields -> pipeline : ['$1'].
arrfields -> pipeline ',' arrfields : ['$1'] ++ '$3'.

Erlang code.

unwrap(Value) ->
  case Value of
    {_Token, _Line, Value1} ->
      Value1;
    _ ->
      Value
  end.
