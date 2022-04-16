function rightwalk (    nodep         : nodeptr;
		    var follow        : setref;
		    var dependsonrule : tokenidrange) : boolean;
{
  Starting at this node (initially always a nonterminal) walk to the
  right until a node is encountered with state = no or the end of the
  production is reached.
  The requested follow-set comprises of the union of the
  first-sets of all successor nodes traversed in this way and if the
  end-of-production is reached its follow-set is also included.

  Returns true when end-of-production reached, and the follow-set of the
  rule with nonterminal 'dependsonrule' needs to be included.
}
{ pre : nodep <> nil, kind <> grammarkind}
var
     stillempty,
     stop       : boolean;
begin
  stop := false;
  repeat
    with nodep^ do
      case {nodep^.}backlink^.kind of

	rulekind :
	  begin
	    nodep := {nodep^.}backlink;
	    stop  := true;
	  end; {if}

	alternative :
	  { E = T1 | T2 | T3 ...
	    follow(Ti) = follow(E)
	  }
	  nodep := {nodep^.}backlink;

	condoneormore :
	  begin
	    if {nodep^.}succp = nil then begin {2-nd arg A}
	      {nodep^.kind = termornonterm, required by syntax}
	      {tokenkind[nodep^.nameid] = true, i.e. nonterminal,
	       never here when terminal!}
	 { F = </ E A> = <. E <* <. A E>>>
	   follow(A) = first(E) + if null(E) then (first(A) + follow(F))
	 }
	      with {nodep^.}backlink^ do begin
		{add first(E):}
		setUnion2 ({..backlink^.}altp^.firstset, follow);

		{ null(E) ? }
		if {nodep^.backlink^.}altp^.state = yes then begin
		  {null(E)}
		  {add first(A):}
		  setUnion2 (nodep^.firstset, follow);
		  { Mind the "with backlink" }
		  nodep := nodep^.backlink; {E's back = A's back}
		end
		else
		  stop := true;
	      end; {with}
	    end
	    else begin {E}
	   { F = </ E A> = <. E <* <. A E>>>
	     follow(E) = first(A) + follow(F) + if null(A) then first(E)
	   }
	      {add first(A):}
	      setUnion2 ({nodep^.}succp^.firstset, follow);
	      {nodep^.succp^.kind = termornonterm, required by syntax}
	      { null(A) ? }
	      if {nodep^.}succp^.state = yes then
		{add first(E):}
		setUnion2 ({nodep^.}firstset, follow);
	      nodep := {nodep^.}backlink; {E's back}
	    end; {if}
	  end; {condoneormore}

	zeroormore,
	oneormore :
	  begin
	    { 1) F = <* E>
		 follow(E) = first(E) + follow(F)
	      2) F = <+ E>
		 follow(E) = first(E) + follow(F)
	    }
	    setUnion2 ({nodep^.}firstset, follow);
	    nodep := {nodep^.}backlink;
	  end;

	epsilon,
	illegal,
	termornonterm : ; {not possible}

	optional :
	  begin
	    { F = <? E>
	      follow(E) = follow(F)
	    }
	    nodep := {nodep^.}backlink;
	  end; {optional}

	factorsequence :
	  begin
	    { T = F1 . F2 . F3 ... Fn
	      follow(Fi) = first(Fi+1) + if null(Fi+1) then follow(Fi+1)
	      follow(Fn) = follow(T)
	    }
	    stillempty := true;
	    while (nodep^.succp <> nil) and stillempty do begin
	      nodep := nodep^.succp;
	      with nodep^ do begin
		{add first(successor):}
		setUnion2 ({nodep^.}firstset, follow);

		stillempty := {nodep^.}state = yes;
	      end; {with}
	    end; {while}

	    if stillempty then
	      nodep := {nodep^.}backlink
	    else
	      stop := true;
	  end; {factorsequence}

      end; {case-with}
  until stop;

  with nodep^ do
    if {nodep^.}kind = rulekind then begin
      {follow-set of initial nodep depends on follow-set of nameid}
      rightwalk := true;
      dependsonrule := {nodep^.}nameid;
    end
    else
      rightwalk := false;
end; {rightwalk}
