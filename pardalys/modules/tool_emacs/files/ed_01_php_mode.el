;; Allows to autoload the package

;; Links
;;
;; http://prajwala-techi.blogspot.com/
;; http://atomized.org/2008/10/php-lint-and-style-checking-from-emacs/
;; http://ww1.netzologie.de/php/phpeditor-emacs.php
;; http://st-on-it.blogspot.com/2008/02/charged-php-mode-for-emacs-and-more.html


;; activate speedbar
(setq php-mode-speedbar-open 1)
(setq imenu-create-index-function 'imenu-default-create-index-function)

(require 'php-mode)
(require 'geben)
(require 'whitespace)

;; Set the location for browsing the php manual.
(setq php-manual-url "http://www.php.net/manual/en")
(setq php-search-url "http://www.php.net/search.php?show=quickref&pattern=")

;; Provide completion support
(setq php-completion-file "/usr/share/doc/php-docs-20071125-r2/en/html/php_completions")

;; Debugger startup command.
(setq geben-dbgp-command-line "xdebug -p 9000")

;; Customizations for Horde editing
(defun php-mode-horde-hook ()
  (c-toggle-syntactic-indentation 1)
  (c-toggle-electric-state 1)
  (c-toggle-auto-hungry-state 1)
  (c-toggle-auto-newline -1)
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
  (setq fill-column 80)
  (run-hooks 'php-mode-pear-hook)
)

;; taken from http://atomized.org/2008/10/php-lint-and-style-checking-from-emacs/
(defun php-lint ()
  "Performs a PHP lint check on the current file."
  (interactive)
  (let ((compilation-error-regexp-alist '(php))
        (compilation-error-regexp-alist-alist ()))
    (pushnew '(php "\\(syntax error.*\\) in \\(.*\\) on line \\([0-9]+\\)$" 2 3 nil nil 1)
             compilation-error-regexp-alist-alist)
    (compile (concat "php -l -f \"" (buffer-file-name) "\""))))

;; taken from http://atomized.org/2008/10/php-lint-and-style-checking-from-emacs/
(defun phpcs ()
  "Performs a PHPCS lint-check on the current file."
  (interactive)
  (let ((compilation-error-regexp-alist '(php))
        (compilation-error-regexp-alist-alist ()))
    (pushnew '(php "\"\\([^\"]+\\)\",\\([0-9]+\\),\\([0-9]+\\),\\(\\(warning\\)\\|\\(error\\)\\),\\(.*\\)" 1 2 3 (5 . 6) 4)
             compilation-error-regexp-alist-alist)
    (compile (concat "phpcs --standard=PEAR --report=csv \"" (buffer-file-name) "\""))))
 
;; Activate PHP Horde editing
(defun php-setenv-horde ()
  (interactive)
  (add-hook 'php-mode-hook 'php-mode-horde-hook)
  (php-mode-horde-hook))

(setq whitespace-modes (append '(php-mode) whitespace-modes))

(defun php-start-php-on-buffer()
  (interactive)
  (if (not buffer-file-read-only)
      (save-buffer))
  (setq currentdir (concat (file-name-directory buffer-file-name) "/"))
  (while (and (not (file-exists-p (concat currentdir ".emacs.php.el")))
	      (not (eq currentdir "/")))
    (setq currentdir (file-name-directory (directory-file-name currentdir))))
  (setq phpsettings (concat currentdir ".emacs.php.el"))
  (if (file-exists-p phpsettings)
      (load phpsettings)
    (setq phpoptions ":/usr/share/php5:/usr/share/php\" -d log_errors=1 -d error_log=\"php-errors.log\" -d error_reporting=\"E_ALL\" "))
  (if classname
      (let ((compilation-error-regexp-alist ()))
	(add-to-list 'compilation-error-regexp-alist
		     '("^\\(\\/.*\.php\\):\\([0-9]+\\)$" 1 2 nil nil nil))
	(add-to-list 'compilation-error-regexp-alist
		     '("\\(^.*[Ee]rror.*\\|^.*Exception.*\\) in \\(.*\\) on line \\([0-9]+\\)$" 2 3 nil nil 1))
	(add-to-list 'compilation-error-regexp-alist
		     '("[0-9]+\. \\([^ ]*\\) \\([^ ]*\\):\\([0-9]+\\)$" 2 3 nil nil 1))
	(set (make-local-variable 'phpunit-command)
	     (concat
	      "export XDEBUG_CONFIG=\"idekey=php_run\";cd "
	      (file-name-directory buffer-file-name)
	      "; php -d include_path=\".:"
	      (file-name-directory buffer-file-name)
	      phpoptions
	      " -f "
	      (file-name-nondirectory buffer-file-name)))
	(compile phpunit-command))
    (message "No possible test class found!")))

(defun php-start-phpunit-on-buffer()
  (interactive)
  (if (not buffer-file-read-only)
      (save-buffer))
  (save-excursion
    (goto-char (point-min))
    (re-search-forward
     "^\\s-*class\\s-+\\([[:alnum:]_]+\\)\\s-*"
     nil nil)
    (setq classname (buffer-substring-no-properties
		     (match-beginning 1) (match-end 1))))
  (setq currentdir (concat (file-name-directory buffer-file-name) "/"))
  (while (and (not (file-exists-p (concat currentdir ".emacs.php.el")))
	      (not (eq currentdir "/")))
    (setq currentdir (file-name-directory (directory-file-name currentdir))))
  (setq phpsettings (concat currentdir ".emacs.php.el"))
  (if (file-exists-p phpsettings)
      (load phpsettings)
    (setq phpunitoptions ":/usr/share/php5:/usr/share/php\" -d log_errors=1 -d error_log=\"php-errors.log\" -d error_reporting=\"E_ALL\" "))
  (if classname
      (let ((compilation-error-regexp-alist ()))
	(add-to-list 'compilation-error-regexp-alist
		     '("^\\(\\/.*\.php\\):\\([0-9]+\\)$" 1 2 nil nil nil))
	(add-to-list 'compilation-error-regexp-alist
		     '("\\(^.*[Ee]rror.*\\|^.*Exception.*\\) in \\(.*\\) on line \\([0-9]+\\)$" 2 3 nil nil 1))
	(add-to-list 'compilation-error-regexp-alist
		     '("[0-9]+\. \\([^ ]*\\) \\([^ ]*\\):\\([0-9]+\\)$" 2 3 nil nil 1))
	(set (make-local-variable 'phpunit-command)
	     (concat
	      "export XDEBUG_CONFIG=\"idekey=php_unit_run\";cd "
	      (file-name-directory buffer-file-name)
	      "; phpunit --verbose -d include_path=\".:"
	      (file-name-directory buffer-file-name)
	      phpunitoptions
	      classname
	      " "
	      (file-name-nondirectory buffer-file-name)))
	(compile phpunit-command))
    (message "No possible test class found!")))

(defun php-start-phpunit-story-on-buffer()
  (interactive)
  (if (not buffer-file-read-only)
      (save-buffer))
  (save-excursion
    (goto-char (point-min))
    (re-search-forward
     "^\\s-*class\\s-+\\([[:alnum:]_]+\\)\\s-*"
     nil nil)
    (setq classname (buffer-substring-no-properties
		     (match-beginning 1) (match-end 1))))
  (setq currentdir (concat (file-name-directory buffer-file-name) "/"))
  (while (and (not (file-exists-p (concat currentdir ".emacs.php.el")))
	      (not (eq currentdir "/")))
    (setq currentdir (file-name-directory (directory-file-name currentdir))))
  (setq phpsettings (concat currentdir ".emacs.php.el"))
  (if (file-exists-p phpsettings)
      (load phpsettings)
    (setq phpunitoptions ":/usr/share/php5:/usr/share/php\" -d log_errors=1 -d error_log=\"php-errors.log\" -d error_reporting=\"E_ALL\" "))
  (if classname
      (let ((compilation-error-regexp-alist ()))
	(add-to-list 'compilation-error-regexp-alist
		     '("^\\(\\/.*\.php\\):\\([0-9]+\\)$" 1 2 nil nil nil))
	(add-to-list 'compilation-error-regexp-alist
		     '("\\(^.*[Ee]rror.*\\|^.*Exception.*\\) in \\(.*\\) on line \\([0-9]+\\)$" 2 3 nil nil 1))
	(add-to-list 'compilation-error-regexp-alist
		     '("[0-9]+\. \\([^ ]*\\) \\([^ ]*\\):\\([0-9]+\\)$" 2 3 nil nil 1))
	(set (make-local-variable 'phpunit-command)
	     (concat
	      "export XDEBUG_CONFIG=\"idekey=php_unit_run\";cd "
	      (file-name-directory buffer-file-name)
	      "; phpunit --story -d include_path=\".:"
	      (file-name-directory buffer-file-name)
	      phpunitoptions
	      classname
	      " "
	      (file-name-nondirectory buffer-file-name)))
	(compile phpunit-command))
    (message "No possible test class found!")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  F3 - Evaluating, programming
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PHP

;; Call PHP help
(define-key php-mode-map (kbd "<f3> <f1>") 'php-search-documentation)
(define-key php-mode-map (kbd "<f3> <f2>") 'php-browse-manual)

;; Completion/Lookup
(define-key php-mode-map (kbd "<f3> <f4>") 'php-complete-function)
(define-key php-mode-map (kbd "<f3> <f5>") 'php-show-arglist)

;; Go to the next error in the compilation buffer
(define-key php-mode-map (kbd "<f4> <f4>") 'next-error)
(define-key php-mode-map (kbd "<f4> <f3>") 'previous-error)

;; Set Horde code style
(define-key php-mode-map (kbd "<f3> H") 'php-setenv-horde)

;; Run php script
(define-key php-mode-map (kbd "<f3> <f7>") 'php-start-php-on-buffer)

;; Run unit tests
(define-key php-mode-map (kbd "<f3> <f8>") 'php-start-phpunit-on-buffer)

;; Run a story test
(define-key php-mode-map (kbd "<f3> <f9>") 'php-start-phpunit-story-on-buffer)

;; Check code
(define-key php-mode-map (kbd "<f3> <f10>") 'php-lint)

;; Check code style
(define-key php-mode-map (kbd "<f3> <f11>") 'phpcs)

;; Move between functions
(define-key php-mode-map (kbd "<f3> <up>")   'beginning-of-defun)
(define-key php-mode-map (kbd "<f3> <down>") 'end-of-defun)
