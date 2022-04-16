procedure initKeywordtable;
var kwidx : 0 .. nrreservedwords;
 
  procedure addkw(keyword : identstrtyp);
  begin
    kwidx := kwidx + 1;
    keywordtable[kwidx] := keyword;
  end; {addkw}
 
begin {initKeywordtable}
  kwidx := 0;
  {add all keywords:}
        {0123456789012345678901234567890123456789012345678901234567890123}
  addkw('EMPTY                                                           ');
  addkw('EOL                                                             ');
  addkw('TAB                                                             ');
end; {initKeywordtable}

function kwsearch(identstr : identstrtyp) : symbolkind;
{Binary search in keyword table for identstr. Returns keyword symbol if found,
 else the token 'identifier'.
}
label   555; {match}
type
        orderkind       = (less, equal, greater);
var
        i, j, k : cardinal;

  function testorder(str1, str2 : identstrtyp) : orderkind;
  {Tests lexicographical order of the 2 strings}

    procedure toUpperStr(var str : identstrtyp);
    {Converts all lower case letters in identifier string to upper case;
     NOTE: identifier may not contain blanks.
    }
    label       1; {exit for-loop}
    const
        casedistance = 32; {= ord('a') - ord('A') }
    var
        i  : identstridxrange;
        ch : char;
    begin
      for i := 1 to maxidentstrlen do begin
	ch := str[i];
	if ch in ['a'..'z'] then
	  str[i] := chr(ord(ch) - casedistance)
	else
	  if ch = ' ' then
	    {exit for-loop:}
	    goto 1;
      end; {for}
      1:
    end; {toUpperStr}

  begin {testorder}
    if caseflag {= caseinsensitive} then begin
      toUpperStr(str1);
      toUpperStr(str2);
    end; {if}

    if str1 < str2 then
      testorder := less
    else
      if str1 > str2 then
        testorder := greater
      else
        {str1 = str2}
        testorder := equal;
  end; {testorder}

begin {kwsearch}
  i := 1;
  j := nrreservedwords;
  repeat
    k := (i + j) div 2;
    case testorder(identstr, {<, =, > ?} keywordtable[k]) of
      less   : j := k - 1;
      equal  : begin {match}
                 kwsearch := k;
                 goto 555;
               end;
      greater: i := k + 1;
    end; {case}
  until i > j;
  kwsearch := identifier;
555: {match}
end; {kwsearch}
