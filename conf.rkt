
(define threaticonscale .15);about accurate, maybe should be fine-tuned
(define threaticonwidth 400);NO TOUCH
(define scopescale 1);this should stay at 1
(define listenport 6001)

(define rwr-scopefont ;font for drawing on the threatscope itself
  (make-font #:size 20 
	     #:family 'modern  
	     #:smoothing 'smoothed 
	     #:size-in-pixels? #t )
  )
(define rwr-threatfont ;font for drawing normal threats
  (make-font #:size 120 
	     #:family 'modern  
	     #:smoothing 'smoothed 
	     #:size-in-pixels? #t )
  )

(define rwr-threatfontbold ;font for drawing high priority threats
  (make-font #:size 120 
	     #:family 'modern 
	     #:weight 'bold  
	     #:smoothing 'smoothed 
	     #:size-in-pixels? #t )
  )
