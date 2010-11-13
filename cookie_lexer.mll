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
  let quoted_RE = Pcre.regexp "\\\\\""
  type cookie_token =
    [ `SEP                              (* cookie separator (i.e. ";") *)
    | `ASSIGNMENT of string * string    (* assignment x=y *)
    | `EOF                              (* end of file *)
    ]
}

rule token = parse
  | [' ' '\t' '\n' '\r'] { token lexbuf }
  | ([^ ' ' '\t' '\n' '\r' '' ' '-'' '\'' '=' ';']+ as name) '='
    ([^ '\n' '\r' '' ' '-'' ';']* as value)
    {
      let val_len = String.length value
      in
      let value =
        if val_len>2 && (value.[0]='"' && value.[val_len-1]='"') then
          let without_quotes = String.sub value 1 (val_len - 2)
          in
          Pcre.replace ~rex:quoted_RE ~templ:"\"" without_quotes
        else
          value
      in
      `ASSIGNMENT (name,value)
    }
  | ';' { `SEP }
  | eof            { `EOF }

