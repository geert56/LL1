procedure pageheading;
begin
  {layout:
<empty-line>
<name of compiler> <version>     [<source-file-name>]   <date-time>      <page>
<empty-line>
<empty-line>

e.g.
PL/HDL version 0.1 (12 july 1984)                                        page 1

  }
  pagecount := pagecount + 1;
  writeln(listing);
{*}
  writeln(listing,
'SBNF Parser/LL(1) Verifier      version 1.0 (April 11, 2022)            page'
  ,pagecount:4);
  {outputting source file pathname NOT YET IMPLEMENTED !}
  writeln(listing);
  writeln(listing);
  pagelinecount := 4;
end; {pageheading}

procedure pageupdate;
begin
  if pagecount = 0 then {first page}
    pageheading
  else
    if pagelinecount < linesperpage then
      pagelinecount := pagelinecount + 1
    else
      begin
        {FIXME page(listing); output ^L}
        write(listing, #12);
        pageheading;
      end;
end; {pageupdate}

procedure initList;
begin
     writeln(erroutput, 'initList');
{*  open(listing, 'LISTING', 'UNKNOWN');}
     {FIXME rewrite(listing, 'listing');}

     assign(listing, 'listing');
     rewrite(listing);

     charcount   := 1;   {needed in case of empty source file}
     linecount   := 0;

     pagecount   := 0;
{*}  list        := true;
     if list then pageupdate;
end; {initList}
