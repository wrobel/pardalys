;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; LOAD TIMER
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq message-log-max 400)

(defun timed-load (file)
  (setq now (float-time))
  (load file)
  (setq then (float-time))
  (message (concat
            "Loaded file \"" file ".el\" in "
            (number-to-string (/ (ffloor (* 100 (- then now))) 100))
            " seconds.")))
