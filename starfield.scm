; starfield.scm
; generates a field of dots of different sizes

; parameters:
; minimum size - minimum radius of dots (int, defaults to 1, range 1-20)
; maximum size - maximum radius of dots (int, defaults to 3, range 1-20)
; density - number of times per pixel a dot will generate at the smallest level
;    (float, defaults to 0.1, range 0-1)
; reduction - amount by which density will be divided each time size increments
;    (float, defaults to 2, range 1-10)
; star saturation - maximum possible amount of red or blue a star can have
;    (int, defaults to 20, range 0-255)

;       set color to a slight tint of red or blue along the gradient
;            (235,235,255) <---> (255,255,255) <---> (255,235,235)

; algorithm:
; totpix = total number of pixels in the drawing space
; starsaturation += 1 *to account for modulo*
; for size in (minsize) to (maxsize):
;    set numstars to (totpix*density)
;    for x in 1 to (numstars):
;       rx = random % (width)
;       ry = random % (height)
;       flag = random % 2
;       r = b = 255
;       declination = random % 20
;       g = 255 - (declination)
;       if (flag) (r -= declination); else (b -= declination)
;       set color to (r,g,b)
;       draw dot of size (size) at position (rx,ry)
;    density = (density*reduction)

(define (script-fu-starfield theImage theLayer minsize maxsize density reduc
			     maxsat)
  (let* (
	 (layer-width (car (gimp-drawable-width theLayer)))
	 (layer-height (car (gimp-drawable-height theLayer)))
	 (totpix (* layer-width layer-height))
	 (size minsize)
	 (tmpbrush (car (gimp-brush-new "Star Brush")))
	 (numstars 0)
	 (ctr 0)
	 (declination 0)
	 (r 255)
	 (g 255)
	 (b 255)
	 (rx 0)
	 (ry 0)
	 (flag 0)
	 (point (make-vector 2 'double))
	 )
    (gimp-undo-push-group-start theImage)
    (gimp-context-push)

    ; define attributes of the brush
    (gimp-brush-set-shape tmpbrush BRUSH-GENERATED-CIRCLE)
    (gimp-brush-set-hardness tmpbrush 0.5)
    (gimp-brush-set-spikes tmpbrush 2)
    (gimp-brush-set-aspect-ratio tmpbrush 1)
    (gimp-brush-set-angle tmpbrush 0)

    ; set the new brush
    (gimp-context-set-brush tmpbrush)


    (while (<= size maxsize)
	   (set! numstars (* totpix density))
	   (gimp-message (string-append "size: " (number->string size)))
	   (set! ctr 0)
	   (gimp-brush-set-radius tmpbrush size)
	   (while (< ctr numstars)
		  (vector-set! point 0 (random layer-width))
		  (vector-set! point 1 (random layer-height))
		  ;(set! flag (random 2))
		  ;(set! declination (random maxsat))
		  ;(set! g 255)
		  ;(when (= flag 0)
			;(set! r (- 255 declination))
			;(set! b 255))
		  ;(when (= flag 1)
			;(set! r 255)
			;(set! b (- 255 declination)))
		  ;(gimp-context-set-foreground '(r g b))
		  (gimp-paintbrush theLayer 0 2 point PAINT-CONSTANT 0)
		  (set! ctr (+ ctr 1))
		  ;(gimp-message (number->string ctr))
	   )
	   (set! density (* density reduc))
	   (set! size (+ size 1))
	   ;(gimp-message "Hello")
    )
    (gimp-displays-flush)
    (gimp-undo-push-group-end theImage)
    (gimp-context-pop)
    )
  )

(script-fu-register
 "script-fu-starfield"
 "Starfield"
 "Generates a field of random stars."
 "Zachary Stark"
 "Zachary Stark, 2014"
 "February 2014"
 "RGB*"
 SF-IMAGE "Image" 0
 SF-DRAWABLE "Drawable" 0
 SF-ADJUSTMENT "Minimum star size"   '(1 1 20 1 5 0 SF_SPINNER)
 SF-ADJUSTMENT "Maximum star size"   '(3 1 20 1 5 0 SF_SPINNER)
 SF-ADJUSTMENT "Star density"        '(0.1 0 0.99 0.001 0.1 4 SF_SLIDER)
 SF-ADJUSTMENT "Density reduction"   '(2 1 10 1 2 0 SF_SPINNER)
 SF-ADJUSTMENT "Max star saturation" '(20 0 255 1 20 0 SF_SPINNER)
 )

(script-fu-menu-register "script-fu-starfield" "<Image>/Filters")

