procedure passdecision (    newstate : statekind;
                            fromp    : nodeptr;
                        var newrulep : nodeptr
                       );
{pre: fromp is a sub-tree whose state was changed to newstate;
      newstate is in a decided state, so either yes or no !
      returns newrulep <> nil when rulekind node becomes decided,
        (newrulep then points to that rule node)
      else newrulep = undefined.

	(3-Feb-88: eliminated tail-recursion)
}
var
        p,
        tempp      : nodeptr;
	stop,
	allyes,
	alldecided : boolean;
begin
  stop := false;
  repeat
    p := fromp^.backlink;
    {assert: p <> nil}
    with p^ do
      if (state <> newstate) then
	{ newstate in [yes, no] and state <> newstate
	  ==>
	     if newstate = yes ==> state in [ no, undecided]
	     if newstate =  no ==> state in [yes, undecided]

		"yes --> no" transitions are not defined
	}
	case kind of

	  grammarkind : {not applicable}
	    stop := true;

	  termornonterm,
	  epsilon,
	  illegal : {not applicable}
	    stop := true;

	  optional,
	  zeroormore : {always initially yes, stop}
	    stop := true;

	  rulekind :
	    begin
	      {here: state = undecided}
	      state := newstate;
	      {rule becomes decided, indicate this via newrulep}
	      newrulep := p;

	      {NOTE: special treatment for rules because of different
		     interpretation of backlink
	      }
	      {rulekind ==> backlink <> nil}
	      with backlink^ do
		if {backlink^.}kind = grammarkind then {first rule}
		  {backlink^.}state := newstate;
	      {else no action for other rules than first}
	      stop := true;
	    end; {rulekind}

	  condoneormore :  { </ E A > }
	    begin
	      {LL(1) violated when state(E) = state(A) = yes}
	      if newstate = yes then
                {==> state of E exor A was changed to yes}
		with altp^ do
		  if {altp^.}state {E} = {altp^.}succp^.state {A} then begin
		    {both states yes}
		    reportLL1conflict (EpsErr, fromp, nil);
		  end; {if-with-if}

	      if fromp^.succp <> nil then begin {from 1-st arg E}
		state := newstate;
		{old state was <> newstate}
		{passdecision (newstate, p, newrulep);}
		fromp := p;
	      end
	      else {from 2-nd arg A : no action}
		stop := true;
	    end;

	  oneormore :
	    begin
	      {here: state = undecided}
	      state := newstate;
	      {passdecision (newstate, p, newrulep);}
	      fromp := p;
	    end;

	  alternative :
	    if newstate = no then begin {state in [yes, undecided]}
	      if state = undecided then begin
   	        { "undecided --> no" transition }
		state := no;
		{passdecision (no, p, newrulep);}
		{newstate = no;}
		fromp := p;
	      end
	      else {state = yes, no change}
		stop := true;
	    end
	    else begin {newstate = yes ==> state in [no, undecided]}
	      { "no, undecided --> yes"  transition }
	      state := yes;
	      {passdecision (yes, p, newrulep);}
	      {newstate = yes;}
	      fromp := p;
	    end; {if}

	  factorsequence :
	    if newstate = no then begin {state in [undecided]}
	      {if still one of p children undecided then stay undecided}
	      {else all no}
	      tempp := {p^.}altp; { first child }
	      alldecided := true;
	      repeat
		with tempp^ do begin
		  if {tempp^.}state = undecided then begin
		    alldecided := false;
		    tempp := nil;
		  end
		  else
		    tempp := {tempp^.}succp;
		end; {with}
	      until tempp = nil;

	      if alldecided then begin
   	        { "undecided --> no" transition }
		state := no;
		{passdecision (no, p, newrulep);}
		{newstate = no;}
		fromp := p;
	      end
	      else {no further action}
		stop := true;
	    end
	    else begin {newstate = yes ==> state in [no, undecided]}
	      { Mind possible no-->yes transitions in alternative.}
	      {if now all children yes then father yes:}
	      tempp := {p^.}altp; { first child }
	      alldecided := true;
	      allyes := true;
	      repeat
		with tempp^ do
		  case {tempp^.}state of 
		    yes : {all factor states yes then term state yes}
		      begin
		        tempp := {tempp^.}succp;
		      end;
		    no :
		      begin
	                allyes := false;
		        tempp := {tempp^.}succp;
		      end;
		    undecided :
		      begin
		        alldecided := false;
  		        tempp := nil;
		      end;
		  end; {case-with}
	      until tempp = nil;

	      if alldecided then begin
		if allyes then begin
  		  { "no, undecided --> yes" transition }
		  state := yes;
		  {passdecision (yes, p, newrulep);}
		  {newstate := yes;}
		  fromp := p;
		end
		else begin
  		  { "undecided --> no" transition }
		  state := no;
		  {passdecision (no, p, newrulep);}
		  newstate := no;
		  fromp := p;
		end;
	      end
	      else
		stop := true;
	    end; {if}

	end {case}
      else begin {state = newstate}
	if state = yes then
	  case kind of

	    alternative,
	    optional,
	    condoneormore,
	    zeroormore :
	      reportLL1conflict (EpsErr, fromp, nil);

	    otherwise ;
	  end; {case-if}
        {always:}
        stop := true;
      end; {if-with}
  until stop;
end; {passdecision}
