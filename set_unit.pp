unit set_unit;
interface

type
{ SET of TERMINAL SYMBOLS: }
        setref          = ^elementtype;
        elementtype     = record
                            contents : integer;
                            nextelem : setref;
                          end;

function includeElem(elem : integer; var aset : setref) : boolean;

procedure includeElem2(elem : integer; var aset : setref);

function isElemOf(elem : integer; aset : setref) : boolean;

function excludeElem(elem : integer; var aset : setref) : boolean;

procedure excludeElem2(elem : integer; var aset : setref);

function copySet(original : setref) : setref;

procedure setUnion(set1 : setref; var set2, intersect  : setref);

procedure setUnion2(set1 : setref; var set2 : setref);

procedure setIntersect(set1, set2 : setref; var intersect : setref);

procedure disposeSet(aset : setref);

procedure writeSet(var outfile : text; aset : setref);

procedure writelnSet(var outfile : text; aset : setref);

implementation

function includeElem (elem : integer; var aset : setref) : boolean;
{ Inclusion of 1 element, also checks whether element already in set. }
var
        currelem : integer;
        p, prevp : setref;
begin
  if aset = nil then begin
    includeElem := true;
    new (aset);
    with aset^ do begin
      contents := elem;
      nextelem := nil;
    end; {with}
    {ready}
  end
  else begin {not empty aset}
    {order > : biggest contents first }
    p := aset;
    currelem := p^.contents;
    prevp := nil;
    while currelem > elem do begin
      prevp := p;
      p := p^.nextelem;
      if p = nil then currelem := elem - 1
      else currelem := p^.contents;
    end; {while}

    if currelem = elem then includeElem := false
    else begin
      includeElem := true;
      if prevp = nil then begin
        new (prevp);
        aset := prevp;
      end
      else
        with prevp^ do begin
          new (nextelem);
          prevp := nextelem;
        end; {with-if}

      with prevp^ do begin
        contents := elem;
        nextelem := p;
      end; {with}
    end; {if}
  end; {if aset = nil}
end; {includeElem}

procedure includeElem2 (elem : integer; var aset : setref);
var dummy : boolean;
begin
  dummy := includeElem (elem, aset);
end; {includeElem2}

function copySet (original : setref) : setref;
{ make a copy of a set;
  returns an empty copy when original is empty upon entry.
}
var
        tailofcopy : setref;
begin
  if original = nil then
    copySet := nil
  else begin
    {copy first element:}
    new (tailofcopy);
    tailofcopy^ := original^;
    copySet := tailofcopy;

    {copy the rest if any:}
    original := original^.nextelem;
    while original <> nil do begin
      with tailofcopy^ do begin
        new (nextelem);
        tailofcopy := nextelem;
      end; {with}

      tailofcopy^ := original^;
      original := original^.nextelem;
    end; {while}
  end; {if}
end; {copySet}

procedure uniteSets(aset : setref; var targetset, intersect : setref;
                    intersectaction : boolean
                   );
{ targetset := targetset + aset
}
var
        intersectlastp,
        prevp,
        currtargetp,
        prefixset,
        prefixlastp     : setref;
        currtargetelem,
        currasetelem    : integer;
        stop            : boolean;
begin {uniteSets}
  intersect := nil;

  if aset <> nil then begin
    if targetset = nil then
      targetset := copySet(aset)
    else begin {both sets non-empty}
      currtargetp    := targetset;
      currtargetelem := currtargetp^.contents;
      currasetelem   := aset^.contents;

      if currasetelem > currtargetelem then begin
        {at least 1 elem must be added to front of target list}
        {first elem of prefix set is dummy:}
        new(prefixset);
        prefixlastp := prefixset;

        repeat
          {add elem to rear of prefix:}
          {create new prefix elem:}
          with prefixlastp^ do begin
            new (nextelem);
            nextelem^.contents := currasetelem;
            prefixlastp := nextelem;
          end; {with}

          aset := aset^.nextelem;
          if aset = nil then {stop repeat-loop}
            currasetelem := currtargetelem
          else
            currasetelem := aset^.contents;
        until currasetelem <= currtargetelem;

        {add prefixset to front of target:}
        prefixlastp^.nextelem := targetset;
        {remove dummy first elem of prefix set:}
        targetset := prefixset^.nextelem;
        dispose(prefixset);
      end; {if}
      {post: perhaps aset = nil}

      if aset <> nil then begin
        stop := false;
        repeat
          {assert: first time: currasetelem <= currtargetelem
                   ==> prevp properly initialised
          }
          if currasetelem = currtargetelem then begin {non-empty intersection}
            if intersectaction then begin
              {add currasetelem to rear of intersect:}
              if intersect = nil then begin
                new (intersect);
                intersectlastp := intersect;
              end
              else
                with intersectlastp^ do begin
                  new(nextelem);
                  intersectlastp := nextelem;
                end; {with-if}
              with intersectlastp^ do begin
                contents := currasetelem;
                nextelem := nil;
              end; {with}
            end; {if}

            {consider next elem of each set:}
            prevp := currtargetp;
            currtargetp := currtargetp^.nextelem;
            if currtargetp = nil then {stop loop}
              stop := true
            else
              currtargetelem := currtargetp^.contents;

            aset := aset^.nextelem;
            if aset = nil then {stop loop}
              stop := true
            else
              currasetelem := aset^.contents;
          end
          else
          if currasetelem > currtargetelem then begin
            {insert curraset elem in front of currtargetp}
            {assert: prevp^.nextelem = currtargetp (<> nil)}
            {misuse prefixlastp}
            new (prefixlastp);
            with prefixlastp^ do begin
              contents := currasetelem;
              nextelem := currtargetp;
            end; {with}
            prevp^.nextelem := prefixlastp;
            prevp := prefixlastp;

            {consider next aset elem:}
            aset := aset^.nextelem;
            if aset = nil then {stop loop}
              stop := true
            else
              currasetelem := aset^.contents;
          end
          else begin {currasetelem < currtargetelem}
            prevp := currtargetp;
            currtargetp := currtargetp^.nextelem;
            if currtargetp = nil then {stop loop}
              stop := true
            else
              currtargetelem := currtargetp^.contents;
          end; {if}
        until stop;

        if aset <> nil then
          prevp^.nextelem := copySet(aset);
      end;
      {else no more actions}
    end; {if}
  end;
  {else no action}
end; {uniteSets}

procedure setUnion (set1 : setref; var set2, intersect : setref);
begin {setUnion}
  uniteSets(set1, set2, intersect, true);
end; {setUnion}

procedure setUnion2 (set1 : setref; var set2 : setref);
var intersect : setref;
begin
  uniteSets(set1, set2, intersect, false);
end; {setUnion2}

procedure setIntersect (set1, set2 : setref; var intersect : setref);
var
        intersectlastp  : setref;
        currset2elem,
        currset1elem    : integer;
        greaterorequal,
        smallerorequal,
        stop            : boolean;
begin
  intersect := nil;

  if (set1 <> nil) and (set2 <> nil) then begin
    currset1elem := set1^.contents;
    currset2elem := set2^.contents;

    stop := false;
    repeat
      greaterorequal := currset1elem >= currset2elem;
      smallerorequal := currset1elem <= currset2elem;

      if currset1elem = currset2elem then begin {non-empty intersection}

	{add currset1elem to rear of intersect:}
	if intersect = nil then begin
          new(intersect);
	  intersectlastp := intersect;
	end
	else
	  with intersectlastp^ do begin
	    new (nextelem);
	    intersectlastp := nextelem;
	  end; {if}

	with intersectlastp^ do begin
	  contents := currset1elem;
	  nextelem := nil;
	end; {with}
      end; {if}

      if greaterorequal then begin
	{consider next set1 elem:}
	set1 := set1^.nextelem;
	if set1 = nil then {stop loop}
	  stop := true
	else
	  currset1elem := set1^.contents;
      end; {if}

      if smallerorequal then begin
        {consider next set2 elem:}
	set2 := set2^.nextelem;
	if set2 = nil then {stop loop}
	  stop := true
	else
	  currset2elem := set2^.contents;
      end; {if}
    until stop;
  end;
  {else no action}
end; {setIntersect}

function isElemOf (elem : integer; aset : setref) : boolean;
var
        currelem : integer;
begin
  if aset = nil then isElemOf := false
  else begin
    currelem := aset^.contents;
    while currelem <> elem do begin
      aset := aset^.nextelem;
      if aset = nil then currelem := elem
      else currelem := aset^.contents;
    end; {while}
    isElemOf := aset <> nil;
  end; {if}
end; {isElemOf}

function excludeElem (elem : integer; var aset : setref) : boolean;
var
        currelem : integer;
        p, prevp : setref;
begin
  if aset = nil then excludeElem := false
  else begin
    p := aset;
    currelem := p^.contents;
    prevp := nil;
    while currelem <> elem do begin
      prevp := p;
      p := p^.nextelem;
      if p = nil then currelem := elem
      else currelem := p^.contents;
    end; {while}
    if p = nil then excludeElem := false
    else
      with p^ do begin
	excludeElem := true;
	if prevp = nil then aset := nextelem
	else prevp^.nextelem := nextelem;
	dispose(p);
      end; {with-if}
  end; {if}
end; {excludeElem}

procedure excludeElem2 (elem : integer; var aset : setref);
var dummy : boolean;
begin
  dummy := excludeElem (elem, aset);
end; {excludeElem2}

procedure disposeSet (aset : setref);
var
        savep : setref;
begin
  while aset <> nil do begin
    savep := aset;
    aset := aset^.nextelem;
    dispose(savep);
  end; {while}
end; {disposeSet}

procedure writeSet (var outfile : text; aset : setref);
begin
  write(outfile, '[');
  if aset <> nil then begin
    with aset^ do begin
      {first elem:}
      write(outfile, contents);
      aset := nextelem;
    end; {with}

    {rest of elems:}
    while aset <> nil do
      with aset^ do begin
	write(outfile, ', ');
	write(outfile, contents);
	aset := nextelem;
      end; {with-while}
  end; {if}

  write(outfile, ']');
end; {writeSet}

procedure writelnSet (var outfile : text; aset : setref);
begin
  writeSet(outfile, aset);
  writeln(outfile);
end; {writelnSet}

end.
