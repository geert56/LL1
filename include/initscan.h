procedure initScanner;
begin
     writeln(erroutput, 'initScanner');
{*}  illegalchars := [chr(0)..chr(31), chr(127)..chr(255)]
                     {except TAB;} - [TAB];

     atendofline := true;
{*}  caseflag    := caseinsensitive;

     initList;
     initError;
end; {initScanner}
