unit ll1_unit;
interface
uses lex_unit, set_unit, names_unit;

procedure processgrammar(grammar : nodeptr);

implementation

{$GOTO ON}

procedure abortProgram;
begin
  finalLex;
  writeln (stderr, 'LL(1) Program deliberately aborted.');
  { goto 9999; does not work on Apollo! }
  Halt;
end; {abortProgram}

{$I 'disposetree.h'}
{$I 'findrule.h'}
{$I 'removerule.h'}
{$I 'copynode.h'}
{$I 'printexcerpt.h'}
{$I 'printconstruct.h'}
{$I 'printtree.h'}
{$I 'report.h'}
{$I 'passdecision.h'}

procedure writestatistics;
begin
  writeln (output,
'(*   -- Some statistics about the input grammar: --'
         );
  writeln (output);
  writeln (output, '     number of terminals       : ', nrterminals);
  writeln (output, '     number of nonterminals    : ', nrnonterminals);
  writeln (output, '     number of productionrules : ', nrproductions);
  writeln (output, '*)');
  writeln (output);
end; {writestatistics}

procedure checkgrammar (grammar : nodeptr);
{pre: grammar^.kind = grammarkind}
var     i       : tokenidrange;
        dummyp,
        p       : nodeptr;
        needheader : boolean;

{$I 'removeinacc.h'}
{$I 'removenont.h'}

begin {checkgrammar}
  {change all non-terminals not appearing on left-hand side of production rule
   to terminals.
   Note: can not use info in tokeninfo[i].lhsoccur because not always defined.
  }

  needheader := true;

  for i := 1 to nrtokens do
    if tokenkind[i] {= nonterm} then
      if not lhsnonterm[i] then begin {just rhs occurrences}

	if needheader then begin
writeln (output,
'(*   -- The following non-terminal symbols will be treated as terminals: --'
       );
writeln (output);
	  needheader := false;
	end; {if}

	{write symbol:}
	write (output, ' ' : 5);
	printsymbol (output, nonterm, i);
	writeln (output);

	tokenkind[i] := terminal;
	{update counts:}
	nrterminals    := nrterminals    + 1;
	nrnonterminals := nrnonterminals - 1;

	{update state fields, tree upwards for all rhs occurrences:}
	p := tokeninfo[i].lastrhsoccur;
	repeat
	  with p^ do begin
	    state := no;
	    passdecision (no, p, dummyp);
	    p := nextrhsoccur;
	  end; {with}
	until p = nil;
      end; {if-if-for}

  if not needheader then
    writeln (output, '*)');

        {post:  for tokenkind[i] = nonterm,

                not necessarily:
                lhsnonterm[i] ==> tokeninfo[i].lastrhsoccur <> nil

                but always:
                tokeninfo[i].lastrhsoccur <> nil ==> lhsnonterm[i]
        }

  {find/list/remove useless productions:}
  removeinaccessibles (grammar);
  removenonterminating (grammar);
  {post: grammar consist of useful productions only,
         all node states determined
  }
end; {checkgrammar}

{$I 'initfirstdet.h'}
{$I 'passfirstup.h'}
{$I 'checkleftrec.h'}
{$I 'rightwalk.h'}
{$I 'initfollowdet.h'}
{$I 'detfollow.h'}
{$I 'firfol.h'}

procedure resetvisited (grammar : nodeptr);
{pre: grammar^.kind = grammarkind}
var
        tempp   : nodeptr;
begin
  with grammar^ do begin
    tempp := altp;
    while tempp <> nil do
      with tempp^ do begin
        visited := false;
        tempp := succp;
      end; {with-while}
  end; {with}
end; {resetvisited}

{ %INCLUDE 'genparser.h' }

procedure processgrammar (grammar : nodeptr);
begin
  checkgrammar (grammar);
  {      nrnonterminals = nrproductions
  }
  writestatistics;

  writeln (output);
  writeln (output,
'(*   -- The grammar as it is processed is: --');
  writeln (output);
  printconstruct (grammar);
  writeln (output, '*)');

  writeln (output);
  writeln (output,
'(*   -- The internal name table is: --');
  printnametable;
  writeln (output, '*)');

  initfirstdet (grammar);
  resetvisited (grammar);
  checkleftrecursion (grammar); {also determines all first sets}
  initfollowdet (grammar);
  firstfollowcheck (grammar);

  writeln (output);
  writeln (output,
'(*   -- The ameliorated grammar tree: --');
  writeln (output);
  printtree (grammar, 0 {indent});
  writeln (output, '*)');
{
  genparser (grammar);
}
{ disposetree (grammar); last thing ever done, let OS do it! }
end; {processgrammar}

end.
