type a = int

external stub : unit -> unit = "mod_a_stub"

let create () =
  stub ();
  42
