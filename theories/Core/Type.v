Require Import Coq.Setoids.Setoid.
Require Import ExtLib.Structures.Proper.

(** Types are defined by their equivalence relations
 ** Proper elements are the elements for which the equivalence
 ** relation is reflexive.
 **)
Polymorphic Class type (T : Type) : Type :=
{ equal : T -> T -> Prop
; proper : T -> Prop
}.

Polymorphic Definition type_from_equal {T} (r : T -> T -> Prop) : type T :=
{| equal := r
 ; proper := fun x => r x x
 |}.

Polymorphic Definition type_libniz T : type T :=
{| equal := @eq T
 ; proper := fun _ => True
 |}.

Existing Class proper.

Section type.
  Polymorphic Context {T : Type}.
  Variable tT : type T.
(*
  Global Instance Proper_type : Proper T :=
  { proper := fun x => equal x x }.
*)
  Polymorphic Class typeOk :=
  { only_proper : forall x y, equal x y -> proper x /\ proper y
  ; equiv_prefl :> PReflexive proper equal
  ; equiv_sym :> Symmetric equal
  ; equiv_trans :> Transitive equal
  }.

  Global Polymorphic Instance proper_left :
    typeOk ->
    forall x y : T, equal x y -> proper x.
  Proof.
    clear. intros. eapply only_proper in H0; intuition.
  Qed.
  Global Polymorphic Instance proper_right :
    typeOk ->
    forall x y : T, equal x y -> proper y.
  Proof.
    clear. intros. eapply only_proper in H0; intuition.
  Qed.

End type.


Polymorphic Definition type1 (F : Type@{d} -> Type@{r}) : Type :=
  forall {T:Type@{d}}, type T -> type (F T).

Polymorphic Definition type2 (F : Type@{t} -> Type@{u} -> Type@{v}) : Type :=
  forall {T:Type@{t}}, type T -> forall {U:Type@{u}}, type U -> type (F T U).

Polymorphic Definition type3 (F : Type@{t} -> Type@{u} -> Type@{v} -> Type@{w}) : Type :=
  forall {T:Type@{t}}, type T -> forall {U:Type@{u}}, type U -> forall {V:Type@{w}}, type V ->  type (F T U V).

Polymorphic Definition typeOk1 F (tF : type1 F) : Type :=
  forall T tT, @typeOk T tT -> typeOk (tF _ tT).

Polymorphic Definition typeOk2 F (tF : type2 F) : Type :=
  forall T tT, @typeOk T tT -> typeOk1 _ (tF _ tT).

Polymorphic Definition typeOk3 F (tF : type3 F) : Type :=
  forall T tT, @typeOk T tT -> typeOk2 _ (tF _ tT).

Existing Class type1.
Existing Class type2.
Existing Class type3.

Global Polymorphic Instance type_type1 F (tF : type1 F) T (tT : type T) : type (F T) :=
  tF _ tT.

Global Polymorphic Instance type1_type2 F (tF : type2 F) T (tT : type T) : type1 (F T) :=
  tF _ tT.

Global Polymorphic Instance type2_type3 F (tF : type3 F) T (tT : type T) : type2 (F T) :=
  tF _ tT.

Polymorphic Class Oktype T : Type :=
{ the_type :> type T
; the_proof :> typeOk the_type
}.

Coercion the_type : Oktype >-> type.

Global Instance typeOk_typeOk1 F (tF : type1 F) T (tT : type T) : type (F T) :=
  tF _ tT.

Global Instance typeOk1_typeOk2 F (tF : type2 F) T (tT : type T) : type1 (F T) :=
  tF _ tT.

Global Instance typeOk2_typeOk3 F (tF : type3 F) T (tT : type T) : type2 (F T) :=
  tF _ tT.


Section typeOk_from_equal.
  Context {T} (r : relation T).
  Hypothesis p : forall x y, r x y -> r x x /\ r y y.
  Hypothesis sym : Symmetric r.
  Hypothesis trans : Transitive r.

  Theorem typeOk_from_equal  : typeOk (type_from_equal r).
  Proof.
    constructor; auto.
    { simpl. red. auto. }
  Qed.
End typeOk_from_equal.

Theorem typeOk_libniz T : typeOk (type_libniz T).
Proof.
  constructor; unfold equal, type_libniz; auto with typeclass_instances.
  { split; exact I. }
Qed.

(*
Add Parametric  Relation (T : Type) (tT : type T) (tokT : typeOk tT) : T (@equal _ tT)
  symmetry proved by (@equiv_sym _ _ _)
  transitivity proved by (@equiv_trans _ _ _)
  as equal_rel.
*)