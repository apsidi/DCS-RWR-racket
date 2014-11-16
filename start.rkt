#lang racket/gui

(define threaticonscale .15)
(define threaticonwidth 400);NO TOUCH
(define scopescale 1)
(define frame (new frame%
                   [label "RWR"]
                   [width 400]
                   [height 400]
                   )
  )
(new canvas% [parent frame]
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


(define (draw-threat dc threatobj)
  (define x (scale-up-and-center 200 threaticonscale))
  (define y (scale-up-and-center 100 threaticonscale))

  ; draw a single threatobj
  (send dc draw-path rwr-airborne x y)
  (send dc draw-path rwr-primarythreat x y)
  (send dc draw-path rwr-tracking x y)
  ;(send dc draw-path rwr-newestthreat x y)
  (send dc set-font rwr-threatfont)
  (define threat-string "27")
  (draw-threatstring dc threat-string (+ x 200) (+ y 200) )
  )
(define (draw-threats dc)
  ;draw network threats with calls to draw-threat
  (draw-threat dc null)
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


(send frame show #t)