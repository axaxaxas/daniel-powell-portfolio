(define bind-over-system
  ; accepts a system of expressions and a bind-table
  ; returns a new system with bindings applied
  (lambda (sys bind-table)
    (if (equal? sys '())
        '()
        (append (list (bind-symbols (car sys) bind-table))
               (bind-over-system (cdr sys) bind-table)))))

(define all-equal?
  (lambda (sys comparand)
    (if (null? sys)
        #t
        (and (equal? (car sys) comparand)
             (all-equal? (cdr sys) comparand)))))

(define equal-under-bindings?
  ; apply a bind-table to all entries in a system,
  ; evaluate them as deeply as possible, and test for
  ; equality
  (lambda (sys bind-table comparand algebra)
    (all-equal? 
      (map (lambda (x) (collapse-evaluate x algebra)) 
           (bind-over-system sys bind-table))
      comparand)))

; This software is released under the GNU Lesser General Public License.
; Copyright 2011, 2012 Daniel Powell
