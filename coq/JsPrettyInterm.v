Set Implicit Arguments.
Require Export JsSyntax JsSyntaxAux JsPreliminary.

(**************************************************************)
(** ** Implicit Types *)

Implicit Type b : bool.
Implicit Type n : number.
Implicit Type k : int.
Implicit Type s : string.
Implicit Type i : literal.
Implicit Type l : object_loc.
Implicit Type w : prim.
Implicit Type v : value.
Implicit Type r : ref.
Implicit Type T : type.

Implicit Type x : prop_name.
Implicit Type m : mutability.
Implicit Type A : prop_attributes.
Implicit Type An : prop_descriptor.
Implicit Type L : env_loc.
Implicit Type E : env_record. 
Implicit Type D : decl_env_record.
Implicit Type X : lexical_env.
Implicit Type O : object.
Implicit Type S : state.
Implicit Type C : execution_ctx.
Implicit Type P : object_properties_type.

Implicit Type e : expr.
Implicit Type p : prog.
Implicit Type t : stat.

Implicit Type res : res.
Implicit Type R : ret.
Implicit Type o : out.



(****************************************************************)
(** ** Intermediate expression for the Pretty-Big-Step semantic *)


(** Grammar of extended expressions *)

Inductive ext_expr :=

  (** Extended expressions include expressions *)

  | expr_basic : expr -> ext_expr

  (** Extended expressions for lists of expressions *)

  | expr_list_then : (list value -> ext_expr) -> list expr -> ext_expr (* [expr_list_then k es] evaluates all the expressions of [es], then call [k] on the generated list of value. *)
  | expr_list_then_1 : (list value -> ext_expr) -> list value -> list expr -> ext_expr (* [expr_list_then_1 k vs es] has already computed all the values [vs], and starts executing [es]. *)
  | expr_list_then_2 : (list value -> ext_expr) -> list value -> out -> list expr -> ext_expr (* [expr_list_then_2 k vs o es] has evaluated the first of the expressions left, that has returned [o]. *)

  (** Extended expressions associated with primitive expressions *)

  | expr_object_1 : object_loc -> list string -> list value -> ext_expr (* All the expressions of the object have been evaluated. *)

  | expr_access_1 : out -> expr -> ext_expr (* The left expression has been executed *)
  | expr_access_2 : object_loc -> out -> ext_expr (* The left expression has been converted to a location and the right expression is executed. *)
  | expr_access_3 : value -> value -> ext_expr

  | expr_new_1 : out -> list expr -> ext_expr (* The function has been evaluated. *)
  | expr_new_2 : object_loc -> function_code -> list value -> ext_expr (* The arguments too. *)
  | expr_new_3 : object_loc -> out -> ext_expr (* The call has been executed. *)
  | expr_call_1 : out -> list expr -> ext_expr (* The function has been evaluated. *)
  | expr_call_2 : object_loc -> object_loc -> list expr -> ext_expr (* A check is performed on the location returned to know if it's a special one. *)
  | expr_call_3 : object_loc -> function_code -> list value -> ext_expr (* The arguments have been executed. *)
  | expr_call_4 : out -> ext_expr (* The call has been executed. *)

  | expr_unary_op_1 : unary_op -> out -> ext_expr (* The argument have been executed. *)
  | expr_unary_op_2 : unary_op -> value -> ext_expr (* The argument is a value. *)
  | expr_delete_1 : out -> ext_expr
  | expr_delete_2 : string -> bool -> out -> ext_expr
  | expr_delete_3 : ref -> env_loc -> bool -> ext_expr
  | expr_typeof_1 : out -> ext_expr
  | expr_typeof_2 : out -> ext_expr
  | expr_prepost_1 : unary_op -> out -> ext_expr
  | expr_prepost_2 : unary_op -> ret -> out -> ext_expr
  | expr_prepost_3 : unary_op -> ret -> out -> ext_expr
  | expr_prepost_4 : value -> out -> ext_expr
  | expr_unary_op_neg_1 : out -> ext_expr
  | expr_unary_op_bitwise_not_1 : int -> ext_expr
  | expr_unary_op_not_1 : out -> ext_expr

  | expr_binary_op_1 : binary_op -> out -> expr -> ext_expr
  | expr_binary_op_2 : binary_op -> value -> out -> ext_expr
  | expr_binary_op_3 : binary_op -> value -> value -> ext_expr
  | expr_binary_op_add_1 : value -> value -> ext_expr
  | expr_binary_op_add_string_1 : value -> value -> ext_expr
  | expr_puremath_op_1 : (number -> number -> number) -> value -> value -> ext_expr
  | expr_shift_op_1 : (int -> int -> int) -> value -> int -> ext_expr
  | expr_shift_op_2 : (int -> int -> int) -> int -> int -> ext_expr
  | expr_inequality_op_1 : bool -> bool -> value -> value -> ext_expr
  | expr_inequality_op_2 : bool -> bool -> value -> value -> ext_expr
  | expr_binary_op_in_1 : object_loc -> out -> ext_expr
  | expr_binary_op_strict_disequal_1 : out -> ext_expr
  | spec_equal : value -> value -> ext_expr
  | spec_equal_1 : type -> type -> value -> value -> ext_expr
  | spec_equal_2 : bool -> ext_expr
  | spec_equal_3 : value -> (value -> ext_expr) -> value -> ext_expr
  | spec_equal_4 : value -> out -> ext_expr
  | expr_bitwise_op_1 : (int -> int -> int) -> value -> int -> ext_expr
  | expr_bitwise_op_2 : (int -> int -> int) -> int -> int -> ext_expr
  | expr_lazy_op_1 : bool -> out -> expr -> ext_expr
  | expr_lazy_op_2 : bool -> value -> out -> expr -> ext_expr

  | expr_assign_1 : out -> option binary_op -> expr -> ext_expr
  | expr_assign_2 : ret -> out -> binary_op -> expr -> ext_expr
  | expr_assign_3 : ret -> value -> binary_op -> out -> ext_expr
  | expr_assign_4 : ret -> out -> ext_expr
  | expr_assign_5 : value -> out -> ext_expr

(* TODO: we could separate ext_spec from ext_expr,
   and separate red_spec from red_expr *)

  (** Extended expressions for conversions *)

  | spec_to_primitive_pref : value -> option preftype -> ext_expr
  | spec_to_boolean : value -> ext_expr
  | spec_to_number : value -> ext_expr
  | spec_to_number_1 : out -> ext_expr
  | spec_to_integer : value -> ext_expr
  | spec_to_integer_1 : out -> ext_expr
  | spec_to_string : value -> ext_expr
  | spec_to_string_1 : out -> ext_expr
  | spec_to_object : value -> ext_expr

  | spec_to_int32 : value -> (int -> ext_expr) -> ext_expr
  | spec_to_uint32 : value -> (int -> ext_expr) -> ext_expr
  | spec_check_object_coercible : value -> ext_expr

  | spec_to_default : object_loc -> option preftype -> ext_expr
  | spec_to_default_1 : object_loc -> preftype -> preftype -> ext_expr
  | spec_to_default_2 : object_loc -> preftype -> ext_expr
  | spec_to_default_3 : ext_expr
  | spec_to_default_sub_1 : object_loc -> string -> ext_expr -> ext_expr
  | spec_to_default_sub_2 : object_loc -> out -> expr -> ext_expr
  | spec_to_default_sub_3 : out -> ext_expr -> ext_expr
  | spec_to_default_sub_4 : value -> ext_expr -> ext_expr

  | spec_convert_twice : ext_expr -> ext_expr -> (value -> value -> ext_expr) -> ext_expr
  | spec_convert_twice_1 : out -> ext_expr -> (value -> value -> ext_expr) -> ext_expr
  | spec_convert_twice_2 : out -> (value -> ext_expr) -> ext_expr


  (** Extended expressions for conversions *)
  | spec_eq : value -> value -> ext_expr
  | spec_eq0 : value -> value -> ext_expr
  | spec_eq1 : value -> value -> ext_expr
  | spec_eq2 : ext_expr -> value -> value -> ext_expr

  (** Extended expressions for operations on objects *)

  | spec_object_get : value -> prop_name -> ext_expr
  | spec_object_get_1 : object_loc -> prop_descriptor -> ext_expr
  | spec_object_get_2 : object_loc -> option value -> ext_expr
  | spec_object_can_put : object_loc -> prop_name -> ext_expr
  | spec_object_can_put_1 : object_loc -> prop_name -> prop_descriptor -> ext_expr
  | spec_object_can_put_2 : object_loc -> prop_name -> bool -> ext_expr
  | spec_object_can_put_3 : object_loc -> prop_name -> value -> ext_expr
  | spec_object_can_put_4 : object_loc -> prop_descriptor -> ext_expr
  | spec_object_put : object_loc -> prop_name -> value -> bool -> ext_expr
  | spec_object_put_1 : object_loc -> prop_name -> value -> bool -> out -> ext_expr
  | spec_object_put_2 : object_loc -> prop_name -> value -> bool -> prop_descriptor -> ext_expr
  | spec_object_put_3 : object_loc -> prop_name -> value -> bool -> prop_descriptor -> ext_expr
  | spec_object_get_special : value -> prop_name -> ext_expr
  | spec_object_get_special_1 : prop_name -> out -> ext_expr
  | spec_object_put_special : value -> prop_name -> value -> bool -> ext_expr
  | spec_object_has_prop : object_loc -> prop_name -> ext_expr
  | spec_object_delete : object_loc -> prop_name -> bool -> ext_expr
  | spec_object_delete_1 : object_loc -> prop_name -> bool -> prop_descriptor -> ext_expr
  | spec_object_delete_2 : object_loc -> prop_name -> bool -> bool -> ext_expr

  | spec_object_define_own_prop : object_loc -> prop_name -> prop_attributes -> bool -> ext_expr
  | spec_object_define_own_prop_1 : object_loc -> prop_name -> prop_descriptor -> prop_attributes -> bool -> bool -> ext_expr
  | spec_object_define_own_prop_2 : object_loc -> prop_name -> prop_attributes -> prop_attributes -> bool -> ext_expr
  | spec_object_define_own_prop_3 : object_loc -> prop_name -> prop_attributes -> prop_attributes -> bool -> ext_expr
  | spec_object_define_own_prop_4a : object_loc -> prop_name -> prop_attributes -> prop_attributes -> bool -> ext_expr
  | spec_object_define_own_prop_4b : object_loc -> prop_name -> prop_attributes -> prop_attributes -> bool -> ext_expr
  | spec_object_define_own_prop_4c : object_loc -> prop_name -> prop_attributes -> prop_attributes -> bool -> ext_expr
  | spec_object_define_own_prop_5 : object_loc -> prop_name -> prop_attributes -> prop_attributes -> bool -> ext_expr

  (** Extended expressions for operations on references *)

  | spec_get_value : ret -> ext_expr
  | spec_put_value : ret -> value -> ext_expr

  (** Shorthand for calling [red_expr] then [ref_get_value] *)

  | spec_expr_get_value : expr -> ext_expr 
  | spec_expr_get_value_1 : out -> ext_expr
  | spec_expr_get_value_conv : (value -> ext_expr) -> expr -> ext_expr 
  | spec_expr_get_value_conv_1 : (value -> ext_expr) -> out -> ext_expr 

  (** Extended expressions for operations on environment records *)

  | spec_env_record_has_binding : env_loc -> prop_name -> ext_expr
  | spec_env_record_has_binding_1 : env_loc -> prop_name -> env_record -> ext_expr
  | spec_env_record_get_binding_value : env_loc -> prop_name -> bool -> ext_expr
  | spec_env_record_get_binding_value_1 : env_loc -> prop_name -> bool -> env_record -> ext_expr
  | spec_env_record_get_binding_value_2 : prop_name -> bool -> object_loc -> out -> ext_expr
  | spec_env_record_set_binding_value : env_loc -> prop_name -> value -> bool -> ext_expr

  | spec_env_record_create_immutable_binding : env_loc -> prop_name -> ext_expr
  | spec_env_record_initialize_immutable_binding : env_loc -> prop_name -> value -> ext_expr
  | spec_env_record_create_mutable_binding : env_loc -> prop_name -> option bool -> ext_expr
  | spec_env_record_create_mutable_binding_1 : env_loc -> prop_name -> bool -> env_record -> ext_expr
  | spec_env_record_create_mutable_binding_2 : env_loc -> prop_name -> bool -> object_loc -> out -> ext_expr
  | spec_env_record_set_mutable_binding : env_loc -> prop_name -> value -> bool -> ext_expr
  | spec_env_record_set_mutable_binding_1 : env_loc -> prop_name -> value -> bool -> env_record -> ext_expr
  | spec_env_record_delete_binding : env_loc -> prop_name -> ext_expr
  | spec_env_record_delete_binding_1 : env_loc -> prop_name -> env_record -> ext_expr

  | spec_env_record_create_set_mutable_binding : env_loc -> prop_name -> option bool -> value -> bool -> ext_expr
  | spec_env_record_create_set_mutable_binding_1 : out -> env_loc -> prop_name -> value -> bool -> ext_expr

  | spec_env_record_implicit_this_value : env_loc -> prop_name -> ext_expr
  | spec_env_record_implicit_this_value_1 : env_loc -> prop_name -> env_record -> ext_expr

  (** Extended expressions for operations on lexical environments *)

  | spec_lexical_env_get_identifier_ref : lexical_env -> prop_name -> bool -> ext_expr
  | spec_lexical_env_get_identifier_ref_1 : env_loc -> lexical_env -> prop_name -> bool -> ext_expr
  | spec_lexical_env_get_identifier_ref_2 : env_loc -> lexical_env -> prop_name -> bool -> out -> ext_expr

  (** Extended expressions for function calls *)

  (* TODO: the definitions below will change *)
  | spec_execution_ctx_function_call : type -> function_code -> value -> list value -> ext_expr
  | spec_execution_ctx_function_call_1 : type -> function_code -> list value -> out -> ext_expr
  | spec_execution_ctx_binding_instantiation : type -> option object_loc -> function_code -> list value -> ext_expr
  | spec_execution_ctx_binding_instantiation_1 : type -> option object_loc -> function_code -> list value -> env_loc -> ext_expr
  | spec_execution_ctx_binding_instantiation_2 : type -> object_loc -> function_code -> list value -> env_loc -> list string -> ext_expr
  | spec_execution_ctx_binding_instantiation_3 : type -> object_loc -> function_code -> list value -> env_loc -> string -> list string -> value -> out -> ext_expr
  | spec_execution_ctx_binding_instantiation_4 : type -> object_loc -> function_code -> list value -> env_loc -> string -> list string -> value -> out -> ext_expr
  | spec_execution_ctx_binding_instantiation_5 : type -> object_loc -> function_code -> list value -> env_loc -> list string -> out -> ext_expr
  | spec_execution_ctx_binding_instantiation_6 : type -> option object_loc -> function_code -> list value -> env_loc -> ext_expr
  | spec_execution_ctx_binding_instantiation_7 : type -> option object_loc -> function_code -> list value -> env_loc -> list function_declaration -> out -> ext_expr
  | spec_execution_ctx_binding_instantiation_8 : type -> option object_loc -> function_code -> list value -> env_loc -> function_declaration -> list function_declaration -> strictness_flag -> out -> ext_expr
  | spec_execution_ctx_binding_instantiation_9 : type -> option object_loc -> function_code -> list value -> env_loc -> function_declaration -> list function_declaration -> strictness_flag -> object_loc -> out -> ext_expr
  | spec_execution_ctx_binding_instantiation_10 : type -> option object_loc -> function_code -> list value -> function_declaration -> list function_declaration -> strictness_flag -> object_loc -> prop_attributes -> option bool -> ext_expr
  | spec_execution_ctx_binding_instantiation_11 : type -> option object_loc -> function_code -> list value -> env_loc -> function_declaration -> list function_declaration -> strictness_flag -> object_loc -> out -> ext_expr
  | spec_execution_ctx_binding_instantiation_12 : type -> option object_loc -> function_code -> list value -> env_loc -> ext_expr
  | spec_execution_ctx_binding_instantiation_13 : type -> option object_loc -> function_code -> list value -> env_loc -> list string -> out -> ext_expr
  | spec_execution_ctx_binding_instantiation_14 : type -> option object_loc -> function_code -> list value -> env_loc -> string -> list string -> out -> ext_expr
  
  (* Execution of "has_instance" *)

  | spec_has_instance : object_loc -> value -> ext_expr (* todo: reduction rules *)

  (* Throwing of errors *)

  | spec_error : builtin -> ext_expr (* todo: reduction rules *)
  | spec_error_or_cst : bool -> builtin -> value -> ext_expr (* todo: reduction rules *)

  (* Function creation *)

  | spec_creating_function_object : list string -> function_code -> lexical_env -> strictness_flag -> ext_expr
  | spec_creating_function_object_1 : strictness_flag -> object_loc -> out -> ext_expr
  | spec_creating_function_object_2 : strictness_flag -> object_loc -> out -> ext_expr
  | spec_creating_function_object_3 : strictness_flag -> object_loc -> object_loc -> out -> ext_expr
  | spec_creating_function_object_4 : strictness_flag -> object_loc -> out -> ext_expr
  | spec_creating_function_object_5 : object_loc -> out -> ext_expr
  | spec_creating_function_object_6 : object_loc -> out -> ext_expr
  
  | spec_call : function_code -> option value -> list value -> ext_expr
  
  | spec_call_builtin : builtin -> list value -> ext_expr
  
  | spec_call_prog : prog -> value -> list value -> ext_expr

  | spec_builtin_object_new : option value -> ext_expr


(** Grammar of extended statements *)

with ext_stat :=

  (** Extended expressions include statements *)

  | stat_basic : stat -> ext_stat

  (** Extended statements associated with primitive statements *)

  | stat_seq_1 : out -> stat -> ext_stat (* The first statement has been executed. *)
  | stat_seq_2 : ret_or_empty -> out -> ext_stat

  | stat_var_decl_1 : out -> ext_stat (* Ignore its argument and returns [undef] *)

  | stat_if_1 : value -> stat -> option stat -> ext_stat

  (* TODO: arthur suggests changing the order of the arguments so that expr and stat are always the last two arguments *)
  | stat_while_1 : expr -> stat -> value -> ext_stat (* The condition have been executed. *)
  | stat_while_2 : expr -> stat -> out -> ext_stat (* The condition have been executed and converted to a boolean. *)

  | stat_for_in_1 : expr -> stat -> out -> ext_stat
  | stat_for_in_2 : expr -> stat -> out -> ext_stat
  | stat_for_in_3 : expr -> stat -> out -> ext_stat
  | stat_for_in_4 : expr -> stat -> object_loc -> option ret -> option out -> set prop_name -> set prop_name -> ext_stat
  | stat_for_in_5 : expr -> stat -> object_loc -> option ret -> option out -> set prop_name -> set prop_name -> prop_name -> ext_stat
  | stat_for_in_6 : expr -> stat -> object_loc -> option ret -> option out -> set prop_name -> set prop_name -> prop_name -> ext_stat
  | stat_for_in_7 : expr -> stat -> object_loc -> option ret -> option out -> set prop_name -> set prop_name -> out -> ext_stat
  | stat_for_in_8 : expr -> stat -> object_loc -> option ret -> option out -> set prop_name -> set prop_name -> out -> ext_stat
  | stat_for_in_9 : expr -> stat -> object_loc -> option ret -> option out -> set prop_name -> set prop_name -> res -> ext_stat

  | stat_with_1 : stat -> value -> ext_stat (* The expression have been executed. *)

  | stat_throw_1 : out -> ext_stat (* The expression have been executed. *)

  | stat_try_1 : out -> option (string*stat) -> option stat -> ext_stat (* The try block has been executed. *)
  | stat_try_2 : out -> lexical_env -> stat -> option stat -> ext_stat (* The catch block is actived and will be executed. *)
  | stat_try_3 : out -> option stat -> ext_stat (* The try catch block has been executed:  there only stay an optional finally. *)
  | stat_try_4 : res -> out -> ext_stat (* The finally has been executed. *)

  (* Auxiliary forms for performing [red_expr] then [ref_get_value] and a conversion *)

  | spec_expr_get_value_conv_stat : expr -> (value -> ext_expr) -> (value -> ext_stat) -> ext_stat
  | spec_expr_get_value_conv_stat_1 : out -> (value -> ext_expr) -> (value -> ext_stat) -> ext_stat
  | spec_expr_get_value_conv_stat_2 : out -> (value -> ext_stat) -> ext_stat
 

(** Grammar of extended programs *)

with ext_prog :=

  (** Extended expressions include statements *)

  | prog_basic : prog -> ext_prog

  (** Extended programs associated with primitive programs *)

  | prog_seq_1 : out -> prog -> ext_prog (* The first program has been executed. *)
.


(** Coercions *)

Coercion expr_basic : expr >-> ext_expr.
Coercion stat_basic : stat >-> ext_stat.
Coercion prog_basic : prog >-> ext_prog.


(** Shorthand for calling toPrimitive without prefered type *)

Definition spec_to_primitive v :=
  spec_to_primitive_pref v None.


(**************************************************************)
(** ** Extracting outcome from an extended expression. *)

(** The [out_of_ext_*] family of definitions is used by
    the generic abort rule, which propagates exceptions,
    and divergence, break and continues. *)

Definition out_of_ext_expr (e : ext_expr) : option out :=
  match e with
  (* TODO: update later
  | expr_basic _ => None
  | expr_list_then _ _ => None
  | expr_list_then_1 _ _ _ => None
  | expr_list_then_2 _ _ o _ => Some o
  | expr_object_1 _ _ _ => None
  | expr_access_1 o _ => Some o
  | expr_access_2 _ o => Some o
  | expr_new_1 o _ => Some o
  | expr_new_2 _ _ _ => None
  | expr_new_3 _ o => Some o
  | expr_call_1 o _ => Some o
  | expr_call_2 _ _ _ => None
  | expr_call_3 _ _ _ => None
  | expr_call_4 o => Some o
  | expr_unary_op_1 _ o => Some o
  | expr_unary_op_2 _ _ => None
  | expr_binary_op_1 o _ _ => Some o
  | expr_binary_op_2 _ _ _ _ => None
     (* TODO (Arthur does not understand this comment:
        If the `option out' is not `None' then the `out' is returned anyway,
        independently of wheither it aborts or not. *)
        (*
  | expr_binary_op_3 _ _ _ => None
  | expr_binary_op_add_1 _ _ => None
  *)
  | expr_assign_1 o _ _ => Some o
  | expr_assign_2 _ o => Some o
  | expr_assign_2_op _ _ _ o => Some o
  | spec_to_number_1 o => Some o
  | spec_to_integer_1 o => Some o
  | spec_to_string_1 o => Some o
  | spec_to_default_1 _ _ _ => None
  | spec_to_default_2 _ _ => None
  | spec_to_default_3 => None
  | spec_to_default_sub_1 _ _ _ => None
  | spec_to_default_sub_2 _ _ _ => None
  | spec_convert_twice _ _ _ => None
  | spec_convert_twice_1 o _ _ => Some o
  | spec_convert_twice_2 o _ => Some o
  (* TODO: missing new extended forms here *)
  *)
  | _ => None
  (* TODO: remove the line above to ensure that nothing forgotten *)
  end.

Definition out_of_ext_stat (p : ext_stat) : option out :=
  match p with
  (* TODO: update later
  | stat_basic _ => None
  | stat_seq_1 o _ => Some o
  | stat_var_decl_1 o => Some o
  | stat_if_1 o _ _ => Some o
  | stat_if_2 o _ _ => out_some_out o
  | stat_if_3 o _ _ => out_some_out o
  | stat_while_1 _ o _ => Some o
  | stat_while_2 _ _ _ => None
  | stat_while_3 _ _ o => Some o
  | stat_throw_1 o => Some o
  | stat_try_1 o _ _=> Some o
  | stat_try_2 _ _ _ => None
  | stat_try_3 o _ => Some o
  | stat_try_4 _ o => Some o
  | stat_with_1 o _ => Some o
  *)
  | _ => None
  end.

Definition out_of_ext_prog (p : ext_prog) : option out :=
  match p with
  | prog_basic _ => None
  | prog_seq_1 o _ => Some o
  end.





(**************************************************************)
(** ** Rules for propagating aborting expressions *)

(** Definition of aborting programs --
   TODO: define [abort] as "not a normal behavior",
   by taking the negation of being of the form [ter (normal ...)]. *)

Inductive abort : out -> Prop :=
  | abort_div :
      abort out_div
  | abort_break : forall S la,
      abort (out_ter S (res_break la))
  | abort_continue : forall S la,
      abort (out_ter S (res_continue la))
  | abort_return : forall S la,
      abort (out_ter S (res_return la))
  | abort_throw : forall S v,
      abort (out_ter S (res_throw v)).

(** Definition of normal results -- TODO: not used ? *)

Inductive is_res_normal : res -> Prop :=
  | is_res_normal_intro : forall v,
      is_res_normal (res_normal v).

(** Definition of exception results, used in the
    semantics of try-catch blocks. *)

Inductive is_res_throw : res -> Prop :=
  | is_res_throw_intro : forall v,
      is_res_throw (res_throw v).

Inductive is_res_break : res -> Prop :=
  | is_res_break_intro : forall label,
      is_res_break (res_break label).

Inductive is_res_continue : res -> Prop :=
  | is_res_continue_intro: forall label,
      is_res_continue (res_continue label).



(**************************************************************)
(** ** Other rules for propagating aborting expressions *)

(** Definition of the behaviors caught by an exception handler,
    and thus not propagated by the generic abort rule *)

Inductive abort_intercepted : ext_stat -> out -> Prop :=
  | abort_intercepted_stat_try_1 : forall S v cb fio o,
      abort_intercepted (stat_try_1 o (Some cb) fio) (out_ter S (res_throw v))
  | abort_intercepted_stat_try_3 : forall S r fio o,
      abort_intercepted (stat_try_3 o fio) (out_ter S r).


(**************************************************************)
(** ** Auxiliary definition used in identifier resolution *)


(**************************************************************)
(** Macros for exceptional behaviors in reduction rules *)

(* TODO: change to proper transitions into allocated errors *)

(** "Syntax error" behavior *)

Definition out_syntax_error S :=
  out_ter S (res_throw builtin_syntax_error).

(** "Type error" behavior *)

Definition out_type_error S :=
  out_ter S (res_throw builtin_type_error).

(** "Reference error" behavior *)

Definition out_ref_error S :=
  out_ter S (res_throw builtin_ref_error).


(* TODO: needed? *)

Definition out_ref_error_or_undef S (bthrow:bool) :=
  if bthrow
    then (out_ref_error S)
    else (out_ter S undef).


(** The "void" result is used by specification-level functions
    which do not produce any javascript value, but only perform
    side effects. (We return the value [undef] in the implementation.)
    -- TODO : sometimes we used false instead  -- where? fix it.. *)

Definition out_void S :=
  out_ter S undef.

(** [out_reject S bthrow] throws a type error if
    [bthrow] is true, else returns the value [false] *)

Definition out_reject S bthrow :=
  ifb bthrow = true
    then (out_type_error S)
    else (out_ter S false).

(** [out_ref_error_or_undef S bthrow] throws a type error if
    [bthrow] is true, else returns the value [undef] *)



(* [identifier_resolution C x] returns the extended expression
   which needs to be evaluated in order to perform the lookup
   of name [x] in the execution context [C]. Typically, a
   reduction rule that performs such a lookup would have a
   premise of the form [red_expr S C (identifier_resolution C x) o1]. *)

Definition identifier_resolution C x :=
  let lex := execution_ctx_lexical_env C in
  let strict := execution_ctx_strict C in
  spec_lexical_env_get_identifier_ref lex x strict.
