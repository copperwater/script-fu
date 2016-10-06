;This script will take a heightmap, given by a greyscale layer that
;the user selects, and draw many contour lines of it on the active layer.
;There is support for different brush sizes, hardnesses, spacing, smoothing,
;differing low and high bounds, and adding a double-weight line every so often.

;NOTE: This script REQUIRES that the Contour Line script-fu be loaded into GIMP
;and for it to be functional. If you cannot run Contour Line, this script
;will not work.

(define (script-fu-contour-map theImage theCurrLayer theHeightmap
			       beginElev endElev
			       separation special theSize theHardness
			       theSmoothing theSmoothAmt)

  (let* (
	 (curr-elev beginElev)
	 (ctr 1)
	 (theLayer (car (gimp-layer-new theImage
					(car (gimp-image-width theImage))
					(car (gimp-image-height theImage))
					RGBA-IMAGE "Contour Map" 100
					NORMAL-MODE)))
	 )

    (gimp-undo-push-group-start theImage)
    ;(set! layer (car
    (gimp-image-insert-layer theImage theLayer 0 -1)

    (while (< curr-elev endElev)
	   (script-fu-contour-line
	    theImage
	    theLayer
	    theHeightmap
	    curr-elev
	    (if (= (modulo ctr special) 0)
		(* 2 theSize)
		theSize)
	    theHardness
	    theSmoothing
	    theSmoothAmt)

	   (set! curr-elev (+ curr-elev separation))
	   (set! ctr (+ ctr 1))
	   )
    (gimp-displays-flush)
    (gimp-undo-push-group-end theImage)

    )
)

(script-fu-register
 "script-fu-contour-map"                        ;func name
 "Contour Map"                                  ;menu label
 "Creates a contour map of the heightfield\
  image, from the beginning elevation to the\
  ending elevation, using the Contour Line script." ;description
 "Zachary Stark"                                  ;author
 "Zachary Stark, 2013"                  ;copyright notice
 "October 2013"                                  ;date created
 "*A"                                  ;image type that the script works on
 SF-IMAGE "Image" 0
 SF-DRAWABLE "Drawable" 0
 SF-DRAWABLE "Layer to use as heightmap" 0
 SF-ADJUSTMENT "Beginning elevation" '(127 0 254 1 10 0 1)
 SF-ADJUSTMENT "Final elevation" '(127 1 255 1 10 0 1)
 SF-ADJUSTMENT "Step separation" '(4 1 32 1 4 0 1)
 SF-ADJUSTMENT "Special line every X lines" '(5 0 100 1 5 0 1)
 SF-ADJUSTMENT "Line weight" '(2 0.1 20 0.1 2 1 0)
 SF-ADJUSTMENT "Hardness" '(0.5 0 1 0.01 0.1 2 0)
 SF-TOGGLE "Smoothing" FALSE
 SF-ADJUSTMENT "Smooth amount" '(4 1 20 1 2 0 0)
 )

(script-fu-menu-register "script-fu-contour-map" "<Image>/Filters/Cartography")
