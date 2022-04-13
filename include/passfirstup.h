procedure passfirstup (fromp : nodeptr; var newrulep : nodeptr);
{pre: fromp^.firstdet changed from false to true

   (3-Feb-88: eliminated tail-recursion)
}
var
        p,
        tempp     : nodeptr;
        intersect : setref;
        stop      : boolean;
begin
  stop := false;
  repeat
    p := fromp^.backlink;
    {assert: p <> nil}
    with p^ do
      if not firstdet then
	case kind of

	  grammarkind : {not applicable}
  	    stop := true;

	  rulekind :
	    begin
	      firstdet := true; {= altp^.firstdet}
	      firstset := altp^.firstset;
	      {rule becomes decided, indicate this via newrulep}
	      newrulep := p;
	      {NOTE: special treatment for rules because of different
		     interpretation of backlink
	      }
	      {rulekind ==> backlink <> nil}
	      with backlink^ do
		if {backlink^.}kind = grammarkind then {first rule}
		  {backlink^.}firstdet := true;
		{else no action for other rules than first}
	      stop := true;
	    end;

	  optional,
	  zeroormore,
	  oneormore :
	    begin
	      firstdet := true; {= altp^.firstdet}
	      firstset := altp^.firstset;
	      {passfirstup (p, newrulep);}
	      fromp := p;
	    end;

	  termornonterm,
	  epsilon,
	  illegal :
	    {not applicable}
	    stop := true;

	  condoneormore :  { </ E A > }
	    begin
	      firstdet := altp^.firstdet;

	      if altp^.state = yes then {null(E)}
		if firstdet then
		  firstdet := altp^.succp^.firstdet;

	      if firstdet then begin
		firstset := altp^.firstset; {inherit ref. to firsts of E}
		if altp^.state = yes then begin {null(E)}
		  {create new set and united with first A}
		  firstset := copySet (firstset);
		  setUnion (altp^.succp^.firstset, firstset, intersect);
		  if intersect <> nil then begin
		    reportLL1conflict (FirstErr, fromp, intersect);
		    disposeSet (intersect);
		  end; {if}
		end; {if}

		{passfirstup (p, newrulep);}
		fromp := p;
	      end
	      else {stop passing info upwards tree}
	        stop := true;
	    end; {condoneormore}

	  alternative :
	    begin
	      tempp := altp;
	      repeat
		with tempp^ do begin
		  p^.firstdet := firstdet;
		  if firstdet then
		    tempp := succp
		  else {forced stop ==> firstdet = false}
		    tempp := nil;
		end; {with}
	      until tempp = nil;

	      if firstdet then begin
		firstset := nil;
		tempp := altp;
		repeat
		  with tempp^ do begin
		    setUnion ({tempp^.}firstset, p^.firstset, intersect);
		    if intersect <> nil then begin
		      reportLL1conflict (FirstErr, tempp, intersect);
		      disposeSet (intersect);
		    end; {if}

		    tempp := succp;
		  end; {with}
		until tempp = nil;

		{passfirstup (p, newrulep);}
		fromp := p;
	      end
	      else {stop passing info upwards tree}
	        stop := true;
	    end; {alternative}

	  factorsequence :
	    begin {perhaps becomes determined}
	      tempp := altp;
	      repeat
		with tempp^ do begin
		  p^.firstdet := firstdet;
		  if (state = yes) and firstdet then
		    tempp := succp
		  else {forced stop ==> state = no or firstdet = false}
		    tempp := nil;
		end; {with}
	      until tempp = nil;

	      if firstdet then begin
		firstset := nil;
		{revisit them until some factor not null(F):}
		tempp := altp;
		repeat
		  with tempp^ do begin
		    setUnion ({tempp^.}firstset, p^.firstset, intersect);
		    if intersect <> nil then begin
		      reportLL1conflict (FirstErr2, tempp, intersect);
		      disposeSet (intersect);
		    end; {if}

		    if state = yes then
		      tempp := succp
		    else
		      tempp := nil;
		  end; {with}
		until tempp = nil;

		{passfirstup (p, newrulep);}
		fromp := p;
	      end
	      else {stop passing info upwards tree}
	        stop := true;
	    end; {factorsequence}

	end {case}
      else {firstdet = true}
        stop := true;
  until stop;
end; {passfirstup}
