; Describes the ring of reals.

(operator '+ 'commutative 'lassociative 'rassociative)
(operator '* 'commutative 'lassociative 'rassociative)
(operator '= 'commutative 'lassociative 'rassociative)

(define real-ring (alg))

(register evaluator of '+ in real-ring as
  +)

(register evaluator of '* in real-ring as
  *)

(register evaluator of '= in real-ring as
  equal?)

(register balanced-introduction in real-ring as
  (rule '(= x y)
        '(= (OP x z) (OP y z))))

(register balanced-elimination in real-ring as
  (rule '(= (OP x y) (OP x z))
        '(= y z)))

(register commutative-law in real-ring as
  (rule '(OP x y)
        '(OP y x)
        '(has-property? (bound-to 'OP binds) 'commutative)))

(register left-associative-law in real-ring as
  (rule '(OP x (OP y z))
        '(OP (OP x y) z)
        '(has-property? (bound-to 'OP binds) 'lassociative)))

(register right-associative-law in real-ring as
  (rule '(OP (OP x y) z)
        '(OP x (OP y z))
        '(has-property? (bound-to 'OP binds) 'rassociative)))

(register additive-identity in real-ring as
  (rule '(+ 0 x)
        'x))

(register multiplicative-identity in real-ring as
  (rule '(* 1 x)
        'x))

; This software is released under the GNU Lesser General Public License.
; Copyright 2011, 2012 Daniel Powell
