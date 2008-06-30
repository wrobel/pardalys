;;; dev-util/git site-lisp configuration

(add-to-list 'load-path "/usr/share/emacs/site-lisp/git")
(autoload 'git-status "git" "Entry point into git-status mode." t)
(autoload 'git-blame-mode "git-blame"
  "Minor mode for incremental blame for Git." t)

(unless (fboundp 'vc-git-registered) 
  (add-to-list 'vc-handled-backends 'GIT))
