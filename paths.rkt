
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
