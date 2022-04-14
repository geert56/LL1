(*
 DOCUMENTATION INFORMATION                               module: LANGUAGE TOOL
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 system    : HP/9000
 file      : EBNF.LEX
 unit-title: LEXICAL RULES FOR BACKUS NAUR FORMs
 ref.      : files *.tax
 author(s) : G.L.J.M. Janssen
 date      : 18-JUN-1985
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*)
(*$C+ non-terminals are case sensitive*)

(* at the lexical level terminals are expressed by single characters *)

<lexical-token> ::= <nonterminal-symbol> |
                    <terminal-symbol> |
                    <empty-symbol> |
                    <separator> |
                    <replacement-symbol> |
                    <choice-symbol> |
                    <period> |
                    <left-parenthesis> |
                    <right-parenthesis> |
                    <left-curly-brace> |
                    <right-curly-brace> (*= <closure0-symbol>*) |
                    <conditional-closure1-symbol> |
                    <closure1-symbol> |
                    <left-bracket> |
                    <right-bracket> .

<nonterminal-symbol> ::= "<" <identifier> ">" .

<identifier> ::= <letter> { <letter> | <digit> | <readability-character> }.

<readability-character> ::= "-" | "_" .

<separator> ::= <blank> | <TAB> | <comment> | <EOL> .

<blank> ::= " " .

<comment> ::= "(" "*" { <a-printable-ASCII-character> } "*" ")" .

(* NOTE: the character "*" immediately followed by ")" should not appear
         within a comment.
*)

<terminal-symbol> ::= """" (* NOTE: to denote a single quotation
                              character as a terminal it is written twice
                           *)
                      { <a-printable-ASCII-character-except-TAB-and-EOL> }+
                      """" |
                      <pseudo-nonterminal> .

<empty-symbol> ::= "<" ">" .

(* NOTE: pseudo non-terminals resemble a non-terminal in appearance
         but in fact they will be considered as terminals.

         Non-terminals names are match case insensitive by default,
         this also applies to the pseudo non-terminals. However, in
         case sensitive mode <TAB> is certainly something else as
         for instance <Tab> .

         Terminal names are always matched case sensitive.

         Whether non-terminals with same letter spelling but different
         letter case for some or all letters are equivalent, can be
         controlled by a BNF-compiler option flag.

         To enter case sensitive mode enclose the following construct
         in comment brackets in your grammar definition:

         $C+

         To go back to the default mode (= case irrelevant) specify:

         $C-

*)

<pseudo-nonterminal> ::= <TAB-character> |
                         <end-of-line> |
                         <alternative-empty-symbol> .

<TAB-character> ::= "<" "T" "A" "B" ">" .

<end-of-line> ::= "<" "E" "O" "L" ">" .

<alternative-empty-symbol> ::= "<" "E" "M" "P" "T" "Y" ">" .

<letter> ::= <lowercase-letter> | <uppercase-letter> .

<lowercase-letter> ::= "a"|"b"|"c"|"d"|"e"|"f"|"g"|"h"|"i"|"j"|"k"|"l"|"m"|
                       "n"|"o"|"p"|"q"|"r"|"s"|"t"|"u"|"v"|"w"|"x"|"y"|"z" .

<uppercase-letter> ::= "A"|"B"|"C"|"D"|"E"|"F"|"G"|"H"|"I"|"J"|"K"|"L"|"M"|
                       "N"|"O"|"P"|"Q"|"R"|"S"|"T"|"U"|"V"|"W"|"X"|"Y"|"Z" .

<digit> ::= "0"|"1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9" .

<a-printable-ASCII-character-except-TAB-and-EOL> ::=
     <letter> | <digit> |
     <special-character> .

<a-printable-ASCII-character> ::=
     <a-printable-ASCII-character-except-TAB-and-EOL> |
     <TAB> | <EOL> .

<special-character> ::=

             " " | "!" | """" | "#" | "$" | "%" | "&" | "'" | "(" | ")" |
             "*" | "+" | "," | "-" | "." | "/" | ":" | ";" | "<" | "=" |
             ">" | "?" | "@" | "[" | "\" | "]" | "^" | "_" | "`" | "{" |
             "|" | "}" | "~" .

<replacement-symbol> ::= ":" ":" "=" .
<period>             ::= "." .
<choice-symbol>      ::= "|" .
<left-parenthesis>   ::= "(" .
<right-parenthesis>  ::= ")" .
<left-curly-brace>   ::= "{" .
<right-curly-brace>  ::= "}" .
<conditional-closure1-symbol> ::= "/" .
<closure1-symbol>    ::= "}" "+" .
<left-bracket>       ::= "[" .
<right-bracket>      ::= "]" .
