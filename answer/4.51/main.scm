; Eval
(define (ewal exp env)
 ((analyze exp) env))

; Analyze
(define (analyze exp)
 (cond 
  ((self-evaluating? exp) (analyze-self-evaluating exp))
  ((variable? exp) (analyze-variable exp))
  ((quoted? exp) (analyze-quoted exp))
  ((assignment? exp) (analyze-assignment exp))
  ((definition? exp) (analyze-definition exp))
  ((if? exp) (analyze-if exp))
  ((amb? exp) (analyze-amb exp))
  ((lambda? exp) (analyze-lambda exp))
  ((begin? exp) (analyze-sequence (begin-actions exp)))
  ((cond? exp) (analyze (cond->if exp)))
  ((application? exp) (analyze-application exp))
  (else
   (error "Unknown expression type -- EVAL" exp))))

(define (analyze-self-evaluating exp)
 (lambda (env succeed fail)
  (succeed exp fail)))

(define (analyze-quoted exp)
 (let ((qval (text-of-quotation exp)))
  (lambda (env succeed fail) 
   (succeed qval fail))))

(define (analyze-variable exp)
 (lambda (env succeed fail) (succeed (lookup-variable-value exp env) fail)))

(define (analyze-assignment exp)
 (let ((var (assignment-variable exp))
       (vproc (analyze (assignment-value exp))))
  (lambda (env succeed fail)
   (vproc env
    (lambda (val fail2)
     (let ((old-value
            (lookup-variable-value var env)))
      (set-variable-value! var val env)
      (succeed 'ok
       (lambda ()
        (set-variable-value! var old-value env)
        (fail2)))))
    fail))))

(define (analyze-definition exp)
 (let ((var (definition-variable exp))
       (vproc (analyze (definition-value exp))))
  (lambda (env succeed fail)
   (vproc env
    (lambda (val fail2)
     (define-variable! var val env)
     (succeed 'ok fail2))
    fail))))

(define (analyze-if exp)
 (let ((pproc (analyze (if-predicate exp)))
       (cproc (analyze (if-consequent exp)))
       (aproc (analyze (if-alternative exp))))
  (lambda (env succeed fail)
   (pproc env
    (lambda (pred-value fail2)
     (if 
      (true? pred-value)
      (cproc env succeed fail2)
      (aproc env succeed fail2)))
    fail))))

(define (analyze-lambda exp)
 (let ((vars (lambda-parameters exp))
       (bproc (analyze-sequence (lambda-body exp))))
  (lambda (env succeed fail)
   (succeed (make-procedure vars bproc env) fail))))

(define (analyze-sequence exps)
 (define (sequentially a b)
  (lambda (env succeed fail)
   (a env
    (lambda (a-value fail2)
     (b env succeed fail2))
    fail)))
 (define (loop first-proc rest-procs)
  (if (null? rest-procs)
   first-proc
   (loop (sequentially first-proc (car rest-procs))
    (cdr rest-procs))))
 (let ((procs (map analyze exps)))
  (if (null? procs)
   (error "Empty sequence -- ANALYZE"))
  (loop (car procs) (cdr procs))))

(define (analyze-application exp)
 (let ((pproc (analyze (operator exp)))
       (aprocs (map analyze (operands exp))))
  (lambda (env succeed fail)
   (pproc env
    (lambda (proc fail2)
     (get-args
      aprocs
      env
      (lambda (args fail3)
       (execute-application
        proc args succeed fail3))
      fail2))
    fail))))

(define (get-args aprocs env succeed fail)
 (if (null? aprocs)
  (succeed '() fail)
  ((car aprocs) env
   (lambda (arg fail2)
    (get-args (cdr aprocs)
     env
     (lambda (args fail3)
      (succeed (cons arg args)
       fail3))
     fail2))
   fail)))

(define (analyze-amb exp)
 (let ((cprocs (map analyze (amb-choices exp))))
  (lambda (env succeed fail)
   (define (try-next choices)
    (if (null? choices)
     (fail)
     ((car choices)
      env
      succeed
      (lambda () (try-next (cdr choices))))))
   (try-next cprocs))))

(define (execute-application procedure arguments succeed fail)
 (cond
  ((primitive-procedure? procedure)
   (succeed (apply-primitive-procedure procedure arguments) fail))
  ((compound-procedure? procedure)
   ((procedure-body procedure)
    (extend-environment
     (procedure-parameters procedure)
     arguments
     (procedure-environment procedure))
    succeed
    fail))
  (else (error "Unknown procedure type -- EXECUTE-APPLICATION" procedure))))

; Apply
(define (epply procedure arguments)
 (cond
  ((primitive-procedure? procedure)
   (apply-primitive-procedure procedure arguments))
  ((compound-procedure? procedure)
   (eval-sequence
    (procedure-body procedure)
    (extend-environment
     (procedure-parameters procedure)
     arguments
     (procedure-environment procedure))))
  (else
   (error "Unknown procedure type -- APPLY" procedure))))

(define (list-of-values exps env)
 (if (no-operands? exps)
  '()
  (cons (ewal (first-operand exps) env)
   (list-of-values (rest-operands exps) env))))

(define (eval-if exp env)
 (if (true? (ewal (if-predicate exp) env))
  (ewal (if-consequent exp) env)
  (ewal (if-alternative exp) env)))

(define (eval-sequence exps env)
 (cond
  ((last-exp? exps) (ewal (first-exp exps) env))
  (else (ewal (first-exp exps) env)
   (eval-sequence (rest-exps exps) env))))

(define (eval-assignment exp env)
 (set-variable-value! (assignment-variable exp)
  (ewal (assignment-value exp) env)
  env)
 'ok)

(define (eval-definition exp env)
 (define-variable! (definition-variable exp)
  (ewal (definition-value exp) env)
  env)
 'ok)

; Expression

(define (self-evaluating? exp)
 (cond 
  ((number? exp) #t)
  ((string? exp) #t)
  (else #f)))

(define (variable? exp) (symbol? exp))

(define (quoted? exp)
 (tagged-list? exp 'quote))
 
(define (text-of-quotation exp) (cadr exp))
 
(define (tagged-list? exp tag)
 (if (pair? exp)
  (eq? (car exp) tag)
  #f))

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

(define (if? exp) (tagged-list? exp 'if))

(define (if-predicate exp) (cadr exp))

(define (if-consequent exp) (caddr exp))

(define (if-alternative exp)
 (if (not (null? (cddr exp)))
  (cadddr exp)
  'false))

(define (make-if predicate consequent alternative)
 (list 'if predicate consequent alternative))

(define (begin? exp) (tagged-list? exp 'begin))

(define (begin-actions exp) (cdr exp))

(define (last-exp? seq) (null? (cdr seq)))

(define (first-exp seq) (car seq))

(define (rest-exps seq) (cdr seq))

(define (sequence->exp seq)
 (cond ((null? seq) seq)
  ((last-exp? seq) (first-exp seq))
  (else (make-begin seq))))

(define (make-begin seq) (cons 'begin seq))

(define (cond? exp) (tagged-list? exp 'cond))

(define (cond-clauses exp) (cdr exp))

(define (cond-else-clause? clause)
  (eq? (cond-predicate clause) 'else))

(define (cond-predicate clause) (car clause))

(define (cond-actions clause) (cdr clause))

(define (cond->if exp)
  (expand-clauses (cond-clauses exp)))

(define (expand-clauses clauses)
  (if (null? clauses)
    'false
    (let ((first (car clauses))
          (rest (cdr clauses)))
      (if (cond-else-clause? first)
        (if (null? rest)
          (sequence->exp (cond-actions first))
          (error "ELSE clause isn't last -- COND->IF" clauses))
        (make-if (cond-predicate first)
                 (sequence->exp(cond-actions first))
                 (expand-clauses rest))))))

(define (application? exp) (pair? exp))

(define (operator exp) (car exp))

(define (operands exp) (cdr exp))

(define (no-operands? ops) (null? ops))

(define (first-operand ops) (car ops))

(define (rest-operands ops) (cdr ops))

; Predicate

(define (true? x)
 (not (eq? x #f)))

(define (false? x)
 (eq? x #f))
; Procedure

(define (make-procedure parameters body env)
 (list 'procedure parameters body env))

(define (compound-procedure? p)
 (tagged-list? p 'procedure))

(define (procedure-parameters p) (cadr p))

(define (procedure-body p) (caddr p))

(define (procedure-environment p) (cadddr p))

; Environment
(define (enclosing-environment env) (cdr env))

(define (first-frame env) (car env))

(define the-empty-environment '())

(define (make-frame variables values)
 (cons variables values))

(define (frame-variables frame) (car frame))

(define (frame-values frame) (cdr frame))

(define (add-binding-to-frame! var val frame)
 (set-car! frame (cons var (car frame)))
 (set-cdr! frame (cons val (cdr frame))))

(define (extend-environment vars vals base-env)
 (if (= (length vars) (length vals))
  (cons (make-frame vars vals) base-env)
  (if (< (length vars) (length vals))
   (error "Too many arguments supplied")
   (error "Too few arguments supplied"))))

(define (lookup-variable-value var env)
 (define (env-loop env)
  (define (scan vars vals)
   (cond ((null? vars)
          (env-loop (enclosing-environment env)))
    ((eq? var (car vars))
     (car vals))
    (else (scan (cdr vars) (cdr vals)))))
  (if (eq? env the-empty-environment)
   (error "Unbound variable" var)
   (let ((frame (first-frame env)))
    (scan (frame-variables frame)
     (frame-values frame)))))
 (env-loop env))

(define (set-variable-value! var val env)
 (define (env-loop env)
  (define (scan vars vals)
   (cond ((null? vars)
          (env-loop (enclosing-environment env)))
    ((eq? var (car vars))
     (set-car! vals val))
    (else (scan (cdr vars) (cdr vals)))))
  (if (eq? env the-empty-environment)
   (error "Unbound variable -- SET!" var)
   (let ((frame (first-frame env)))
    (scan (frame-variables frame)
     (frame-values frame)))))
 (env-loop env))

(define (define-variable! var val env)
 (let ((frame (first-frame env)))
  (define (scan vars vals)
   (cond ((null? vars)
          (add-binding-to-frame! var val frame))
    ((eq? var (car vars))
     (set-car! vals val))
    (else (scan (cdr vars) (cdr vals)))))
  (scan (frame-variables frame) (frame-values frame))))

; Setup
(define (setup-environment)
 (let ((initial-env
        (extend-environment
         (primitive-procedure-names)
         (primitive-procedure-objects)
         the-empty-environment)))
  (define-variable! 'true #t initial-env)
  (define-variable! 'false #f initial-env)
  initial-env))

(define (primitive-procedure? proc)
 (tagged-list? proc 'primitive))

(define (primitive-implementation proc) (cadr proc))

(define primitive-procedures
 (list 
  (list 'car car)
  (list 'cdr cdr)
  (list 'cons cons)
  (list 'list list)
  (list 'null? null?)
  (list '+ +)
  (list '- -)
  (list '* *)
  (list '/ /)
  (list '= =)
 ))

(define (primitive-procedure-names)
 (map car primitive-procedures))

(define (primitive-procedure-objects)
 (map (lambda (proc) (list 'primitive (cadr proc))) primitive-procedures))

(define (apply-primitive-procedure proc args)
 (apply (primitive-implementation proc) args))

; Prompt
(define input-prompt ";;; Amb-Eval input:")
(define output-prompt ";;; Amb-Eval value:")

(define (driver-loop)
 (define (internal-loop try-again)
  (prompt-for-input input-prompt)
  (let ((input (read)))
   (if (eq? input 'try-again)
    (try-again)
    (begin
     (newline)
     (display ";;; Starting a new problem ")
     (ambeval
      input
      the-global-environment
      (lambda (val next-alternative)
       (announce-output output-prompt)
       (user-print val)
       (internal-loop next-alternative))
      (lambda ()
       (announce-output
        ";;; There are no more values of")
       (user-print input)
       (driver-loop)))))))
 (internal-loop
  (lambda()
   (newline)
   (display ";;; There is no current problem")
   (driver-loop))))

(define (prompt-for-input string)
 (newline) (newline) (display string) (newline))

(define (announce-output string)
 (newline) (display string) (newline))

(define (user-print object)
 (if (compound-procedure? object)
  (display (list 'compound-procedure
            (procedure-parameters object)
            (procedure-body object)
            '<procedure-env>))
  (display object)))

; Amb
(define (amb? exp) (tagged-list? exp 'amb))

(define (amb-choices exp) (cdr exp))

(define (ambeval exp env succeed fail)
 ((analyze exp) env succeed fail))

; Main
(define the-global-environment (setup-environment))

(driver-loop)
