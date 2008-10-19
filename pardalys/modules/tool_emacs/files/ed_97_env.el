;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BASE
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; turn on font-lock mode
(global-font-lock-mode t)
;; enable visual feedback on selections
(setq-default transient-mark-mode t)

;; always end a file with a newline
(setq require-final-newline t)

;; disable beeps
(setq visible-bell t)

;; get rid of yes-or-no questions - y or n is enough
(defalias 'yes-or-no-p 'y-or-n-p)

;; not really interesting
(setq-default inhibit-startup-message t)

 ;; i want a mouse yank to be inserted where the point is, not where i click
(setq-default mouse-yank-at-point t)

;; Spell checking
(setq-default ispell-program-name "aspell")
(setq-default spell-command "aspell")

;; Use utf-8
(set-language-environment "utf-8")
(set-keyboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Backups
(setq backup-dir "~/.backup")

(unless (file-directory-p backup-dir)
  (make-directory backup-dir))
(setq backup-directory-alist (list (cons "." backup-dir)))

(setq backup-by-copying t    ; Don't delink hardlinks
      delete-old-versions t  ; Clean up the backups
      version-control t      ; Use version numbers on backups,
      kept-new-versions 3    ; keep some new versions
      kept-old-versions 2)   ; and some old ones, too

;; Why not backing up every save. Lots of data, but cleaning later 
;; is cheaper than loosing data
(require 'backup-each-save)
(add-hook 'after-save-hook 'backup-each-save)
(defun backup-each-save-filter (filename)
  (let ((ignored-filenames
    	 '("^/tmp" "semantic.cache$" "\\.emacs-places$"
    	   "\\.recentf$" ".newsrc\\(\\.eld\\)?"))
    	(matched-ignored-filename nil))
    (mapc
         (lambda (x)
           (when (string-match x filename)
	     (setq matched-ignored-filename t)))
         ignored-filenames)
    (not matched-ignored-filename)))
(setq backup-each-save-filter-function 'backup-each-save-filter)

;; Avoid having semantic.cache files all over the place
(setq semanticdb-default-save-directory "~/.semantic")

;; position information
(column-number-mode 1)
(line-number-mode 1)

;; clock is nice
(display-time)

;; Do not check leading whitespace by default
(setq whitespace-check-indent-whitespace nil)
(setq whitespace-check-leading-whitespace nil)
