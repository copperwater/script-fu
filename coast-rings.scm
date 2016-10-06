;This script will take the selected region of an image and draw coastal rings
;emanating from it.

;Therefore, it expects that you already have selected whatever landmasses
;you want to generate the rings around when you activate the script.

;If the rings ever reach the complete edge of the image, the script will end.

;The script requires that the current selection is not empty and there is an
;active (selected) layer to operate on.

;Options available:
; init-trace: This enables/disables stroking of the initial selection.
; quick-mode: For large selected areas, this can reduce the running time of the
;  script by iterating the selection outward step by step instead of restoring
;  the initial selection every time. The drawback to this option is that the
;  rings generated tend to appear polygonal rather than curved.

(define (script-fu-coast-rings theImage theLayer spacing lineWidth1
			       lineWidth2 numrings init-trace quick-mode)

(let* (
       (selChannel 0)
       (brushTemp 0)
       (ctr 1)
       (img-width (car (gimp-image-width theImage)))
       (img-height (car (gimp-image-height theImage)))
       (layer-width (car (gimp-drawable-width theLayer)))
       (layer-height (car (gimp-drawable-height theLayer)))
       (bigger-rad (if (>= lineWidth1 lineWidth2)
		       (ceiling (/ lineWidth1 2))
		       (ceiling (/ lineWidth2 2))))
       ;wrappers for the variables
       ;(SF-TOGGLE doesn't pass the right type to use in if statements)
       (initTrace (not (= init-trace 0)))
       (quickMode (not (= quick-mode 0)))
       )

  ;check for errors: no layer is selected or selection is empty
  ;(this prevents messy error messages and incomplete undo groups)
  (when (= (car (gimp-image-get-active-layer theImage)) -1)
	(error "No layer selected. Please select a layer to draw on."))
  (when (= (car (gimp-selection-is-empty theImage)) 1)
	(error "Selection is empty. Please select a region to trace."))

  ;start the party
  (gimp-image-undo-group-start theImage)
  (gimp-context-push)

  ;save original selection (needed whether quick-mode is set or not)
  (set! selChannel (car (gimp-selection-save theImage)))

  ;resize image and layer so as not to stroke the edge
  (gimp-image-resize theImage
		     (+ img-width (* 2 bigger-rad))
		     (+ img-height (* 2 bigger-rad))
		     bigger-rad
		     bigger-rad)

  (gimp-layer-resize theLayer
		     (+ layer-width (* 2 bigger-rad))
		     (+ layer-height (* 2 bigger-rad))
		     bigger-rad
		     bigger-rad)

  ;define stroking brush
  (set! brushTemp (car (gimp-brush-new "CoastRingsBrush")))
  (gimp-brush-set-shape brushTemp BRUSH-GENERATED-CIRCLE)
  (gimp-brush-set-hardness brushTemp 0.5)
  (gimp-brush-set-radius brushTemp (/ lineWidth1 2))
  (gimp-brush-set-spikes brushTemp 2)
  (gimp-brush-set-aspect-ratio brushTemp 1)
  (gimp-brush-set-angle brushTemp 0)
  (gimp-context-set-brush brushTemp)

  ;Stroke the land itself first (when init-trace is enabled)
  (when initTrace (gimp-edit-stroke theLayer))

  ;Repeatedly grow and stroke the selection. If quick-mode is NOT set, then
  ;restore the original selection every time for a better line.
  (gimp-brush-set-radius brushTemp (/ lineWidth2 2))
  (while (and (<= ctr numrings) (= (car (gimp-selection-is-empty theImage)) 0))

	 (gimp-selection-grow theImage (if quickMode spacing (* ctr spacing)))
	 (gimp-edit-stroke theLayer)
	 (set! ctr (+ ctr 1))
	 (when (not quickMode)
	       (gimp-image-select-item theImage CHANNEL-OP-REPLACE selChannel))
	 )

  ;restore original image dimensions
  (gimp-layer-resize theLayer
		     layer-width layer-height
		     (* -1 bigger-rad) (* -1 bigger-rad))
  (gimp-image-resize theImage
		     img-width img-height
		     (* -1 bigger-rad) (* -1 bigger-rad))

  ;quick-mode needs to restore the original selection at the end
  (when quickMode
	(gimp-image-select-item theImage CHANNEL-OP-REPLACE selChannel))

  ;clean up
  (gimp-brush-delete brushTemp)
  (gimp-image-remove-channel theImage selChannel)
  (gimp-image-undo-group-end theImage)
  (gimp-displays-flush)
  (gimp-context-pop)
  )
)

(script-fu-register
 "script-fu-coast-rings"
 "Coast Rings"
 "Creates concentric rings emanating from a selection, intended to be used for generating the coastal rings found on maps."
 "Zachary Stark"
 "Zachary Stark, 2014"
 "February 2014"
 "*A"
 SF-IMAGE "Image" 0
 SF-DRAWABLE "Drawable" 0
 SF-ADJUSTMENT "Spacing" '(5 5 100 1 5 0 SF-SLIDER)
 SF-ADJUSTMENT "Initial trace width" '(2 0.1 30 0.1 3 1 SF-SLIDER)
 SF-ADJUSTMENT "Subsequent trace width" '(1 0.1 30 0.1 3 1 SF-SLIDER)
 SF-ADJUSTMENT "Number of rings" '(5 1 200 1 3 0 SF-SLIDER)
 SF-TOGGLE "Trace initial selection" TRUE
 SF-TOGGLE "Faster, but lossy, rings" FALSE
 )

(script-fu-menu-register "script-fu-coast-rings" "<Image>/Filters/Cartography")
