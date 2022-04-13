procedure options;
{Adjusts some compiler option flags according their settings in a special
 comment string: the first character immediately following the start of
 comment symbol must be the DOLLAR sign '$'

 SYNTAX:
      <option-list> ::= "$" <option> ( ","  <option> )* .
      <option>      ::= <Upper-case-letter> ("+" | "-") .
}
var
      nch  : char;
      stop : boolean;
begin {options}
  if peeknextch = '$' then begin
    {read the "$":}
    getch;

    repeat
      nch := peeknextch;
      if nch in ['A'..'Z'] then begin
	{read that letter:}
	getch; {ch = nch}
	nch := peeknextch;
	if (nch = '+') or (nch = '-') then begin
	  {NOTE: ch is option letter, nch is the sign}
	  case ch of
	    {defined options:}
	    'C' : caseflag := (nch = '-');      { $C+ : case distinct,
						   caseflag = false}
	    'L' : list := (nch = '+');
{
		:
		:
		:
}
	    else {otherwise} {undefined option letter: ignore};
	  end; {case}
	  {read the sign}
	  getch;
	end;
	{else ignore option}
	stop := peeknextch <> ',';
	if not stop then {read the comma} getch;
      end
      else stop := true;
    until stop;
  end; {if}
  {else no options}
end; {options}
