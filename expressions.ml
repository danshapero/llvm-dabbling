
type variable = string

type constant =
    | Int of int
    | Float of float
    | Bool of bool


type data_type = Bool_t
               | Int_t
               | Float_t
               | Function_t of (data_type list) * data_type

type expr =
    | Const of constant
    | Var of variable
    | App of expr * expr list
    | Abs of (variable * data_type) list * expr
    | Let of (variable * expr) list * expr
    | Fix of expr
    | Cond of (expr * expr * expr)
    | Def of (variable * expr)


let string_of_constant c =
  match c with
  | Int i   -> string_of_int i
  | Float x -> string_of_float x
  | Bool p  -> string_of_bool p


let rec string_of_data_type t =
  match t with
    | Bool_t                 -> "bool"
    | Int_t                  -> "int"
    | Float_t                -> "float"
    | Function_t (args, ret) ->
       let args_string =
         String.concat " " (List.map string_of_data_type args)
       and ret_string =
         string_of_data_type ret
       in
       "(-> " ^ args_string ^ " " ^ ret_string ^ ")"

let indent i = String.make i ' '

let rec string_of_expr level expr =
  let string_of_binding (name, expr) =
    name ^ " " ^ (string_of_expr 1 expr)
  and string_of_arg_decl (name, t) =
    name ^ ":" ^ (string_of_data_type t)
  in
  (indent level) ^
  match expr with
  | Const c ->
    string_of_constant c
  | Var v ->
    v
  | App (f, args) ->
    let f = string_of_expr 0 f in
    let args = List.map (string_of_expr 0) args in
    "(" ^ f ^ " " ^ (String.concat " " args) ^ ")"
  | Abs (args, body) ->
    let args = List.map string_of_arg_decl args in
    let decl = "(lambda [" ^ (String.concat " " args) ^ "]" in
    let level = level + 2 in
    let body = string_of_expr level body in
    decl ^ "\n" ^ body ^ ")"
  | Let (bindings, body) ->
    let bindings = List.map string_of_binding bindings
    and binding_level = level + (String.length "(let [") in
    let separator = "\n" ^ (indent binding_level) in
    let decl = "(let [" ^ (String.concat separator bindings) ^ "]" in
    decl ^ "\n" ^ (string_of_expr (level + 2) body) ^ ")"
  | Fix f ->
     "(fix" ^ string_of_expr 1 f ^ ")"
  | Cond (cond, t, f) ->
    let level = level + 4 in
    "(if " ^ (string_of_expr 0 cond) ^ "\n"
    ^ (string_of_expr level t) ^ "\n"
    ^ (string_of_expr level f) ^ ")"
  | Def (var, e) ->
    "(def " ^ var ^ "\n" ^ (string_of_expr (level + 2) e)
