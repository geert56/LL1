procedure initfirstdet (grammar : nodeptr);
{ Depth first search in grammar data structure;
  performs as postfix operation the calculation of the
  firstdet field for each node; no initial value for any of these fields
  is assumed.
  When firstdet evaluates to true then its first set is also determined.
  pre: nullable determined, so each state is either yes or no.
}
var
        dummyset : setref;

  procedure dfsfirst (p : nodeptr; var firstsetp : setref);
  var
          tempp       : nodeptr;
  begin
    with p^ do begin
      case kind of

        { node with no predecessor }
        grammarkind :
          begin
            if altp = nil then begin {no rules, empty grammar}
              firstdet := true; {namely empty!}
              firstset := nil;
            end
            else begin
	      tempp := altp;
	      repeat {for every rule:}
		dfsfirst (tempp, firstsetp);
		tempp := tempp^.succp;
	      until tempp = nil;
	      {inherit state+set of first rule (start symbol of grammar):}
	      firstdet := altp^.firstdet; {just for completeness}
	      firstset := altp^.firstset;
	    end; {if}
          end; {grammarkind}

        { nodes with just 1 successor }
        rulekind,    { <: E> }
        optional,    { <? E> }
        oneormore,   { <+ E> }
        zeroormore : { <* E> }
          begin
            dfsfirst (altp, firstset);
            {inherit firstdet of expression:}
            firstdet  := altp^.firstdet;
          end;

        { nodes with no successor }
        termornonterm :
          begin {reached a leaf node of the tree}
            firstdet := not (tokenkind[nameid] {= nonterm});
            if firstdet then begin {here: terminal}
              {create singleton set:}
              new (firstset);
              with firstset^ do begin
                contents := {p^.}nameid;
                nextelem := nil;
              end; {with}
            end
            else {nonterminal node, firstdet = false}
	      firstset := nil;
          end; {termornonterm}

        { special nodes with no sucessors }
        epsilon,
        illegal :
          begin {reached a leaf node of the tree}
            firstdet := true;
            {create empty set:}
            firstset := nil;
          end;

        condoneormore :  { </ E A > }
          begin
            dfsfirst (altp, firstset); {E}
            {inherit firstdet of expression:}
            firstdet := altp^.firstdet;
            dfsfirst (altp^.succp, firstsetp); {A}
            {in case E is not nullable, this is all we have to do}

            if altp^.state = yes then {null(E)}
              if firstdet then
                firstdet := altp^.succp^.firstdet;

            if firstdet then begin
              {E, or when null(E) both E and A determined}
	      if altp^.state = yes then begin {null(E)}
		{==> both E and A determined}
                {create new set and unite with first A}
		firstset := copySet (firstset);
		setUnion (altp^.succp^.firstset, firstset, dummyset);
		if dummyset <> nil then begin
		  reportLL1conflict (FirstErr, altp^.succp, dummyset);
		  disposeSet (dummyset);
		end; {if}
	      end; {if}
            end
    	    else
	      firstset := nil;
          end;

        { node with 2 or more siblings }
        factorsequence :
          begin
            { T = F1 . F2. F3 ...
              first(T) = first(F1) + if null(F1) then first(F2.F3...)
            }
            {visit all factors and apply dfs on them:}
            tempp := altp;
            repeat {for every factor:}
              dfsfirst (tempp, firstsetp);
              tempp := tempp^.succp;
            until tempp = nil;

            {revisit them until some factor not null(F) or not firstdet:}
            tempp := altp;
            repeat
              with tempp^ do begin
                p^.firstdet := {tempp^.}firstdet;
                if (state = yes) and firstdet then
                  tempp := succp
                else {forced stop}
                  tempp := nil;
                end; {with}
            until tempp = nil;
            {post: some factor is not nullable
	           or its firstdet = false or both}

            {init firstset of factorsequence:}
            firstset := nil;

            if firstdet then begin
              {set union: p^.firstset := p^.firstset + firstset
               (create new result set)
               LL(1) check
              }
              {revisit factors until some factor not null(F):}
              tempp := altp;
              repeat
                with tempp^ do begin
		  setUnion ({tempp^.}firstset, p^.firstset, dummyset);
		  if dummyset <> nil then begin
		    reportLL1conflict (FirstErr2, tempp, dummyset);
		    disposeSet (dummyset);
		  end; {if}

		  if state = yes then {allowed to go on}
		    tempp := succp
		  else {forced stop}
		    tempp := nil;
                end; {with}
              until tempp = nil;
            end; {if}
            {else firstdet = false}
          end; {factorsequence}

        alternative :
          begin
            { E = T1 | T2 | T3 ...
              first(E) = first(T1) + first(T2) + ...
            }	      
            {check if all terms have determined firstset:}
            {must hit every term to properly complete dfs!}
            {assume that this is so:}
	    firstdet := true;
            tempp := altp;
            repeat {for every term:}
              dfsfirst (tempp, firstsetp);
	      if not tempp^.firstdet then
                {cannot determine firstset of alternative}
	        firstdet := false;
              tempp := tempp^.succp;
            until tempp = nil;
            {post: all terms dealt with; firstdet indicates if all are
	     determined.}

            firstset := nil; {init}

            if firstdet then begin {all terms okay}
              {set union of all terms: (create new result set)}
	      tempp := altp;
	      repeat
		with tempp^ do begin
		  setUnion ({tempp^.}firstset, p^.firstset, dummyset);
		  if dummyset <> nil then begin
		    reportLL1conflict (FirstErr, tempp, dummyset);
		    disposeSet (dummyset);
		  end; {if}

		  tempp := succp;
		end; {with}
	      until tempp = nil;
	    end; {if}
            {else firstdet = false}
          end; {alternative}

      end; {case}

      {pass on reference:}
      firstsetp := firstset;
    end; {with}
  end; {dfsfirst}

begin {initfirstdet}
  dfsfirst (grammar, dummyset);
end; {initfirstdet}
