;; Allows to autoload the package

(require 'php-mode)

(setq php-manual-url "http://www.php.net/manual/en/")

;; Customizations for Horde editing
(defun php-mode-horde-hook ()
  (c-toggle-auto-newline 1)
  (c-toggle-syntactic-indentation 1)
  (c-toggle-electric-state 1)
  (c-toggle-auto-hungry-state 1)
  (c-toggle-syntactic-indentation 1)
  (c-set-offset 'arglist-intro '+)
  (c-set-offset 'arglist-close '0)
;;  (semantic-show-unmatched-syntax-mode nil)
  (setq c-hanging-braces-alist '((brace-list-open)
                                 (brace-entry-open)
                                 (statement-cont)
                                 (substatement-open after)
                                 (block-close . c-snug-do-while)
                                 (extern-lang-open after)
                                 (namespace-open after)
                                 (module-open after)
                                 (composition-open after)
                                 (inexpr-statement after)
                                 (inexpr-class-close before)))
  (run-hooks 'php-mode-pear-hook)
)
 
;; Activate PHP Horde editing
(defun php-setenv-horde ()
  (interactive)
  (add-hook 'php-mode-user-hook 'php-mode-horde-hook)
  (php-mode-horde-hook))

;; Setting environments
(php-setenv-horde)

;; Call PHP help
(define-key php-mode-map (kbd "<f3> <f1>") 'php-search-documentation)
