        LL1Errs         = (NoErr, EpsErr, FirstErr, FirstErr2, FollowErr);

{ GRAMMAR DATA STRUCTURE: }
        kinds           = (grammarkind,
                           rulekind,
                           termornonterm, epsilon,
                           zeroormore,
                           oneormore,
                           condoneormore, optional,
                           factorsequence,
                           alternative,
                           illegal
                          );
        statekind       = (yes, no, undecided);
        nodeptr         = ^nodetyp;
        nodetyp         = record {packed not possible because of parameter
                                  passing requirements}

        {interpretation of states and defined transitions:
         - yes : construct generates empty string, thus terminates
         - no  : construct generates sentence, whether empty not yet sure
         - undecided :
                 not (yes or no)

         transition matrix :  ( X = defined, else not)

              \ to
         from  \  yes  no  und.
                +--------------
            yes |    |    |
            no  |  X |    |
            und.|  X |  X |
        }
                            state    : statekind;
                            {indicates whether the first set is determined:}
                            firstdet : boolean;
                            firstset : setref;

        { for backlink's the following relations are invariant:

                backlink = nil, for kind = grammarkind
                backlink = pointer to root of sub-tree, otherwise

                backlink <> nil ==>
                        not backlink^.kind in [epsilon, illegal, termornonterm]
        }
                            backlink,
                            succp  : nodeptr;
                            {NOTE: deliberately made tagless for dirty trick}
                            kind : kinds;
                            case kinds of
                              epsilon : ();

                              termornonterm :
                                (nextrhsoccur : nodeptr;
                                 nameid   : tokenidrange;
                                );

                              rulekind :
                                (dum1     : nodeptr;      {overlaps with altp}
                                 dum2    : tokenidrange; {overlaps with nameid}
                                 linenr   : cardinal;
                                 visited  : boolean;
                                );

                              grammarkind,
                              zeroormore, oneormore,
                              condoneormore, optional,
                              factorsequence,
                              alternative, illegal :
                                (altp : nodeptr);
                          end; {nodetyp}
