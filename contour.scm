;This script will take a greyscale heightmap and draw a contour line across it
;at one elevation (certain shade of grey). The elevation, brush size, brush
;hardness, and amount of smoothing are controlled by the user.

;This is not really intended to be used by itself. The Contour Map script allows
;you to draw many contour lines at once while retaining all the functionality
;of this script.

(define (script-fu-contour-line theImage theLayer theHeightmap thresh
				theSize theHardness theSmoothing theSmoothAmt)

(let* (
       (width (car (gimp-image-width theImage)))
       (height (car (gimp-image-height theImage)))
       (theBrush (car (gimp-brush-new "Linebrush")))
       (theGrowRad (ceiling (/ theSize 2)))
       )

  (gimp-undo-push-group-start theImage)
  (gimp-context-push)
					;begin the process

  (gimp-brush-set-shape theBrush BRUSH-GENERATED-CIRCLE)
  (gimp-brush-set-hardness theBrush theHardness)
  (gimp-brush-set-radius theBrush (/ theSize 2))
  (gimp-brush-set-aspect-ratio theBrush 1)
  (gimp-brush-set-angle theBrush 0)
  (gimp-context-set-brush theBrush)

  (gimp-context-set-sample-threshold-int (- 255 thresh))
  (gimp-context-set-antialias FALSE)

  (gimp-image-select-color
   theImage CHANNEL-OP-REPLACE theHeightmap '(255 255 255))
					;threshold it to whatever setting
  (when (= theSmoothing TRUE)
	(gimp-image-resize theImage
		     (+ width (* 2 theSmoothAmt))
		     (+ height (* 2 theSmoothAmt))
		     theSmoothAmt
		     theSmoothAmt)
	(gimp-selection-grow theImage theSmoothAmt)
	(gimp-selection-shrink theImage theSmoothAmt)
	(gimp-image-resize theImage
			   width height
			   (* -1 theSmoothAmt) (* -1 theSmoothAmt))
	)

  (gimp-image-resize theImage
		     (+ width (* 2 theGrowRad))
		     (+ height (* 2 theGrowRad))
		     theGrowRad
		     theGrowRad)

  (gimp-layer-resize theLayer
		     (+ width (* 2 theGrowRad))
		     (+ height (* 2 theGrowRad))
		     theGrowRad
		     theGrowRad)

  (gimp-selection-grow theImage theGrowRad)

  (gimp-edit-stroke theLayer)

  (gimp-layer-resize theLayer
		     width height
		     (* -1 theGrowRad) (* -1 theGrowRad))

  (gimp-image-resize theImage
		     width height
		     (* -1 theGrowRad) (* -1 theGrowRad))

  (gimp-selection-none theImage)
  (gimp-brush-delete theBrush)
  (gimp-undo-push-group-end theImage)
  (gimp-context-pop)
  (gimp-displays-flush)
					;clean up
  )
)

(script-fu-register
 "script-fu-contour-line"                        ;func name
 "Contour Line"                                  ;menu label
 "Creates a contour line of the foreground
  color at the given threshold."                 ;description
 "Zachary Stark"                                  ;author
 "Zachary Stark, 2013"                  ;copyright notice
 "October 2013"                                  ;date created
 "*A"                                  ;image type that the script works on
 SF-IMAGE "Image" 0
 SF-DRAWABLE "Drawable" 0
 SF-DRAWABLE "Layer to use as heightmap" 0
 SF-ADJUSTMENT "Threshold" '(127 0 255 1 10 0 0)
 SF-ADJUSTMENT "Stroke size" '(2 1 16 1 4 0 0)
 SF-ADJUSTMENT "Hardness" '(0.5 0 1 0.01 0.1 2 0)
 SF-TOGGLE "Smoothing" FALSE
 SF-ADJUSTMENT "Smooth amount" '(4 1 20 1 2 0 0)
 )

(script-fu-menu-register "script-fu-contour-line" "<Image>/Filters/Cartography")
