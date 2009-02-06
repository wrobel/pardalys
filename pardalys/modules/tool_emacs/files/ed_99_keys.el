;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  KEYMAPS
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Set up the keyboard so the delete key on both the regular keyboard
;; and the keypad delete the character under the cursor and to the right
;; under X, instead of the default, backspace behavior.
(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)
(global-set-key [pause] 'keyboard-quit)
(global-set-key [key-20] 'keyboard-quit)
(global-set-key [XF86Save] 'save-buffer)
(global-set-key [XF86Close] 'kill-buffer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  F3 - Evaluating, programming
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global

;; Make sure we can use it as prefix
(global-set-key (kbd "<f3>") nil)

;; Make sure we can use it as prefix
(global-set-key (kbd "<f4>") nil)

;; evaluate a region
(global-set-key (kbd "<f3> RET") 'eval-region)

;; activate debugging
(global-set-key (kbd "<f3> d") 'set-personal-variable-debug-on-error)

;; check for useless whitespace
(global-set-key (kbd "<f3> w") 'whitespace-buffer)
(global-set-key (kbd "<f3> q") 'whitespace-cleanup)

;; Go to the next error in the compilation buffer
(global-set-key (kbd "<f3> <f5>") 'next-error)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  F5 - 
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Make sure we can use it as prefix
(global-set-key (kbd "<f5>") nil)

;; evaluate a region
(global-set-key (kbd "<f5> <f5>") 'find-file)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  F6 - 
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Make sure we can use it as prefix
(global-set-key (kbd "<f6>") nil)

;; kill a buffer
(global-set-key (kbd "<f6> <f6>") 'kill-buffer)

(defun save-and-kill ()
  (interactive)
  (save-buffer)
  (kill-buffer (current-buffer)))

;; save and kill
(global-set-key (kbd "<f6> <f11>") 'save-and-kill)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  F9 - Create new stuff
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Make sure we can use it as prefix
(global-set-key (kbd "<f9>") nil)

;; create a new task 
;;(global-set-key (kbd "<f9> t") 'planner-create-task-from-buffer)
;; copy a task to a new date
;;(global-set-key (kbd "<f9> c") 'planner-create-task-from-task)

;; create a new note
;;(global-set-key (kbd "<f9> n") 'planner-create-note-on-page)

;; create a new blog entry
(global-set-key (kbd "<f9> b") 'muse-blosxom-new-entry)

;; create a new diary entry
(global-set-key (kbd "<f9> d") 'muse-private-new-entry)

;; post a link to del.icio.us
(global-set-key (kbd "<f9> l") 'delicious-post)

;; post a link to del.icio.us offline
(global-set-key (kbd "<f9> o") 'delicious-post-offline)

;; create a password
(global-set-key (kbd "<f9> p") 'make-password-here)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Formatting

;; fix a python line
(global-set-key (kbd "<f9> f p") 'python-fix-string-line)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  F10 - Visibility/Spellcheck stuff
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Make sure we can use it as prefix
(global-set-key (kbd "<f10>") nil)

;; spell checking
(global-set-key (kbd "<f10> <f10>") 'ispell)

;; Toggle exit/enter
(global-set-key (kbd "<f10> d") 'wrobel/spellcheck-de)

;; Toggle exit/enter
(global-set-key (kbd "<f10> e") 'wrobel/spellcheck-en)

;;  Folding mode
;;;;;;;;;;;;;;;;

;; ;; Hide current fold
;; (define-key folding-mode-map (kbd "<f10> h") 'folding-hide-current-entry)
;; ;; Hide all folds
;; (define-key folding-mode-map (kbd "<f10> w") 'folding-whole-buffer)

;; ;; Show current fold
;; (define-key folding-mode-map (kbd "<f10> s") 'folding-show-current-entry)

;; ;; Show all folds
;; (define-key folding-mode-map (kbd "<f10> a") 'folding-show-all)

;; ;; Enter single fold 
;; (define-key folding-mode-map (kbd "<f10> >") 'folding-shift-in)

;; ;; Exit single fold 
;; (define-key folding-mode-map (kbd "<f10> <") 'folding-shift-out)

;; ;; Toggle show/hide 
;; (define-key folding-mode-map (kbd "<f10> <f9>") 'folding-toggle-show-hide)

;; ;; Toggle exit/enter
;; (define-key folding-mode-map (kbd "<f10> <f11>") 'folding-toggle-enter-exit)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  F11 - Buffer stuff
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Make sure we can use it as prefix
(global-set-key (kbd "<f11>") nil)

;; save buffer as indicated on the f11 key
(global-set-key (kbd "<f11> <f11>") 'save-buffer)

;; switch between windows
(global-set-key (kbd "<f11> DEL") 'other-window)

;; switch between frames
(global-set-key  (kbd "<f11> RET") 'other-frame)

;; switch between frames
(global-set-key  (kbd "<f11> <f12> <f12>") 'erc-track-switch-buffer)
(global-set-key  (kbd "<f11> <f12> RET") 'irc)
(global-set-key  (kbd "<f11> <f12> DEL") 'erc-next-channel-buffer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Special keys
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key (kbd "<XF86Messenger>") 'erc-track-switch-buffer)
(global-set-key (kbd "M-<XF86Messenger>") 'irc)
(global-set-key (kbd "C-<XF86Messenger>") 'erc-next-channel-buffer)
(global-set-key (kbd "S-<XF86Messenger> <delete>") 'reset-erc-track-mode)

(defun go-browse ()
  (interactive)
  (browse-url (browse-url-url-at-point)))

(global-set-key (kbd "<XF86HomePage>") 'go-browse)
(global-set-key (kbd "M-<XF86HomePage>") 'delicious-post)
(global-set-key (kbd "C-<XF86HomePage>") 'delicious-post-offline)

;; for church in case backspace does not work
;;(global-set-key (kbd "C-h") 'delete-backward-char)

(global-set-key (kbd "<XF86Mail>") 'gnus-group-mail)
(global-set-key (kbd "M-<XF86Mail>") 'gnus)
(global-set-key (kbd "C-<XF86Mail>") 'mml-secure-message-sign-pgpmime)
(global-set-key (kbd "C-S-<XF86Mail>") 'gnus-create-imap-folder)
(global-set-key (kbd "<f9> <XF86Mail> g") 'wrobel/gnus-mail-gentoo)
(global-set-key (kbd "<f9> <XF86Mail> p") 'wrobel/gnus-mail-post)
(global-set-key (kbd "<f9> <XF86Mail> c") 'wrobel/gnus-mail-pardus)

;; using dabbrev
(global-set-key (kbd "C-<") 'dabbrev-expand)
