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

(defun php-compile (arg)
  "Runs a compilation process with a number of PHP style checks."
  (interactive "p")
  (let ((compilation-error-regexp-alist (get-php-compilation-regexp)))
    (setq cb (current-buffer))
    (php-loc arg)
    (switch-to-buffer "*compilation*")
    (if (get-buffer  "*php lines of code*")
	(kill-buffer "*php lines of code*"))
    (rename-buffer "*php lines of code*")
    (switch-to-buffer cb)
    (php-pmd arg)
    (switch-to-buffer "*compilation*")
    (if (get-buffer  "*php mess detection*")
	(kill-buffer "*php mess detection*"))
    (rename-buffer "*php mess detection*")
    (switch-to-buffer cb)
    (php-cpd arg)
    (switch-to-buffer "*compilation*")
    (if (get-buffer  "*php copy paste detection*")
	(kill-buffer "*php copy paste detection*"))
    (rename-buffer "*php copy paste detection*")
    (switch-to-buffer cb)
    (phpcs arg)
    (switch-to-buffer "*compilation*")
    (if (get-buffer  "*php code style*")
	(kill-buffer "*php code style*"))
    (rename-buffer "*php code style*")
    (switch-to-buffer cb)
    (php-lint arg)
    (switch-to-buffer "*compilation*")
    (if (get-buffer  "*php lint*")
	(kill-buffer "*php lint*"))
    (rename-buffer "*php lint*")
    (switch-to-buffer cb)
    ))

;; taken from http://atomized.org/2008/10/php-lint-and-style-checking-from-emacs/
(defun php-lint (arg)
  "Performs a PHP lint check on the current file."
  (interactive "p")
  (setq phpsettings (get-file-in-hierarchy ".emacs.php.el"))
  (load phpsettings)
  (let ((compilation-error-regexp-alist (get-php-compilation-regexp))
	(file-arg (if (> arg 1) (get-one-below-dir-in-hierarchy package_dir)
		    (buffer-file-name))))
    (compile (format "%s \"%s\""
		     phplint_cmd
		     file-arg))))

(defun phpcs (arg)
  "Performs a PHP code sniffer check on the current file."
  (interactive "p")
  (setq phpsettings (get-file-in-hierarchy ".emacs.php.el"))
  (load phpsettings)
  (let ((compilation-error-regexp-alist (get-php-compilation-regexp))
	(file-arg (if (> arg 1) (get-one-below-dir-in-hierarchy package_dir)
		    (buffer-file-name))))
    (compile (format "%s %s %s"
		     phpcs_command
		     phpcs_options
                     file-arg))))
 
(defun php-loc (arg)
  (interactive "p")
  (if (not buffer-file-read-only)
      (save-buffer))
  (setq phpsettings (get-file-in-hierarchy ".emacs.php.el"))
  (load phpsettings)
  (let ((compilation-error-regexp-alist (get-php-compilation-regexp))
	(file-arg (if (> arg 1) (get-one-below-dir-in-hierarchy package_dir)
		    (buffer-file-name))))
    (compile (format "%s %s %s"
		     plc_command
		     plc_options
		     file-arg))))

(defun php-cpd (arg)
  (interactive "p")
  (if (not buffer-file-read-only)
      (save-buffer))
  (setq phpsettings (get-file-in-hierarchy ".emacs.php.el"))
  (load phpsettings)
  (let ((compilation-error-regexp-alist (get-php-compilation-regexp))
	(file-arg (if (> arg 1) (get-one-below-dir-in-hierarchy package_dir)
		    (buffer-file-name))))
    (compile (format "%s %s %s"
		     pcp_command
		     pcp_options
		     file-arg))))

(defun php-pmd (arg)
  (interactive "p")
  (if (not buffer-file-read-only)
      (save-buffer))
  (setq phpsettings (get-file-in-hierarchy ".emacs.php.el"))
  (load phpsettings)
  (let ((compilation-error-regexp-alist (get-php-compilation-regexp))
	(file-arg (if (> arg 1) (get-one-below-dir-in-hierarchy package_dir)
		    (buffer-file-name))))
  (compile (format "%s;cd %s;%s %s %s %s %s"
		     pmd_pre
		     (file-name-directory buffer-file-name)
		     pmd_command
		     file-arg
		     pmd_format
		     pmd_codestyle
		     pmd_options))))

(defun php-unit (format)
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
  (setq phpsettings (get-file-in-hierarchy ".emacs.php.el"))
  (load phpsettings)
  (setq phpunit_options (concat phpunit_options
                                " "
                                (cond ((string= format "Story") "--story")
                                      ((string= format "Dox") "--testdox")
                                      (t ""))))
  (if classname
      (let ((compilation-error-regexp-alist (get-php-compilation-regexp)))
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

(defun php-start-php-on-buffer()
  (interactive)
  (if (not buffer-file-read-only)
      (save-buffer))
  (setq phpsettings (get-file-in-hierarchy ".emacs.php.el"))
  (load phpsettings)
  (let ((compilation-error-regexp-alist (get-php-compilation-regexp)))
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Helpers
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun get-php-compilation-regexp ()
  (let ((php-regexp-alist ()))
    ;; Syntax error when running the php lint process
    (add-to-list 'php-regexp-alist
		 '("\\(syntax error.*\\) in \\(.*\\) on line \\([0-9]+\\)$" 2 3 nil nil 1))

    ;; GNU definition from compile.el used with the Code Sniffer style check
    (add-to-list 'php-regexp-alist
		 '("^\\(?:[[:alpha:]][-[:alnum:].]+: ?\\)?\
\\([0-9]*[^0-9\n]\\(?:[^\n ]\\| [^-\n]\\)*?\\): ?\
\\([0-9]+\\)\\(?:\\([.:]\\)\\([0-9]+\\)\\)?\
\\(?:-\\([0-9]+\\)?\\(?:\\3\\([0-9]+\\)\\)?\\)?:\
\\(?: *\\(\\(?:Future\\|Runtime\\)?[Ww]arning\\|W:\\)\\|\
 *\\([Ii]nfo\\(?:\\>\\|rmationa?l?\\)\\|I:\\|instantiated from\\|[Nn]ote\\)\\|\
\[0-9]?\\(?:[^0-9\n]\\|$\\)\\|[0-9][0-9][0-9]\\)"
		   1 (2 . 5) (4 . 6) (7 . 8)))

    ;; Errors from the Emacs driver of the PHP mess detector
    (add-to-list 'php-regexp-alist
		 '("^\\([^:]*\\):\\([0-9]+\\)[^:]+: \\(?:[Ee]rror\\|[Ww]arnin\\(g\\)\\):.+$" 1 2 nil (3) nil))
    
    ;; Errors when running php on a buffer
    (add-to-list 'php-regexp-alist
		 '("^\\(\\/.*\.php\\):\\([0-9]+\\)$" 1 2 nil nil nil))
    (add-to-list 'php-regexp-alist
		 '("\\(^.*[Ee]rror.*\\|^.*Exception.*\\) in \\(.*\\) on line \\([0-9]+\\)$" 2 3 nil nil 1))
    (add-to-list 'php-regexp-alist
		 '("[0-9]+\. \\([^ ]*\\) \\([^ ]*\\):\\([0-9]+\\)$" 2 3 nil nil 1))

    ;; Errors when running PHPUnit on a test case
    (add-to-list 'php-regexp-alist
		 '("^\\(\\/.*\.php\\):\\([0-9]+\\)$" 1 2 nil nil nil))
    (add-to-list 'php-regexp-alist
		 '("\\(^.*[Ee]rror.*\\|^.*Exception.*\\) in \\(.*\\) on line \\([0-9]+\\)$" 2 3 nil nil 1))
    (add-to-list 'php-regexp-alist
		 '("[0-9]+\. \\([^ ]*\\) \\([^ ]*\\):\\([0-9]+\\)$" 2 3 nil nil 1))))

(defun get-file-in-hierarchy (file)
  "Searches the directory tree upwards for the given file and returns the path."
  (setq currentdir (file-name-directory buffer-file-name))
  (while (and (not (file-exists-p (concat currentdir file)))
	      (not (string= currentdir "/")))
    (setq currentdir (file-name-directory (directory-file-name currentdir))))
  (concat currentdir file))

(defun get-one-below-dir-in-hierarchy (dir)
  "Searches the directory tree upwards for the given directory and returns the path."
  (setq currentdir (file-name-directory buffer-file-name))
  (while (and (not (string= (file-name-nondirectory
			     (directory-file-name
			      (file-name-directory
			       (directory-file-name currentdir))))
			    dir))
	      (not (string= currentdir "/")))
    (setq currentdir (file-name-directory (directory-file-name currentdir))))
  currentdir)

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

;; Count lines of code
(define-key php-mode-map (kbd "<f3> <f6>") 'php-loc)

;; Run php script
(define-key php-mode-map (kbd "<f3> <f7>") 'php-start-php-on-buffer)

;; Run unit tests
(define-key php-mode-map (kbd "<f3> <f8>") 'php-unit)

;; Check code
(define-key php-mode-map (kbd "<f3> <f9>") 'php-lint)

;; Check code style
(define-key php-mode-map (kbd "<f3> <f10>") 'phpcs)

;; Check copy/paste
(define-key php-mode-map (kbd "<f3> <f11>") 'php-cpd)

;; Run pmd
(define-key php-mode-map (kbd "<f3> <f12>") 'php-pmd)

;; Run all checks combined
(define-key php-mode-map (kbd "<f3> <f3>") 'php-compile)

;; Move between functions
(define-key php-mode-map (kbd "<f3> <up>")   'beginning-of-defun)
(define-key php-mode-map (kbd "<f3> <down>") 'end-of-defun)
