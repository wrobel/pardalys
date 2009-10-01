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

;; Initialize the PHPUnit format history
(setq phpunit-format-history nil)

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

;; Customizations for Horde editing
(defun php-mode-zend-hook ()
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
  (setq indent-tabs-mode 1)
  (setq tab-width 4)
  (setq c-basic-offset 4)
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

(defun get-file-in-hierarchy (file)
  "Searches the directory tree upwards for the given file and returns the path."
  (setq currentdir (file-name-directory buffer-file-name))
  (while (and (not (file-exists-p (concat currentdir file)))
	      (not (string= currentdir "/")))
    (setq currentdir (file-name-directory (directory-file-name currentdir))))
  (concat currentdir file))

(defun phpcs-pear ()
  "Performs a PEAR style PHP code sniffer check on the current file."
  (interactive)
  (phpcs "PEAR"))

(defun phpcs-zend ()
  "Performs a Zend style PHP code sniffer check on the current file."
  (interactive)
  (phpcs "Zend"))
 
(defun phpcs (format)
  "Performs a PHP code sniffer check on the current file."
  (interactive)
  (setq phpsettings (get-file-in-hierarchy ".emacs.php.el"))
  (if (file-exists-p phpsettings)
      (load phpsettings)
    (setq phpcs_command "phpcs"))
  (let ((compilation-error-regexp-alist '(gnu)))
    (compile (format (concat phpcs_command
			     " --standard="
			     format
			     " --report=emacs \"%s\"")
                     (buffer-file-name)))))
 
;; Activate PHP Horde editing
(defun php-setenv-horde ()
  (interactive)
  (add-hook 'php-mode-hook 'php-mode-horde-hook)
  (php-mode-horde-hook))

;; Activate PHP Horde editing
(defun php-setenv-zend ()
  (interactive)
  (add-hook 'php-mode-hook 'php-mode-zend-hook)
  (php-mode-horde-hook))

(setq whitespace-modes (append '(php-mode) whitespace-modes))

(defun php-start-php-on-buffer()
  (interactive)
  (if (not buffer-file-read-only)
      (save-buffer))
  (setq currentdir (concat (file-name-directory buffer-file-name) "/"))
  (while (and (not (file-exists-p (concat currentdir ".emacs.php.el")))
	      (not (string= currentdir "/")))
    (setq currentdir (file-name-directory (directory-file-name currentdir))))
  (setq phpsettings (concat currentdir ".emacs.php.el"))
  (if (file-exists-p phpsettings)
      (load phpsettings)
    (setq phpoptions ":/usr/share/php5:/usr/share/php\" -d log_errors=1 -d error_log=\"php-errors.log\" -d error_reporting=\"E_ALL\" "))
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
    (compile phpunit-command)))

(defun php-start-phpunit-on-buffer (format)
  (interactive (list (completing-read "Output format: "
                                      '(("Default" 1) ("Story" 2) ("Dox" 3))
                                      nil t phpunit-format-history "Default")))
  (if (not buffer-file-read-only)
      (save-buffer))
  (save-excursion
    (goto-char (point-min))
    (re-search-forward
     "^\\s-*class\\s-+\\([[:alnum:]_]+\\)\\s-*"
     nil nil)
    (setq classname (buffer-substring-no-properties
		     (match-beginning 1) (match-end 1))))
  (setq currentdir (file-name-directory buffer-file-name))
  (while (and (not (file-exists-p (concat currentdir ".emacs.php.el")))
	      (not (string= currentdir "/")))
    (setq currentdir (file-name-directory (directory-file-name currentdir))))
  (setq phpsettings (concat currentdir ".emacs.php.el"))
  (if (file-exists-p phpsettings)
      (load phpsettings)
    (progn (setq phpunit_pre "export XDEBUG_CONFIG=\"idekey=php_unit_run\"")
           (setq phpunit_options "--verbose")
           (setq phpunit_phpoptions "-d log_errors=1 -d error_log=\"php-errors.log\" -d error_reporting=\"E_ALL\"")
           (if (compare-strings "/kolab" 0 7
                                (file-name-directory buffer-file-name) 0 7)
               ;; A hack to support the default setup for the Kolab environment
               (progn (setq phpunit_command "/kolab/bin/phpunit")
                      (setq phpunit_includes "/kolab/lib/php"))
             (progn (setq phpunit_command "phpunit")
                    (setq phpunit_includes "/usr/share/php5:/usr/share/php")))))
  (setq phpunit_options (concat phpunit_options
                                " "
                                (cond ((string= format "Story") "--story")
                                      ((string= format "Dox") "--testdox")
                                      (t ""))))
  (if classname
      (let ((compilation-error-regexp-alist ()))
	(add-to-list 'compilation-error-regexp-alist
		     '("^\\(\\/.*\.php\\):\\([0-9]+\\)$" 1 2 nil nil nil))
	(add-to-list 'compilation-error-regexp-alist
		     '("\\(^.*[Ee]rror.*\\|^.*Exception.*\\) in \\(.*\\) on line \\([0-9]+\\)$" 2 3 nil nil 1))
	(add-to-list 'compilation-error-regexp-alist
		     '("[0-9]+\. \\([^ ]*\\) \\([^ ]*\\):\\([0-9]+\\)$" 2 3 nil nil 1))
	(set (make-local-variable 'phpunit-command)
	     (format "%s;cd %s;%s %s -d include_path=\".:%s:%s\" %s %s %s"
	      phpunit_pre
	      (file-name-directory buffer-file-name)
	      phpunit_command
	      phpunit_options
	      (file-name-directory buffer-file-name)
	      phpunit_includes
	      phpunit_phpoptions
	      classname
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

;; Set Zend code style
(define-key php-mode-map (kbd "<f3> Z") 'php-setenv-zend)

;; Run php script
(define-key php-mode-map (kbd "<f3> <f7>") 'php-start-php-on-buffer)

;; Run unit tests
(define-key php-mode-map (kbd "<f3> <f8>") 'php-start-phpunit-on-buffer)

;; Check code
(define-key php-mode-map (kbd "<f3> <f10>") 'php-lint)

;; Check code style
(define-key php-mode-map (kbd "<f3> <f11>") 'phpcs-pear)

;; Check Zend code style
(define-key php-mode-map (kbd "<f3> <f12>") 'phpcs-zend)

;; Move between functions
(define-key php-mode-map (kbd "<f3> <up>")   'beginning-of-defun)
(define-key php-mode-map (kbd "<f3> <down>") 'end-of-defun)
