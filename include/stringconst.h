procedure literalconstant (delimiter : char);
{pre: ch = delimiter}
label 1,
      2; {string complete}
begin
  clearsymbuf;

  {clear id buffer:}
  identstr := blankidentstr;

1:
  getch;
  {NOTE: perhaps now ch = EOLINE (EOFILE impossible)}
  if ch = delimiter then begin {quote in string}
    {do not store in identstr}
    getch;
    {NOTE: perhaps now ch = EOLINE (EOFILE impossible)}
    if ch <> delimiter then
      {NOTE: perhaps now ch = EOLINE (EOFILE impossible) but no error}
      goto 2 {string complete, but perhaps empty};
    {post: ch = delimiter}
  end; {if}

  {post: perhaps ch = delimiter}
  {NOTE: perhaps now ch = EOLINE (EOFILE impossible)}

  if atendofline then begin
    {'...? and ? = EOLINE}
    error(5); {literal constant must not extend passed end-of-line}
    {consider string complete:}
  end
  else begin
{        handle_esc;}

    if symlength < maxidentstrlen then begin
      symlength := symlength + 1;

      {store ch in symbol buffer:}
      symbuf[symlength] := ch;

      {store character in id buffer:}
      identstr[symlength] := ch;
    end
    else
      putsymbuf (ch);

    goto 1;
  end; {if}

  2: {string complete, but perhaps empty}
  if symlength > 0 then {valid constant}
    symbol := literal
  else {symlength = 0}
    symbol := epsilonsym;
  {store delimiter character in buffer:}
  symbuf[symlength+1] := delimiter;
end; {literalconstant}
