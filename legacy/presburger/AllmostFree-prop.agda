module AllmostFree-prop where

open import Representation
open import Properties
open import Properties-prop
open import Semantics
open import Semantics-prop
open import Equivalence

open import Data.Nat as ℕ using (ℕ)
import Data.Nat.Divisibility as Ndiv
import Data.Nat.LCM as LCM
import Data.Nat.Properties as NProp

open import Data.Integer as ℤ using (ℤ)
import Data.Integer.Divisibility as Zdiv
open import Data.Integer.DivMod
open import Data.Integer.Divisibility.Properties
import Data.Integer.Properties as ZProp

open import Data.Fin as Fin using (Fin)
import Data.Fin.Properties as FProp

open import Data.Product as Prod
open import Data.Vec
open import Function

open import Function
open import Relation.Nullary.Decidable
open import Relation.Binary.PropositionalEquality
import Relation.Binary.SetoidReasoning as ≋-Reasoning


lcm-:∣′ : ∀ {n f} → Free0 {n} f → ∃ (λ k → All∣′ k f)
lcm-:∣′ T        = (-, +[1+ 0 ]) , T
lcm-:∣′ F        = (-, +[1+ 0 ]) , F
lcm-:∣′ (e :≤0)  = (-, +[1+ 0 ]) , _ :≤0
lcm-:∣′ (e :≡0)  = (-, +[1+ 0 ]) , _ :≡0
lcm-:∣′ (e :≢0)  = (-, +[1+ 0 ]) , _ :≢0
lcm-:∣′ (k :| e) = (-, k) , ∣′-refl [ k ]:| _
lcm-:∣′ (k :|̸ e) = (-, k) , ∣′-refl [ k ]:|̸ _
lcm-:∣′ (φ :∧ ψ) =
  let ((k , k≠0) , φ′) = lcm-:∣′ φ; ((l , l≠0) , ψ′) = lcm-:∣′ ψ
      (_ , lcm) = LCM.lcm ℤ.∣ k ∣ ℤ.∣ l ∣ in
  (-, lcm≠0 k≠0 l≠0) , ∣m⇒∣′m (proj₁ (LCM.LCM.commonMultiple lcm)) ∣′-All∣′ φ′
                    :∧ ∣m⇒∣′m (proj₂ (LCM.LCM.commonMultiple lcm)) ∣′-All∣′ ψ′
lcm-:∣′ (φ :∨ ψ) =
  let ((k , k≠0) , φ′) = lcm-:∣′ φ; ((l , l≠0) , ψ′) = lcm-:∣′ ψ
      (_ , lcm) = LCM.lcm ℤ.∣ k ∣ ℤ.∣ l ∣ in
  (-, lcm≠0 k≠0 l≠0) , ∣m⇒∣′m (proj₁ (LCM.LCM.commonMultiple lcm)) ∣′-All∣′ φ′
                    :∨ ∣m⇒∣′m (proj₂ (LCM.LCM.commonMultiple lcm)) ∣′-All∣′ ψ′

⟦_mod-E_|:_[_]⟧ : ∀ {n t} → Unit-E {ℕ.suc n} t → (σ : Notnull) → ∀ k → k Zdiv.∣′ proj₁ σ →
                  ∀ q x ρ → ⟦ k :| t ⟧ (x ∷ ρ) ↔ ⟦ k :| t ⟧ (q ℤ.* proj₁ σ ℤ.+ x ∷ ρ)
⟦ val v             mod-E σ       |: k [ k∣σ ]⟧ q x ρ = ↔-refl
⟦ varn p + e        mod-E σ , σ≠0 |: k [ k∣σ ]⟧ q x ρ = begin⟨ ↔-setoid ⟩
  let t = toExp (Lin-E (ℕ.suc p)) e in
  k Zdiv.∣′ ⟦ t ⟧e (x ∷ ρ) ≡⟨ cong (k Zdiv.∣′_) (lin-ext₁ e x (q ℤ.* σ ℤ.+ x) ρ) ⟩
  k Zdiv.∣′ ⟦ t ⟧e (q ℤ.* σ ℤ.+ x ∷ ρ) ∎ where open ≋-Reasoning
⟦ c [ prf ]*var0+ e mod-E σ , σ≠0 |: k [ k∣σ ]⟧ q x ρ = begin⟨ ↔-setoid ⟩
  let t = toExp (Lin-E 1) e; qσ = q ℤ.* σ in
  k Zdiv.∣′ c ℤ.* x ℤ.+ (⟦ t ⟧e (x ∷ ρ))
    ≈⟨ ∣′m∣′n⇒∣′m+n (∣′n⇒∣′m*n c (∣′n⇒∣′m*n q k∣σ))
     , flip ∣′m+n∣′m⇒∣′n (∣′n⇒∣′m*n c (∣′n⇒∣′m*n q k∣σ)) ⟩
  k Zdiv.∣′ c ℤ.* qσ ℤ.+ (c ℤ.* x ℤ.+ (⟦ t ⟧e (x ∷ ρ)))
      ≡⟨ cong (k Zdiv.∣′_) (sym (ZProp.+-assoc (c ℤ.* qσ) (c ℤ.* x) (⟦ t ⟧e (x ∷ ρ)))) ⟩
  k Zdiv.∣′ (c ℤ.* qσ ℤ.+ c ℤ.* x) ℤ.+ (⟦ t ⟧e (x ∷ ρ))
    ≡⟨ cong₂ (λ m n → k Zdiv.∣′ m ℤ.+ n) (sym (ZProp.*-distribˡ-+ c qσ x))
                                        (lin-ext₁ e x (qσ ℤ.+ x) ρ) ⟩
  k Zdiv.∣′ c ℤ.* (qσ ℤ.+ x) ℤ.+ (⟦ t ⟧e (q ℤ.* σ ℤ.+ x ∷ ρ))
    ∎ where open ≋-Reasoning


⟦_mod_⟧ : ∀ {n f σ} → Free0 {ℕ.suc n} f → All∣′ σ f →
          ∀ q x ρ → ⟦ f ⟧ (x ∷ ρ) ↔ ⟦ f ⟧ (q ℤ.* proj₁ σ ℤ.+ x ∷ ρ)
⟦ T      mod T               ⟧ q x ρ = ↔-refl
⟦ F      mod F               ⟧ q x ρ = ↔-refl
⟦ e :≤0  mod t :≤0           ⟧ q x ρ = begin⟨ ↔-setoid ⟩
  ⟦ t :≤ :0 ⟧ (x ∷ ρ) ≡⟨ cong (ℤ._≤ ℤ.+ 0) (lin-ext₁ (proj₂ (Free0-Lin-E e)) x _ ρ) ⟩
  ⟦ t :≤ :0 ⟧ (_ ∷ ρ) ∎ where open ≋-Reasoning
⟦ e :≡0  mod t :≡0           ⟧ q x ρ = begin⟨ ↔-setoid ⟩
  ⟦ t :≡ :0 ⟧ (x ∷ ρ) ≡⟨ cong (_≡ ℤ.+ 0) (lin-ext₁ (proj₂ (Free0-Lin-E e)) x _ ρ) ⟩
  ⟦ t :≡ :0 ⟧ (_ ∷ ρ) ∎ where open ≋-Reasoning
⟦ e :≢0  mod t :≢0           ⟧ q x ρ = ↔¬_ $′ begin⟨ ↔-setoid ⟩
  ⟦ t :≡ :0 ⟧ (x ∷ ρ) ≡⟨ cong (_≡ ℤ.+ 0) (lin-ext₁ (proj₂ (Free0-Lin-E e)) x _ ρ) ⟩
  ⟦ t :≡ :0 ⟧ (_ ∷ ρ) ∎ where open ≋-Reasoning
⟦_mod_⟧ {σ = σ} (k :| e) (k|σ [ k≠0 ]:| t) q x ρ = ⟦ e mod-E σ |: _ [ k|σ ]⟧ q x ρ
⟦_mod_⟧ {σ = σ} (k :|̸ e) (k|σ [ k≠0 ]:|̸ t) q x ρ = ↔¬ ⟦ e mod-E σ |: _ [ k|σ ]⟧ q x ρ
⟦ φ :∧ ψ mod divφ :∧ divψ    ⟧ q x ρ = ⟦ φ mod divφ ⟧ q x ρ ↔× ⟦ ψ mod divψ ⟧ q x ρ
⟦ φ :∨ ψ mod divφ :∨ divψ    ⟧ q x ρ = ⟦ φ mod divφ ⟧ q x ρ ↔⊎ ⟦ ψ mod divψ ⟧ q x ρ

⟦finite_when_:|_⟧_ : ∀ {n f} (φ : Free0 {ℕ.suc n} f) (σ : Notnull) → All∣′ σ f → ∀ ρ →
                ∃ (λ (x : ℤ)                 → ⟦ f ⟧ (x             ∷ ρ))
              ↔ ∃ (λ (k : Fin ℤ.∣ proj₁ σ ∣) → ⟦ f ⟧ (ℤ.+ Fin.toℕ k ∷ ρ))
⟦finite φ when (σ , σ≠0) :| divφ ⟧ ρ = flip _,_ (Prod.map (ℤ.+_ ∘′ Fin.toℕ) id) $ uncurry $
  λ x ⟦f⟧k∷ρ →
    let ∣σ∣≢0 = to≢0 [∣ σ≠0 ∣≠0] ∘′ cong ℤ.pos
        d     = ℕ.suc (ℕ.pred ℤ.∣ σ ∣)
        d≡d'  = sym $ NProp.m≢0⇒m≡s[pred[m]] ∣σ∣≢0
        divφ′ : All∣′ (ℤ.+ d , +[1+ _ ]) _
        divφ′ = subst (σ Zdiv.∣′_) (sym $ cong ℤ.pos d≡d') m∣′∣m∣ ∣′-All∣′ divφ
        q     = x divℕ d
        r<d   = n%d<d x (ℕ.pred ℤ.∣ σ ∣)
        r     = Fin.fromℕ≤ r<d
        r-eq  : ∀ {d'} → (eq : d ≡ d') → Fin.toℕ (subst Fin eq r) ≡ Fin.toℕ r
        r-eq  = λ where refl → refl
        eq    : x ≡ q ℤ.* ℤ.+ d ℤ.+ ℤ.+ (Fin.toℕ r)
        eq    = let open ≡-Reasoning in begin
                x
                  ≡⟨ a≡a%n+[a/n]*n x (ℕ.pred d) ⟩
                ℤ.+ (x modℕ d) ℤ.+ x divℕ d ℤ.* ℤ.+ d
                  ≡⟨ cong (λ r → ℤ.+ r ℤ.+ q ℤ.* ℤ.+ d) (sym (FProp.toℕ-fromℕ≤ r<d)) ⟩
                ℤ.+ Fin.toℕ r ℤ.+ x divℕ d ℤ.* ℤ.+ d
                  ≡⟨ ZProp.+-comm (ℤ.+ Fin.toℕ r) (q ℤ.* ℤ.+ d) ⟩
                q ℤ.* ℤ.+ d ℤ.+ ℤ.+ Fin.toℕ r
                ∎
    in _,_ (subst Fin d≡d' r)
     $′ subst (λ x → ⟦ _ ⟧ (ℤ.+ x ∷ ρ)) (sym (r-eq d≡d'))
     $′ proj₂ (⟦ φ mod divφ′ ⟧ q (ℤ.+ Fin.toℕ r) ρ)
     $′ subst (λ x → ⟦ _ ⟧ (x ∷ ρ)) eq
     ⟦f⟧k∷ρ

{-

  Af0-Fin-reduc : ∀ {n} (φ : Af0 (ℕs n)) (σ : Dall (proj₁ φ)) ρ → P.∃ (λ x → [| proj₁ φ |] (x ∷ ρ)) ↔ [| proj₁ (Finite-disjunction {_} {_} {0} (proj₁ φ , (isunitary-islin ∘ allmost-free0-isunitary) (proj₂ φ)) (Vmap (λ u → (val (+ toℕ u) , val-islinn-i)) (allFin ((∣′_∣′ ∘ proj₁ ∘ proj₁) σ)))) |] ρ
  Af0-Fin-reduc {n} φ σ ρ with Finite-disjunction-sem {_} {_} {0} (proj₁ φ , isunitary-islin (allmost-free0-isunitary (proj₂ φ))) (Vmap (λ u → val (+ toℕ u) , val-islinn-i) (allFin ∣′ proj₁ (proj₁ σ) ∣′)) ρ | Af0-Fin-equiv₁ φ σ ρ
  ... | P._,_ P₁ Q₁ | PQ = P._,_ (λ h → Q₁ (P._,_ (P.proj₁ (PQ h)) (subst (λ u → [| proj₁ φ |] ([| proj₁ u |]e (+ 0 ∷ ρ) ∷ ρ)) (Fin-Vmap-compat {_} {_} {Lin′ (ℕs n) 1} (λ (u : Fin ((∣′_∣′ ∘ proj₁ ∘ proj₁) σ)) → (val (+ toℕ u) , val-islinn-i)) (allFin ((∣′_∣′ ∘ proj₁ ∘ proj₁) σ)) (P.proj₁ (PQ h))) (subst (λ u → [| proj₁ φ |] ([| val (+ toℕ u) |]e (+ 0 ∷ ρ) ∷ ρ)) (sym (allFin-inv (P.proj₁ (PQ h)))) (P.proj₂ (PQ h)))))) (λ h → P.proj₂ (Af0-Fin-equiv φ σ ρ) (P._,_ (P.proj₁ (P₁ h)) (subst (λ u → [| proj₁ φ |] ([| val (+ toℕ u) |]e (+ 0 ∷ ρ) ∷ ρ)) (allFin-inv (P.proj₁ (P₁ h))) (subst (λ u → [| proj₁ φ |] ([| proj₁ u |]e (+ 0 ∷ ρ) ∷ ρ)) (sym (Fin-Vmap-compat {_} {_} {Lin′ (ℕs n) 1} (λ (u : Fin ((∣′_∣′ ∘ proj₁ ∘ proj₁) σ)) → (val (+ toℕ u) , val-islinn-i)) (allFin ((∣′_∣′ ∘ proj₁ ∘ proj₁) σ)) (P.proj₁ (P₁ h)))) (P.proj₂ (P₁ h))))))
-}
