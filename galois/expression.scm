(define sub-term
		; substitutes sub for every instance of target
		; that occurs anywhere in expression
  (lambda (expression target sub)
    (cond ((equal? expression target) sub)
	        ((not (list? expression)) expression)
	        (else (map (lambda (x) (sub-term x target sub)) expression)))))

(define bind-symbols
		; accepts an expression and an association list of symbols and values
		; substitutes value for each instance of each symbol in bind-table
  (lambda (expression bind-table)
    (cond ((null? expression) '())
	        ((null? bind-table) expression)
	        ((assoc expression bind-table) (cdr (assoc expression bind-table)))
	        ((not (list? expression)) expression)
	        (else (append
		              (list (bind-symbols (car expression) bind-table))
		              (bind-symbols (cdr expression) bind-table))))))

(define bound-to
		; accepts a symbol and a bind-table
		; returns the value which is bound to the symbol
  (lambda (symbol bind-table)
    (if (assoc symbol bind-table)
	      (cdr (assoc symbol bind-table))
	    #f)))

; This software is released under the GNU Lesser General Public License.
; Copyright 2011, 2012 Daniel Powell
