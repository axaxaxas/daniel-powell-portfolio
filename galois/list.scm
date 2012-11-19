(define push
  (lambda (x L)
    (append (list x) L)))

(define enqueue
  (lambda (x L)
    (append L (list x))))

(define remove
       ; removes all instances of target from list L
  (lambda (target L)
    (if (null? L)
	'()
	(if (equal? target (car L))
	    (remove target (cdr L))
	    (append
	     (list (car L))
	     (remove target (cdr L)))))))

(define remove-first
	; removes first instance of target from list L
  (lambda (target L)
    (if (null? L)
	'()
	(if (equal? target (car L))
	    (cdr L)
	    (append (list (car L))
		    (remove-first target (cdr L)))))))

(define nth
	   ; returns nth element of list L
  (lambda (L n)
    (cond ((null? L) '())
	  ((zero? n) (car L))
	  (else (nth (cdr L) (- n 1))))))

(define replace-nth
	; replaces nth element of list L with r
  (lambda (L n r)
    (cond ((null? L) '())
	  ((zero? n) (append (list r) (cdr L)))
	  (else (append (list (car L)) (replace-nth (cdr L) (- n 1) r))))))

(define idem-merge
	; takes an arbitrary number of lists and combines them,
	; efficiently removing duplicates.
  (lambda args
    (cond 
			((null? args) '())
	 		((equal? (length args) 1)
	   		(idem-merge (car args) (car args)))
	  	((equal? (length args) 2)
	   		(cond ((null? (cadr args))
		  					(car args))
		 					((null? (car args))
		  					(idem-merge (cadr args))) ; merge when the car runs out to avoid
		 					(else												; duplicates surviving from the cdr
		  					(append (list (car (car args)))
			  								(idem-merge (remove (car (car args)) (car args))
				      											(remove (car (car args)) (cadr args)))))))
	  	(else (idem-merge (car args) (apply idem-merge (cdr args)))))))

(define merge-over-range
  (lambda (proc range)
    (if (zero? range)
	(proc range)
	(idem-merge
	 (proc range)
	 (merge-over-range proc (- range 1))))))

; This software is released under the GNU Lesser General Public License.
; Copyright 2011, 2012 Daniel Powell

