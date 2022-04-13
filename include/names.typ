        tokenidrange    = ENDOFTEXT .. maxtokens;

{ NOTE: character strings are aligned on word (= 4 byte) boundaries
        on HP-9000
}
        str4            = packed array[1.. 4] of char;
        str8            = packed array[1.. 8] of char;
        str12           = packed array[1..12] of char;
        str16           = packed array[1..16] of char;
        str20           = packed array[1..20] of char;
        str24           = packed array[1..24] of char;
        str28           = packed array[1..28] of char;
        str32           = packed array[1..32] of char;
        str36           = packed array[1..36] of char;
        str40           = packed array[1..40] of char;
        str44           = packed array[1..44] of char;
        str48           = packed array[1..48] of char;
        str52           = packed array[1..52] of char;
        str56           = packed array[1..56] of char;
        str60           = packed array[1..60] of char;
        str64           = packed array[1..64] of char;

        namereclink     = ^namerec;
        namerec         = record
                            tokenid : tokenidrange;
                            link    : namereclink;
                            case identstridxrange of
                              4 : (lit4  : str4);
                              8 : (lit8  : str8);
                              12: (lit12 : str12);
                              16: (lit16 : str16);
                              20: (lit20 : str20);
                              24: (lit24 : str24);
                              28: (lit28 : str28);
                              32: (lit32 : str32);
                              36: (lit36 : str36);
                              40: (lit40 : str40);
                              44: (lit44 : str44);
                              48: (lit48 : str48);
                              52: (lit52 : str52);
                              56: (lit56 : str56);
                              60: (lit60 : str60);
                              64: (lit   : str64);
                          end; {namerec}
