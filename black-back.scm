(define (script-fu-black-back theImage theLayer)

(let* (
       ;(width (car (gimp-image-width theImage)))
       ;(height (car (gimp-image-height theImage)))
       (theNewLayer (car (gimp-layer-copy theLayer 1)))
       ;(theNewLayer (car (gimp-layer-new theImage width height 1 "Black" 100 0)))
       ;(text (car (gimp-text-layer-get-text theTextLayer)))
       ;(font (car (gimp-text-layer-get-font theTextLayer)))
       ;(fontsiz (gimp-text-layer-get-font-size theTextLayer))
       ;(font-size (car fontsiz))
       ;(font-unit (cadr fontsiz))
       )

  (when (= 0 (car (gimp-item-is-text-layer theLayer)))
	(error "Not a text layer."))

  (gimp-undo-push-group-start theImage)
  (gimp-context-push)
					;begin the process

  (gimp-image-insert-layer theImage theNewLayer 0 -1)
					;put in the copied layer
  (gimp-image-lower-item theImage theNewLayer)

  (gimp-text-layer-set-color theNewLayer '(0 0 0))

  ;Very small Gaussian blur to convert the layer to raster colors.
  (plug-in-gauss 1 theImage theNewLayer 0.1 0.1 1)

  (gimp-context-set-antialias 0)
  (gimp-image-select-color theImage 2 theNewLayer '(0 0 0))

  (gimp-layer-resize-to-image-size theNewLayer)

  (gimp-selection-grow theImage 16)

  (gimp-context-set-foreground '(0 0 0))

  (gimp-edit-fill theNewLayer 0)

  (gimp-selection-none theImage)

  (plug-in-gauss 1 theImage theNewLayer 35 35 1)

  (gimp-context-pop)
  (gimp-undo-push-group-end theImage)
  (gimp-image-set-active-layer theImage theLayer)
  (gimp-displays-flush)
					;clean up
  )
)

(script-fu-register
   "script-fu-black-back"                       ;func name
   "Black Back"                                 ;menu label
 "Creates a black area behind some text."       ;description
 "Zachary Stark"                                ;author
 "Zachary Stark, 2013"                          ;copyright notice
 "December 2013"                                ;date created
 ""                                             ;image type that the script works on
 SF-IMAGE "Image" 0
 SF-DRAWABLE "Drawable" 0
 )

(script-fu-menu-register "script-fu-black-back" "<Image>/Filters")
