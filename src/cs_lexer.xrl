Definitions.

INT = \-?[0-9]+
VAR = [A-Za-z0-9_]*
CMP = (<|<=|=|=>|>|!=)
STRING = \"[^\"]*\"
WHITESPACE = [\s\t\n\r]

Rules.
{INT}         : {token, {int, TokenLine, list_to_integer(TokenChars)}}.
{VAR}         : {token, {var, TokenLine, TokenChars}}.
{CMP}         : {token, {cmp, TokenLine, TokenChars}}.
{STRING}      : {token, {string, TokenLine, string:slice(TokenChars, 1, length(TokenChars) - 2)}}.
\!            : {token, {'!', TokenLine}}.
\[            : {token, {'[', TokenLine}}.
\]            : {token, {']', TokenLine}}.
\,            : {token, {',', TokenLine}}.
\:            : {token, {':', TokenLine}}.
\.            : {token, {'.', TokenLine}}.
\|            : {token, {'|', TokenLine}}.
\(            : {token, {'(', TokenLine}}.
\)            : {token, {')', TokenLine}}.
\{            : {token, {'{', TokenLine}}.
\}            : {token, {'}', TokenLine}}.
{WHITESPACE}+ : skip_token.
.             : {error, illegal}.

Erlang code.
