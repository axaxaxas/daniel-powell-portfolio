; Defines Boolean algebra with the and, or, not and implication operators.

(operator '^  'commutative  'lassociative 'rassociative) ; conjunction
(operator 'v  'commutative  'lassociative 'rassociative) ; disjunction
(operator '~)  ; negation
(operator ':-) ; material implication

(define boolean (alg))

(register evaluator of '^ in boolean as
  (lambda (p q)
    (if (and 
          (equal? p 1)
          (equal? q 1))
         1
         0)))

(register evaluator of 'v in boolean as
  (lambda (p q)
    (if (or
          (equal? p 1)
          (equal? q 1))
          1
          0)))

(register evaluator of '~ in boolean as
  (lambda (p)
    (if (equal? p 1)
        0
        1)))

(register evaluator of ':- in boolean as
  (lambda (p q)
    (if (equal? p 0)
        1
        (if (equal? q 1)
            1
            0))))

(register commution in boolean
  as (rule '(OP p q)
           '(OP q p)
           '(has-property? (bound-to 'OP binds) 'commutative)))

(register lassociation in boolean
  as (rule '(OP p (OP q r))
           '(OP (OP p q) r)
           '(has-property? (bound-to 'OP binds) 'lassociative)))

(register rassociation in boolean
  as (rule '(OP (OP p q) r)
           '(OP p (OP q r))
           '(has-property? (bound-to 'OP binds) 'rassociative)))

(register conjunctive-identity in boolean
  as (rule '(^ 1 p)
         'p))

(register conjunctive-absorption in boolean
  as (rule '(^ 0 p)
            0))

(register disjunctive-identity in boolean
  as (rule '(v 0 p)
           'p))

(register disjunctive-absorption in boolean
  as (rule '(v 1 p)
           1))

(register disjunction-elimination in boolean
  as (rule '(v p q)
           'p))

(register implication-distribution in boolean
  as (rule '(:- s (:- p q))
            '(:- (:- s p) (:- s q))))

(register implication-currying in boolean
  as (rule '(:- s (:- p q))
           '(:- (^ s p) q)))

(register implication-elimination in boolean
  as (rule '(:- p q)
           '(~ (^ p (~ q)))))

(register demorgans-law-conjunction in boolean
  as (rule '(~ (^ p q))
           '(v (~ p) (~ q))))

(register demorgans-law-disjunction in boolean
  as (rule '(~ (v p q))
           '(^ (~ p) (~ q))))

; This software is released under the GNU Lesser General Public License.
; Copyright 2011, 2012 Daniel Powell
