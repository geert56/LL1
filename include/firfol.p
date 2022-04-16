procedure firstfollowcheck (grammar : nodeptr);
{ pre: grammar^.kind = grammarkind;
}
var
        intersect : setref;

  procedure checksets (p : nodeptr);
  var
          follow : setref;
  begin
    detfollow (p, follow);
    setIntersect (p^.firstset, follow, intersect);
    if intersect <> nil then {LL(1) conflict}
      reportLL1conflict (FollowErr, p, intersect);
    disposeSet (intersect);
    disposeSet (follow);
  end; {checksets}

  procedure traverse (p : nodeptr);
  label 111;
  var
          tempp : nodeptr;
  begin
  111: {restart, in order to resolve tail-recursion in some cases}
  
    {assert: p <> nil}
    with p^ do
      case kind of

        illegal,
        epsilon,
        termornonterm : ;

        rulekind :
          begin
            if state = yes then begin
              setIntersect ({p^.}firstset, tokeninfo[nameid].followset,
                             intersect);
              if intersect <> nil then {LL(1) conflict}
                reportLL1conflict (FollowErr, p, intersect);
              disposeSet (intersect);
            end; {if}
            {traverse (altp);}
	    p := altp;
	    goto 111;
          end; {if}

        grammarkind :
          if altp <> nil then begin
            tempp := altp;
            repeat
              traverse (tempp);
              tempp := tempp^.succp;
            until tempp = nil;
          end; {if}

        oneormore,
        zeroormore,
        optional :
          begin
            checksets (p);
            {traverse (altp);}
	    p := altp;
	    goto 111;
          end;

        condoneormore :
          begin
            {traverse (altp);}
	    p := altp;
	    goto 111;
          end;

        alternative,
        factorsequence :
          begin
            if state = yes then
              checksets (p);
            tempp := altp;
            repeat
              traverse (tempp);
              tempp := tempp^.succp;
            until tempp = nil;
          end;

      end; {case-with}
  end; {traverse}

begin
  {each rhs node is visited at most once}
  traverse (grammar);
end; {firstfollowcheck}
