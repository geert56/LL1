//{$MODE ISO}
{$modeSwitch ISOIO+}
{$modeSwitch nonLocalGoto+}

unit lex_unit;
interface

const
{$I 'scanner.con'}
{$I 'error.con'}
{$I 'list.con'}
{$I 'lex.con'}
{$I 'kwsyms.con'}
type
{$I 'general.typ'}
{$I 'lex.typ'}
var
{$I 'scanner.var'}
{$I 'error.var'}
{$I 'list.var'}
{$I 'kwtab.var'}
{$I 'lex.var'}

{$I 'lex.ext'}

implementation

{$GOTO ON}

{$I 'list.h'}
{$I 'error.h'}
{$I 'scanner.h'}
{$I 'kwtab.h'}
{$I 'symbuf.h'}
{$I 'lex.h'}

end.
