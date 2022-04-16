procedure checkleftrecursion (grammar : nodeptr);
{ Finishes first set calculation and
  detects the left-recursive non-terminals
}
{pre: grammar^.kind = grammarkind;
}
var
        rulep      : nodeptr;
        fatalerror : boolean;
        needheader : boolean;

  procedure processrule (rulep : nodeptr);
  { Resolves all undecided occurrences of associated non-terminal;
    calls itself recursively when "passfirstup" causes a new
    rule to be determined.
  }
  {pre:  (rulep^.firstdet = true) and not rulep^.visited }
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
	  {note: rhsp^.firstdet = false, because non-terminal}
	  {rhsp^.}firstdet := true; {so now equal to rulep^.firstdet}
	  {inherit reference to first set:}
	  {rhsp^.}firstset := rulep^.firstset;
	  newrulep := nil;
	  {assert: backlink <> nil}
	  passfirstup (rhsp, newrulep);
	  {if rule becomes decided ==> not yet visited then
	     recursively go on with that rule
	  }
	  if newrulep <> nil then
	    processrule (newrulep);
	  rhsp := {rhsp^.}nextrhsoccur;
	end; {with rhsp^-while}
      end; {with rulep^}
  end; {processrule}

begin {checkleftrecursion}
  { Visit each rule: }
  rulep := grammar^.altp; {perhaps nil ==> no rules}
  while rulep <> nil do
    with rulep^ do begin
      if {rulep^.}firstdet and not {rulep^.}visited then
        processrule (rulep);
      {else skip this rule}
      rulep := {rulep^.}succp;
    end; {with rulep^-while}
  {post: all rules visited once, undecided firstdet's resolved as much
         as possible
  }

  needheader := true;
  fatalerror := false;

  { Visit each rule again: }
  rulep := grammar^.altp; {perhaps nil ==> no rules}
  while rulep <> nil do
    with rulep^ do begin
      if not {rulep^.}firstdet then begin

        if needheader then begin
  writeln (output,
  '(*   -- The following non-terminals are left-recursive: --');
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

  if not needheader then
    writeln (output, '*)');

  {post: all nodes have firstdet = true}
end; {checkleftrecursion}
