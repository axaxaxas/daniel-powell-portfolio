(define test-apply
  ; accepts an expression and a rewrite rule as a list of the form 
  ; (antecedent consequent condition). if the expression can be unified with 
  ; the antecedent term of the rule, and the condition holds, then 
  ; the rule is applied and the result returned
	(lambda (expression rule)
		(let ((u (unify expression (car rule))))
		  (if (apply (caddr rule) (list u))
			    (bind-symbols (cadr rule) u)
		  	   expression))))

(define derived-by?
  ; accepts two expressions and a rewrite rule, and determines 
  ; whether the rule is sufficient to derive the second 
  ; expression from the first
  (lambda (precedent consequent rule)
    (if (and (apply (caddr rule) (list (unify precedent (car rule))))
             (equal? (bind-symbols (car rule) (unify consequent (cadr rule)))
                      precedent))
         #t
         #f)))

(define consequent-list
	; accepts an expression and a single rewrite rule.
	; returns a list of all expressions which can be derived by
	; one application of the rule to any one term or subterm of the expression
  (lambda (expression rule)
    (cond ((null? expression) '())
	  ((not (list? expression))
	   expression)
	  (else
	   (idem-merge
	    (list (test-apply expression rule))
	    (merge-over-range
	     (lambda (n)
	       (map (lambda (x) (replace-nth expression n x))
		    (consequent-list (nth expression n) rule)))
	     (length expression)))))))

(define rule-branches
	; takes an expression and a list of rules,
	; returns all expressions obtainable
	; by one-step derivation
  (lambda (expression rules)
    (if (null? rules)
	'()
	(idem-merge
	 (consequent-list expression (car rules))
	 (rule-branches expression (cdr rules))))))

(define evaluation-branches
  ; accepts an expression and an algebra
  ; returns a list of all expressions which can be derived by
  ; one application of any semantic evaluator in the algebra
  ; to any one term or subterm of the expression
  (lambda (expression algebra)
    (cond ((null? expression) '())
          ((not (list? expression))
              expression)
          (else
            (idem-merge
              (list (evaluate-in expression algebra))
              (merge-over-range
                (lambda (n)
                  (map (lambda (x) (replace-nth expression n x))
                       (evaluation-branches (nth expression n) algebra)))
                (length expression)))))))

; This software is released under the GNU Lesser General Public License.
; Copyright 2011, 2012 Daniel Powell
