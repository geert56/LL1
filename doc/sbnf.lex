<replace-symbol> ::= ":" | ":=" | "=" | "::=" | "->" .

<choice-symbol> ::= "|" | "," .

<separator-symbol> ::= "/" | "\" .

<rule-terminator> ::= "." | ";" .

<nonterminal-symbol> ::= "<" <identifier> ">"
                      |  <identifier> .

<identifier> ::= <initial-char> <rest-of-identifier> .

<initial-char> ::= <letter> | "_" .

<rest-of-identifier> ::= { <letter> | <digit> | "_" | "-" } .

<terminal-symbol> ::= <single-quote-delimited-string>
                   |  <double-quote-delimited-string>
                   |  "<" <reserved-word> ">"
                   |  <reserved-word> .

<reserved-word> ::= "EOL" | "EMPTY" | "TAB" .

<empty-symbol>  ::= (* implicit via empty rule body *)
                 |  <EMPTY>     (* pseudo-nonterminal *)
                 |  EMPTY       (* reserved word *)
                 |  ""          (* 0 character literal *)
                 |  ''          (* 0 character literal *)
                 |  <>          (* 0 character non-terminal *)
                 .
