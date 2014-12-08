
(define rwr%
  (class object%
	 (init-field frame)
	 (super-new)
	 (define canvas null)
	 (define listener '())
	 (define connections '())
	 (define i 0);frame counter
	 (define mode 0) ;mode is 0 meaning "show all emitters" by default. Can also be 1 for "show only locked emitters"
	 ;in this case, it is received for each json message and used here to show the status. Changing this will not change what is actually shown, it reflects the in-game value.
	 (define/public (get-canvas) canvas)
	 (define/public (get-frame) frame)
	 (define/public (set-mode x)
			(set! mode x)
			)
	 (define/public (get-mode) mode)
	 (define/public (set-i x)
			(set! i x)
			)
	 (define/public (get-i) i)
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
					      (draw-threatscope dc) ;draw the outline, center cross, etc

					      (send dc set-pen "green" 10 'solid)
					      (send dc set-scale threaticonscale threaticonscale)
					      (draw-threats dc) ; receive, parse, and draw each threat

					      )
					    ]
				       ;(new button% [parent frame]
						    ;[label "Shutdown"]
						    ;[callback (lambda (button event)
							    ;(send rwr shutdown)
							    ;(exit:exit)))])
			                                 
					  )
			  )
			(set! listener (tcp-listen listenport 2 #t))
			(send frame show #t)
			this)
	 (define/public (update) 
			(send canvas refresh-now)
			this)
	 (define/public (connect host port) 1) ;not used for now. Maybe later?
	 (define/public (tcp-ready?) 
			(if (tcp-accept-ready? listener)
			  #t
			  #f
			)
			)
	 (define/public (accept)
			(define-values (in out) (tcp-accept listener)) ; this is blocking, i believe. tcp-ready can be used to determine if there's someone waiting to connect
			(set! connections (cons in out))
			connections
			)
	 (define/public (shutdown);graceful shutdown
			(if (tcp-listener? listener)
				(tcp-close listener)
				#f
				)
			)
	 (define/public (read) ; return either #f if we don't have a connection yet, or a json message
			(define jsonline "{ \"Mode\":0.000000, \"MTime\": 10.600000, \"Emitters\":[ { \"ID\":\"16781568\", \"Power\":0.400990, \"Azimuth\":-2.259402, \"Priority\":160.400986, \"SignalType\":\"scan\", \"Type\":\"F-15C\", \"TypeInts\":[1.000000,1.000000,1.000000,6.000000] },{ \"ID\":\"16778496\", \"Power\":0.719001, \"Azimuth\":-1.720845, \"Priority\":110.719002, \"SignalType\":\"scan\", \"Type\":\"a-50\", \"TypeInts\":[1.000000,1.000000,5.000000,26.000000] },{ \"ID\":\"16777472\", \"Power\":0.183416, \"Azimuth\":1.909581, \"Priority\":130.183411, \"SignalType\":\"scan\", \"Type\":\"TAKR Kuznetsov\", \"TypeInts\":[3.000000,12.000000,12.000000,1.000000] },{ \"ID\":\"16778240\", \"Power\":0.251832, \"Azimuth\":-0.261481, \"Priority\":160.251831, \"SignalType\":\"scan\", \"Type\":\"mig-29c\", \"TypeInts\":[1.000000,1.000000,1.000000,50.000000] }] }")
			(if (null? connections)
				  #f
				  (read-json (car connections))
				  ;(string->jsexpr jsonline)
				); parse a line of json and handle it
			)
	 )
  )


(define last-stl '()) ;last short-threat-list
(define (draw-threats dc)
  (define frame-counter (send rwr get-i))
  (define error #f) ;
  (define threat-list '())


  (define jsonline "{ \"Mode\":0.000000, \"MTime\": 10.600000, \"Emitters\":[ { \"ID\":\"16781568\", \"Power\":0.400990, \"Azimuth\":-2.259402, \"Priority\":160.400986, \"SignalType\":\"scan\", \"Type\":\"F-15C\", \"TypeInts\":[1.000000,1.000000,1.000000,6.000000] },{ \"ID\":\"16778496\", \"Power\":0.719001, \"Azimuth\":-1.720845, \"Priority\":110.719002, \"SignalType\":\"scan\", \"Type\":\"a-50\", \"TypeInts\":[1.000000,1.000000,5.000000,26.000000] },{ \"ID\":\"16777472\", \"Power\":0.183416, \"Azimuth\":1.909581, \"Priority\":130.183411, \"SignalType\":\"scan\", \"Type\":\"TAKR Kuznetsov\", \"TypeInts\":[3.000000,12.000000,12.000000,1.000000] },{ \"ID\":\"16778240\", \"Power\":0.251832, \"Azimuth\":-0.261481, \"Priority\":160.251831, \"SignalType\":\"scan\", \"Type\":\"mig-29c\", \"TypeInts\":[1.000000,1.000000,1.000000,50.000000] }] }")
  (define js (string->jsexpr jsonline))
  ; above two lines are handy for testing, if you're not able to use the network based (netcat, pipeviewer, etc) testing data.



  (set! js (send rwr read))
  ; parse the objects from json
  (when (equal? js (json-null)) (set! error #t) )
  ; for if we ever find a nice way to handle errors, i suppose ~MM


  (define mode (hash-ref js 'Mode)) ;the RWR mode
  (send rwr set-mode mode) ; update RWR object with current mode
  (define ModelTime (hash-ref js 'MTime)) ; the time within the simulator
  (define Emitters (hash-ref js 'Emitters)); the array of emitters

  (printf "Time: ~a\n" ModelTime)


  (map  ;make threat-list contain threat% objects based on received json data
    (lambda (jsemit) 
      (set! threat-list (append threat-list (list
		 (new threat% 
		      [jsexpr jsemit ]
		      [jsonstr ""]
		      )
		 )))
      ) 
       Emitters)

  (map (lambda (x) ;update each threat with the current frame id so it can blink if it needs to
	 (send x set-i frame-counter)
	 ) threat-list)

  (map (lambda (x) (send x parse) ) threat-list) ;tell each threat to parse its jsexpr data

  (define sorted-threat-list ;sort the list by priority, highest first - this means the 'primary' threat is accessible with (car sorted-threat-list)
    (sort threat-list (lambda (x y) (if (> (send x get-priority) (send y get-priority) ) #t #f)) )
    )

  (define short-threat-list ;F-15 RWR supposedly has a max of 16 displayed at one time - the game doesn't seem to adhere to that, but we will.
    (if (> (length sorted-threat-list) 16)
      (take sorted-threat-list 16)
      sorted-threat-list
      ))

  (if (> (length short-threat-list) 0) ;make the highest priority emitter the primary (the diamond symbology)
	  (send (car short-threat-list) set-primary #t) 
	  null
    )


  (if (null? last-stl) #f ;if we had data before, last-stl contains the list of old threats. 
    ;We can easily replicate the simulator's RWR function of determining the latest received threat emission, and marking it appropriately
    (let* (
	   [old-ids (map (lambda (x) (send x get-id)) last-stl)] ;list of ids from the list of old threats so we can do..
	   [new-threats (filter (lambda (x) (not (member (send x get-id) old-ids))) short-threat-list)] ;this line, which gives us a list of threats that aren't in last-stl
	   )
      (if (not (null? new-threats))
	(set! newest (send (car new-threats) get-id)) ; if we have new threats 
	;(probably never more than one at a time because of how the simulator models the TEWS system (discovers roughly one at a time), 
	; the highest priority one will be marked as the 'newest')
	#f
	)
      )
    )
  (if (not (null? newest)) ;if there is a newest, make sure that threatobj knows it should draw itself as the newest!
    (let ([x (get-threat-by-id short-threat-list newest) ])
      (unless (equal? #f x) (send x set-newthreat #t) )
      )
    #f
    )
    ;if most recent newest threat  is no longer detected, there is no 'new threat' symbology

  (set! last-stl short-threat-list); needed to be able to mark newest threat

  (define (threat-draw threatobj)
    (define r (send threatobj get-distance-from-center)) ;get distance from center of scope in pixels
    (define a (+ pi (/ pi 2) (send threatobj get-azimuth))) ;get-azimuth is in radians
    ;The additions modify the azimuth so it plays nice when we draw it. See the README under DCS World for more info.
    (define-values ( x y ) (convert-to-xy r a)) ; convert from polar to rectangular
    (send threatobj draw dc (+ x 200) (+ y 200)) ;the +200 to x and y account for the origin being at 0,0, where we want to draw around the center of our scope, at 200,200 (racket)
    ; or (200,-200) (cartesian)
    )
  (map threat-draw short-threat-list) ;draw each threat on the scope
  (map (lambda (x) (send x summarize)) short-threat-list) ;write a summary of detected threats to the console screen

  )
(define (draw-threatscope dc)
  ; draws the basic elements of the threatscope
  ; a circle at max distance at each o'clock.
  ; plus a cross at the center of the scope
  (send dc draw-path (rwr-cross 15 200 200) )
  (send dc draw-path (rwr-periphery 5 200 200) )
  (let (
	[mode (send rwr get-mode)]
	[middlex 50]
	[middley 50]
	)
    (define modestr (if (= 1 mode) "Lock Only" "All"))
    (define oldfont (send dc get-font))
    (send dc set-font rwr-scopefont)
    (send dc draw-text modestr 0 0)
    (send dc set-font oldfont)
    )
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
	 (define awacs #f)
	 (define primary #f)
	 (define tracking #f)
	 (define newthreat #f)
	 (define i 0)
	 (define typeints '(0,0,0,0))
	 (super-new)
	 (define/public (get-highpriority) highpriority)
	 (define/public (get-priority) priority)
	 (define/public (get-power) power)
	 (define/public (get-id) id)
	 (define/public (get-typeints) typeints)
	 (define/public (get-newthreat) newthreat)
	 (define/public (get-primary) primary)
	 (define/public (get-azimuth) azimuth)
	 (define/public (set-i tf)
			(set! i tf)
			)
	 (define/public (set-highpriority tf)
			(set! highpriority tf)
			)
	 (define/public (set-newthreat tf)
			(set! newthreat tf)
			)
	 (define/public (set-primary tf)
			(set! primary tf)
			)
	 (define/public (get-distance-from-center) ;this is not correct to the game - unsure how to make this accurate
			(cond
			  ;[highpriority 75]
			  ;[primary 100]
			  [awacs 175]
			  ;[ew 175]
			  ;[#t (- 300 (* 100 power))]
			  [else (/ (+ 
				     (- 300 priority)
				     (* power 200)
				     ) 2.10)
				     ]
			  )
			)
	 (define/public (parse)
			
			(if (and (equal? jsexpr (json-null)) (not (equal? jsonstr "")))
			  (set! jsexpr (string->jsexpr jsonstr) )
			  null)
			;(if (equal? jsexpr (json-null)  ;i want to return early, is that not a thing?
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
			;(set! highpriority (high-priority this typeints))
			(set! awacs (if (and
					  (= (car typeints) 1)
					  (= (cadr typeints) 1)
					  (= (caddr typeints) 5)
					 ) #t #f))
			(set! tracking (if 
					 ( and (equal? signaltype "lock") (equal? (modulo i 2) 0))
					 #t 
					 #f
					 )
			  )

			this)
	 (define/public (draw dc centerx centery) 
			; x and y coordinates to center the threatobj icon on
			;we're given a centerx and centery value for the scope itself, but our pixels are scaled down
			; by the threaticonscale value. So we scale-up the pixel values of centerx and centery to convert them
			; from the threatscope coordinate-space to our smaller-scale one
			(define x (scale-up-and-center centerx threaticonscale))
			(define y (scale-up-and-center centery threaticonscale))


			(if airborne (send dc draw-path rwr-airborne x y) null) ; airborne is the small carat above the threatstring
			(if primary (send dc draw-path rwr-primarythreat x y) null) ;primary is the diamond around the highest priority threat
			(if tracking (send dc draw-path rwr-tracking x y) null) ; tracking is the circle around any threat that has a 'lock'
			(if newthreat (send dc draw-path rwr-newestthreat x y) null) ;is the top semi-circle around the most recently detected threat
			(if (or highpriority tracking)
			  (send dc set-font rwr-threatfontbold);then
			  (send dc set-font rwr-threatfont);else
			  )
			(define threat-string (get-threatstring radartype))
			(draw-threatstring dc threat-string (+ x 200) (+ y 200) ) ;the 200's center the threatstring within the 400px by 400px threaticon - remember this is all scaled down when actually drawn.

			this)
	 (define/public (summarize);print a summary of this object
			(printf "~a ~a  ~a ~a  ~a\t~a ~a ~a i:~a\n" (if newthreat "*" " " ) signaltype power priority typeints id azimuth radartype i)

			)
	 )
  )
