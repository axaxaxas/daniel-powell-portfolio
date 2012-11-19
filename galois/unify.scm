(define unify
	; provides an interface to recunify below,
	; allowing the empty list to act as a default
	; argument for recunify's bind-table
  (lambda (expression pattern)
    (recunify expression pattern '())))

(define recunify
	; accepts an expression and a pattern with which to unify it.
	; if unification is possible, returns a new bind-table associating
	; values from expression with symbols in pattern.
	; if unification is impossible, returns false
  (lambda (expression pattern bind-table)
    (if (not bind-table)
	      #f
	      (if (and (null? expression)
		             (null? pattern))
	          bind-table
	          (if (or (null? expression)
		                (null? pattern))
		             #f
		            (let ((lpattern (bind-symbols pattern bind-table)))
		               (if (freevar? lpattern)
		                  (append (list (cons lpattern expression)) bind-table)
		                  (if (or 
			                      (not (list? lpattern))
			                      (not (list? expression)))
			                    (if (equal? expression lpattern)
			                         bind-table
			                         #f)
			                    (recunify (car expression) (car lpattern)
				                    (recunify (cdr expression) (cdr lpattern)
					                    bind-table))))))))))

; This software is released under the GNU Lesser General Public License.
; Copyright 2011, 2012 Daniel Powell

