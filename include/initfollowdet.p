procedure initfollowdet (grammar : nodeptr);
{
 determines the follow sets of all non-terminals;
 these sets are recorded in tokeninfo.
}
{pre: grammar^.kind = grammarkind;
}
var
        reachedby,
        reach     : array[tokenidrange] of setref;
        {interpretation:
           reach    [j] = all nodes that reach node j,
           reachedby[j] = all nodes that are reached by j.
        }

  procedure rightclosure (firstrulep : nodeptr);
  { Determine transitive closure of right sets: }
  { Warshall algorithm  (on Boolean matrix) :

      for j := 1 to n do (columns)
        for i := 1 to n do (rows)
          if i <> j then (not diagonal)
            if M[i,j] then (rows conjunction)
              for k := 1 to n do
                M[i,k] := M[i,k] or M[j,k];

      post: M is now transitive closure of original
  }
  var
        j : nodeptr;
        i,
        k : setref;
  begin
{
writeln (output, 'enter: RIGHT CLOSURE');
}
    {**********************************************}
    {* NOTE: depends on the sets being ordered!!! *}
    {**********************************************}

    j := firstrulep;
    repeat
      with j^ do begin
{
printsymbol (output, nonterm, nameid);
write (output, ' from ');
printSet (reach  [nameid]);
write (output, ' to ');
printSet (reachedby[nameid]);
writeln (output);
}
        i := reach  [{j^.}nameid]; {all elem in i reach j}
        while i <> nil do
	  with i^ do begin
	    if {i^.}contents <> {j^.}nameid then begin {not diagonal}
	      {unite sets of nodes :}
              {"all that is reached by j can also be reached by every
                element in i"}
	      setUnion2 (reachedby[{j^.}nameid],reachedby[{i^.}contents]);

	      {also update transpose of relation:}
	      k := reachedby[{j^.}nameid];
	      while k <> nil do
	        with k^ do begin
		  includeElem2 (i^.contents, reach  [{k^.}contents]);
		  k := {k^.}nextelem;
	        end; {with-while}
{
writeln (output);
writeln (output, 'update follow set');
write (output, 'follow ');
printsymbol (output, nonterm, nameid);
write (output, ': ');
printSet (tokeninfo[nameid].followset);
writeln (output);

write (output, 'follow ');
printsymbol (output, nonterm, contents);
write (output, ': ');
printSet (tokeninfo[contents].followset);
writeln (output);

writeln (output);
}
                {update follow set of i:}
                setUnion2 (tokeninfo[{j^.}nameid].followset,
                           tokeninfo[{i^.}contents].followset);
{
writeln (output, 'new follow set');
write (output, 'follow ');
printsymbol (output, nonterm, contents);
write (output, ': ');
printSet (tokeninfo[contents].followset);
writeln (output);
}
            end; {if}
            i := {i^.}nextelem;
          end; {with i-while}
        j := {j^.}succp; {next rule}
      end; {with j}
    until j = nil;

    { Dispose of all reachedby and reach sets: }
    j := firstrulep;
    repeat
      with j^ do begin
        disposeSet (reachedby[nameid]);
        disposeSet (reach    [nameid]);
        j := {j^.}succp;
      end; {with j}
    until j = nil;
  end; {rightclosure}

  procedure initialise (firstrulep : nodeptr);
  {initialisation:}
  var
        rulep : nodeptr;

    procedure processrhsoccurs (rulep : nodeptr);
    var
          rhsp            : nodeptr;
          dependsonrule   : tokenidrange;
    begin {processrhsoccurs}
      with rulep^ do begin
	{visit each rhs occurrence}
	rhsp := tokeninfo[{rulep^.}nameid].lastrhsoccur; {perhaps nil}
	while rhsp <> nil do
	  with rhsp^ do begin
	    if rightwalk (rhsp,
			  tokeninfo[rulep^.nameid].followset,
			  dependsonrule) then
	      if dependsonrule <> {rhsp^.}nameid then begin
		includeElem2 (dependsonrule, reachedby[{rhsp^.}nameid]);
		includeElem2 ({rhsp^.}nameid, reach  [dependsonrule]); 
	      end; {if}

	    {next rhs occurrence:}
	    rhsp := {rhsp^.}nextrhsoccur;
	  end; {with rhsp^-while}
      end; {with rulep^}
      {post: relation DIRECTLY-FOLLOWS and RIGHT determined}
    end; {processrhsoccurs}

  begin {initialise}
    { Visit each rule: }
    rulep := firstrulep;
    repeat
      with rulep^ do begin
        reachedby[nameid] := nil;
        reach    [nameid] := nil;
        tokeninfo[nameid].followset := nil;
        {next rule:}
        rulep := {rulep^.}succp;
      end; {with rulep^-while}
    until rulep = nil;

    { Init follow set of first rule to special end-of-text symbol: }
    includeElem2 (ENDOFTEXT, tokeninfo[firstrulep^.nameid].followset);

    { Visit each rule: }
    rulep := firstrulep;
    repeat
      processrhsoccurs (rulep);
      {next rule:}
      rulep := rulep^.succp;
    until rulep = nil;
  end; {initialise}

begin {initfollowdet}
  with grammar^ do
    if {grammar^.}altp <> nil then begin
      initialise ({grammar^.}altp);
      rightclosure ({grammar^.}altp);
    end; {if-with}
end; {initfollowdet}
