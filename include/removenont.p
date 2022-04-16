procedure removenonterminating (grammar : nodeptr);
{pre: grammar^.kind = grammarkind;
      all rhs non-terminals have a corresponding rule;
      states of all rhs non-terminal nodes are undecided;
      inaccessible rules removed;
}
{NOTE: all rules with determined state (either yes or no) are
       terminating, i.e. they can generate a sentence of the language
       being defined by the grammar.
       Filling in decided states on the right-hand side might generate
       new determined left-hand sides.
       When no new determined states can be generated (or all rules are
       undecided from the start) then the undecided rules
       that remain can be considered useless because they are not terminating.
       All such rules and their rhs occurrences of the
       associated non-terminal should be removed. Removing right-hand sides
       does not cause any new state changes.

 possible algorithm:

       while there are decided non-terms: not empty decided-set do
         begin
           choose one, say N;
           remove from decided-set;
           pass state of N to all rhs occurrences;
           include all non-terms of rules that become decided in decided-set;
         end;

       for each N that is undecided do
         begin
           remove all right-hand side occurrences;
           remove its rule;
         end;

       in fact for-loop is replaced by warning message and
       program is aborted.
}
var
        rulep : nodeptr;
        fatalerror : boolean;
        needheader : boolean;

  procedure processrule (rulep : nodeptr);
  { resolve all undecided occurrences of associated non-terminal;
    call itself recursively when "passdecision" causes a new
    rule to be determined.
  }
  {pre:  (rulep^.state <> undecided) and not rulep^.visited }
  var
        rhsp,
        newrulep : nodeptr;
  begin
    with rulep^ do begin
      {set visited:}
      visited := true;
      {visit each rhs occurrence}
      rhsp := tokeninfo[{rulep^.}nameid].lastrhsoccur; {perhaps nil}
      while rhsp <> nil do
	with rhsp^ do begin
	  {note: rhsp^.state = undecided, initially for all rhs occurs}
	  {rhsp^.}state := rulep^.state;
	  {now rhs occur. is decided}
	  newrulep := nil;
	  passdecision ({rhsp^.}state, rhsp, newrulep);
	  {if rule becomes decided ==> not yet visited then
	     recursively go on with that rule
	  }
	  if newrulep <> nil then
	    processrule (newrulep);
	  rhsp := {rhsp^.}nextrhsoccur;
	end; {with rhsp^-while}
    end; {with rulep^}
  end; {processrule}

begin {removenonterminating}
  {visit each rule:}
  rulep := grammar^.altp; {perhaps nil ==> no rules}

  while rulep <> nil do
    with rulep^ do begin
      if ({rulep^.}state <> undecided) and not {rulep^.}visited then
        {decided: yes or no}
        processrule (rulep);
      {else skip this rule}
      rulep := {rulep^.}succp;
    end; {with rulep^-while}

  {post: all rules visited once, undecided non-terms resolved as much
         as possible
  }

  needheader := true;
  fatalerror := false;

  {visit each rule again:}
  rulep := grammar^.altp; {perhaps nil ==> no rules}
  while rulep <> nil do
    with rulep^ do begin
      if ({rulep^.}state = undecided) then begin

        if needheader then begin
  writeln (output,
  '(*   -- The following non-terminals are non-terminating: --');
{
  writeln (output,
  '        (their corresponding rules and occurrences are removed)');
}
  writeln (output);
          needheader := false;
        end; {if}

        write (output, ' ' : 5);
	printsymbol (output, nonterm, {rulep^.}nameid);
	writeln (output);

	{remove all rhs occurrences (perhaps also in rule to be removed):}

	{remove the rule:}

	fatalerror := true;
      end; {if}
      {else skip this rule}
      rulep := {rulep^.}succp;
    end; {with rulep^-while}

  if fatalerror then begin
    writeln (output);
    writeln (output,
'     LL(1) check aborted; please reconsider your input grammar');
    writeln (output, '*)');

    writeln (output);
    writeln (output,
  '(*   -- The ameliorated grammar tree: --');
    writeln (output);
    printtree (grammar, 0 {indent});
    writeln (output, '*)');

    abortProgram;
  end; {if}

  if not needheader then writeln (output, '*)');
end; {removenonterminating}
