; Eval and Apply
(define (eval exp env)
 (cond 
  ((self-evaluating? exp) exp)
  ((variable? exp) (lookup-variable-value exp env))
  ((quoted? exp) (text-of-quotation exp))
  ((assignment? exp) (eval-assignment exp env))
  ((definition? exp) (eval-definition exp env))
  ((lambda? exp)
   (make-procedure
    (lambda-parameters exp)
    (lambda-body exp)
    env))
  (else
   (error "Unknown expression type -- EVAL" exp))))

(define (apply procedure artuments)
 (cond
  ((primitive-procedure? procedure)
   (apply-primitive-procedure procedure artuments))
  ((compound-procedure? procedure)
   (eval-sequence
    (procedure-body procedure)
    (extend-envifonment
     (procedure-parameters procedure)
     artuments
     (procedure-environment procedure))))
  (else
   (error "Unknown procedure type -- APPLY" procedure))))

(define (list-of-values exps env)
 (if (no-operands? exps)
  '()
  (cons (eval (first-operand exps) env)
   (list-of-values (rest-operands exps) env))))

(define (eval-if exp env)
 (if (true? (eval (if-predicate exp) env))
  (eval (if-consequent exp) env)
  (eval (if-alternative exp) env)))

(define (eval-sequence exps env)
 (cond
  ((last-exp? exps) (eval (first-exp exps) env))
  (else (eval (first-exp exps) env)
   (eval-sequence (rest-exps exps) env))))

(define (eval-assignment exp env)
 (set-variable-value! (assignment-variable exp)
  (eval (assignment-value exp) env)
  env)
 'ok)

(define (eval-definition exp env)
 (define-variable! (definition-variable exp)
  (eval (definition-value exp) env)
  env)
 'ok)
; Expression
(define (self-evaluating? exp)
 (cond 
  ((number? exp) true)
  ((string? exp) true)
  (else false)))

(define (variable? exp) (symbol? exp))

(define (quoted? exp)
 (tagged-list? exp 'quote))
 
(define (text-of-quotation exp) (cadr exp))
 
(define (tagged-list? exp tag)
 (if (pair? exp)
  (eq? (car exp) tag)
  false))

(define (assignment? exp)
 (tagged-list? exp 'set!))

(define (assignment-variable exp) (cadr exp))

(define (assignment-value exp) (caddr exp))

(define (definition? exp)
 (tagged-list? exp 'define))

(define (definition-variable exp)
 (if (symbol? (cadr exp))
  (cadr exp)
  (caadr exp)))

(define (definition-value exp)
 (if (symbol? (cadr exp))
  (caddr exp)
  (make-lambda (cdadr exp)
   (cddr exp))))

(define (lambda? exp) (tagged-list? exp 'lambda))

(define (lambda-parameters exp) (cadr exp))

(define (lambda-body exp) (cddr exp))

(define (make-lambda parameters body)
 (cons 'lambda (cons parameters body)))

; Main
(define exps1 
 (
  ('define (some-func x)
   x)
  (some-func 5)))

(define env1 ...)

(list-of-values exps1 env1)
