{ SET of TERMINAL SYMBOLS: }
        setref          = ^elementtype;
        elementtype     = record
                            contents : integer;
                            nextelem : setref;
                          end;
