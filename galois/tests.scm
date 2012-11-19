; A unit testing system and suite of unit tests for Galois.

(define run-test
  (lambda (name-string expression intent)
    (if (equal? (eval expression) intent)
        (begin (display
                  (string-append
                    name-string ": pass\n"))
                #t)
        (begin (display
                  (string-append
                    name-string ": fail\n"))
                #f))))

(display "\n--- galois unit tests ---\n\n")

(run-test
  "term substitution"
  '(sub-term '(a b (b a (a))) 'a 3)
  '(3 b (b 3 (3))))

(run-test
  "symbol binding"
  '(bind-symbols '(+ x (+ y z))
                  (list (cons 'x 1) (cons 'y 2) (cons 'z 3)))
  '(+ 1 (+ 2 3)))

(run-test
  "unification"
  '(unify '(* 3 (+ x y z))
          '(* a (OP b c d)))
   (list (cons 'a 3) (cons 'OP '+) (cons 'b 'x) (cons 'c 'y) (cons 'd 'z)))

(run-test
  "rewriting"
  '(consequent-list '(+ y x) commutative-law)
  '((+ x y)))

(run-test
  "rule nonmatch"
  '(consequent-list '(/ y x) commutative-law)
  '((/ y x)))

(run-test
  "additive identity"
  '(consequent-list '(+ 0 4) additive-identity)
  '(4))

(run-test
  "multiplicative identity"
  '(consequent-list '(* 1 9) multiplicative-identity)
  '(9))

(run-test
  "introduction-rule verification"
  '(derived-by? '(= (+ x (* 3 y)) (/ (* x x) (+ 9 z)))
                '(= (* (+ x (* 3 y)) x) (* (/ (* x x) (+ 9 z)) x))
                 balanced-introduction)
    #t)

; This software is released under the GNU Lesser General Public License.
; Copyright 2011, 2012 Daniel Powell
