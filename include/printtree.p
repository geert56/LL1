procedure printList (aset : setref);
{ Writes out a set like:
  elem1, elem2, elem3
}
begin
  if aset <> nil then begin
    with aset^ do begin
      {first elem:}
      printsymbol (output, tokenkind[contents], contents);
      aset := nextelem;
    end; {with}

    {rest of elems:}
    while aset <> nil do
      with aset^ do begin
	write (output, ', ');
	printsymbol (output, tokenkind[contents], contents);
	aset := nextelem;
      end; {with-while}
    write (output, ' ');
  end; {if}
end; {printList}

procedure printSet (aset : setref);
begin
  write (output, '[ ');
  printList (aset);
  write (output, ']');
end; {printSet}

procedure writeKind (p : nodeptr);
begin
  with p^ do
    case kind of
      grammarkind :
        write (output, '<$> ');
      rulekind :
        write (output, '<:> ');
      termornonterm :
        ;
      epsilon :
        write (output, '<> ');
      zeroormore :
        write (output, '<*> ');
      oneormore :
        write (output, '<+> ');
      condoneormore :
        write (output, '</> ');
      optional :
        write (output, '<?> ');
      factorsequence :
        write (output, '<.> ');
      alternative :
        write (output, '<|> ');
      illegal :
        write (output, '@ ');
    end; {case-with}
end; {writeKind}

procedure printtree (nodep : nodeptr; indent : cardinal);
var
        p : nodeptr;

  procedure writeState (nodep : nodeptr);
  begin
    with nodep^ do begin
      write (output, '(');
      case state of
	yes       : write (output, 'y');
	no        : write (output, 'n');
	undecided : write (output, 'u');
      end; {case}
      write (output, ') ');
      if kind = termornonterm then begin
	if tokenkind[nameid] {= nonterm} then
	  if firstdet then printSet (firstset) else write (output, '?');
	{else no action for terminal}
      end
      else
	if firstdet then printSet (firstset) else write (output, '?');
    end; {with}
  end; {writeState}

begin {printtree}
  if nodep <> nil then
    with nodep^ do begin
      if indent > 0 then
        write (output, ' ' : indent);
      writeKind (nodep);

      case kind of

	grammarkind :
	  begin
	    writeState (nodep);
	    writeln (output);
	    p := altp;
	    while p <> nil do begin
              writeln (output);
	      printtree (p, indent + 3);
	      p := p^.succp;
	    end; {while}
	  end;

	rulekind :
	  begin
	    printsymbol (output, nonterm, nameid);
	    write (output, ' ');
	    writeState (nodep);
write (output, ' ');
printSet (tokeninfo[nameid].followset);

	    writeln (output);
	    printtree (altp, indent + 3);
	  end;

	termornonterm :
	  begin
	    printsymbol (output, tokenkind[nameid], nameid);
	    write (output, ' ');
	    writeState (nodep);
	    writeln (output);
	  end;

	illegal,
	epsilon :
	  begin
	    writeState (nodep);
	    writeln (output);
	  end;

	optional,
	oneormore,
	zeroormore,
	condoneormore,
	alternative,
	factorsequence :
	  begin
	    writeState (nodep);
	    writeln (output);
	    p := altp;
	    repeat
	      printtree (p, indent + 3);
	      p := p^.succp;
	    until p = nil;
	  end;

      end; {case}
    end; {with-if}
end; {printtree}
