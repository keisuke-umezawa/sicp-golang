(define initial-seed 317)

(define (rand-update)
  (random (expt 2 31)))
 
(define (random-init seed)
  (random-seed seed)
  (rand-update))

(define (random-stream seed)
  (define random-from
    (cons-stream (random-init seed)
                 (stream-map (lambda (x) (rand-update)) random-from)))
  random-from)

(define (display-stream s)
 (stream-for-each display-line s))

(define (display-line x)
 (newline)
 (display x))

(define (rand seed requests)
  (define (rand-iter randoms actions)
    (if (stream-null? actions) 
        null
        (let ((request (stream-car actions)))
          (cond ((eq? 'generate request)
                 (cons-stream (stream-car randoms)
                              (rand-iter (stream-cdr randoms) 
                                         (stream-cdr actions))))
                ((eq? 'reset request)
                 (let ((new-randoms (random-stream (random-init seed)))) 
                   (cons-stream (stream-car new-randoms)
                                (rand-iter (stream-cdr new-randoms) 
                                           (stream-cdr (stream-cdr actions))))))
                (else (error "RAND -- unknown request" request))))))
  (rand-iter (random-stream (random-init seed)) 
             requests))
 
(display-stream (rand (cons-stream (list 'generate 'generate 'generate))) 3)
