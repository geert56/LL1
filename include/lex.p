procedure getsymbol;
{ Gets next lexical token from input stream;
  also reads 1 character ahead, thus error reported for a symbol is
  always at position directly following last char belonging to symbol.
  pre: getch called prior to first call of getsymbol
}
label   111;    {entry after illegal symbol or comment}

{$I 'options.p'}

//{$I 'handle_esc.p'}
{$I 'stringconst.p'}
{$I 'identifier.p'}
{$I 'comment.p'}
{$I 'c_comment.p'}

begin {getsymbol}

111: {entry after illegal symbol or comment (or EOLINE)}

  {skip white space:}
  while (ch = ' ') or (ch = TAB) do
    getch;

  if ch in firstidentifier then
{ IDENTIFIER or RESERVED WORD: }                                { identifier }
    identifierorreservedword
  else

  case ch of

{ CHARACTER or STRING CONSTANT: }
'''', '"' :                                                          { '...' }
  literalconstant(ch);                                               { "..." }

{ COMMENT or LEFT PARENTHESIS: }
'(' :
  commentorleftparenthesis;

'/' :
  commentorDIVIDEsym;

EOLINE:
  begin
    newlineseen := true;
    getch;
    goto 111;
  end;

EOFILE:                                                                { EOF }
  begin
    symbol := fileend;
  end; {EOFILE}

'-' :
  begin
    symbol := replacesym;
    getch;
    if ch = '>' then		                                        { -> }
      getch
    else
      error(6); { replacement symbol expected; inserted }
  end;

':' :
  begin
    getch;
    if ch = '=' then
      begin { REPLACEMENT SYMBOL: }                                     { := }
        symbol := replacesym;
        getch;
      end
    else
    if ch = ':' then
      begin
        getch;
        if ch = '=' then
          begin { REPLACEMENT SYMBOL: }                                { ::= }
            symbol := replacesym;
            getch;
          end
        else {::?}
          begin
            error(6); { "::=" expected; inserted }
            symbol := replacesym;
          end; {if}
      end
    else
      begin { REPLACEMENT SYMBOL: }                                      { : }
        symbol := replacesym;
      end; {if}
  end; {':'}

{ 1-CHARACTER SYMBOLS: }
',', ';', '=','\', '.', '|', '+', '*', ')', '{', '}', '[', ']', '<', '>', '?' :
  begin
    symbol := onecharsymbols[ch];
    getch;
  end;

{otherwise}
else
  begin
    error(3); {illegal symbol}
    getch;
    {discard 1-character symbol:}
    goto 111;
  end; {otherwise}

  end; {case-if}
  {writeln(stderr, '*symbol: ', symbol);}
end; {getsymbol}

procedure skipuntil(symset : setofsymbol);
{ skip a number (possible zero) of symbols of the input stream,
  until symbol in symset;
  Note: symset should contain "fileend" to avoid endless looping.
}
var first : boolean;
begin
  first := true;
  while not (symbol in symset) do begin
    if first then first := false
    else error(0);
    getsymbol;
  end; {while}
end; {skipuntil}

procedure initLex;
var
        cc : char;
        i  : identstridxrange;
        valididentchars : setofchar;
begin
  {writeln(stderr, 'initLex');}
  initScanner;

  getch;

{*}  firstidentifier := ['A' .. 'Z', 'a' .. 'z', '_', '%' ];
{*}  decimaldigits   := ['0' .. '9'];

{*}  valididentchars := [ 'A'..'Z', 'a'..'z', '0'..'9', '_', '-' ];

  for cc := chr(0) to chr(127) do
    notidentchar[cc] := not (cc in valididentchars);

  for i := 1 to maxidentstrlen do
    blankidentstr[i] := ' ';

{*}
{ 1-CHARACTER SYMBOLS: }
  onecharsymbols[ '\' ] := separatesym; {separator-symbol}
  //onecharsymbols[ '/' ] := separatesym; GJ22: reserve for comments

  onecharsymbols[ '.' ] := period; {rule-terminator}
  onecharsymbols[ ';' ] := period;

  onecharsymbols[ '|' ] := choicesym; {choice-symbol}
  onecharsymbols[ ',' ] := choicesym;

  onecharsymbols[ '=' ] := replacesym; {replace-symbol}

  onecharsymbols[ '+' ] := PLUSsym;
  onecharsymbols[ '*' ] := TIMESsym;
  onecharsymbols[ ')' ] := rparen;
  onecharsymbols[ '{' ] := lbrace;
  onecharsymbols[ '}' ] := rbrace;
  onecharsymbols[ '[' ] := lbracket;
  onecharsymbols[ ']' ] := rbracket;
  onecharsymbols[ '<' ] := LESSop;
  onecharsymbols[ '>' ] := GREATERop;
  onecharsymbols[ '?' ] := questsym;

  initKeywordtable;

  newlineseen := false;
end; {initLex}

procedure finalLex;
begin
  finalScanner;
end; {finalLex}
