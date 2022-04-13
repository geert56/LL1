procedure disposenode (node : nodeptr);
begin
  case node^.kind of
    epsilon :
      dispose (node{, epsilon});

    termornonterm :
      dispose (node{, termornonterm});

    rulekind :
      dispose (node{, rulekind});

    grammarkind,
    zeroormore, oneormore,
    condoneormore, optional,
    factorsequence,
    alternative, illegal :
      dispose (node{, alternative});

  end; {case}
end; {disposenode}

procedure disposetree (r : nodeptr);
{ Disposes a syntax diagram data structure;
  the data is binary tree like structured.
}
begin
  if r <> nil then
    with r^ do begin
      {first sets are not disposed because of multiple references
       disposeSet (firstset);
      }

      disposetree (succp);
      case kind of
	epsilon :
	  dispose (r{, epsilon});

	termornonterm :
	  dispose (r{, termornonterm});

	rulekind :
	  begin
	    disposetree (altp);
	    dispose (r{, rulekind});
	  end;

	grammarkind,
	zeroormore, oneormore,
	condoneormore, optional,
	factorsequence,
	alternative, illegal :
	  begin
	    disposetree (altp);
	    dispose (r{, alternative});
	  end;
      end; {case}
    end; {with-if}
end; {disposetree}
