procedure getch;
{ read next character in global variable ch;
  features:
  - autonomously generates listing and error messages,
  - no bound on input line length,
  - when eoln(input) the symbolic character EOLINE is returned,
  - when eof(input)  the symbolic character EOFINE is returned (repeatedly),
  - invariant: EOFILE or EOLINE returned implies atendofline = true
  - discard all illegal characters as specified by the set
    'illegalchars' (no trouble when EOLINE and/or EOFILE are included),
  - efficiency: average of 3 if-tests, 2 assignments, 1 read and 1 write
    operation per character read.
}
{ possible errors reported:
       2. illegal character; discarded
}
label 111, {exit when eof(input)}
      222; {entry when illegal char detected}
begin
  { Assumes no eof condition before eoln possible, except when source file
    is empty which case is correctly handled because atendofline is true
    initially!
  }

  if atendofline then begin
    { Remember:
      last character read and returned was symbolic EOLINE char,
      however not yet 'writeln'-ed to the listing,
      so we are at the end of the current listing line.
    }
    if eof (input) then begin
      {NOTE: only 1 test for eof per source line}
      {return special EOFILE character}
      {leave charcount at end-of-line position,
       also stay in atendofline state.
      }
      ch := EOFILE;
      {any errors on the last line will be output by finalScanner}
      goto 111;
    end; {if}

    { Deal with any errors occurred in last sourceline: }
    if erroroccurred then
      listerrors
    else
    if list then {now echo end-of-line to listing:}
      writeln (listing);

    { Prepare for next listing line: }
    charcount := 0;
    linecount := linecount + 1;
    if list then begin
      pageupdate;
      write (listing, linecount : 9, ' ');
    end; {if}
  end; {if}

222: {entry when illegal char detected}

  { Read a new character: }
  charcount := charcount + 1;
  if eoln (input) then begin
    {return symbolic EOLINE char}
    readln (input);
    ch := EOLINE;
    atendofline := true;
    {NOTE: not yet written to listing}
  end
  else begin {next char is not EOLINE}
    atendofline := false;
    read (input, ch);
    if ch in illegalchars then begin
      {echo ? to listing:}
      if list then write (listing, '?');
      error (2);
      {discard:}
      goto 222;
    end; {if}

    if list then
      {echo to listing:}
      write (listing, ch);
  end; {if}

111: {eof (input) exit}
end; {getch}
