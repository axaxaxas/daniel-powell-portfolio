; This software is released under the GNU Lesser General Public License.
; Copyright 2011, 2012 Daniel Powell

(define alg
  (lambda ()
    (list (cons 'rules '())
          (cons 'evaluators '()))))

(define-syntax rule
  (syntax-rules ()
    ((_ antecedent consequent test)
      (list antecedent
            consequent
            (eval 
              `(lambda (binds)
                  (if binds 
                      ,test
                      #f)))))
   ((_ antecedent consequent)
      (list antecedent
           consequent
          (lambda (binds) #t)))))

(define-syntax register
  (syntax-rules (evaluator of in as)
    ((_ name in algebra as rule)
      (begin
        (define name rule)
        (set! (cdr (assoc 'rules algebra)) 
              (append (list rule) (cdr (assoc 'rules algebra))))))
    ((_ evaluator of operator in algebra as proc)
        (set! (cdr (assoc 'evaluators algebra)) 
              (append (list (list operator proc)) (cdr (assoc 'evaluators algebra)))))))

(define evaluator-of
  (lambda (symbol algebra)
    (cadr (assoc symbol (cdr (assoc 'evaluators algebra))))))

(define rules-in
  (lambda (algebra)
    (cdr (assoc 'rules algebra))))

(define evaluators-in
  (lambda (algebra)
    (cdr assoc 'evaluators algebra)))

(define has-evaluator?
  (lambda (symbol algebra)
    (if (assoc symbol (cdr (assoc 'evaluators algebra)))
        #t
        #f)))

(define evaluate-in
  (lambda (expression algebra)
    (if (and (list? expression)
             (has-evaluator? (car expression) algebra)
             (simple? expression))
        (apply (evaluator-of (car expression) algebra) (cdr expression))
        expression)))

(define evaluate-subs-in
  (lambda (expression algebra)
     (cond ((not (list? expression))
            expression)
           ((equal? expression '())
            '())
           ((and (has-evaluator? (car expression) algebra)
                 (simple? expression))
            (apply (evaluator-of (car expression) algebra) (cdr expression)))
           (else (append (list (evaluate-subs-in (car expression) algebra))
                         (evaluate-subs-in (cdr expression) algebra))))))

(define collapse-evaluate
  (lambda (expression algebra)
    (let ((evex (evaluate-subs-in expression algebra)))
          (if (equal? expression evex)
              evex
              (collapse-evaluate evex algebra)))))
        
