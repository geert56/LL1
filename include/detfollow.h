procedure detfollow (nodep : nodeptr; var follow : setref);
{ Determines follow set of construct pointed to by nodep. }
var dependsonrule : tokenidrange;
begin {detfollow}
  follow := nil;
  if rightwalk (nodep, follow, dependsonrule) then
    {add follow(lhs):}
    setUnion2 (tokeninfo[dependsonrule].followset, follow);
end; {detfollow}
