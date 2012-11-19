(define *gsymtab* '()) ; general symbol table for galois instance
					   ; it is an association list, with a list of 
			           ; attributes cons'd to each key symbol

(define add-gsym
	; mutator. adds a new symbol to gsymtab. accepts a cons cell
  (lambda (x)
    (set! *gsymtab*
	        (append (list x) *gsymtab*))))

(define gsym?
     ; determines if a symbol is in the current galois symbol table
  (lambda (x)
    (if (not (assoc x *gsymtab*))
	#f
	#t)))

(define has-property?
    ; determines if a symbol has a given property in the galois symbol table
  (lambda (symbol property)
    (if (and (gsym? symbol)
	      (member property (cdr (assoc symbol *gsymtab*))))
	 #t
	 #f)))

(define freevar?
	; accepts a scheme symbol and determines whether it can act as a free variable
	; in a galois expression
  (lambda (arg)
    (if (and 								
	 (not (list? arg))
	 (not (number? arg))
	 (not (gsym? arg)))
	#t
	#f)))

(define has-freevars?
  ; accepts a galois expression and determines
  ; whether any of its terms or subterms are free variables
  (lambda (expression)
    (cond ((null? expression) #f)
          ((freevar? expression) #t)
          ((not (list? expression)) #f)
          (else
            (or (has-freevars? (car expression))
                (has-freevars? (cdr expression)))))))

(define compound-exp?
  ; accepts a galois expression and determines
  ; whether any of its terms are themselves multi-term expressions
  (lambda (expression)
    (cond ((null? expression) #f)
          ((and (not (list? (car expression)))
                (not (compound-exp? (cdr expression))))
           #f)
          (else #t))))

(define simple?
  ; accepts a galois expression and determines
  ; if it is a simple expression -- that is, if it
  ; is neither a compound expression nor contains 
  ; any free variables
  (lambda (expression)
    (and (not (has-freevars? expression)) (not (compound-exp? expression)))))

; This software is released under the GNU Lesser General Public License.
; Copyright 2011, 2012 Daniel Powell
