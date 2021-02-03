(define (make-wire)
 (let ((signal-value 0) (action-procedures '()))
  (define (set-my-signal! new-value)
   (if (not (= signal-value new-value))
    (begin (set! signal-value new-value)
     (call-each action-procedures))
    'done))

  (define (accept-action-procedure! proc)
   (set! action-procedures (cons proc action-procedures))
   (proc))

  (define (dispatch m)
   (cond 
    ((eq? m 'get-signal) signal-value)
    ((eq? m 'set-signal!) set-my-signal!)
    ((eq? m 'add-action!) accept-action-procedure!)
    (else (error "Unknown operation -- WIRE" m))))
   dispatch))

(define (get-signal wire)
 (wire 'get-signal))

(define (set-signal! wire new-value)
 ((wire 'set-signal!) new-value))

(define (add-action! wire action-procedures)
 ((wire 'add-action!) action-procedures))

(define (logical-and s1 s2)
 (if (and (= s1 1) (= s2 1)) 1 0))

(define (and-gate a1 a2 output)
 (define (and-action-procedure)
  (let ((new-value
         (logical-and (get-signal a1) (get-signal a2))))
   (after-delay and-gate-delay
    (lamba ()
     (set-signal! output new-value)))))
 (add-action! a1 and-action-procedure)
 (add-action! a2 and-action-procedure)
 'ok)

(define (logical-or s1 s2)
 (if (or (= s1 1) (= s2 1)) 1 0))

(define (or-gate a1 a2 output)
 (define (or-action-procedure)
  (let ((new-value
         (logical-or (get-signal a1) (get-signal a2))))
   (after-delay or-gate-delay
    (lambda ()
     (set-signal! output new-value)))))
 (add-action! a1 or-action-procedure)
 (add-action! a2 or-action-procedure)
 'ok)

(define (after-delay delay acton)
 (add-to-agenda! (+ delay (current-time the-agenda))
  action
  the-agenda))

(define (make-agenda) (list 0))

(define (current-time agenda) (car agenda ))

; Main
(define the-agenda (make-agenda))
(define add-gate-delay 3)
(define or-gate-delay 5)

(define a (make-wire))
(define b (make-wire))
(define c (make-wire))
(define d (make-wire))
(define e (make-wire))
(define s (make-wire))

(display (or-gate a b d))

(display (and-gate a b c))

