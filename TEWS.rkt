;#lang racket/gui

(require racket/gui)
(require racket/draw)
(require racket/tcp)
(require json)
(require racket/include)

(include "conf.rkt") ; minor configurations, fonts, etc
(include "classes.rkt") ; classes (e.g. threat%, rwr%, and functions draw-threats and draw-threatscope
(include "threats.rkt") ; threat definitions and helper functions
(include "paths.rkt") ;drawing path definitions

;this file: minor things, plus "main" function


(define frame (new frame%
		   [label "RWR"]
		   [width 400]
		   [height 400]
		   )
  )
(define (alist->string l) 
  ;http://lists.racket-lang.org/users/archive/2010-November/042915.html
    (string-join 
          (map (lambda (x) (format "~s=~s" (car x) (cdr x))) l) " "))

(define (convert-to-xy distance azimuth)
  (values (* distance (cos azimuth ) )
	  (* distance (sin azimuth ) )
	  )
  )

(define (scale-up-and-center x reverse-factor)
  (- 
    (* x (/ x (* x reverse-factor) ) ;scale-up
       ) (/ threaticonwidth 2)) ;center
  )

(define (block-till-json conn)
  (let ([x (read-json conn)])
    (printf "~a \n" x)
    (if (eof-object? x) (block-till-json conn) x)
    )
  )





(define i 0 )
(define rwr (new rwr% [frame frame]) ) ;instantiate
(define (shutdown) (send rwr shutdown))
(define f (send rwr create)) ;create the window and display
(define (main i)
  ;(sleep 0.017)
  (if (send rwr tcp-ready?)
	  (send rwr accept);blocks!
	  #f)
  (set! i (+ i 1) )
  (send rwr set-i i) ; Frame counter for tracking threats
  (with-handlers ([exn:fail? (lambda (v) (printf "oops ~a\n" v))])
	  (send f update) ;force an update of the display
	  )
  (main i); 'loop'
  )
(main i)
