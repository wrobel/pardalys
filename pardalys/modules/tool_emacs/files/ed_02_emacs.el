;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Debugging

(defun set-personal-variable-debug-on-error ()
  (interactive)
  (if debug-on-error
      (setq debug-on-error nil)
    (setq debug-on-error t))
  (print debug-on-error)
)
