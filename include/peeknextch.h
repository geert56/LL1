function peeknextch : char;
{Peeks at character immediately following the one last returned by getch}
begin
  if eof(input) then    peeknextch := EOFILE
  else
    if eoln(input) then peeknextch := EOLINE
    else                peeknextch := input^;
end; {peeknextch}
