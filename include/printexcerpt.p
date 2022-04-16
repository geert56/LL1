procedure printexcerpt (p : nodeptr; maxlevel, maxitems : cardinal);
{ Partially prints a syntax construct;
  nested constructs are printed up to a level of maxlevel, any
  deeper nesting is replaced by a single ellipsis ( ".." ).
  constructs that have many factors or terms at one level are abbreviated
  to "maxitems" number of factors c.q. terms, again the rest is replaced
  by "..".
  when maxlevel = 0 only '.. ' is printed.
  when maxitems = 0 no factorsequences and alternatives are printed.
  Does not issue a newline (writeln) except for a rule kind of node.
  To get everything printed use: printconstruct.
}
var
        indent,
        currnritems : cardinal;
        tempp       : nodeptr;
begin
  if maxlevel = 0 then
    write (output, '.. ')
  else
    with p^ do
      case kind of

	grammarkind :
	  begin
	    tempp := altp;
            { the rules: }
	    while tempp <> nil do begin
	      printexcerpt (tempp, maxlevel, maxitems);
              {leave 1 blank line between rules:}
	      writeln (output);
	      writeln (output);
	      tempp := tempp^.succp;
            end; {while}
	  end;

	rulekind :
	  begin
            {lhs:}
            {get length of lhs nonterminal name:}
{
  lhsname ::= ...
           |
 01234567890123
}
            {indent indicates #spaces to insert to
	       get to middle of "::=" symbol}
            indent := tokeninfo[{}nameid].nametabidx {>0} + 2;
            printsymbol (output, nonterm, {p^.}nameid);
            write (output, ' ::= ');

            {rhs:}
            if altp^.kind = alternative then begin {>=2 terms}
  	      tempp := altp^.altp; {go to first term}
              printexcerpt (tempp, maxlevel, maxitems);

              tempp := tempp^.succp; {consider 2-nd term}
              repeat
	        writeln (output);
	        write (output, ' ':indent);
                {              ::=    }
	        write (output, '|  ');
	        printexcerpt (tempp, maxlevel, maxitems); {next term}
	        tempp := tempp^.succp;
              until tempp = nil;
              writeln (output);
              write (output, ' ':indent);
            end
	    else
	      printexcerpt ({p^.}altp, maxlevel, maxitems);

            {the end:}
            write (output, '.');
	  end; {rulekind}

	termornonterm :
	  begin
	    printsymbol (output, tokenkind[nameid], nameid);
	    write (output, ' ');
	  end;

	epsilon :
          write (output, '<> ');

	illegal :
	  write (output, '@ ');

	oneormore,
	zeroormore :
	  begin
	    write (output, '{ ');
	    printexcerpt (altp, maxlevel-1, maxitems);
	    write (output, '}');
	    if kind = zeroormore then
	      write (output, ' ')
	    else
	      write (output, '+ ');
	  end;

	condoneormore :
	  begin
	    write (output, '{ ');
	    printexcerpt (altp, maxlevel-1, maxitems);
	    write (output, '/ ');
	    printexcerpt (altp^.succp, maxlevel-1, maxitems);
	    write (output, '}');
	    if backlink^.kind = optional then
	      write (output, '* ')
	    else
	      write (output, '+ ');
	  end;

	optional :
	  begin
	    if altp^.kind <> condoneormore then begin
	      write (output, '[ ');
	      printexcerpt (altp, maxlevel-1, maxitems);
	      write (output, '] ');
	    end
	    else {altp^.kind = condoneormore, see there}
              {optionality will be reflected by adding a '*' }
	      printexcerpt (altp, maxlevel-1, maxitems);
	  end;

	factorsequence :
	  begin
	    currnritems := maxitems;
	    tempp := altp;
	    repeat
	      if currnritems = 0 then begin
                write (output, '.. ');
                tempp := nil;
	      end
	      else begin
		printexcerpt (tempp, maxlevel, maxitems);
		currnritems := currnritems - 1;
		tempp := tempp^.succp;
              end; {if}
	    until tempp = nil;
	  end;

	alternative :
	  begin
	    currnritems := maxitems;
	    if backlink^.kind = factorsequence then
              {obey precedence of operators}
	      write (output, '( ');

	    if currnritems = 0 then
	      write (output, '.. ')
	    else begin
	      printexcerpt (altp, maxlevel, maxitems);
	      currnritems := currnritems - 1;
	      tempp := altp^.succp;
	      repeat
		write (output, '| ');
		if currnritems = 0 then begin
		  write (output, '.. ');
		  tempp := nil;
		end
		else begin
		  printexcerpt (tempp, maxlevel, maxitems);
		  currnritems := currnritems - 1;
		  tempp := tempp^.succp;
		end; {if}
	      until tempp = nil;
	    end; {if}

	    if backlink^.kind = factorsequence then {close}
	      write (output, ') ');
	  end;

      end; {case-with}
end; {printexcerpt}

procedure printcontext (nodep : nodeptr; maxlevel : cardinal);
{ Visits 'father' of nodep and if kind is factorsequence or alternative
  then searches for 'son' node preceding nodep, or first ('eldest') son is
  nodep. Duplicates father node and lets its altp point to the son,
  thus enabling the use of the printexcerpt routine.
}
var
        context : nodeptr;
begin
  {assert: nodep^.backlink <> nil}
  context := copynode (nodep^.backlink);
  with context^ do begin
    {assert: not kind in [termornonterm, illegal, epsilon]}

    if kind in [factorsequence, alternative] then begin
      {2 or more sons ==> altp^.succp <> nil}
      if altp <> nodep then begin {nodep is not first son}
	write (output, '.. ');

	{look for preceding 'brother':}
	{assert: altp^.succp <> nil}
	while altp^.succp <> nodep do
	  {succp <> nil and <> nodep ==> succp^.succp <> nil}
	  altp := altp^.succp {post: altp^.succp <> nil};
	{loop terminates because nodep is son of father}
	{post: the correct (left) brother (= altp) found}
        {print left context + nodep + right context (3 items)}
	printexcerpt (context, maxlevel, 3);
      end
      else {nodep is first son}
	printexcerpt (context, maxlevel, 2);
    end
    else {context okay}
      printexcerpt (context, maxlevel, 2);
  end; {with}

  disposenode (context);
end; {printcontext}
