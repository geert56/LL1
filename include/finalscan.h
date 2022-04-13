procedure finalScanner;

{*}  procedure writemessages(start, endm : cardinal);
  var
        i       : 1..maxerrnr;
        errstr  : packed array[1..60] of char;
  begin
    for i := start to endm do
      if errorsummary[i] then
        begin

case i of

{ LEXICAL ERRORS }

{  0 : errstr := 'this symbol is skipped';}
                {123456789012345678901234567890123456789012345678901234567890}
  1 : errstr := 'unexpected end-of-file; program aborted';
  2 : errstr := 'illegal character; discarded';
  3 : errstr := 'illegal symbol; discarded';
  4 : errstr := 'too many errors detected on this source line';

  5 : errstr := 'literal constant must not extend passed end-of-line';
  6 : errstr := 'replacement symbol expected; inserted';

{ SYNTACTIC ERRORS }

 10 : errstr := '"+" or "*" expected; "+" assumed';
 11 : errstr := '"<" expected; inserted';
 12 : errstr := 'error in primary';
 13 : errstr := 'replacement symbol expected; inserted';
 14 : errstr := '">" expected; inserted';
 15 : errstr := 'identifier expected';
 16 : errstr := '")" expected; inserted';
 17 : errstr := '"]" expected; inserted';
 18 : errstr := '"}"  expected; inserted';
 19 : errstr := 'rule terminator expected; inserted';
 20 : errstr := 'atomic symbol expected';
 21 : errstr := 'non-terminal symbol expected';
 22 : errstr := 'identifier or reserved word expected';
                
{ IMPLEMENTATION DEFINED ERRORS }

{ WARNINGS }
                {123456789012345678901234567890123456789012345678901234567890}
200 : errstr := 'too many non-terminal symbols';
201 : errstr := 'too many terminal symbols';
202 : errstr := 'LL(1) conflict : more than 1 empty term';
203 : errstr := 'LL(1) conflict : expr. in optional construct may be empty';
204 : errstr := 'LL(1) conflict : E in "{ E \ A }*" construct may be empty';
205 : errstr := 'LL(1) conflict : E in "{ E \ A }"  construct may be empty';
206 : errstr := 'LL(1) conflict : Primary in "Primary *" may be empty';
207 : errstr := 'LL(1) conflict : Primary in "Primary ?" may be empty';
208 : errstr := 'LL(1) conflict : E in "{ E }*" construct may be empty';
209 : errstr := 'LL(1) conflict : E in "{ E }" construct may be empty';

end; {case}

          if list then
            begin
              pageupdate;
              writeln(listing, i:9,' : ', errstr);
            end;
        end; {if-for}
  end; {writemessages}

begin
  if erroroccurred then listerrors;

  if list then
    begin {2 blank lines:}
      pageupdate;
      writeln(listing);
      pageupdate;
      writeln(listing);
    end;

  if (totalerrors = 0) and (totalwarnings = 0) then
    begin
      if list then
        begin
          pageupdate;
          writeln(listing, 'No (compilation) errors detected');
        end;
{      writeln(errout, 'No (compilation) errors detected');}
    end
  else {some errors or warnings}
    begin
      if totalerrors > 0 then
        begin
          if list then
            begin
              pageupdate;
              writeln(listing, '* * * * * Error Summary * * * * *');
              pageupdate;
              writeln(listing);
              pageupdate;
              writeln(listing,
'Number of errors in this compilation:', totalerrors:5);
            end;
{         writeln(errout,
'Number of errors in this compilation:', totalerrors:5);}

          if errorsummary[0] then
            begin
              if list then
                begin
                  pageupdate;     {1234567890}
                  writeln(listing, '        * : this symbol is skipped');
                end;
            end;
          writemessages(1, startwarnings-1);
          if list then
            begin
              pageupdate;
              writeln(listing);
            end;
        end; {if}

      if totalwarnings > 0 then
        begin
          if list then
            begin
              pageupdate;
              writeln(listing, '* * * * * Warning Summary * * * *');
              pageupdate;
              writeln(listing);
              pageupdate;
              writeln(listing,'Number of warning(s) issued :',totalwarnings:5);
            end;
{          writeln(errout, 'Number of warning(s) issued :',totalwarnings:5);}
          writemessages(startwarnings, maxerrnr);
          if list then
            begin
              pageupdate;
              writeln(listing);
            end;
        end; {if}
    end; {if}
  if list then
    begin
      pageupdate;
      writeln(listing, 'Number of lines processed   :', linecount:5);
    end;
{  writeln(errout, 'Number of lines processed   :', linecount:5);}
end; {finalScanner}
