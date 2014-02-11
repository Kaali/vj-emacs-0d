;; -*-mode: Emacs-Lisp; folding-mode:t-*-
;; Fold shortcuts:
;;   Enter fold C-c @ >
;;   Exit fold C-c @ <
;;   Show whole C-c @ C-o
;;   Hide whole C-c @ C-w
;;   Show subtree C-c @ C-y
;;   Hide subtree C-c @ C-z

;;; TODO: Cleanup the file
;;; TODO: More stuff from my old config
;;; TODO: Fix annoying autocomplete when replacing words
;;; TODO: Decide between smartparen vs paredit
;;; TODO: M-/ does not autocomplete globally
;;; TODO: tab completion?

;;{{{ Bootstrap Emacs with packages

(require 'cl)

(setq package-enable-at-startup nil)
(package-initialize)

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(setq el-get-install-skip-emacswiki-recipes t)
(unless (require 'el-get nil 'noerror)
    (with-current-buffer
            (url-retrieve-synchronously
                     "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
                (goto-char (point-max))
                    (eval-print-last-sexp)))

(setq el-get-sources
      '(
        (:name ede-compdb
               :type git
               :url "https://github.com/randomphrase/ede-compdb")
        (:name eval-sexp-fu
               :type http
               :url "http://www.emacswiki.org/emacs/download/eval-sexp-fu.el")
        (:name folding
               :type http
               :url "http://www.emacswiki.org/emacs/download/folding.el")
        (:name magit-filenotify
               :type git
               :url "https://github.com/magit/magit-filenotify")
        (:name helm-swoop
               :type git
               :url "https://github.com/ShingoFukuyama/helm-swoop")
        (:name helm-cscope
               :type git
               :url "https://github.com/Kaali/helm-cscope")
        (:name zenburn-emacs
               :type git
               :url "https://github.com/Kaali/zenburn-emacs")
        ))

(setq my-el-get-packages
      (append
        '()
        (mapcar 'el-get-source-name el-get-sources)))

(el-get 'sync my-el-get-packages)

(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))

(setq packages-list
      '(
	ac-nrepl
	ace-jump-mode
	ack-and-a-half
	auto-complete
	back-button
	cider
	clojure-mode
	diff-hl
	dired+
	discover
	elpy
	expand-region
	fic-ext-mode
	flycheck
	helm
	helm-c-yasnippet
	helm-descbinds
	helm-git
	helm-gtags
	helm-projectile
	highlight
	highlight-symbol
	key-chord
	magit
	move-text
	multiple-cursors
	nrepl-eval-sexp-fu
	org
	paredit
	pos-tip
	rainbow-mode
	sequential-command
	smartparens
	undo-tree
	yasnippet
color-theme-solarized))

;; from http://blog.zhengdong.me/2012/03/14/how-i-manage-emacs-packages
(defun has-package-not-installed ()
  (loop for p in packages-list
        when (not (package-installed-p p)) do (return t)
        finally (return nil)))

(when (has-package-not-installed)
  ;; Check for new packages (package versions)
  (message "%s" "Get latest versions of all packages...")
  (package-refresh-contents)
  (message "%s" " done.")
  ;; Install the missing packages
  (dolist (p packages-list)
    (when (not (package-installed-p p))
      (package-install p))))

;;}}}

;;{{{ Settings

;;{{{ Basics

;; Locale
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)

;; General settings
(setq
 inhibit-startup-message t
 require-final-newline t
 major-mode 'text-mode
 indicate-buffer-boundaries 'left
 )

(put 'narrow-to-region 'disabled nil)

(global-auto-revert-mode 1)
(show-paren-mode t)
(defalias 'yes-or-no-p 'y-or-n-p) 

(require 'saveplace)
(setq-default save-place t)

;; Put backup files to temporary file directory
(setq
 backup-directory-alist `((".*" . ,temporary-file-directory))
 auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Allow some folding-mode in local variables
(setq safe-local-variable-values
      (quote ((folding-mode . t))))

;; Mark-ring is navigable by typing C-u C-SPC and then repeating C-SPC forever
(setq set-mark-command-repeat-pop t)

;;}}}

;;{{{ Visual

(global-font-lock-mode 1)
;; (load-theme 'zenburn t)
(load-theme 'solarized-dark t)
(setq solarized-termcolors 256)
(setq solarized-contrast 'low)
(setq frame-background-mode 'dark)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(transient-mark-mode 1)
(show-paren-mode 1)
(column-number-mode 1)
(size-indication-mode t)
(set-default 'indicate-empty-lines 1)

;; Setup font and small/normal/large font size switch
(defvar *small-font* "-apple-inconsolata-medium-r-normal--10-0-72-72-m-0-iso10646-1")
(defvar *normal-font* "-apple-inconsolata-medium-r-normal--12-0-72-72-m-0-iso10646-1")
(defvar *large-font* "-apple-inconsolata-medium-r-normal--15-0-72-72-m-0-iso10646-1")

(set-face-font 'default *normal-font*)

;;}}}

;;{{{ Mac Settings

(if (eq system-type 'darwin)
  (setq mac-pass-option-to-system t
	mac-command-key-is-meta t
	mac-pass-control-to-system nil
	mac-pass-command-to-system nil
	mac-option-modifier nil
	mac-command-modifier 'meta
	mac-control-modifier 'control
	mac-pass-command-to-system nil
	browse-url-browser-function 'browse-url-default-macosx-browser
	ns-use-native-fullscreen nil
	calc-gnuplot-name "/usr/local/bin/gnuplot"
	calc-gnuplot-default-device "dumb"
	calc-gnuplot-default-output "STDOUT"
	))

;;}}}

;;{{{ Custom Functions

;; Output calc gnuplot to temp svg
(defun vj/calc-plot-set-svg ()
  (interactive)
  (setq calc-plot-svg-tempname (concat (make-temp-file "calcplot") ".svg"))
  (calc-graph-set-command "output" (prin1-to-string calc-plot-svg-tempname))
  (calc-graph-set-command "terminal" "svg")
  (calc-graph-plot nil)
  (shell-command (format "open \"%s\"" calc-plot-svg-tempname)))

(defun vj/calc-plot-set-default ()
  (interactive)
  (calc-graph-set-command "output" (prin1-to-string "STDOUT"))
  (calc-graph-set-command "terminal" "dumb"))

;; Vim like open line
(defun vj/open-line-after ()
  (interactive)
  (end-of-line)
  (newline-and-indent))

;; Zap up to char like in Vim, Emacs behaviour maps to M-Z
(defun vj/zap-up-to-char (arg char)
  "Zap up to a character."
  (interactive "p\ncZap up to char: ")
  (zap-to-char arg char)
  (insert char)
  (forward-char -1))

(defun vj/small-font () (interactive) (set-face-font 'default *small-font*))
(defun vj/normal-font () (interactive) (set-face-font 'default *normal-font*))
(defun vj/large-font () (interactive) (set-face-font 'default *large-font*))

(defun eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

;; Change cutting behaviour:
;;  "Many times you'll do a kill-line command with the only intention of
;;  getting the contents of the line into the killring. Here's an idea
;;  stolen from Slickedit, if you press copy or cut when no region is
;;  active you'll copy or cut the current line:"
;;  <http://www.zafar.se/bkz/Articles/EmacsTips>
(defadvice kill-ring-save (before slickcopy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defadvice kill-region (before slickcut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defun vj/get-keychain-password (account server keychain)
  (with-temp-buffer
    (call-process-shell-command "security" nil (current-buffer) nil "-v find-internet-password -g -a" account "-s" server keychain)
    (goto-char 0)
    (re-search-forward "password: \"\\(.*\\)\"")
    (match-string 1)))

;; From http://hjiang.net/archives/253, optional arg added by
;; Väinö Järvelä
(defun smart-split (&optional arg)
  "Split the frame into 80-column sub-windows, and make sure no window has
   fewer than 80 columns.

   If OPTIONAL arg is supplied, then use that as the minimum width of the
   windows."
  (interactive "P")
  (defun smart-split-helper (w min-width)
    "Helper function to split a given window into two, the first of which
     has min-width columns."
    (if (> (window-width w) (* 2 (+ min-width 1)))
    (let ((w2 (split-window w (+ min-width 2) t)))
      (smart-split-helper w2 min-width))))
  (smart-split-helper nil (or arg 80)))

(defun credmp/flymake-display-err-minibuf ()
  "Displays the error/warning for the current line in the minibuffer"
  (interactive)
  (let* ((line-no             (flymake-current-line-no))
         (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
         (count               (length line-err-info-list))
         )
    (while (> count 0)
      (when line-err-info-list
        (let* ((file       (flymake-ler-file (nth (1- count) line-err-info-list)))
               (full-file  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
          (message "[%s] %s" line text)
          )
        )
      (setq count (1- count)))))

;;}}}

;;{{{ Package configuration

;; cua
;; (cua-mode nil)
;; (setq cua-enable-cua-keys nil)

(eval-after-load "ace-jump-mode"
  '(ace-jump-mode-enable-mark-sync))

;; On OSX change calc-roll-up M-tab to C-tab because of conflict
(if (eq system-type 'darwin)
    (require 'calc)
    (add-hook 'calc-mode-hook
	      '(lambda ()
		 (local-set-key [(control tab)] 'calc-roll-up))))

;; (require 'paredit)
;; (autoload 'paredit-mode "paredit"
;;   "Minor mode for pseudo-structurally editing Lisp code." t)
;; (add-hook 'emacs-lisp-mode-hook       (lambda () (paredit-mode +1)))
;; (add-hook 'lisp-mode-hook             (lambda () (paredit-mode +1)))
;; (add-hook 'lisp-interaction-mode-hook (lambda () (paredit-mode +1)))

(require 'auto-complete-config)
(ac-config-default)
(setq ac-use-fuzzy t)
(setq ac-auto-show-menu nil)
(setq ac-quick-help-delay nil)

;; Ripped from Stecker Halter's Emacs configuration at http://steckerhalter.co.vu/steckemacs.html
(require 'pos-tip)
(defun stk/ac-show-help (ac-doc-function)
  "Show docs for symbol at point or at beginning of list if not on a symbol.
Pass symbol-name to the function AC-DOC-FUNCTION."
  (interactive)
  (let ((s (symbol-name
            (save-excursion
              (or (symbol-at-point)
                  (progn (backward-up-list)
                         (forward-char)
                         (symbol-at-point)))))))
    (let ((doc-string (funcall ac-doc-function s)))
      (if doc-string
          (if ac-quick-help-prefer-x
              (pos-tip-show doc-string 'popup-tip-face (point) nil -1 60)
            (popup-tip doc-string :point (point)))
        (message "No documentation for %s" s)
        ))))
(define-key lisp-mode-shared-map (kbd "C-c C-d")
  (lambda ()
    (interactive)
    (stk/ac-show-help #'ac-symbol-documentation)))

;; back-button
(setq back-button-local-keystrokes nil)
(require 'back-button)
(back-button-mode 1)

;; nrepl / cider
(setq nrepl-popup-stacktraces nil)
(setq nrepl-popup-stacktraces-in-repl nil)
(setq nrepl-hide-special-buffers t)

;; font-locking for the nrepl
;; https://github.com/kylefeng/.emacs.d/commit/45f2bece4652f4345ec08e68e8ef0608b81c5db7
(add-hook 'nrepl-mode-hook
          (lambda ()
            (font-lock-mode nil)
            (clojure-mode-font-lock-setup)
            (font-lock-mode t)))

(require 'ac-nrepl)
(add-hook 'nrepl-mode-hook 'ac-nrepl-setup)
(add-hook 'nrepl-interaction-mode-hook 'ac-nrepl-setup)
(add-to-list 'ac-modes 'nrepl-mode)

(add-hook 'cider-repl-mode-hook 'smartparens-strict-mode)

;; hl-mode
(global-diff-hl-mode)
(diff-hl-margin-mode)

(defun stk/diff-hl-update ()
  (with-current-buffer (current-buffer) (diff-hl-update)))

(add-hook 'magit-refresh-file-buffer-hook 'stk/diff-hl-update)

;; dired+
(setq dired-auto-revert-buffer t)
(toggle-diredp-find-file-reuse-dir 1)
(setq diredp-hide-details-initially-flag nil)
(setq diredp-hide-details-propagate-flag nil)

;; python
(elpy-enable)
(delq 'flymake-mode elpy-default-minor-modes)

;; eval-sexp-fu
;;; TODO: Fix colors
(require 'eval-sexp-fu)
(setq eval-sexp-fu-flash-duration 0.2)
(turn-on-eval-sexp-fu-flash-mode)
(require 'nrepl-eval-sexp-fu)
(setq nrepl-eval-sexp-fu-flash-duration 0.4)

;; erc
(require 'tls)
(add-hook 'erc-mode-hook (lambda ()
                           (erc-truncate-mode t)
                           (erc-fill-disable)
                           (set (make-local-variable 'scroll-conservatively) 1000)
                           (visual-line-mode)
                           )
          )
(setq erc-timestamp-format "%H:%M "
      erc-fill-prefix "      "
      erc-insert-timestamp-function 'erc-insert-timestamp-left)
(setq erc-interpret-mirc-color t)
(setq erc-kill-buffer-on-part t)
(setq erc-kill-queries-on-quit t)
(setq erc-kill-server-buffer-on-quit t)
(setq erc-server-send-ping-interval 45)
(setq erc-server-send-ping-timeout 180)
(setq erc-server-reconnect-timeout 60)
(erc-track-mode t)
(setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"
                                "324" "329" "332" "333" "353" "477"))
(setq erc-hide-list '("JOIN" "PART" "QUIT" "NICK"))

;; fix-ext-mode
(add-hook 'prog-mode-hook 'fic-ext-mode)

;; flycheck
(add-hook 'sh-mode-hook 'flycheck-mode)
(add-hook 'json-mode-hook 'flycheck-mode)
(add-hook 'nxml-mode-hook 'flycheck-mode)
(add-hook 'python-mode-hook 'flycheck-mode)
(add-hook 'emacs-lisp-mode-hook 'flycheck-mode)
(add-hook 'lisp-interaction-mode-hook 'flycheck-mode)
(setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)) ;disable the annoying doc checker
(setq flycheck-indication-mode 'left-fringe)

;; helm
(require 'helm-config)
(setq enable-recursive-minibuffers t)
(helm-mode 1)
(helm-gtags-mode 1)
(helm-descbinds-mode)
(setq helm-idle-delay 0.1)
(setq helm-input-idle-delay 0.1)
(setq helm-buffer-max-length 50)
(setq helm-M-x-always-save-history t)
(setq helm-buffer-details-flag nil)
(setq helm-ff-tramp-not-fancy nil)
(setq helm-for-files-preferred-list
      '(helm-source-buffers-list
        helm-source-recentf
        helm-source-bookmarks
        helm-source-file-cache
        helm-source-files-in-current-dir
	helm-source-locate))
(add-to-list 'helm-completing-read-handlers-alist '(org-refile)) ; helm-mode does not do org-refile well
(require 'helm-git)

(setq highlight-symbol-on-navigation-p t)
(setq highlight-symbol-idle-delay 0.2)
(add-hook 'prog-mode-hook 'highlight-symbol-mode)

;; magit
(when (fboundp 'file-notify-add-watch)
  (add-hook 'magit-status-mode-hook 'magit-filenotify-mode))
(setq magit-save-some-buffers nil) ;don't ask to save buffers
(setq magit-set-upstream-on-push t) ;ask to set upstream
(setq magit-diff-refine-hunk t) ;show word-based diff for current hunk

;; move-text
(require 'move-text)

;; smartparens
(require 'smartparens-config)
(smartparens-global-mode nil)
(sp-use-paredit-bindings)
(define-key sp-keymap (kbd "M-<up>") nil)
(define-key sp-keymap (kbd "M-<down>") nil)
(add-hook 'emacs-lisp-mode-hook 'smartparens-strict-mode)
;; "fix"" highlight issue in scratch buffer
(custom-set-faces '(sp-pair-overlay-face ((t ()))))

;; (defadvice delete-backward-char (before sp-delete-pair-advice activate)
;;   (sp-delete-pair (ad-get-arg 0)))

;; delete-selection-mode
;; (defadvice delete-selection-mode (after delete-selection-mode-fix-selection activate)
;;   (when (and delete-selection-mode)
;;     (remove-hook 'pre-command-hook 'delete-selection-pre-hook)))
(delete-selection-mode t)

;; uniquify
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)
(setq uniquify-min-dir-content 2)

;; yasnippet
(yas-global-mode 1)
(setq yas-prompt-functions '(yas-completing-prompt yas-ido-prompt yas-x-prompt yas-dropdown-prompt yas-no-prompt))

;; saveplace
(require 'saveplace)
(setq-default save-place t)
(setq savehist-additional-variables '(kill-ring mark-ring global-mark-ring search-ring regexp-search-ring extended-command-history))
(savehist-mode 1)


;; rainbow-mode
(dolist (hook '(css-mode-hook
                html-mode-hook
                js-mode-hook
                emacs-lisp-mode-hook
                org-mode-hook
                text-mode-hook
                ))
  (add-hook hook 'rainbow-mode)
  )

;; mu4e
(when (file-exists-p "/usr/local/share/emacs/site-lisp/mu4e")
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/mu4e")
(autoload 'mu4e "mu4e" "Mail client based on mu (maildir-utils)." t)
(setq mu4e-mu-binary "/usr/local/bin/mu")
(require 'org-mu4e)
;; enable inline images
(setq mu4e-view-show-images t)
;; use imagemagick, if available
(when (fboundp 'imagemagick-register-types)
  (imagemagick-register-types))
(setq mu4e-html2text-command "/usr/local/bin/html2text -nobs -width 72")
(setq mu4e-update-interval 60)
(setq mu4e-auto-retrieve-keys t)
(setq mu4e-headers-leave-behavior 'apply)
(setq mu4e-headers-visible-lines 20)
(setq mu4e-hide-index-messages t)

(setq mu4e-bookmarks
      '(("flag:unread AND NOT flag:trashed" "Unread messages"      ?u)
	("date:today..now"                  "Today's messages"     ?t)
	("date:7d..now"                     "Last 7 days"          ?w)
	("flag:flagged"                     "Flagged"              ?f)
	("mime:image/*"                     "Messages with images" ?p)))

(add-hook 'mu4e-headers-mode-hook (lambda () (local-set-key (kbd "X") (lambda () (interactive) (mu4e-mark-execute-all t)))))
(add-hook 'mu4e-view-mode-hook
	  (lambda ()
	    (local-set-key (kbd "X") (lambda () (interactive) (mu4e-mark-execute-all t)))
	    (local-set-key (kbd "o") 'mu4e-view-open-attachment-try-single)
	    ))

(defun mu4e-headers-mark-all-unread-read ()
  (interactive)
  (mu4e~headers-mark-for-each-if
   (cons 'read nil)
   (lambda (msg param)
     (memq 'unread (mu4e-msg-field msg :flags)))))

(defun mu4e-flag-all-read ()
  (interactive)
  (mu4e-headers-mark-all-unread-read)
  (mu4e-mark-execute-all t)))

(defun mu4e-view-open-attachment-try-single (&optional msg attnum)
  (interactive)
  (let* ((count (hash-table-count mu4e~view-attach-map)) (def))
    (when (zerop count) (mu4e-error "No attachments for this message"))
    (if (= count 1)
            (mu4e-view-open-attachment msg 1)
	  (mu4e-view-open-attachment msg))))

(require 'sequential-command)
(define-sequential-command vj/cycle-font vj/small-font vj/normal-font vj/large-font)

;; org-mode
(require 'org)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(add-to-list 'ac-modes 'org-mode)
(setq org-startup-folded t)
(setq org-startup-with-inline-images t)
(setq org-startup-truncated t)
(setq org-src-fontify-natively t)
(setq org-src-tab-acts-natively t)
(setq org-use-speed-commands t)
(setq org-agenda-start-with-log-mode t)
(setq org-directory "~/Documents/org")
(setq org-default-notes-file (concat org-directory "/notes.org"))
;; Remove org-mode meta-cursor bindings as it's used by windmove
(add-hook 'org-mode-hook
          '(lambda ()
             (local-unset-key [(meta down)])
             (local-unset-key [(meta up)])
             (local-unset-key [(meta left)])
             (local-unset-key [(meta right)])
             (local-unset-key "C-'")
	     (define-key org-mode-map "C" 'self-insert-command)))
(winner-mode t)

;; programming
(setq c-default-style
      '((java-mode . "java") (awk-mode . "awk") (other . "bsd"))
      c-basic-offset 4)

(setq auto-mode-alist
      (cons '("\\.m$" . objc-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.mm$" . objc-mode) auto-mode-alist))

(defun my-c-mode-setup ()
  (subword-mode 1)
  (c-set-offset 'innamespace 0))

(add-hook 'c-mode-common-hook 'my-c-mode-setup)

;; ediff
;; I don't want any new frames with ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-split-window-function 'split-window-horizontally)

(add-hook 'ediff-load-hook
	  (lambda ()
	    (add-hook 'ediff-before-setup-hook
		      (lambda ()
			(setq ediff-saved-window-configuration (current-window-configuration))))
	    (let ((restore-window-configuration
		   (lambda ()
		     (set-window-configuration ediff-saved-window-configuration))))
	      (add-hook 'ediff-quit-hook restore-window-configuration 'append)
	      (add-hook 'ediff-suspend-hook restore-window-configuration 'append))))

;; tramp
(setq enable-remote-dir-locals t)

(global-undo-tree-mode)

(require 'helm-cscope)

;; semantic
;; (add-to-list 'semantic-default-submodes 'global-semantic-decoration-mode)
;; (add-to-list 'semantic-default-submodes 'global-semantic-idle-local-symbol-highlight-mode)
;; (add-to-list 'semantic-default-submodes 'global-semantic-idle-scheduler-mode)
;; (add-to-list 'semantic-default-submodes 'global-semantic-idle-completions-mode)
;; (semantic-mode t)
;; (require 'semantic/ia)
;; (require 'semantic/bovine/gcc)
;; (add-to-list 'ac-sources 'ac-source-semantic)


;;}}}

;;{{{ Keyboard

;; Ergonomics
(global-set-key (kbd "C-h C-p") 'find-file)
(global-set-key (kbd "C-h r") 'query-replace)
(global-set-key (kbd "C-h C-s") 'save-buffer)

;; Move between windows/frames with meta+arrows
;; (define-key paredit-mode-map (kbd "M-<up>") nil)
;; (define-key paredit-mode-map (kbd "M-<down>") nil)
(windmove-default-keybindings 'meta)

;; Always reindent on newline
(define-key global-map (kbd "RET") 'newline-and-indent)

;; Use Vim like open line
(global-set-key "\C-o" 'vj/open-line-after)

;; Use Vim like zap up to char
(global-set-key (kbd "M-z") 'vj/zap-up-to-char)
(global-set-key (kbd "M-Z") 'vj/zap-to-char)

;; Display flymake messages in minibuffer
(define-key global-map (kbd "C-c ;") 'credmp/flymake-display-err-minibuf)

;; Bind smart-split
(define-key global-map (kbd "C-c s") 'smart-split)

;; Use regex searches by default.
(global-set-key "\C-s" 'isearch-forward-regexp)
(global-set-key "\C-r" 'isearch-backward-regexp)
(global-set-key "\C-\M-s" 'isearch-forward)
(global-set-key "\C-\M-r" 'isearch-backward)

;; I want to use regexps by default with query-replace
(global-set-key (kbd "M-%") 'query-replace-regexp)
(global-set-key (kbd "C-M-%") 'query-replace)

;; Magit
(global-set-key (kbd "C-x g") 'magit-status)

;; Start eshell or switch to it if it's active.
(global-set-key (kbd "C-x m") 'eshell)

;; Start a new eshell even if one is active.
(global-set-key (kbd "C-x M") (lambda () (interactive) (eshell t)))

;; Helm
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-h C-h") 'helm-M-x)
(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "\M-N") 'helm-next-source)
(global-set-key (kbd "\M-P") 'helm-prev-source)
(global-set-key (kbd "C-'") 'helm-for-files)
(global-set-key (kbd "C-h c") 'helm-show-kill-ring)
(global-set-key (kbd "C-h m") 'helm-all-mark-rings)
(global-set-key (kbd "M-i") 'helm-swoop)
(global-set-key (kbd "M-I") 'helm-swoop-back-to-last-point)

;; Autocomplete
(global-set-key (kbd "M-/") 'auto-complete)
(define-key ac-completing-map (kbd "<return>") 'ac-complete)

;; Help should search more than just commands
(global-set-key (kbd "C-h a") 'apropos)

;; C programming
(global-set-key (kbd "C-c o") 'ff-find-other-file)

;; Expand-region
(global-set-key (kbd "M-[") 'er/contract-region)
(global-set-key (kbd "M-]") 'er/expand-region)

;; Editing
(global-set-key (kbd "M-j") 'join-line)

;; Dash integration
(global-set-key "\C-cd" 'dash-at-point)

;; ACE Jump
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)
(define-key global-map (kbd "C-x SPC") 'ace-jump-mode-pop-mark)
(define-key global-map (kbd "<f9>") 'ace-jump-mode)

;; OSX Fullscreen
(define-key global-map (kbd "C-M-f") 'toggle-frame-fullscreen)

(global-set-key (kbd "M--") 'back-button-local-backward)
(global-set-key (kbd "M-=") 'back-button-local-forward)

;; Lisp
(key-chord-define lisp-interaction-mode-map "90" 'eval-sexp-fu-eval-sexp-inner-list)
(key-chord-define emacs-lisp-mode-map "90" 'eval-sexp-fu-eval-sexp-inner-list)
(define-key lisp-interaction-mode-map (kbd "C-c C-c") 'eval-sexp-fu-eval-sexp-inner-list)
(define-key lisp-interaction-mode-map (kbd "C-c C-e") 'eval-sexp-fu-eval-sexp-inner-sexp)
(define-key emacs-lisp-mode-map (kbd "C-c C-c") 'eval-sexp-fu-eval-sexp-inner-list)
(define-key emacs-lisp-mode-map (kbd "C-c C-e") 'eval-sexp-fu-eval-sexp-inner-sexp)

;; move-text
(global-set-key [M-S-up] 'move-text-up)
(global-set-key [M-S-down] 'move-text-down)

;; smartparens
(define-key sp-keymap (kbd "C-{") 'sp-select-previous-thing)
(define-key sp-keymap (kbd "C-}") 'sp-select-next-thing)
(define-key sp-keymap (kbd "C-\\") 'sp-select-previous-thing-exchange)
(define-key sp-keymap (kbd "C-]") 'sp-select-next-thing-exchange)

;; multiple-cursors
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-*") 'mc/mark-all-like-this)

;; Misc
(global-set-key (kbd "C-M-=") 'vj/cycle-font)
(global-set-key (kbd "C-h T") 'org-capture)
(global-set-key [(control return)] 'rectangle-mark-mode)

;; keychorded shortcuts
(key-chord-mode 1)
(setq key-chord-two-keys-delay 0.02)
(key-chord-define-global "fj" 'helm-M-x)
(key-chord-define-global "fm" 'mu4e)
(key-chord-define-global "fo" 'helm-find-files)

(key-chord-define-global "su" 'winner-undo)
(key-chord-define-global "si" 'winner-redo)

(define-key isearch-mode-map (kbd "C-o") 'isearch-occur)

;;}}}

(server-start)

;;}}}
