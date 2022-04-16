function copynode (node : nodeptr) : nodeptr;
{ Returns a copy of `node'. }
var
      p : nodeptr;

begin {copynode}
  {**************  IMPORTANT NOTICE: cannot use
     p  := newnode (node^.kind);
     p^ := node^;

  Something goes wrong doing the record copy.
  Probably this is implementation dependent.
  Guess that the compiler generates a MOVEBYTES instruction
  for the statement with the number of bytes fixed.
  However 'p^' can be smaller than the largest case variant.
  Better reconsider the use of variant records!!!
  }
  with node^ do begin
    case kind of
      epsilon :
	begin
	  new (p{, epsilon});
	  p^.kind := epsilon;
	end;

      termornonterm :
	begin
	  new (p{, termornonterm});
	  p^.kind         := termornonterm;
          p^.nextrhsoccur := nextrhsoccur;
          p^.nameid       := nameid;
	end;

      rulekind :
	begin
	  new (p{, rulekind});
	  p^.kind    := rulekind;
          p^.dum1       := dum1;
          p^.dum2       := dum2;
          p^.linenr  := linenr;
          p^.visited := visited;
	end;

      grammarkind,
      zeroormore,
      oneormore,
      condoneormore,
      optional,
      factorsequence,
      alternative,
      illegal :
	begin
	  new (p{, alternative});
	  p^.kind := kind;
          p^.altp := altp;
	end;
    end; {case}

    p^.state    := state;
    p^.firstdet := firstdet;
    p^.firstset := firstset;
    p^.backlink := backlink;
    p^.succp    := succp;
  end; {with}

  copynode := p;
end; {copynode}
