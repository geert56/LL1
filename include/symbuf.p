procedure clearsymbuf;
begin
  symlength := 0;
end; {clearsymbuf}

procedure putsymbuf(cc : char);
begin
  if symlength < maxsymlength then begin
    symlength := symlength + 1;
    symbuf[symlength] := cc;
  end
  else {symbol too long}
    {action not yet decided}
end; {putsymbuf}
