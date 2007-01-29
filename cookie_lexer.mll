(*
  OCaml HTTP - do it yourself (fully OCaml) HTTP daemon

  Copyright (C) <2002-2007> Stefano Zacchiroli <zack@cs.unibo.it>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU Library General Public License as
  published by the Free Software Foundation, version 2.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
  USA
*)

{
  type cookie_token =
    [ `QSTRING of string (* quoted string, argument is the content (no quotes) *)
    | `SEP               (* cookie separator (i.e. ";") *)
    | `TOKEN of string   (* unitary token *)
    | `ASSIGN            (* equal sign *)
    | `EOF               (* end of file *)
    ]
}

rule token = parse
  | [' ' '\t' '\n' '\r'] { token lexbuf }
  | '"' ([^ '"'] | "\\\"")* '"' as lexeme
      {
        let len = String.length lexeme in
        let content = String.sub lexeme 1 (len - 2) in
        `QSTRING content
      }
  | ';' { `SEP }
  | '=' { `ASSIGN }
  | [^ ' ' '\t' '\n' '\r' '' ' '-'' '\'' '<' '=' '>' ',' ';' ':' '?' '/'
       '(' ')' '[' ']' '{' '}' '@' '\\']+ as lexeme
      {
        `TOKEN lexeme
      }
  | eof            { `EOF }

