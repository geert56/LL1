procedure error(errnr : cardinal);
{report the error with error number "errnr";
 errors occurred in one line are collected in errorrecord.
}
begin
  {gather error statistics:}
  if errnr >= startwarnings then
    totalwarnings := totalwarnings + 1
  else
    if errnr > 0 then {skipped symbol not counted as error}
      totalerrors := totalerrors + 1;

  erroroccurred {or warning or skip action} := true;

  with errorrecord do
    begin
      if erridx = maxerrperline then
        {current error/warning counted,
         but not indicated in the listing and neither
         indicated in summary ! instead #4 emitted
        }
        errnr := 4
      else
        erridx := erridx + 1;

      {record error:}
      errorsummary[errnr] := true;

      with errlist[erridx] do
        begin
          {errlist[erridx].}errnum := errnr;
          {errlist[erridx].}pos    := charcount;
        end; {with}

    end; {with}
end; {error}

procedure listerrors;
{show the error numbers at proper positions in a line directly following
 the input line
}
var
    i           : 1..maxerrperline;
    lastpos,                    {position of previous erroneous symbol}
    freepos     : cardinal;     {free position in current error message line}
    {EXAMPLE:

column :      123456789....
listing:   54 blabla
                    ^2,10
                    |    |
                 lastpos |
                        freepos

    }
    width       : 0..3;

  procedure startnewline;
  begin
    if list then
      begin
        writeln(listing);
        pageupdate;
                     {1234567890}
        write(listing,'##REMARK: ');
      end; {if}
    lastpos := 0;
    freepos := 1;
  end; {startnewline}

begin
  {pre erridx > 0}
  {pre: at end of current listing line}
  startnewline;
  with errorrecord do
    begin
      for i := 1 to erridx do
        with errlist[i] do
          begin
            if pos = lastpos then
              begin {error at same symbol}
                if list then
                  write(listing, ',');
              end
            else {error at new symbol}
              begin
                if freepos > pos then {no more room} startnewline;

                {post: freepos <= pos}
                if freepos < pos then
                  begin {adjust position : move to the right}
                    if list then
                      write(listing, ' ':(pos-freepos));
                    freepos := pos;
                  end; {if}

                {output start of error indicator:}
                if errnum = 0 then
                  begin {special case: skip symbol action of compiler}
                    { "underline" last symbol with "*" }
                    if list then
                      write(listing, '*');
                  end
                else {real error/warning}
                  begin
                    if list then
                      write(listing, '^');
                  end;
                lastpos := pos;
              end; {if}

            {output error number:}
            if errnum = 0 then width := 0
            else
              begin
                if errnum < 10 then width := 1
                else
                  if errnum < 100 then width := 2
                  else width := 3;
                if list then
                  write(listing, errnum:width);
              end; {if}

            {adjust freepos:}
            freepos := freepos + width + 1 {because of "," or "^"};
          end; {with-for}
      {free errorrecord:}
      erridx := 0;
    end; {with}

  if list then
    writeln(listing);
  erroroccurred := false;
end; {listerrors}

procedure initError;
var i : cardinal;
begin
  {writeln(stderr, 'initError');}
  for i := 0 to maxerrnr do errorsummary[i] := false;
  erroroccurred         := false;
  errorrecord.erridx    := 0;
  totalerrors           := 0;
  totalwarnings         := 0;
end; {initError}
