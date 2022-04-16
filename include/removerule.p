procedure removeRule (p : nodeptr);
{pre: p^.kind = rulekind;
 note: rulekind node itself is not yet disposed of !
}
begin
  with p^ do begin
    {remove expression sub-tree:}
    disposeTree (altp);

    {update rulekind nodes links:}
    with {p^.}backlink^ do
      if {p^.backlink^.}kind = grammarkind then {first rule:}
	{p^.backlink^.}altp := p^.succp {perhaps nil}
      else {not first rule, perhaps last rule}
	{p^.backlink^.}succp := p^.succp; {perhaps nil}

    if {p^.}succp <> nil then {not last rule}
      {set up correct backlink:}
      {p^.}succp^.backlink := {p^.}backlink;
  end; {with p}

  nrproductions  := nrproductions  - 1;
  nrnonterminals := nrnonterminals - 1;
end; {removeRule}
