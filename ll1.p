program ll1_program (input, output, stderr);

{author:

        G.L.J.M. Janssen
        Building: EH,   room 7.27,      phone +31-40-473387
        e-mail: geert@es.ele.tue.nl

        Eindhoven University of Technology
        Dept. of Electrical Engineering
        P.O. Box 513
        5600 MB Eindhoven
        The Netherlands

  references:

}
uses
  lex_unit,
  names_unit,
  ll1_unit;

var i : integer;

procedure sbnf_parser;
var
        savep,
        startp, finalp : nodeptr;

        atombeginsyms,
        primbeginsyms,
        factbeginsyms,
        termfollowsyms  : setofsymbol;

function getlhsnonterm : boolean;
begin
  if not (symbol in [ LESSop, identifier ]) then begin
    error (21);
    skipuntil ([ LESSop, identifier, fileend ]);
  end; {if}

  if (symbol in [ LESSop, identifier ]) then begin

    if symbol = LESSop then begin
      getsymbol;
      if symbol <> identifier then begin
        error (15);
{identifier expected}
        skipuntil ([identifier, fileend]);
      end; {if}

      if symbol = identifier then begin
        getsymbol;
        if symbol <> GREATERop then error (14);
  { ">" expected; inserted}
        getlhsnonterm := true;
        symbol := nonterminalsym;
      end
      else {fileend}
        getlhsnonterm := false;
    end
    else begin {identifier}
      getlhsnonterm := true;
      symbol := nonterminalsym;
    end; {if}
  end
  else {fileend}
    getlhsnonterm := false;
end; {getlhsnonterm}

procedure production_rule (var startp, finalp : nodeptr);
var
        ntindex : tokenidrange;
        savefinalp,
        savep   : nodeptr;

  procedure createleafnode (sort : kinds;
                            var startp, finalp : nodeptr
                           );
  begin
    case sort of

      epsilon :
        begin
          new (startp{, epsilon});
          startp^.state := yes;
        end; {epsilon}

      termornonterm :
        begin
          new (startp{, termornonterm});
          with startp^ do begin
            getindex (nameid);
            {update rhs links:}
            with tokeninfo[nameid] do begin
	      {push at front:}
	      nextrhsoccur := {token..}lastrhsoccur;
	      {token..}lastrhsoccur := startp;
	      {token..}rhscount     := {token..}rhscount + 1;
            end; {with}

            if tokenkind[nameid] {= nonterm} then begin
              state := undecided;
              {information in possible lhs-node for this non-term
               intentionally not used because of possibility of
               useless productions
              }
            end
            else begin
              state := no;
            end; {if}
          end; {with}
        end;

      illegal :
        begin
          new (startp{, illegal});
          startp^.state := no;
        end; {illegal}

      grammarkind,
      rulekind,
      zeroormore, oneormore,
      condoneormore, optional,
      factorsequence,
      alternative : {not applicable};

    end; {case}

    with startp^ do begin
{     backlink := nil;}
      kind     := sort;
      firstdet := false;
      firstset := nil;
      succp    := nil;
    end; {with}
    finalp := startp;
    {post: startp = finalp (<> nil)}
  end; {createleafnode}

  procedure expression (var startp, finalp : nodeptr);

    procedure term (var startp, finalp : nodeptr);

      procedure factor (var startp, finalp : nodeptr);

        function atomic : boolean;
        var   savesymbol : symbolkind;
        begin
          if symbol in atombeginsyms then begin

            atomic := true;
            if symbol in [ LESSop, identifier, EMPTYkw, EOLkw, TABkw ] then
              begin {perhaps: non-terminal or pseudo}
              if symbol = LESSop then begin
		getsymbol;
		if symbol = GREATERop then
		  symbol := epsilonsym
		else begin {identifier or keyword expected}
		  if not (symbol in [ identifier,
				      EMPTYkw, EOLkw, TABkw ] ) then begin
		    error (22);
		    {identifier or reserved word expected}
		    skipuntil ([identifier, EMPTYkw, EOLkw, TABkw, fileend]);
		  end; {if}

		  if symbol <> fileend then begin
		    savesymbol := symbol;
		    getsymbol;
		    if symbol <> GREATERop then error (14);
		    { ">" expected; inserted}

		    if savesymbol = identifier then
		      symbol := nonterminalsym
		    else begin {reserved word}
		      case savesymbol of
			EMPTYkw : symbol := epsilonsym;
			EOLkw   :
			  begin
			    identstr := blankidentstr;
			    identstr[1] := EOLINE;
			    symlength := 1;
			    symbol := terminalsym;
			  end;
			TABkw   :
			  begin
			    identstr := blankidentstr;
			    identstr[1] := TAB;
			    symlength := 1;
			    symbol := terminalsym;
			  end;
		      end; {case}
		    end; {if}
     {identstr still contains the identifier when no error}
		  end
		  else {fileend}
		    atomic := false;
		  end; {if}
	      end
              else {identifier or reserved word}
                if symbol = identifier then
                  symbol := nonterminalsym
                else begin {reserved word}
                  case symbol of
                    EMPTYkw : symbol := epsilonsym;
                    EOLkw   :
                      begin
                        identstr := blankidentstr;
                        identstr[1] := EOLINE;
                        symlength := 1;
                        symbol := terminalsym;
                      end;
                    TABkw   :
                      begin
                        identstr := blankidentstr;
                        identstr[1] := TAB;
                        symlength := 1;
                        symbol := terminalsym;
                      end;
                  end; {case}
                end; {if}
            end; {if}
            {else proper atomic symbol}

          end
          else
            atomic := false;
        end; {atomic}

        procedure primary (var startp, finalp : nodeptr);
        begin {primary}
          {writeln (stderr, 'primary');}

          if atomic then begin
            {writeln (stderr, 'atom');}
            case symbol of
              epsilonsym     :
                createleafnode (epsilon, startp, finalp);

              terminalsym    :
                createleafnode (termornonterm, startp, finalp);

              nonterminalsym :
                createleafnode (termornonterm, startp, finalp);
            end; {case}

            getsymbol;
          end
          else
            case symbol of

              lparen:
                begin
                  {writeln (stderr, 'compound');}
                  getsymbol;
                  expression (startp, finalp);
                  if symbol = rparen then
                    getsymbol
                  else error (16);
                  { ")" expected; inserted}
                end; {lparen}

              otherwise
                begin
                  error (12);
                  { error in primary }
                  createleafnode (illegal, startp, finalp);
                end; {otherwise}

            end; {case-if}
        {post: startp = finalp  (<> nil)}
      end; {primary}

    begin {factor}
      {writeln (stderr, 'factor');}

      case symbol of

{ [ E ] }
        lbracket: {option}
          begin
            {writeln (stderr, 'option');}
            getsymbol;
            expression (startp, finalp);
            if startp^.state = yes then
              error (203);
{LL(1) conflict : expr. in optional construct may be empty}

            new (finalp{, optional});
            with finalp^ do begin
{             backlink := nil;}
              state    := yes;
              kind     := optional;
              succp    := nil;
              altp     := startp;
              firstdet := false;
              firstset := nil;
            end; {with}
            startp^.backlink := finalp;
            startp := finalp;

            if symbol = rbracket then
              getsymbol
            else error (17);
  { "]" expected; inserted}
          end; {lbracket}

{ (: E :) }
{ (: E :) + }
{ (: E :) * }
{ (: E / A :) }
{ (: E / A :) + }
{ (: E / A :) * }
        lbrace: {list}
          begin
            {writeln (stderr, 'list');}
            getsymbol;
            new (startp{, assume: zeroormore});
            with startp^ do begin
{             backlink := nil;}
              kind     := zeroormore;
              succp    := nil;
              expression (altp, finalp);
	      { temp. value, corrected later: }
              state    := altp^.state;
              altp^.backlink := startp;
              firstdet := false;
              firstset := nil;
            end; {with}

            if symbol = separatesym then begin
{ (: E / A :) }
{ (: E / A :) + }
{ (: E / A :) * }
              getsymbol;
              if atomic then begin

                case symbol of
{ (: E / <> :) ==> (: E :) }
                  epsilonsym     : ;

                  terminalsym,
                  nonterminalsym :
                    begin
                      createleafnode (termornonterm, finalp^.succp, finalp);
                      finalp^.backlink := startp;
                      startp^.kind := condoneormore;
                    end;
                  end; {case}
                getsymbol;
              end
            else
                error (20);
{atomic symbol expected}
            end; {if symbol =separatesym}

            if symbol = rbrace then getsymbol
            else error (18);
            {  expected; inserted}

            if symbol in [ PLUSsym, TIMESsym] then begin
{ (: E :) + }
{ (: E :) * }
{ (: E / A :) + }
{ (: E / A :) * }
              case symbol of
                PLUSsym  :
                  with startp^ do
                    if kind = zeroormore then
                      kind := oneormore;

                TIMESsym :
                  if startp^.kind = condoneormore then begin
                    if startp^.state = yes then
                      error (204);
{LL(1) conflict : E in (: E / A :)* construct may be empty}

                    finalp := startp;
                    new (startp{, optional});
                    with startp^ do begin
{                     backlink := nil;}
                      state    := yes;
                      kind     := optional;
                      succp    := nil;
                      altp     := finalp;
		      firstdet := false;
		      firstset := nil;
                    end; {with}
                    finalp^.backlink := startp;
                  end
                  else begin {kind = zeroormore}
                    if startp^.state = yes then
                      error (208)
{LL(1) conflict : E in (: E :)* construct may be empty}
                    else
                      startp^.state := yes;
                  end; {if}
              end; {case}

              getsymbol;
            end
            else {no PLUS or TIMES sym}
{ (: E :) }
{ (: E / A :) }
              {same action as if TIMES where present}
              if startp^.kind = condoneormore then begin
{ (: E / A :) }
                if startp^.state = yes then
                  error (205);
{LL(1) conflict : E in (: E / A :) construct may be empty}

                finalp := startp;
                new (startp{, optional});
                with startp^ do begin
{                 backlink := nil;}
                  state    := yes;
                  kind     := optional;
                  succp    := nil;
                  altp     := finalp;
		  firstdet := false;
	          firstset := nil;
                end; {with}
                finalp^.backlink := startp;
              end
              else begin {kind = zeroormore}
{ (: E :) }
                if startp^.state = yes then
                  error (209)
{LL(1) conflict : E in (: E :) construct may be empty}
                else
                  startp^.state := yes;
              end; {if}

            finalp := startp;
          end; {lbrace}

        otherwise
          begin
            primary (startp, finalp);
            if symbol in [ PLUSsym, TIMESsym, questsym] then begin

              case symbol of
                PLUSsym  :
                  begin
                    new (finalp{, oneormore});
                    with finalp^ do begin
                      state    := startp^.state;
                      kind     := oneormore;
		      firstdet := false;
		      firstset := nil;
                    end; {with}
                  end;

                TIMESsym :
                  begin
                    if startp^.state = yes then
                      error (206);
{LL(1) conflict : Primary in "Primary *" may be empty}

                    new (finalp{, zeroormore});
                    with finalp^ do begin
                      state    := yes;
                      kind     := zeroormore;
		      firstdet := false;
		      firstset := nil;
                    end; {with}
                  end;

                questsym :
                  begin
                    if startp^.state = yes then
                      error (207);
{LL(1) conflict : Primary in "Primary ?" may be empty}
                    new (finalp{, optional});
                    with finalp^ do begin
                      state    := yes;
                      kind     := optional;
		      firstdet := false;
		      firstset := nil;
                    end; {with}

                  end;
              end; {case}

              with finalp^ do begin
{               backlink := nil;}
                succp    := nil;
                altp     := startp;
              end; {with}

              startp^.backlink := finalp;
              startp := finalp;

              getsymbol;
            end; {if}
          end; {otherwise}

        end; {case}
      {post: startp = finalp (<> nil)}
    end; {factor}

  begin {term}
{writeln (stderr, 'term');}

    if symbol in factbeginsyms then begin
      factor (startp, finalp);

      if symbol in factbeginsyms then begin {note: startp = finalp}

        new (startp{, factorsequence});
        with startp^ do begin
{         backlink := nil;}
          state    := finalp^.state;
          kind     := factorsequence;
          succp    := nil;
          altp     := finalp;
          firstdet := false;
          firstset := nil;
        end; {with}
        finalp^.backlink := startp;

        repeat
          factor (finalp^.succp, finalp);
          finalp^.backlink := startp;
          with startp^ do
            case state of 
              yes : {all factor states yes then term state yes}
                state := finalp^.state;
              no :
                if finalp^.state = undecided then
                  state := undecided;
              undecided : ; {once undecided, always undecided}
            end; {case-with}
        until not (symbol in factbeginsyms);
        finalp := startp;
      end; {if}
    end
    else {probably empty term; check followsyms:}
      if symbol in termfollowsyms then {empty term}
        createleafnode (epsilon, startp, finalp)
      else begin
        error (3); {illegal symbol}
        skipuntil (termfollowsyms + [ fileend ]);
        createleafnode (illegal, startp, finalp);
      end; {if}
    {post: startp = finalp (<> nil)}
  end; {term}

begin {expression}
  {writeln (stderr, 'expression');}

  term (startp, finalp);

  if symbol = choicesym then begin  { 2 or more terms}
    {create alternative kind descriptor and link first term to it:}
    new (startp{, alternative});
    with startp^ do begin
{     backlink := nil;}
      state    := finalp^.state;
      kind     := alternative;
      succp    := nil;
      altp     := finalp;
      firstdet := false;
      firstset := nil;
    end; {with startp^}
    finalp^.backlink := startp;

    repeat {for all Ti, 2 <= i <= n}
      getsymbol;

      term (finalp^.succp, finalp);
      finalp^.backlink := startp;
      with startp^ do begin
        case state of
          yes : {1 term yes then expr. yes}
            {Note: state remains the same!}
            if finalp^.state = yes then {more than 1 eps term}
              {==> kind <> termornonterm}
              begin
                error (202);
{LL(1) condition violated because of more than 1 empty term}
              end; {if}

          no :
            if finalp^.state = yes then
              state := yes;

          undecided : {terms undecided or no then expr. undecided}
            if finalp^.state <> undecided then
              state := finalp^.state;
            {else remains undecided}
        end; {case}
      end; {with startp}
    until (symbol <> choicesym);
    finalp := startp;

  end; {if symbol = choice ...}
  {post: startp = finalp (<> nil)}
end; {expression}

begin {production_rule}
{writeln (stderr, 'production_rule    : ');}

  {symbol = (lhs) nonterminalsym}
  {combine rules with same lhs non-terminal:}

  getindex (ntindex);

  {read replacement symbol:}
  getsymbol;
  if symbol = replacesym then getsymbol else error (13);
  {"::=" expected; inserted}

  if not lhsnonterm[ntindex] then begin {not yet occurred on lhs}
    nrproductions := nrproductions + 1;
    lhsnonterm[ntindex] := true;

    {create rulekind node:}
    new (startp{, rulekind});
    with startp^ do begin
{     backlink := nil;}
      kind     := rulekind;
      succp    := nil;
      nameid   := ntindex;
      linenr   := linecount; {line where this lhs first occurs}
      visited  := false;
      expression (altp, finalp);
      state    := finalp^.state;
      firstdet := false;
      firstset := nil;
    end; {with}
    finalp^.backlink := startp;
    tokeninfo[ntindex].lhsoccur := startp;
    finalp := startp; {both <> nil}
    {ready}
  end
  else begin {rule with this non-terminal on lhs exists}
    {make sure value of finalp does not change for caller:}
    savefinalp := finalp;

    {get pointer to lhs:}
    startp := tokeninfo[ntindex].lhsoccur;
    {check if E has alternative kind of top node:}
    with startp^ do begin
      if altp^.kind <> alternative then begin
        {create new alternative node:}
        {this code is executed at most once}
        {save link:}
        finalp := altp;
        new (altp{, alternative});
        with altp^ do begin
          kind     := alternative;
          backlink := startp;
          succp    := nil;
          state    := finalp^.state;
          {restore link:}
          {startp^.altp^.}altp := finalp;
          firstdet := false;
          firstset := nil;
        end; {with altp^}
        finalp^.backlink := altp;
        {startp^.state = startp^.altp^.state}
      end; {if}

      {altp^.kind = alternative}
      {save all terms that are already there:}
      savep := altp^.altp;
      {new term in front:}
      expression (altp^.altp, finalp);
      finalp^.backlink := altp;
      finalp^.succp := savep;
      with altp^ do begin
        {same state check as with expr.}
        case state of
          yes : {1 term yes then expr. yes}
            if finalp^.state = yes then {more than 1 eps term}
              {==> kind <> termornonterm}
              begin
                error (202);
{LL(1) condition violated because of more than 1 empty term}
              end; {if}

          no :
            if finalp^.state = yes then
              state := yes;

          undecided :
            if finalp^.state <> undecided then
              state := finalp^.state;
            {else remains undecided}

        end; {case}
      end; {with altp^}

      {pass state onto rulekind node:}
      state := altp^.state;

      {if first rule then also pass state onto grammarkind node:}
      if {startp^.}backlink^.kind = grammarkind then begin
        backlink^.state := state;
      end; {if}
    end; {with startp^}

    {NOTE: because of chaining action in sbnf_parser routine, startp should
     return nil when no new rule created and finalp must be unchanged in that
     case
    }
    finalp := savefinalp;
    startp := nil;
  end; {if}

  if symbol = period then getsymbol else error (19);
{"." expected; inserted}
end; {production_rule}

begin {sbnf_parser}
  {writeln (stderr, 'sbnf_parser');}

  atombeginsyms  := [ epsilonsym, terminalsym, LESSop, identifier,
                      EMPTYkw, EOLkw, TABkw ];
  primbeginsyms  := atombeginsyms + [ lparen ];
  factbeginsyms  := primbeginsyms + [ lbrace, lbracket ];
  termfollowsyms := [ rbracket, rbrace, separatesym, questsym, rparen,
                      choicesym, period ];

  new (startp{, grammarkind});
  with startp^ do begin
    backlink := nil;
    state    := undecided;
    kind     := grammarkind;
    succp    := nil;
    altp     := nil;
    firstdet := false;
    firstset := nil;
  end; {with}

  getsymbol;

  if symbol <> fileend then begin
    if getlhsnonterm then begin
      with startp^ do begin
        production_rule ({startp^.}altp, finalp);
        {inherit state of first rule:}
        {startp^.}state  := altp^.state;
        {first rule backlinks to grammar node:}
        finalp^.backlink := startp;
      end; {with startp^}

      while symbol <> fileend do
        if getlhsnonterm then begin
          {save pointer to last rule:}
          savep := finalp;
          production_rule (finalp^.succp, finalp);
          {if rule with same lhs was found then succp is made nil
           finalp still points to last rule
           else finalp points new last rule.
          }
          {establish backlink:}
          {NOTE: the interpretation of backlink for rulekind nodes:
                 backlink refers to the previous rule for second and
                 following rules. backlink of first rule points back to
                 the grammarkind node.
          }
          if finalp <> savep then {new rulekind node added}
            finalp^.backlink := savep;
          {else no action}
        end; {if-while}
      {here: symbol=fileend}

    end; {if}
    {else symbol=fileend}
  end; {if}

  {writeln(stderr, 'Successfully parsed input.');}
  {post: all non-terminals on rhs have undecided state;
         nrnonterminals >= nrproductions
  }
  processgrammar (startp);
end; {sbnf_parser}

begin {main}
   {Parse cmdline arguments:}
   for i := 1 to paramCount() do begin
      {writeLn(stderr, i:2, '. argument: ', paramStr(i));}
   end;

   if paramCount() > 0 then begin
      {$I-}
      assign(input, paramStr(1));
      reset(input);
      {$I+}
      if IoResult <> 0 then begin
	 writeln(stderr, '(E): cannot read file: ', paramStr(1));
	 Halt;
      end;
   end;

   initLex;
   initNameTable;

   sbnf_parser;

   finalLex;
   close(listing);
end.
