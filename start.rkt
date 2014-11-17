;#lang racket/gui

(require racket/gui)
(require racket/draw)
(require json)

(define threaticonscale .15);about accurate, maybe should be fine-tuned
(define threaticonwidth 400);NO TOUCH
(define scopescale 1);this should stay at 1
(define frame (new frame%
		   [label "RWR"]
		   [width 400]
		   [height 400]
		   )
  )


(define jsonstrexample "{\"ID\":\"16777984\",\"Power\":0.794159,\"Azimuth\":0.043698,\"Priority\":260.79,\"SignalType\":\"lock\",\"Type\":\"mig-29\"}" )

(define (convert-to-xy distance azimuth)
  (values (* distance (cos azimuth ) )
	  (* distance (sin azimuth ) )
	  )
  )

(define rwr-threatfont
  (make-font #:size 120 
	     #:family 'modern  
	     #:smoothing 'smoothed 
	     #:size-in-pixels? #t )
  )

(define rwr-threatfontbold
  (make-font #:size 120 
	     #:family 'modern 
	     #:weight 'bold  
	     #:smoothing 'smoothed 
	     #:size-in-pixels? #t )
  )

(define rwr%
  (class object%
	 (init-field frame)
	 (define canvas null)
	 (super-new)
	 (define/public (get-canvas) canvas)
	 (define/public (get-frame) frame)
	 (define/public (create) 
			(set! canvas (new canvas% [parent frame]
			     [paint-callback
			       (lambda (canvas dc)
				 (send dc set-brush "black" 'transparent)
				 (send dc set-background "black")
				 (send dc set-text-mode 'transparent)
				 (send dc set-text-foreground "green")
				 (send dc set-smoothing 'smoothed)
				 (send dc clear)


				 (send dc set-scale scopescale scopescale)
				 (send dc set-pen "green" 1 'solid)
				 (send dc draw-rectangle 0 0 400 400)
				 (send dc set-pen "green" 2 'solid)
				 (draw-threatscope dc)

				 (send dc set-pen "green" 10 'solid)
				 (send dc set-scale threaticonscale threaticonscale)
				 (draw-threats dc)

				 ;(send dc scale .5 .5)

				 )
			       ]
			     )
			  )
			(send frame show #t)
			this)
	 (define/public (update) 
			(send canvas refresh-now)
			this)
	 (define/public (connect host port) 1);connect to a tcp server and port with our data...
	 (define/public (accept port) 1); OR receive tcp connects on a port
	 (define/public (parse jsonarray) 1); parse a line of json and handle it
	 )
  )
(define (get-threatstring type)
  "29"
  )
(define (airborne-type type)
  1
  )
(define (high-priority threat%) 
  1
  )
(define threat%
  (class object%
	 (init-field [jsonstr ""])
	 (define jsexpr null)
	 (define azimuth 0)
	 (define id 1)
	 (define power 0.5)
	 (define priority 100)
	 (define signaltype "")
	 (define radartype "")
	 (define airborne 0)
	 (define highpriority 0)
	 (define primary 0)
	 (define tracking 0)
	 (define newthreat 0)
	 (super-new)
	 (define/public (parse)
			(set! jsexpr (string->jsexpr jsonstr) )
			(set! azimuth (hash-ref jsexpr 'Azimuth) )
			(set! id (hash-ref jsexpr 'ID) )
			(set! power (hash-ref jsexpr 'Power) )
			(set! priority (hash-ref jsexpr 'Priority) )
			(set! signaltype (hash-ref jsexpr 'SignalType) )
			(set! radartype (hash-ref jsexpr 'Type) )
			(define airborne (airborne-type radartype) )
			(define highpriority (high-priority this))

			this)
	 (define/public (get-distance-from-center) (* 1 (/ threaticonwidth 4)))
	 (define/public (get-azimuth) azimuth)
	 (define/public (draw dc centerx centery) 
			(define x (scale-up-and-center centerx threaticonscale))
			; x and y coordinates to center the threatobj icon on
			(define y (scale-up-and-center centery threaticonscale))
			; draw a single threatobj
			(if airborne (send dc draw-path rwr-airborne x y) null)
			(if primary (send dc draw-path rwr-primarythreat x y) null)
			(if tracking (send dc draw-path rwr-tracking x y) null)
			(if newthreat (send dc draw-path rwr-newestthreat x y) null)
			(if highpriority
			  (send dc set-font rwr-threatfontbold);then
			  (send dc set-font rwr-threatfont);else
			  )
			(define threat-string (get-threatstring radartype))
			(draw-threatstring dc threat-string (+ x 200) (+ y 200) )

			this)
	 )
  )


(define (draw-threatstring dc threat-string middlex middley)
  ;draw the string representing the received radar type, centered over the middlex,middley coordinates.

  (match-define-values (text-width text-height _ _) (send dc get-text-extent threat-string))
  ; get-text-extent returns four values, we only want the height and width so we can position the text
  ; centered on the coordinates we're given (represented with middlex and middley

  (send dc draw-text threat-string (- middlex (/ text-width 2)) (- middley (/ text-height 2)))
  ; drawing text , the x and y values are the top-left of any written string. So we take the text height and width,
  ; divide them by 2 (to get a center value), and then subtract these values from middlex and middley to get the necessary
  ; offset to have the text string centered

  )
(define (scale-up-and-center x reverse-factor)
  ;assume threat icon width and height is 400 each
  (- 
    (* x (/ x (* x reverse-factor) ) ;scale-up
       ) (/ threaticonwidth 2)) ;center
  )


(define (draw-threats dc)
  ;draw network threats with calls to draw-threat
  ; remember, per spec we only draw up to 16 threats at a time.
  ; must sort threats by priority first, then draw the first 16
  (define demothreat 
    (new threat% 
	 [ jsonstr jsonstrexample ] 
	 ) 
    )
  (send demothreat parse)
  (define r (send demothreat get-distance-from-center))
  (define a (send demothreat get-azimuth))
  (define-values ( x y ) (convert-to-xy r azimuth))
  (send demothreat draw dc (+ x 200) (+ y 200))
  )
(define (draw-threatscope dc)
  ; draws the basic elements of the threatscope
  ; a circle at max distance at each o'clock.
  ; plus a cross at the center of the scope
  (send dc draw-path (rwr-cross 15 200 200) )
  (send dc draw-path (rwr-periphery 5 200 200) )
  )

(define (rwr-cross radius centerx centery)
  ; the cross at the center of the threat scope
  (let ([p (new dc-path%)])
    (send p move-to (- centerx radius) centery)
    (send p line-to (+ centerx radius) centery)
    (send p move-to centerx (- centery radius))
    (send p line-to centerx (+ centery radius))
    p)
  )
(define (rwr-periphery dotsize centerx centery)
  ; the dots around the periphery of the threat scope
  ;... or, more cheaply, just a circle.
  (let ([p (new dc-path%)])
    (send p ellipse 0 0 400 400)
    p)
  )
(define rwr-airborne
  ; the path representing an airborne threat
  ; a small carat above the threat string
  (let ([p (new dc-path%)])
    (send p move-to 138 147)
    (send p line-to 200 104)
    (send p line-to 262 147)
    p)
  )
(define rwr-primarythreat
  ; the path representing a 'primary' threat
  ; a diamond around the threat icon
  (let ([p (new dc-path%)])
    (send p move-to 200 0)
    (send p line-to 400 200)
    (send p line-to 200 400)
    (send p line-to 0 200)
    (send p close)
    p)
  )
(define rwr-tracking
  ; the path representing a tracking radar threat or a locked radar threat
  ; a centered circle around the entire threat icon
  ; properly, this should also blink!
  (let ([p (new dc-path%)])
    (send p ellipse 0 0 400 400)
    p)
  )
(define rwr-newestthreat
  ; the path representing the newest threat
  ; a half semicircle from 9 to 3 clockwise around a clock face
  (let([p (new dc-path%)])
    (send p arc 0 0 400 400 0 pi)
    p)
  )


(define i 0 )
(define azimuth 0)

(define rwr (new rwr% [frame frame]) )
(define f (send rwr create))

(define (main i)
  (sleep 0.001)
  (set! i (+ i 1) )
  (set! azimuth (+ azimuth .01))
  (send f update)
  (printf "~a\n" azimuth)
  (main i)
  )

;(main i)
