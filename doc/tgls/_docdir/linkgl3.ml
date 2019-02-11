(*---------------------------------------------------------------------------
   Copyright (c) 2013 Daniel C. Bünzli. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   tgls v0.8.5
  ---------------------------------------------------------------------------*)

(* Tests that the Tgl3 library link flags are correct.

   Compile with:
   ocamlfind ocamlc -linkpkg -package ctypes.foreign,tgls.tgl3 \
                    -o linkgl3.byte linkgl3.ml
   ocamlfind ocamlopt -linkpkg -package ctypes.foreign,tgls.tgl3 \
                      -o linkgl3.native linkgl3.ml

   We try to load a symbol that should only be in the corresponding
   version.  We load directly with ctypes since Tgls functions fail on
   use and we cannot use since we don't have any context (and don't
   want to setup one as this may automatically link other things
   in). *)

open Tgl3
open Ctypes
open Foreign

let str = Printf.sprintf

let lookup min symb =
  try
    ignore (foreign_value symb (ptr void));
    Printf.printf "[OK] Found %s for OpenGL 3.%d\n" symb min;
    exit 0
  with
  | Dl.DL_error _ ->
      Printf.eprintf "[FAIL] %s not found for OpenGL 3.%d\n" symb min;
      exit 1

let yes = ref true
let test minor =
  let link () = if !yes then () else Gl.viewport 0 0 400 400; in
  link (); (* just make sure the library is linked *)
  match minor with
  | 2 -> lookup minor "glProvokingVertex"
  | 3 -> lookup minor "glQueryCounter"
  | x -> Printf.eprintf "[FAIL] Unsupported OpenGL version: 3.%d\n" x; exit 1

let main () =
  let exec = Filename.basename Sys.executable_name in
  let usage = str "Usage: %s [OPTION]\n Tests Tgl3 linking.\nOptions:" exec in
  let minor = ref 2 in
  let options =
    [ "-minor", Arg.Set_int minor,
      " <x> use Use an OpenGL 3.x context (default to 3.2)"; ]
  in
  let anon _ = raise (Arg.Bad "no arguments are supported") in
  Arg.parse (Arg.align options) anon usage;
  test !minor

let () = main ()

(*---------------------------------------------------------------------------
   Copyright (c) 2013 Daniel C. Bünzli

   Permission to use, copy, modify, and/or distribute this software for any
   purpose with or without fee is hereby granted, provided that the above
   copyright notice and this permission notice appear in all copies.

   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
   WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
   MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
   ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
   WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
   ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
   OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  ---------------------------------------------------------------------------*)
