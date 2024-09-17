open Lwt.Infix
open Cohttp
open Cohttp_lwt_unix

(* Define the types for ingredients *)
type ingredient = Tobacco | Paper | Matches

(* Define a function to convert an ingredient to a string *)
let string_of_ingredient = function
  | Tobacco -> "Tobacco"
  | Paper -> "Paper"
  | Matches -> "Matches"

(* Global state *)
let available_ingredients = ref []

(* Synchronization primitives *)
let agent_mutex = Lwt_mutex.create ()
let ingredient_condition = Lwt_condition.create ()

(* Function to simulate the agent providing ingredients *)
let agent_thread () =
  let rec loop () =
    Lwt_mutex.lock agent_mutex >>= fun () ->
    (* Randomly choose two different ingredients to provide *)
    let ingredients = [Tobacco; Paper; Matches] in
    let shuffled = List.sort (fun _ _ -> Random.int 3 - 1) ingredients in
    let ing1, ing2 = List.hd shuffled, List.hd (List.tl shuffled) in
    
    (* Update the shared state and notify waiting smokers *)
    available_ingredients := [ing1; ing2];
    Lwt_condition.broadcast ingredient_condition ();
    Lwt_mutex.unlock agent_mutex;
    Lwt_unix.sleep 1.0 >>= loop
  in
  loop ()

(* Function to simulate a smoker *)
let smoker_thread needed_ingredient () =
  let rec loop () =
    Lwt_mutex.lock agent_mutex >>= fun () ->
    Lwt_condition.wait ingredient_condition >>= fun () ->
    if List.mem needed_ingredient !available_ingredients then (
      (* Simulate smoking *)
      Printf.printf "Smoker with %s ingredient is smoking.\n" (string_of_ingredient needed_ingredient);
      Lwt_mutex.unlock agent_mutex;
      Lwt_unix.sleep 2.0 >>= loop
    ) else (
      Lwt_mutex.unlock agent_mutex;
      loop ()
    )
  in
  loop ()

(* HTTP server callback *)
let server_callback _conn req _body =
  let uri_path = Cohttp.Request.uri req |> Uri.path in
  let cors_headers = Cohttp.Header.add (Cohttp.Request.headers req) "Access-Control-Allow-Origin" "*" in
  match uri_path with
  | "/ingredients" ->
    let body = List.map string_of_ingredient !available_ingredients |> String.concat ", " in
    Server.respond_string ~headers:cors_headers ~status:`OK ~body ()
  | _ ->
    Server.respond_string ~headers:cors_headers ~status:`Not_found ~body:"Not found" ()

(* Main function to start the server and threads *)
let () =
  let port = 8081 in
  let server = Server.make ~callback:server_callback () in

  let start_threads () =
    Lwt_list.iter_p (fun thread -> Lwt.async thread; Lwt.return ()) [
      agent_thread;
      (fun () -> smoker_thread Paper ());
      (fun () -> smoker_thread Tobacco ());
      (fun () -> smoker_thread Matches ())
    ]
  in

  let start_server () =
    Server.create ~mode:(`TCP (`Port port)) server
  in

  Lwt_main.run (
    start_threads () >>= fun () ->
    start_server ()
  )
