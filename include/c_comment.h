procedure commentorDIVIDEsym;
  {reads C-like comments: /* .... */ }
  {pre: ch = '/'}
begin
  getch;
  if ch = '/' then begin { C++-style line comment }
    {skip the comment text:}
    repeat
      getch;
    until (ch = EOLINE) or (ch = EOFILE);
    if ch = EOLINE then getch;
  end
  else
  if ch <> '*' then begin
{ DIVIDE BY SYMBOL: }                                                   { / }
    symbol := DIVIDEsym;
    {ready}
  end
  else begin {ch = '*'}

    {check for option constructs right after comment start symbol:}
    options;

    {skip the comment text:}
    repeat
      getch;
    until ((ch = '*') and (peeknextch = '/')) or (ch = EOFILE);

    if ch = EOFILE then
      error (1)
    else begin
      {read the '/':}
      getch;
      {read next character:}
      getch;
      {treat comment as white-space: try to construct next symbol:}
      goto 111; {see lex.h}
    end; {if}
  end; {if}
end; {commentorDIVIDEsym}
