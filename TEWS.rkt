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
(define (alist->string l) 
  ;http://lists.racket-lang.org/users/archive/2010-November/042915.html
    (string-join 
          (map (lambda (x) (format "~s=~s" (car x) (cdr x))) l) " "))

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
  type
  )
(define (airborne-type type typeints)
  (if (= (car typeints) 1) #t #f)
  )
(define (high-priority threat% typeints) 
  1
  )
(define threat%
  (class object%
	 (init-field [jsonstr ""][jsexpr null])
	 (define azimuth 0)
	 (define id 1)
	 (define power 0.5)
	 (define priority 100)
	 (define signaltype "")
	 (define radartype "")
	 (define airborne #f)
	 (define highpriority #f)
	 (define primary #f)
	 (define tracking #f)
	 (define newthreat #f)
	 (define typeints '())
	 (super-new)
	 (define/public (get-highpriority) highpriority)
	 (define/public (get-priority) priority)
	 (define/public (get-power) power)
	 (define/public (get-id) id)
	 (define/public (get-typeints) typeints)
	 (define/public (get-newthreat) newthreat)
	 (define/public (get-primary) primary)
	 (define/public (get-azimuth) azimuth)
	 (define/public (set-highpriority tf)
			(set! highpriority tf)
			)
	 (define/public (set-newthreat tf)
			(set! newthreat tf)
			)
	 (define/public (set-primary tf)
			(set! primary tf)
			)
	 (define/public (get-distance-from-center) (* 1 (/ threaticonwidth 4)))
	 (define/public (parse)
			(if (equal? jsexpr null) 
			  (set! jsexpr (string->jsexpr jsonstr) )
			  null)
			(set! azimuth (hash-ref jsexpr 'Azimuth) )
			(set! id (hash-ref jsexpr 'ID) )
			(set! power (hash-ref jsexpr 'Power) )
			(set! priority (hash-ref jsexpr 'Priority) )
			(set! signaltype (hash-ref jsexpr 'SignalType) )
			(set! radartype (hash-ref jsexpr 'Type) )
			(if (member 'TypeInts (hash-keys jsexpr))
			  (set! typeints (hash-ref jsexpr 'TypeInts))
			  null)
			(set! airborne (airborne-type radartype typeints) )
			(set! highpriority (high-priority this typeints))

			this)
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
	 (define/public (summarize)
			(printf "~a  ~a  ~a\t~a ~a\n" signaltype priority typeints id radartype)

			)
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
  ; must sort threats by priority, highest first, then draw the first 16
  (define jsonline "{ \"Mode\":0.000000, \"MTime\": 10.600000, \"Emitters\":[ { \"ID\":\"16781568\", \"Power\":0.400990, \"Azimuth\":-2.259402, \"Priority\":160.400986, \"SignalType\":\"scan\", \"Type\":\"F-15C\", \"TypeInts\":[1.000000,1.000000,1.000000,6.000000] },{ \"ID\":\"16778496\", \"Power\":0.719001, \"Azimuth\":-1.720845, \"Priority\":110.719002, \"SignalType\":\"scan\", \"Type\":\"a-50\", \"TypeInts\":[1.000000,1.000000,5.000000,26.000000] },{ \"ID\":\"16777472\", \"Power\":0.183416, \"Azimuth\":1.909581, \"Priority\":130.183411, \"SignalType\":\"scan\", \"Type\":\"TAKR Kuznetsov\", \"TypeInts\":[3.000000,12.000000,12.000000,1.000000] },{ \"ID\":\"16778240\", \"Power\":0.251832, \"Azimuth\":-0.261481, \"Priority\":160.251831, \"SignalType\":\"scan\", \"Type\":\"mig-29c\", \"TypeInts\":[1.000000,1.000000,1.000000,50.000000] }] }")

  (define threat-list '())

  (define js (string->jsexpr jsonline))
  ; parse the objects from json
  (define mode (hash-ref js 'Mode))
  (define ModelTime (hash-ref js 'MTime))
  (define Emitters (hash-ref js 'Emitters))

  (printf "Time: ~a\n" ModelTime)

  (map 
    (lambda (jsemit) 
      (set! threat-list (append threat-list (list
		 (new threat% 
		      [jsexpr jsemit ]
		      [jsonstr ""]
		      )
		 )))
      ) 
       Emitters)
  ; sort the  list, take highest 16 (per the spec)
  (define sorted-threat-list
    (sort threat-list (lambda (x y) (if (< (send x get-priority) (send y get-priority) ) #t #f)) )
    )
  (define short-threat-list 
    (if (> (length sorted-threat-list) 16)
      (take sorted-threat-list 16)
      sorted-threat-list
      ))
  ; map across that sublist of 16 the function that draws and handles them

  (define (threat-draw threatobj)
    (send threatobj parse)
    (define r (send threatobj get-distance-from-center))
    (define a (send threatobj get-azimuth))
    (define-values ( x y ) (convert-to-xy r a))
    (send threatobj draw dc (+ x 200) (+ y 200))
    )
  (map threat-draw short-threat-list)
  (map (lambda (x) (send x summarize)) short-threat-list)

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
(define rwr (new rwr% [frame frame]) ) ;instantiate
(define f (send rwr create)) ;create the window and display
(define (main i)
  (sleep 0.002)
  (set! i (+ i 1) )
  (send f update) ;force an update of the display
  (main i); 'loop'
  )
(main i)