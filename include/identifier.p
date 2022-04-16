procedure identifierorreservedword;
{
  - first "maxidentstrlen" characters are significant;
    excess characters are discarded.
}
{pre: ch in firstidentifier}
begin
  clearsymbuf;

  {clear id buffer:}
  identstr := blankidentstr;

  repeat
    if symlength < maxidentstrlen then begin
      symlength := symlength + 1;

      {store ch in symbol buffer:}
      symbuf[symlength] := ch;

      {store character in id buffer:}
      identstr[symlength] := ch;
    end
    else
      putsymbuf (ch);
    getch;
  until notidentchar[ch];

  {check for reserved word:}
  symbol := kwsearch (identstr);
end; {identifierorreservedword}
