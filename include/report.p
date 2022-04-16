procedure reportLL1conflict (reason : LL1Errs;
                             cause  : nodeptr;
                             symset : setref
                            );
{pre: not node^.kind in [grammarkind, rulekind]}
{ example: (note: starts at fresh line)

  LL(1) confict detected,
  reason  2   : non-disjunct first sets      (verbal description)
[ terminal(s) : [ 'ident' ]     ]
  caused by   :                 (cause)
  in context  :                 (backlink)
  in rule for : N               (printsymbol)
  at line     : 12              (linenr)
}
var
        rulep : nodeptr;
begin
writeln (output);

if reason <> NoErr then

writeln (output, 'LL(1) conflict detected,');
write   (output, 'reason ', ord (reason):4, ' : ');

 case reason of
    NoErr       :
writeln (output);
    EpsErr      :
writeln (output, 'more than 1 way of generating the empty string');
    FirstErr    :
      begin
writeln (output, 'first sets collide (must be disjunct)');
write   (output, 'terminal(s) : '); printList (symset);
writeln (output);
      end;
    FirstErr2   :
      begin
writeln (output, 'first set collides with that of (empty) predecessor');
write   (output, 'terminal(s) : '); printList (symset);
writeln (output);
      end;
    FollowErr   :
      begin
writeln (output, 'first set collides with follow set');
write   (output, 'terminal(s) : '); printList (symset);
writeln (output);
      end;
{
    4 direct left-recursion
    5 indirect left-recursion
}
  end; {case}

write (output, 'caused by   : ');
  {write construct that CAUSES the confict (not the one where it is detected!)}
  printexcerpt (cause, 2, 1);
  writeln (output);

  {be sure that cause construct appears in context:}
write (output, 'in context  : ');
  printcontext (cause, 2 {= level});
  writeln (output);

  rulep := findrulenode (cause);
  with rulep^ do begin
write (output, 'in rule for : ');
    printsymbol (output, nonterm, nameid);
    writeln (output);
write (output, 'at line     : ');
    writeln (output, linenr:1);
  end; {with}
end; {reportLL1conflict}
