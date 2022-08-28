Definitions.

INT = [0-9]+
VAR = \.[A-Za-z0-9\s]*
WHITESPACE = [\s\t\n\r]

Rules.
{INT}         : {token, {int, TokenLine, list_to_integer(TokenChars)}}.
{VAR}         : {token, {var, TokenLine, TokenChars}}.
\[            : {token, {'[', TokenLine}}.
\]            : {token, {']', TokenLine}}.
\,            : {token, {',', TokenLine}}.
\:            : {token, {':', TokenLine}}.
{WHITESPACE}+ : skip_token.

Erlang code.
