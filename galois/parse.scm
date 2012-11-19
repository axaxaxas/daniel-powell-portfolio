; recursive implementation of dijkstra's shunting-yard algorithm.

(define tokenize
  (lambda (str)
    (map (lambda (x) (if (string->number x)
			 (string->number x)
			 (string->symbol x)))
		(string-split str))))

(define push-new-tree
  (lambda (operator operand-list)
    (push (append (list operator) (list (cadr operand-list) (car operand-list))) (cddr operand-list))))

(define parse
  (lambda (input)
    (shunt
     (tokenize input)
     '()
     '())))

(define shunt
  (lambda (lex operands operators)
    (if (null? lex)
		(if (member (string->symbol "(") operators)
			#f ; unbalanced parens
			(if (null? operators)
				(car operands)
				(shunt '() (push-new-tree (car operators) operands) (cdr operators))))
		(let ((token (car lex)))
			 (if (lparen? token)
					(shunt (cdr lex) operands (push token operators))
					(if (rparen? token)
							(if (not (member (string->symbol "(") operators))
								#f ; unbalanced parens
								(if (lparen? (car operators)) ; unroll operator stack until we hit the matching paren
										(shunt (cdr lex) operands (cdr operators))
										(shunt lex (push-new-tree (car operators) operands) (cdr operators))))
			 			(if (operator? token)
				 			(if (or (null? operators)
						 		(> (prec token) (prec (car operators))))
					 				(shunt (cdr lex) operands (push token operators))
									(shunt lex (push-new-tree (car operators) operands) (cdr operators)))
				 			(shunt (cdr lex) (push token operands) operators))))))))

; This software is released under the GNU Lesser General Public License.
; Copyright 2011, 2012 Daniel Powell

