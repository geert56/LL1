unit names_unit;
interface
uses set_unit, lex_unit;

const
{$I 'names.con'}
type
{$I 'names.typ'}
{$I 'tree.typ'}
var
{$I 'names.var'}

procedure getindex ({OUT} var nindex : tokenidrange);

procedure initNameTable;

procedure printsymbol(var outfile : text;
                          symkind : boolean;
                          index   : tokenidrange
                     );

procedure printnametable;

implementation

{$GOTO ON}

function AreNotEqualCh (ch1, ch2 : char; caseflag : boolean) : boolean;

  function toUpper (ch : char) : char;
  begin
    if (ch >= 'a') and (ch <= 'z') then
      toUpper := chr (ord (ch) - 32 {ASCII})
    else
      toUpper := ch;
  end; {toUpper}

begin
  if ch1 = ch2 then
    AreNotEqualCh := false
  else {ch1 <> ch2}
    if caseflag {= caseinsensitive} then
      {perhaps only case difference in letter case}
      AreNotEqualCh := (toUpper (ch1) <> toUpper (ch2))
    else {case distinct}
      AreNotEqualCh := true;
end; {AreNotEqualCh}

procedure getindex ({OUT} var nindex : tokenidrange);
{ look-up current token in name table, if found return identity
  else generate new identity return this and store current name
  in the name table.
}
label   111,    {abort search}
        222;    {index found; exit while-loop}
var
     p          : namereclink;
     tokensort  : boolean;
     k          : identstridxrange;
begin
  p := nametable[symlength];
  tokensort := (symbol = nonterminalsym);

111:
  {search in list pointed to by p :}
  while (p <> nil) do begin
    with p^ do begin
      if tokensort = tokenkind[{p^.}tokenid] then begin
	{kind of symbol agrees}
	{test names:}
	if tokensort {= nonterm} then begin
	  {equivalence of non-terminals depends on letter case}
	  for k := 1 to symlength do
	    if AreNotEqualCh ({p^.}lit[k], identstr[k], caseflag) then begin
	      {not equal names, consider next p}
   	      {examine next list element:}
	      p := {p^.}link;
	      goto 111;
            end; {if-for}
	end
	else begin {terminal name}
	  {equivalence of terminals does not depend on letter case}
	  for k := 1 to symlength do
	    if {p^.}lit[k] <> identstr[k] then begin
	      {not equal names, consider next p}
	      {examine next list element:}
	      p := {p^.}link;
	      goto 111;
            end; {if-for}
	end; {if}
	{post: names are equal}
	nindex := {p^.}tokenid;
	{ready}
	goto 222;
      end
      else
        begin
	  {examine next list element:}
	  p := {p^.}link;
        end; {if}
    end; {with}
  end; {while}

  { p = nil ==> new entry}

  {administer statistics:}
  case tokensort of
    nonterm  : nrnonterminals := nrnonterminals + 1;
    terminal : nrterminals    := nrterminals    + 1;
  end; {case}

  { increment nrtokens:}
  if nrtokens < maxtokens then begin
    nrtokens := nrtokens + 1;
    {post: 0 < nrtokens <= maxtokens}
    nindex := nrtokens;
  end
  else begin
    if tokensort {= nonterm} then error (200) else error (201);
    { *** too many terminal and/or nonterminal symbols }
    nindex := maxtokens;
  end;

  {update tokeninfo and tokenkind:}
  with tokeninfo[nindex] do begin
    nametabidx   := symlength;
    lastrhsoccur := nil;
    rhscount     := 0;
  end; {with}
  tokenkind[nindex] := tokensort;

  {add new element at front of list:}
  {symlength > 0}
  new(p);

  with p^ do begin
    for k := 1 to symlength do
      lit[k] := identstr[k];
    tokenid := nindex;
    link    := nametable[symlength];
    nametable[symlength] := p;
  end; {with p^}

  222:
end; {getindex}

procedure printsymbol (var outfile : text;
                           symkind : boolean;
                           index   : tokenidrange
                      );
var
    p      : namereclink;
    i,
    keylen : identstridxrange;

  procedure getentry;
  {GLOBAL: index, p, keylen,
           tokeninfo, nametable,
  }
  {pre: index is indeed present}
  label 111;    {found, exit while-loop}
  begin
    keylen := tokeninfo[index].nametabidx;
    p      := nametable[keylen];
    while (p <> nil) do
      with p^ do
        if {p^.}tokenid = index then
          goto 111
        else
          p := {p^.}link;
    111:
  end; {getentry}

begin {printsymbol}
  case symkind of

    nonterm:
      begin
        if index = ENDOFTEXT then
          write (outfile, '"**program error**" ')
        else begin
	  getentry;
	  with p^ do begin
	    for i := 1 to keylen do
	      write (outfile, lit[i]);
	  end; {with}
	end; {if}
      end; {nonterm}

    terminal:
      begin
        if index = ENDOFTEXT then
          write (outfile, 'EOT')
        else begin
	  getentry;
	  with p^ do begin
	    case lit[1] of
	      EOLINE  : write (outfile, 'EOL');
	      TAB     : write (outfile, 'TAB');

	      otherwise
		begin
		  write (outfile, '''');
		  for i := 1 to keylen do begin
		    write (outfile, lit[i]);
		    if lit[i] = '''' then
		      write (outfile, '''');
		  end; {for}
		  write (outfile, '''');
		end; {otherwise}
	    end {case}
	  end; {with p^}
	end; {if}
      end; {terminal}

  end; {case}
end; {printsymbol}

procedure printnametable;
var
        i, k    : identstridxrange;
        p       : namereclink;
begin
  writeln (output, '*** Symbol Table ***');
  writeln (output);
  for i := 1 to maxidentstrlen do begin
    p := nametable[i];
    while p <> nil do
      with p^ do begin
	 write (output, tokenid:3, ' ':3);

        case lit[1] of
                                  {1234567890123456}
	  EOLINE : write (output, 'EOL             ');
	  TAB    : write (output, 'TAB             ');
	  otherwise begin
	    for k := 1 to i do
	      write (output, lit[k]);
            if i < 16 then
	      write (output, ' ': 16-i);
          end;
	end; {case}

	if tokenkind[tokenid] then begin {nonterm}
	  write (output, '   non-terminal', ' ':3);
          with tokeninfo[tokenid] do begin
            write (output, nametabidx:4, ' ':3);
            if rhscount > 0 then begin
              if lastrhsoccur = nil then
                write (output, 'ERROR1')
              else
                write (output, rhscount:6);
            end
            else begin {rhscount = 0}
              if lastrhsoccur = nil then
                write (output, 'no rhs')
              else
                write (output, 'ERROR2');
            end;
          end; {with}
        end
	else begin
	  write (output, '       terminal', ' ':3);
        end; {if}

	writeln (output);
	p := link;
      end; {with-while}
  end; {for i}
end; {printnametable}

procedure initNameTable;
var
        i : cardinal;
begin
  {writeln(stderr, 'initNameTable');}
  nrtokens              := 0;
  nrterminals           := 0;
  nrnonterminals        := 0;
  nrproductions         := 0;

  for i := 1 to maxtokens do
    lhsnonterm[i] := false;

  for i := 1 to maxidentstrlen do
    nametable[i] := nil;

  {special treatment for token with id 0: ENDOFTEXT}
  tokenkind[ENDOFTEXT] := terminal;
end; {initNameTable}

end.
