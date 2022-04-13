        symbolkind      = firstsymbol .. lastsymbol;
        setofsymbol     = set of symbolkind;

{ SYMBOL ATTRIBUTES: }
        identstridxrange= 1 .. maxidentstrlen;
        identstrtyp     = packed array[identstridxrange] of char;

{ SYMBOL BUFFER: }
        symlenrange     = 0 .. maxsymlength;
        symbufidxrange  = 1 .. maxsymlength;
