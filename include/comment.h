procedure commentorleftparenthesis;
{reads Pascal-like comments}
{pre: ch = '(' }
begin
  getch;
  if ch <> '*' then begin
{ LEFT PARENTHESIS: }                                                   { ( }
    symbol := lparen;
    {ready}
  end
  else begin {ch = '*'}

    {check for option constructs right after comment start symbol:}
    options;

    {skip the comment text:}
    repeat
      getch;
    until ((ch = '*') and (peeknextch = ')')) or (ch = EOFILE);

    if ch = EOFILE then
      error(1)
    else begin
      {read ')' :}
      getch;
      {read next character:}
      getch;
      {treat comment as white-space: try to construct next symbol:}
      goto 111;
    end; {if}
  end; {if}
end; {commentorleftparenthesis}
