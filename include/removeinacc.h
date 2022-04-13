procedure removeinaccessibles (grammar : nodeptr);
{pre: grammar^.kind = grammarkind;
      all rhs non-terminals have a corresponding rule;
      states of all rhs non-terminal nodes are undecided;
}
var
        marked     : {packed} array[tokenidrange] of boolean; {init = false}
        i          : tokenidrange;
        needheader : boolean;
        prevp,
	rulep,
        rhsp       : nodeptr;

  procedure traverse (r : nodeptr);
  label 111;
  var
	  p : nodeptr;
  begin
  111: {restart, in order to resolve tail-recursion in some cases}

    {assert: r <> nil}
    with r^ do begin
      case kind of

	illegal,
	epsilon : ;

	termornonterm :
	  if tokenkind[nameid] {= nonterm} then
	    if not marked[nameid] then begin
	      {traverse (tokeninfo[nameid].lhsoccur);}
	      r := tokeninfo[nameid].lhsoccur;
	      goto 111;
	    end; {if}
	    {else marked ==> corresponding rule already visited}
	  {else terminal}

	rulekind :
	  begin
	    marked[nameid] := true;
	    {traverse (altp);}
	    r := altp;
	    goto 111;
	  end; {if}

	grammarkind :
	  if altp <> nil then begin
	    {traverse (altp);}
	    r := altp;
	    goto 111;
	  end; {if}

	zeroormore, oneormore,
	optional :
	  begin
	    {traverse (altp);}
	    r := altp;
	    goto 111;
	  end;

	condoneormore,
	alternative,
	factorsequence :
	  begin
	    p := altp;
	    repeat
	      traverse (p);
	      p := p^.succp;
	    until p = nil;
	  end;

      end; {case}
    end; {with}
  end; {traverse}

begin {removeinaccessibles}
  for i := 1 to nrtokens do
    if tokenkind[i] {= nonterm} then
      marked[i] := false;
    {undefined for terminals}

  {each rhs node is visited at most once}
  traverse (grammar);

  needheader := true;

  for i := 1 to nrtokens do
    if tokenkind[i] {= nonterm} then
      if not marked[i] then begin {inaccessible}

        if needheader then begin
  writeln (output,
  '(*   -- The following non-terminals are inaccessible: --');
  writeln (output,
  '        (their corresponding rules are discarded)');
  writeln (output);
          needheader := false;
        end; {if}

	write (output, ' ' : 5);
	printsymbol (output, nonterm, i);
	writeln (output);
      end; {if-if-for}

  if not needheader then writeln (output, '*)');

{Note: all rules with this inaccessible non-terminal appearing
       on their right hand side are also inaccessible}

  {for all accessible non-terminals appearing in rhs of rule to be removed
   , i.e. inaccessible, must decrement their rhs occur administration.}
  for i := 1 to nrtokens do
    if tokenkind[i] {= nonterm} then
      if marked[i] then begin {accessible}
        {update rhs occurrence list if necessary:}
        {obtain rhs occurs:}
        rhsp  := tokeninfo[i].lastrhsoccur;
        prevp := nil;
        while rhsp <> nil do
          with rhsp^ do begin
	    {if on rhs of rule to be removed then unlink but don't dispose! :}
            rulep := findRuleNode (rhsp);
	    if marked[rulep^.nameid] then {also accessible}
	      prevp := rhsp
	    else begin {found rule to be removed}
              tokeninfo[i].rhscount := tokeninfo[i].rhscount - 1;
	      if prevp = nil then
                tokeninfo[i].lastrhsoccur := {rhsp^.}nextrhsoccur
              else {bypass}
	        prevp^.nextrhsoccur := {rhsp^.}nextrhsoccur;
	    end; {if}

	    rhsp := {rhsp^.}nextrhsoccur;
          end; {with-while}
      end; {if-if-for}

  {remove the inaccessible rules:}
  for i := 1 to nrtokens do
    if tokenkind[i] {= nonterm} then
      if not marked[i] then begin {inaccessible}
	{pointer to lhs: tokeninfo[i].lhsoccur}
	with tokeninfo[i] do begin
	  removeRule (lhsoccur);
	  dispose (lhsoccur{, rulekind});
	  lhsoccur     := nil;
          lastrhsoccur := nil;
	  rhscount     := 0;
	end; {with}
      end; {if-if-for}
end; {removeinaccessibles}
