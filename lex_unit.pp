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

{$I 'list.p'}
{$I 'error.p'}
{$I 'scanner.p'}
{$I 'kwtab.p'}
{$I 'symbuf.p'}
{$I 'lex.p'}

end.
