(define (front-ptr queue) (car queue))

(define (rear-ptr queue) (cdr queue))

(define (set-front-ptr! queue item) (set-car! queue item))

(define (set-rear-ptr! queue item) (set-cdr! queue item))

(define (empty-queue? queue) (null? (front-ptr queue)))

(define (make-queue) (cons '() '())) ; Meaning of '

(define (front-queue queue)
 (if (empty-queue? queue)
  (error "FRONT called with an empty queue" queue)
  (car (front-ptr queue))))

(define (insert-queue! queue item)
 (let ((new-pair (cons item '())))
  (cond ((empty-queue? queue)
         (set-front-ptr! queue new-pair)
         (set-rear-ptr! queue new-pair)
         queue)
   (else
    (set-cdr! (rear-ptr queue) new-pair)
    (set-rear-ptr! queue new-pair)
    queue))))

(define (delete-queue! queue)
 (cond ((empty-queue? queue)
        (error "DELETE! called with an empty queue" queue))
  (else
   (set-front-ptr! queue (cdr (front-ptr queue)))
   queue)))

(define (print-queue queue)
 (display (front-ptr queue)))

; Main
(define q1 (make-queue))
(display q1)
(newline)
(print-queue q1)
(newline)

(insert-queue! q1 'a)
(display q1)
(newline)
(print-queue q1)
(newline)

(insert-queue! q1 'b)
(display q1)
(newline)
(print-queue q1)
(newline)

(delete-queue! q1)
(display q1)
(newline)
(print-queue q1)
(newline)

(delete-queue! q1)
(display q1)
(newline)
