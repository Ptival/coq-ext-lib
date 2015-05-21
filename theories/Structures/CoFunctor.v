Require Import ExtLib.Core.Any.

Set Implicit Arguments.
Set Strict Implicit.

Section functor.
  Polymorphic Variable F : Type@{d} -> Type.

  Polymorphic Class CoFunctor : Type :=
  { cofmap : forall {A B : Type@{d}}, (B -> A) -> F A -> F B }.

  Definition ID {T : Type} (f : T -> T) : Prop :=
    forall x, f x = x.

  Polymorphic Class CoPFunctor : Type :=
  { CoFunP : Type -> Type
  ; copfmap : forall {A B} {P : CoFunP B}, (B -> A) -> F A -> F B
  }.

  Existing Class CoFunP.
  Hint Extern 0 (@CoFunP _ _ _) => progress (simpl CoFunP) : typeclass_instances.

  Global Polymorphic Instance CoPFunctor_From_CoFunctor (F : CoFunctor) : CoPFunctor :=
  { CoFunP := Any
  ; copfmap := fun _ _ _ f x => cofmap f x
  }.
End functor.
