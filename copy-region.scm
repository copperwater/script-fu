(define (script-fu-copy-region theImage)

(let* (
       (res (gimp-edit-copy-visible theImage))
       (theNewImage (car (gimp-edit-paste-as-new)))
       )

  (gimp-display-new theNewImage)

  (gimp-image-scale theNewImage
		    (* (car (gimp-image-width theNewImage)) 3)
		    (* (car (gimp-image-height theNewImage)) 3))

  (gimp-image-insert-layer theNewImage (car (gimp-layer-new theNewImage
                  (car (gimp-image-width theNewImage))
                  (car (gimp-image-height theNewImage))
                  RGBA-IMAGE
                  "new"
                  100
                  NORMAL-MODE)) 0 -1)

  (gimp-displays-flush)
					;clean up
  )
)

(script-fu-register
 "script-fu-copy-region"                        ;func name
 "Copy/Paste/Scale as New"                                  ;menu label
 "Copies the visible selection, pastes it into a new image, and scales by 3."      ;description
 "Zachary Stark"                                  ;author
 "Zachary Stark, 2014"                  ;copyright notice
 "January 2014"                                  ;date created
 ""                                  ;image type that the script works on
 SF-IMAGE "Image" 0
 SF-DRAWABLE "Drawable" 0
 )

(script-fu-menu-register "script-fu-copy-region" "<Image>/Edit")
