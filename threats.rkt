
(define (get-threat-by-id lst id) ;given a lst of threat objects, and an id (number), return the first matching one or #f if none
  (let (
	[matches (filter 
		   (lambda (x) (if (equal? (send x get-id) id) #t #f))
		   lst)]
	)
    (if (> (length matches) 0) (car matches) #f)
    )
  )

(define threatstrings #hash(  ;return the string to be drawn on the scope, given a unit type.
			    ("F-15C" . "15")
			    ("mig-29s" . "29");these cannot be told apart by the american TEWs equipment supposedly
			    ("mig-29c" . "29");
			    ("su-27" . "29")  ;
			    ("su-33" . "29")  ;
			    ("a-50" . "50");an awacs
			    ("TAKR Kuznetsov" . "SW");ship
			    ("s-300ps 64h6e sr". "BB"); sam
			    ("CONN" . "CONN");test json to indicate the sim is running but no data is available (like: in the wrong aircraft, no TEWS, damaged equipment...)
			    ))
(define (get-threatstring type)
  (define str (if (hash-has-key? threatstrings type)
		(hash-ref threatstrings type)
		"U" ; if we haven't already defined it, it's a "U" for unknown.
		))
  str
  )

(define (airborne-type type typeints)
  (if (= (car typeints) 1) #t #f); in typeints, a 1 is airborne, 2 is ground, 3 is seagoing. Unsure what '4' is.
  )

(define newest '()); the newest threat as received by the rwr

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
