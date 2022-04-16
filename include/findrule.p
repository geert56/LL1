function findrulenode (p : nodeptr) : nodeptr;
{ p^.kind <> grammarkind }
begin
  while p^.kind <> rulekind do
    p := p^.backlink;
  findrulenode := p;
end; {findrulenode}
