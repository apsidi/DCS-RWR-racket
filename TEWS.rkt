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

;this file: minor things, plus "main" loop


(define frame (new (class frame%	;make the window for our display
			  ;add our code to handle being closed
			  ; currently breaks the terminal it's run in, and requires a user break (C-c) type in the racket terminal
			  ; ...not sure why - or how to fix this with anything we were taught in class.
			  (super-new)
			  (define/augment (on-close)
					  (printf "Closing!...")
					  (send rwr shutdown)
					  (exit)
					  )
			  )
		   [label "RWR"]
		   [width 400]
		   [height 400]
		   )
  )
(define (alist->string l) 
  ;http://lists.racket-lang.org/users/archive/2010-November/042915.html
    (string-join 
          (map (lambda (x) (format "~s=~s" (car x) (cdr x))) l) " "))

(define (convert-to-xy distance azimuth) ;take the polar coordinates from the sim and 
  ; convert to an x,y (to be later used for drawing after shifting the origin)
  (values (* distance (cos azimuth ) )
	  (* distance (sin azimuth ) )
	  )
  )

(define (scale-up-and-center x reverse-factor) ;used to convert between scaled-down 'pixels' 
  ;when drawing threat-icon paths to the regular size pixels of the threatscope for positioning
  (- 
    (* x (/ x (* x reverse-factor) ) ;scale-up
       ) (/ threaticonwidth 2)) ;center
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
  (with-handlers ([exn:fail? (lambda (v) (printf "." ))]) ;catch errors, continue anyway (until we get a better way of handling errors)
	  (send f update) ;force an update of the display (thereby calling draw-threats and such in the paint callback)
	  )
  (main i); 'loop'
  )
(main i)
