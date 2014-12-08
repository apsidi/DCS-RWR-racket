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





(define i 0 ) ; frame counter
(define rwr (new rwr% [frame frame]) ) ;instantiate the rwr
(define (shutdown) (send rwr shutdown)) ;faster for mike to type while debugging
(define f (send rwr create)) ;create the window and display
(define (main i)
  ;(sleep 0.017) ; not necessary because we're dependent on receiving data from the network.
  ; could be uncommented to enforce a frame rate
  (if (send rwr tcp-ready?) ;every loop, check for new connections (in case old one died, or sim makes two connection attempts)
	  (send rwr accept);blocks!
	  #f)
  (set! i (+ i 1) ) ; increment frame counter
  (send rwr set-i i);TODO: rename to frame-counter because that would be way nicer.
  (with-handlers ([exn:fail? (lambda (v) (printf "oops ~a\n" v))]) ;catch errors, and print without quitting
	  (send f update) ;force an update of the display
	  )
  (main i); 'loop'
  )
(main i)
