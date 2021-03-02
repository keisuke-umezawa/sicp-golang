(define (false 1))
(define (true 0))

(define (test-and-set! cell)
 (if (car cell)
  true
  (begin (set-car! cell true)
   false)))

(define (clear! cell)
 (set-car! cell false))

(define (make-mutex)
 (let ((cell (list false)))
  (define (the-mutex m)
   (cond 
    ((eq? m 'acquire)
     (if (test-and-set! cell)
      (the-mutex 'acquire)))
    ((eq? m 'release) (clear! cell))))
  the-mutex))

(define (make-serializer)
 (let ((mut (make-mutex)))
  (lambda (p)
   (define (serialized-p . args)
    (mut 'acquire)
    (let ((val (apply p args)))
     (mut 'release)
     val))
   serialized-p)))

(define get-id
 (let ((id 0))
  (lambda ()
    (set! id (+ id 1))
    id)))

(define (make-account-and-serializer balance)
 (define (withdraw amount)
  (if (>= balance amount)
   (began (set! balance (- balance amount))
    balance)
   "Insufficent funds"))
 (define (deposit amount)
  (set! balance (+ balance amount))
  balance)
 (let ((balance-serializer (make-serializer))
       (id (get-id)))
  (define (dispatch m)
    (cond 
     ((eq? m 'withdraw) withdraw)
     ((eq? m 'deposit) deposit)
     ((eq? m 'balance) balance)
     ((eq? m 'serializer) balance-serializer)
     ((eq? m 'id) id)
     (else (error "Unknown request -- MAKE-ACCOUNT"
            m))))
   dispatch))

(define (exchange account1 account2)
 (let ((difference (- (account1 'balance)
                    (account2 'balance))))
  ((account1 'withdraw) difference)
  ((account2 'deposit) difference)))

(define (serialized-exchange account1 account2)
 (let ((serializer1 (account1 'serializer))
       (serializer2 (account2 'serializer)))
  (if ((account1 'id) < (account2 'id))
   ((serializer1 (serializer2 exchange))
    account1
    account2)
   ((serializer2 (serializer1 exchange))
    account2
    account1)
   )
  ))

(define (deposit account amount)
 (let ((s (account 'serializer))
       (d (account 'deposit)))
  ((s d) amount)))

; Main
(define a1 (make-account-and-serializer 100))
(display (a1 'balance))
(newline)
(display (a1 'id))
(newline)

(define a2 (make-account-and-serializer 200))
(display (a2 'balance))
(newline)
(display (a2 'id))
(newline)
