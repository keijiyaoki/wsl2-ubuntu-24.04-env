;;; init.el --- My init.el  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

;; Initialize package manager for compile time
(eval-and-compile
  (customize-set-variable
   'package-archives '(("org"   . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu"   . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  ;; Leaf keywords
  (leaf leaf-keywords
    :doc "Use leaf as a package manager"
    :url "https://github.com/conao3/leaf.el"
    :ensure t
    :init
    (leaf hydra :ensure t)
    :config
    (leaf-keywords-init)))

;; Compile
(eval-and-compile
  (leaf *byte-compile
    :custom
    (byte-compile-warnings . '(not free-vars))
    (byte-compile-warnings . '(cl-functions))
    (debug-on-error        . nil)))
(leaf *native-compile
  :doc "Native Compile by gccemacs"
  :url "https://www.emacswiki.org/emacs/GccEmacs"
  :if (and (fboundp #'native-comp-available-p)
           (native-comp-available-p))
  :custom
  (native-comp-jit-compilation . nil)
  (native-comp-async-jobs-number . 4)
  (native-comp-speed . 2)
  :config
  (native-compile-async "~/.emacs.d/early-init.el")
  (native-compile-async "~/.emacs.d/init.el")
  (native-compile-async "~/.emacs.d/elpa/"))

(leaf package-utils
  :doc "Interactive package manager"
  :url "https://github.com/Silex/package-utils"
  :ensure t)

;; -----------------------------------------------------------------------------------------
;;
;; Generic Configurations
;;
;; -----------------------------------------------------------------------------------------

;; Silencer
(leaf no-littering
  :doc "Keep .emacs.d clean"
  :url "https://github.com/emacscollective/no-littering"
  :custom `((custom-file . ,(expand-file-name "custom.el" user-emacs-directory)))
  :ensure t
  :require t)
(leaf *to-be-quiet
  :doc "Quite annoying messages"
  :preface
  (defun display-startup-echo-area-message ()
    "no startup message"
    (message ""))
  :config
  (defalias 'yes-or-no-p #'y-or-n-p))

(leaf *server
  :doc "Use Emacs as a Server"
  :global-minor-mode server-mode)

(leaf *encoding
  :doc "It's time to use UTF-8"
  :config
  (set-locale-environment "en_US.UTF-8")
  (prefer-coding-system          'utf-8-unix)
  (set-default-coding-systems    'utf-8-unix)
  (set-selection-coding-system   'utf-8-unix)
  (set-buffer-file-coding-system 'utf-8-unix))

(leaf *formatting
  :custom
  (truncate-lines        . t)
  (require-final-newline . t)
  (tab-width             . 2)
  (indent-tabs-mode      . nil))

(leaf *autorevert
  :doc "Revert changes if local file is updated"
  :global-minor-mode global-auto-revert-mode
  :custom (auto-revert-interval . 0.1))

(leaf *recovery
  :doc "Save place of cursor"
  :global-minor-mode save-place-mode)

(leaf *tramp
  :doc "Edit remote file via SSH or SCP"
  :custom
  (tramp-auto-save-directory . "~/.emacs.d/.cache/tramp/")
  (tramp-chunksize           . 2048))

(leaf *savehist
  :doc "save history of minibuffer"
  :global-minor-mode savehist-mode)

(leaf *recentf
  :doc "Record open files history"
  :global-minor-mode recentf-mode
  :custom
  (recentf-max-saved-items . 20000)
  (recentf-max-menu-items  . 20000)
  (recentf-auto-cleanup    . 'never)
  (recentf-exclude
   . '((expand-file-name package-user-dir)
		   ".cache"
		   "cache"
       "bookmarks"
		   "recentf"
       "*.png"
       "*.jpeg"
       ".org_archive"
		   "COMMIT_EDITMSG\\'")))

(leaf *large-file
  :doc "Adjust large file threshold"
  :custom
  (large-file-warning-threshold . 1000000))

;; Basic Editing Operation
(leaf *delsel
  :doc "Replace the region just by typing text, or delete just by hitting the DEL key"
  :global-minor-mode delete-selection-mode)

(leaf undo-fu
  :doc "Redo and Undo operations"
  :url "https://github.com/emacsmirror/undo-fu"
  :ensure t
  :bind*
  ("C-/" . undo-fu-only-undo)
  ("M-/" . undo-fu-only-redo))

(leaf treesit-auto
  :ensure t
  :config
  (setq treesit-auto-install t))

;; -----------------------------------------------------------------------------------------
;;
;; Window System
;;
;; -----------------------------------------------------------------------------------------

;; Font Size checker
;;
;; |∞≤≥∏∑∫ ×±⊆⊇|
;; |αβγδεζ ηθικλμ|
;; |abcdef ghijkl|
;; |ABCDEF GHIJKL|
;; |'";:-+ =/\~`?|
;; |日本語 の美観|
;; |あいう えおか|
;; |アイウ エオカ|
;; |ｱｲｳｴｵｶ ｷｸｹｺｻｼ|
;; |🀄🀅🀆 🀇🀈🀄| emoji font
;; |󰎥󰎨󰎫 󰎲󰎯󰎴| nerd font
;;
;; | hoge                 | hogeghoe | age               |
;; |----------------------+----------+-------------------|
;; | 今日もいい天気ですね | お、     | 等幅になった :+1: |

(leaf font-for-gui
  :doc "Use Japanese+Nerd fonts for coding"
  :if (window-system)
  :preface
  (defun set-fonts (family)
    (set-fontset-font t 'japanese-jisx0208 (font-spec :family family))
    (set-fontset-font t 'japanese-jisx0212 (font-spec :family family))
    (set-fontset-font t 'jisx0201         (font-spec :family family))
    (set-fontset-font t 'kana             (font-spec :family family))
    (set-fontset-font t 'latin  (font-spec :family family))
    (set-fontset-font t 'greek  (font-spec :family family))
    (set-fontset-font t 'arabic (font-spec :family family))
    (set-fontset-font t 'symbol (font-spec :family family)))
  (defun set-emoji-font (family)
    (set-fontset-font t '(#x1F004 . #x1FFFD) (font-spec :family family)))
  :custom
  (use-default-font-for-symbols   . nil)
  (inhibit-compacting-font-caches . t)
  ;; --------------------
  ;; (jp-font-family      . "HackGen Console")
  ;; --
  ;; (jp-font-family      . "Firge Console")
  ;; --
  (jp-font-family      . "Moralerspace Neon HW")
  ;; (jp-font-family      . "Moralerspace Argon HW")
  ;; (jp-font-family      . "Moralerspace Xenon HW")
  ;; --
  ;; (jp-font-family      . "PlemolJP Console")
  ;; --
  ;; (jp-font-family      . "UDEV Gothic")
  ;; --------------------
  (emoji-font-family . "Symbola")
  (nerd-font-family  . "Symbols Nerd Font Mono")
  :config
  (set-fonts jp-font-family)
  (set-emoji-font emoji-font-family)
  ;; --------------------
  ;; -- for UDEV Gothic
  ;; (set-face-attribute 'default nil :family jp-font-family :height 120)
  ;; (add-to-list 'face-font-rescale-alist (cons emoji-font-family 1.25)))
  ;; -- for Moralerspace */Firge */HackGen */PlemolJP *
  (set-face-attribute 'default nil :family jp-font-family :height 130)
  (add-to-list 'face-font-rescale-alist (cons emoji-font-family 1.40))
  (add-to-list 'face-font-rescale-alist (cons nerd-font-family 1.10)))

(leaf mouse
  :if (window-system)
  :custom
  (mouse-wheel-scroll-amount     . '(1 ((shift) . 1)))
  (mouse-wheel-progressive-speed . nil)
  (scroll-step           . 1)
  (scroll-margin         . 0)
  (scroll-conservatively . 100000))

(leaf dashboard
  :url "https://github.com/emacs-dashboard/emacs-dashboard"
  :ensure t
  :init
  (dashboard-setup-startup-hook)
  :custom
  (dashboard-center-content . t)
  (dashboard-startup-banner . 3)
  (dashboard-items          . '((recents . 15)
                                (projects . 5)
                                (bookmarks . 5)))
  :custom-face
  (dashboard-heading . '((t (:foreground "#f1fa8c" :weight bold)))))

(leaf *wl-clipboard
  ;; credit: yorickvP on Github
  :preface
  (setq wl-copy-process nil)
  (defun wl-copy (text)
    (setq wl-copy-process (make-process :name "wl-copy"
                                        :buffer nil
                                        :command '("wl-copy" "-f" "-n")
                                        :connection-type 'pipe
                                        :noquery t))
    (process-send-string wl-copy-process text)
    (process-send-eof wl-copy-process))
  (defun wl-paste ()
    (if (and wl-copy-process (process-live-p wl-copy-process))
        nil ; should return nil if we're the current paste owner
      (shell-command-to-string "wl-paste -n | tr -d \r")))
  (setq interprogram-cut-function 'wl-copy)
  (setq interprogram-paste-function 'wl-paste))

;; -----------------------------------------------------------------------------------------
;;
;; GNU/Linux
;;
;; -----------------------------------------------------------------------------------------

(leaf mozc
  :url "https://github.com/google/mozc"
  :if (equal system-type 'gnu/linux)
  :ensure t
  :bind* ("M-l" . mozc-start)
  :custom
  (kana-cursor-color        . "#ff79c6")
  (eisuu-cursor-color       . "cyan")
  (default-input-method     . "japanese-mozc")
  (mozc-helper-program-name . "/usr/bin/mozc_emacs_helper")
  :preface
  (defun mozc-start()
    (interactive)
    (set-cursor-color kana-cursor-color)
    (message "Mozc start")
    (mozc-mode 1))
  (defun mozc-end()
    (interactive)
    (mozc-handle-event 'enter)
    (set-cursor-color  eisuu-cursor-color)
    (message "Mozc end")
    (mozc-mode -1))
  (defun disable-input-method ()
    (interactive)
    (if current-input-method
        (deactivate-input-method)))
  (defun mozc-insert-str (str)
    (interactive)
    (mozc-handle-event 'enter)
    (insert str))
  (defun mozc-insert-non () (interactive) (mozc-insert-str ""))
  (defun mozc-insert-exc () (interactive) (mozc-insert-str "！"))
  (defun mozc-insert-que () (interactive) (mozc-insert-str "？"))
  (defun mozc-insert-com () (interactive) (mozc-insert-str "、"))
  (defun mozc-insert-per () (interactive) (mozc-insert-str "。"))
  :advice
  (:after after-focus-change-function disable-input-method)
  :hook (mozc-mode-hook
         . (lambda ()
             (define-key mozc-mode-map (kbd "C-m")     'mozc-insert-non)
             (define-key mozc-mode-map (kbd "<enter>") 'mozc-insert-non)
             (define-key mozc-mode-map "l"             'mozc-end)
             (define-key mozc-mode-map "!"             'mozc-insert-exc)
             (define-key mozc-mode-map "?"             'mozc-insert-que)
             (define-key mozc-mode-map ","             'mozc-insert-com)
             (define-key mozc-mode-map "."             'mozc-insert-per))))

(leaf mozc-posframe
  :if (equal system-type 'gnu/linux)
  :doc "Use posframe for speed and multi-byte characters."
  :vc ( :url "https://github.com/Ladicle/mozc-posframe" )
  :require t
  :custom
  (mozc-candidate-style         . 'posframe)
  (mozc-cand-posframe-separator . "\t\t")
  :config
  (mozc-posframe-register)
  :custom-face
  (mozc-cand-posframe-border-face . '((t (:background "#323445"))))
  (mozc-cand-overlay-footer-face  . '((t (:foreground "#6272a4"))))
  (mozc-cand-overlay-focused-face . '((t (:background "#44475a" :foreground "#76e0f3"))))
  (mozc-cand-overlay-odd-face     . '((t (:background "#323445" :foreground "#8995ba"))))
  (mozc-cand-overlay-even-face    . '((t (:background "#323445" :foreground "#8995ba")))))

(leaf exec-path-from-shell
  :doc "Share PATH from shell environment variables"
  :url "https://github.com/purcell/exec-path-from-shell"
  :ensure t
  ;; :if (and (equal system-type 'darwin) (window-system))
  :if (and (equal system-type 'gnu/linux) (window-system))
  :custom
  (exec-path-from-shell-check-startup-files . nil)
  (exec-path-from-shell-variables . '("PATH" "GOPATH" "LC_LANG" "LANG"))
  :config
  (exec-path-from-shell-initialize))

;; -----------------------------------------------------------------------------------------
;;
;; Brackets Guide
;;
;; -----------------------------------------------------------------------------------------

(leaf smartparens
  :ensure t
  :require smartparens-config
  :global-minor-mode smartparens-global-mode
  :bind
  (:smartparens-mode-map
   ("M-<DEL>" . sp-backward-unwrap-sexp)
   ("M-]"     . sp-up-sexp)
   ("M-["     . sp-down-sexp)
   ("C-("     . sp-beginning-of-sexp)
   ("C-)"     . sp-end-of-sexp)
   ("C-M-f"   . sp-forward-sexp)
   ("C-M-b"   . sp-backward-sexp)
   ("C-M-n"   . sp-next-sexp)
   ("C-M-p"   . sp-previous-sexp))
  :config
  (sp-local-pair 'org-mode "*" "*")
  (sp-local-pair 'org-mode "=" "=")
  (sp-local-pair 'org-mode "~" "~")
  (sp-local-pair 'org-mode "+" "+"))

;; -----------------------------------------------------------------------------------------
;;
;; Custom Functions
;;
;; -----------------------------------------------------------------------------------------

(leaf *convert-letter-case
  :bind*
  (("M-u" . upcase-backward-word)
   ("M-_" . downcase-backward-word)
   ("M-c" . capitalize-backward-word))
  :preface
  (defun upcase-backward-word (arg)
    (interactive "p")
    (upcase-word (- arg)))
  (defun downcase-backward-word (arg)
    (interactive "p")
    (downcase-word (- arg)))
  (defun capitalize-backward-word (arg)
    (interactive "p")
    (capitalize-word (- arg))))

(leaf *smart-kill
  :bind*
  (("M-d" . kill-word-at-point)
   ("C-w" . backward-kill-word-or-region))
  :init
  (defun kill-word-at-point ()
    (interactive)
    (let ((char (char-to-string (char-after (point)))))
      (cond
       ((string= " " char) (delete-horizontal-space))
       ((string-match "[\t\n -@\[-`{-~],.、。" char) (kill-word 1))
       (t (forward-char) (backward-word) (kill-word 1)))))
  (defun backward-kill-word-or-region (&optional arg)
    (interactive "p")
    (if (region-active-p)
        (call-interactively #'kill-region)
      (backward-kill-word arg))))

(leaf *copy-info-to-clipboard
  :preface
  (defun browse-url-or-copy ()
    "Browse URL if window-sytem otherwise copy it"
    (interactive)
    (if (window-system)
        (browse-url-at-point)
      (kill-new (thing-at-point-url-at-point))))
  (defun copy-filepath ()
    "Copy file path of the current buffer into the clipboard."
    (interactive)
    (let ((file-path buffer-file-name)
          (dir-path default-directory))
      (cond
       (file-path
        (kill-new (expand-file-name file-path)))
       (dir-path
        (kill-new (expand-file-name dir-path)))
       (t (error-message-string "Fail to get path name.")))))
  (defun copy-filename ()
    "Copy filename of the current buffer into the clipboard."
    (interactive)
    (let ((file-path buffer-file-name)
          (dir-path default-directory))
      (cond
       (file-path
        (kill-new (file-name-nondirectory file-path)))
       (dir-path
        (kill-new (file-name-nondirectory dir-path)))
       (t (error-message-string "Fail to get path name.")))))
  (defun copy-filename-with-line()
    "Copy filename with line number at the cursor into the clipboard."
    (interactive)
    (let ((file-path buffer-file-name)
          (dir-path default-directory))
      (cond
       (file-path
        (kill-new
         (format "%s:%s"
                 (file-name-nondirectory file-path)
                 (count-lines (point-min) (point)))))
       (dir-path
        (kill-new (file-name-nondirectory dir-path)))
       (t (error-message-string "Fail to get path name."))))))

(leaf *chmod-executable-file
  :doc "Change file mode to executable if it has shebang"
  :hook (after-save-hook . executable-make-buffer-file-executable-if-script-p))

;; -----------------------------------------------------------------------------------------
;;
;; Cursor
;;
;; -----------------------------------------------------------------------------------------

(leaf *general-cursor-options
  :custom
  (kill-whole-line  . t)
  (track-eol        . t)
  (line-move-visual . nil))

(leaf mwim
  :doc "Move cursor to beginning/end of code or line"
  :url "https://github.com/alezost/mwim.el"
  :ensure t
  :bind*
  (("C-a" . mwim-beginning-of-code-or-line)
   ("C-e" . mwim-end-of-code-or-line)))

;; Avy
(leaf avy
  :doc "Jump to things in tree-style"
  :url "https://github.com/abo-abo/avy"
  :ensure t)
(leaf avy-zap
  :doc "Zap to char using avy"
  :url "https://github.com/cute-jumper/avy-zap"
  :ensure t)

;; -----------------------------------------------------------------------------------------
;;
;; Window Layout
;;
;; -----------------------------------------------------------------------------------------

(leaf ace-window
  :doc "Select window like tmux"
  :url "https://github.com/abo-abo/ace-window"
  :ensure t
  :bind
  ("C-o" . ace-window)
  :custom
  (aw-keys . '(?j ?k ?l ?i ?o ?h ?y ?u ?p))
  :custom-face
  (aw-leading-char-face . '((t (:height 4.0 :foreground "#f1fa8c")))))

(leaf rotate
  :doc "Rotate the layout like tmux panel"
  :vc ( :url "https://github.com/daichirata/emacs-rotate" )
  :require t)

(leaf presentation
  :doc "Scale all for presentation"
  :url "https://github.com/zonuexe/emacs-presentation-mode"
  :if (window-system)
  :ensure t)

(leaf *window-maximizer
  :doc "Maximize current window"
  :if (window-system)
  :custom
  (is-window-maximized . nil)
  :preface
  (defun toggle-window-maximize ()
    (interactive)
    (progn
      (if is-window-maximized
          (balance-windows)
        (maximize-window))
      (setq is-window-maximized
            (not is-window-maximized)))))

(leaf *window-transparency
  :doc "Set window transparency level"
  :if (window-system)
  :hook (after-init-hook . toggle-window-transparency)
  :custom
  (window-transparency . 100)
  :preface
  (defun toggle-window-transparency ()
    "Cycle the frame transparency from default to transparent."
    (interactive)
    (let ((transparency window-transparency)
          (opacity 100))
      (if (and (not (eq (frame-parameter nil 'alpha) nil))
               (< (frame-parameter nil 'alpha) opacity))
          (set-frame-parameter nil 'alpha opacity)
        (set-frame-parameter nil 'alpha transparency)))))

;; -----------------------------------------------------------------------------------------
;;
;; Error Checker
;;
;; -----------------------------------------------------------------------------------------

(leaf flycheck
  :doc "Syntax checker"
  :url "https://www.flycheck.org/en/latest/"
  :ensure t
  :global-minor-mode global-flycheck-mode
  :custom
  (flycheck-display-errors-delay . 0))

;; flyspell + UI
(leaf flyspell
  :doc "Spell checker"
  :url "https://www.emacswiki.org/emacs/FlySpell"
  :ensure t
  :hook
  (prog-mode-hook . flyspell-prog-mode)
  ((markdown-mode-hook git-commit-mode-hook) . flyspell-mode)
  :custom
  (ispell-program-name . "aspell")
  (ispell-extra-args   . '("--sug-mode=ultra" "--lang=en_US" "--run-together"))
  :custom-face
  (flyspell-incorrect  . '((t (:underline (:color "#f1fa8c" :style wave)))))
  (flyspell-duplicate  . '((t (:underline (:color "#50fa7b" :style wave))))))
(leaf flyspell-correct
  :doc "Correcting misspelled words with flyspell using favourite interface"
  :url "https://github.com/d12frosted/flyspell-correct"
  :ensure t
  :bind*
  ("C-M-i" . flyspell-correct-at-point)
  :custom
  (flyspell-correct-interface . #'flyspell-correct-completing-read))

;; -----------------------------------------------------------------------------------------
;;
;; Completion
;;
;; -----------------------------------------------------------------------------------------

(leaf company
  :doc "Modular in-buffer completion framework"
  :url "http://company-mode.github.io/"
  :ensure t
  :hook (prog-mode-hook . company-mode)
  :bind
  ((:company-active-map
    ("C-n" . company-select-next)
    ("C-p" . company-select-previous)
    ("<tab>" . company-complete-common-or-cycle))
   (:company-search-map
    ("C-p" . company-select-previous)
    ("C-n" . company-select-next)))
  :custom
  (company-idle-delay  . 0)
  (company-echo-delay  . 0)
  (company-ignore-case . t)
  (company-selection-wrap-around . t)
  (company-minimum-prefix-length . 1)
  :custom-face
  (company-tooltip          . '((t (:background "#323445"))))
  (company-template-field   . '((t (:foreground "#ff79c6"))))
  (yas-field-highlight-face . '((t (:foreground "#ff79c6")))))

;; -----------------------------------------------------------------------------------------
;;
;; Tools
;;
;; -----------------------------------------------------------------------------------------

(leaf go-translate
  :doc "a translation framework"
  :ensure t
  :bind (("C-c T" . gt-do-translate)
         (:embark-identifier-map
          :package embark
          ("T" . gt-do-translate))
         (:embark-region-map
          :package embark
          ("T" . gt-do-translate)))
  :hook
  (gt-buffer-render-output-hook . visual-line-mode)
  :config
  (cl-defmethod gt-output :around ((render gt-buffer-render) translator)
    (when-let (buf (get-buffer (or (oref render buffer-name) gt-buffer-render-buffer-name)))
      (gt-buffer-render-output buf render translator)))
  (setq gt-langs '(en ja))
  (setq gt-default-translator
        (gt-translator
         :taker (gt-taker
                 :then (lambda (translator)
                         (with-slots (text) translator
                           (setf text (mapcar
                                       (lambda (line)
                                         (if (string-match-p "[\n\r]" line)
                                             (replace-regexp-in-string "[\n\r]" "" line)
                                           line))
                                       text)))))
         :engines (gt-google-engine)
         :render (gt-buffer-render
                  :window-config '((display-buffer-reuse-window
                                    display-buffer-pop-up-frame)
                                   . ((reusable-frames . t)
                                      (inhibit-same-window . t)
                                      (inhibit-switch-frame . t)))))))

;; Git ------------------------------------------------------------------------------------

(leaf *git-commit-mode
  :doc "Mode for git commit message editing"
  :mode "\\COMMIT_EDITMSG\\'")
(leaf git-modes
  :doc "Modes for git configuration files"
  :url "https://github.com/magit/git-modes"
  :ensure t)

(leaf magit
  :doc "Complete text-based user interface to Git"
  :url "https://magit.vc/"
  :ensure t
  :init
  (setq magit-auto-revert-mode nil))

(leaf git-gutter
  :doc "Show git status in fringe & operate hunks"
  :url "https://github.com/emacsorphanage/git-gutter"
  :ensure t
  :global-minor-mode global-git-gutter-mode
  :custom
  (git-gutter:modified-sign . "┃")
  (git-gutter:added-sign    . "┃")
  (git-gutter:deleted-sign  . "┃")
  :custom-face
  (git-gutter:modified . '((t (:foreground "#f1fa8c"))))
  (git-gutter:added    . '((t (:foreground "#50fa7b"))))
  (git-gutter:deleted  . '((t (:foreground "#ff79c6")))))

(leaf browse-at-remote
  :doc "Browse target page on github/bitbucket"
  :url "https://github.com/rmuslimov/browse-at-remote"
  :ensure t
  :preface
  (defun browse-at-remote-or-copy ()
    (interactive)
    (if (window-system)
        (browse-at-remote)
      (browse-at-remote-kill)))
  :custom
  (browse-at-remote-prefer-symbolic . nil))

(leaf smerge-mode
  :doc "Manage git confliction"
  :ensure t
  :preface
  (defun start-smerge-mode-with-hydra ()
    (interactive)
    (progn
      (smerge-mode 1)
      (smerge-mode/body)))
  :pretty-hydra
  ((:color blue :quit-key "q" :foreign-keys warn)
   ("Move"
    (("n" smerge-next "next")
     ("p" smerge-prev "preview"))
    "Keep"
    (("b" smerge-keep-base "base")
     ("u" smerge-keep-upper "upper")
     ("l" smerge-keep-lower "lower")
     ("a" smerge-keep-all "both")
     ("\C-m" smerge-keep-current "current"))
    "Others"
    (("C" smerge-combine-with-next "combine with next")
     ("r" smerge-resolve "resolve")
     ("k" smerge-kill-current "kill current"))
    "End"
    (("ZZ" (lambda ()
             (interactive)
             (save-buffer)
             (bury-buffer))
      "Save and bury buffer" :color blue)
     ("q" nil "cancel" :color blue)))))

;; -----------------------------------------------------------------------------------------
;;
;; Programming Mode
;;
;; -----------------------------------------------------------------------------------------

(leaf quickrun
  :doc "Run program quickly"
  :url "https://github.com/emacsorphanage/quickrun"
  :ensure t
  :require t)

;; LSP
(leaf lsp-mode
  :doc "Client for language server protocol"
  :url "https://emacs-lsp.github.io"
  :ensure t
  :custom
  ;; General settings
  (lsp-auto-guess-root                . t)
  (lsp-modeline-diagnostics-enable    . t)
  (lsp-headerline-breadcrumb-enable   . nil)
  ;; Performance tuning
  (lsp-log-io               . nil)
  (lsp-print-performance    . nil)
  (lsp-completion-provider  . :none)
  (lsp-enable-file-watchers . nil)
  (lsp-idle-delay           . 0.500)
  (gc-cons-threshold        . 100000000)
  (read-process-output-max  . 1048576)
  :bind
  (:lsp-mode-map
   ("C-c r"   . lsp-rename)
   ("C-c C-c" . lsp-execute-code-action))
  :hook
  (lsp-mode-hook
   . (lambda ()
       (setq-local company-backends '((company-yasnippet company-capf :separate))))))
(leaf lsp-ui
  :doc "UI integrations for lsp-mode"
  :url "https://github.com/emacs-lsp/lsp-ui"
  :ensure t
  :hook (lsp-mode-hook . lsp-ui-mode)
  :custom
  (lsp-ui-flycheck-enable     . t)
  (lsp-ui-sideline-enable     . t)
  (lsp-ui-sideline-show-hover . nil)
  (lsp-ui-imenu-enable        . nil)
  (lsp-ui-peek-fontify        . 'on-demand)
  (lsp-ui-peek-enable         . t)
  (lsp-ui-doc-enable          . nil)
  (lsp-ui-doc-max-height      . 12)
  (lsp-ui-doc-max-width       . 56)
  (lsp-ui-doc-position        . 'at-point)
  (lsp-ui-doc-border          . "#323445")
  :custom-face
  (lsp-ui-doc-background . '((t (:background "#282a36"))))
  (lsp-ui-doc-header     . '((t (:foreground "#76e0f3" :weight bold))))
  (lsp-ui-doc-url        . '((t (:foreground "#6272a4"))))
  :bind
  ((:lsp-mode-map
    ("C-c C-r"   . lsp-ui-peek-find-references)
    ("C-c C-j"   . lsp-ui-peek-find-definitions)
    ("C-c C-M-j" . xref-find-definitions-other-window)
    ("C-c i"     . lsp-ui-peek-find-implementation)
    ("C-c m"     . counsel-imenu)
    ("C-c M"     . lsp-ui-imenu)
    ("C-c s"     . toggle-lsp-ui-sideline)
    ("C-c d"     . toggle-lsp-ui-doc))
   (:lsp-ui-doc-mode-map
    ("q"         . toggle-lsp-ui-doc)
    ("C-i"       . lsp-ui-doc-focus-frame)))
  :init
  (defun toggle-lsp-ui-sideline ()
    (interactive)
    (if lsp-ui-sideline-show-hover
        (progn
          (setq lsp-ui-sideline-show-hover nil)
          (message "sideline-hover disabled :P"))
      (progn
        (setq lsp-ui-sideline-show-hover t)
        (message "sideline-hover enabled :)"))))
  (defun toggle-lsp-ui-doc ()
    (interactive)
    (if lsp-ui-doc-mode
        (progn
          (lsp-ui-doc-mode -1)
          (lsp-ui-doc--hide-frame)
          (message "lsp-ui-doc disabled :P"))
      (progn
        (lsp-ui-doc-mode 1)
        (message "lsp-ui-doc enabled :)")))))

;; Debugger
(leaf *gdb
  :doc "Adjust gdb settings"
  :defvar my-gdb-display-buffer-other-frame-action
  :preface
  (defun my-gdb-many-windows ()
    "my gdb-many-windows"
    (interactive)
    (if (gdb-get-buffer 'gdb-locals-buffer)
        (message "gdb-locals-buffer already exist.")
      (progn
        (gdb-get-buffer-create 'gdb-locals-values-buffer)
        (display-buffer (gdb-get-buffer-create 'gdb-locals-buffer)
                        my-gdb-display-buffer-other-frame-action)
        (gdb-get-buffer-create 'gdb-breakpoints-buffer)
        (gdb-get-buffer-create 'gdb-inferior-io)
        (let* ((win0 (get-buffer-window (gdb-get-buffer 'gdb-locals-buffer) t))
               (win1 (split-window win0))
               (win2 (split-window win0)))
          (select-window win1)
          (gdb-set-window-buffer (gdb-inferior-io-name))
          (select-window win2)
          (gdb-set-window-buffer (gdb-breakpoints-buffer-name))
          (select-window win0)))))
  (defun my-gdb-frame-stack-buffer ()
    "my gdb-frame-stack-buffer"
    (interactive)
    (if (gdb-get-buffer 'gdb-stack-buffer)
        (message "gdb-stack-buffer already exist.")
      (display-buffer (gdb-get-buffer-create 'gdb-stack-buffer)
		                  my-gdb-display-buffer-other-frame-action)))
  (defun my-gdb-locals-table-columns-list (alist)
    "Format and arrange the columns in locals display based on ALIST."
    (let (columns)
      (dolist (config gdb-locals-table-row-config columns)
        (let* ((key  (car config))
               (max  (cdr config))
               (prop (alist-get key alist)))
          (when prop
            (if (and (> max 0) (length> prop max))
                (let* ((truncated-prop (truncate-string-to-width prop (- max 3)))
                       (joined-prop (string-join (list truncated-prop "..."))))
                  (push (propertize joined-prop 'help-echo prop) columns))
              (push prop columns)))))
      (nreverse columns)))
  :advice
  (:override gdb-locals-table-columns-list my-gdb-locals-table-columns-list)
  :custom
  (my-gdb-display-buffer-other-frame-action
   . '((display-buffer-reuse-window display-buffer-pop-up-frame)
       (reusable-frames . visible)
       (inhibit-same-window . t)))
  (gdb-non-stop-setting . nil)
  (gdb-display-source-buffer-action . '(nil . ((inhibit-same-window . t) (inhibit-switch-frame . t))))
  (gdb-max-source-window-count . 5))

(leaf dap-mode
  :doc "Client for Debug Adapter Protocol"
  :url "https://emacs-lsp.github.io/dap-mode/"
  :ensure t
  :defer-config
  (require 'dap-hydra)
  (require 'dap-go)
  (require 'dap-gdb-lldb)
  (dap-register-debug-template
   "RUSTC::Run"
   (list :type "gdb"
         :request "launch"
         :name "RUSTC::Run"
         :target "/home/keiji/BUILD/rust/build/x86_64-unknown-linux-gnu/stage2/bin/rustc"
         :cwd "/home/keiji/RUST/MONAD/hkt"
         :gdbpath "/home/keiji/BUILD/rust/build/x86_64-unknown-linux-gnu/rustfmt/bin/rust-gdb"
         :arguments "src/lib.rs --crate-type=lib"
         :stopAtEntry t)))

(leaf dape
  :url "https://github.com/svaante/dape/"
  :ensure t
  ;; By default dape shares the same keybinding prefix as `gud'
  ;; If you do not want to use any prefix, set it to nil.
  ;; :preface
  ;; (setq dape-key-prefix "\C-x\C-a")
  ;;
  ;; May also need to set/change gud (gdb-mi) key prefix
  ;; (setq gud-key-prefix "\C-x\C-a")
  :init
  ;; To use window configuration like gud (gdb-mi)
  ;; (setq dape-buffer-window-arrangement 'gud)
  ;;
  ;; To save breakpoints and exceptions with `savehist-mode'
  (setq dape-use-savehist t)
  :config
  ;; Info buffers to the right
  (setq dape-buffer-window-arrangement 'right)
  ;;
  ;; To not display info and/or buffers on startup
  ;; (remove-hook 'dape-on-start-hooks 'dape-info)
  ;; (remove-hook 'dape-on-start-hooks 'dape-repl)
  ;;
  ;; To display info and/or repl buffers on stopped
  ;; (add-hook 'dape-on-stopped-hooks 'dape-info)
  ;; (add-hook 'dape-on-stopped-hooks 'dape-repl)
  ;;
  ;; Kill compile buffer on build success
  (add-hook 'dape-compile-compile-hooks 'kill-buffer)
  ;;
  ;; Save buffers on startup, useful for interpreted languages
  (add-hook 'dape-on-start-hooks
            (defun dape--save-on-start ()
              (save-some-buffers t t)))
  ;;
  ;; Projectile users
  (setq dape-cwd-fn 'projectile-project-root))

;; Rust
(leaf rustic
  :doc "Rust development environment"
  :url "https://github.com/brotzeit/rustic"
  :ensure t
  :require t
  :hook (rust-mode-hook . lsp-deferred)
  :bind
  (:rust-mode-map
   ("C-c C-n" . rust-run)
   ("C-c C-a" . quickrun-with-arg))
  :custom
  (rustic-format-trigger . 'on-save)
  (rustic-babel-auto-wrap-main . t))

;; Go
(leaf go-mode
  :doc "Go development environment"
  :url "https://github.com/dominikh/go-mode.el"
  :ensure t
  :mode "\\.go\\'"
  :hook
  (go-mode-hook
   . (lambda ()
       (lsp-deferred)
       (add-hook 'before-save-hook #'lsp-format-buffer t t)
       (add-hook 'before-save-hook #'lsp-organize-imports t t)))
  :bind
  (:go-mode-map
   ("C-c C-n" . go-run)
   ("C-c v"   . go-mod-vendor))
  :preface
  (defun go-mod-vendor ()
    "Run 'go mod vendor' at repository root."
    (interactive)
    (progn
      (call-process-shell-command (concat "cd " (vc-root-dir) "; go mod vendor") nil 0)
      (message "Run 'go mod vendor'!"))))
(leaf gotest
  :doc "Run Go unit-tests"
  :url "https://github.com/nlamirault/gotest.el"
  :ensure t
  :require t
  ;; :bind
  ;; (:go-mode-map
  ;;  ("C-c t" . go-test-clean-and-current-test)
  ;;  ("C-c f" . go-test-clean-and-current-file)
  ;;  ("C-c T" . go-test-current-test)
  ;;  ("C-c F" . go-test-current-file)
  ;;  ("C-c a" . go-test-current-project))
  :preface
  (defun go-test-clean-and-current-test()
    (interactive)
    (progn
      (call-process-shell-command "go clean -testcache" nil 0)
      (go-test-current-test)))
  (defun go-test-clean-and-current-file()
    (interactive)
    (progn
      (call-process-shell-command "go clean -testcache" nil 0)
      (go-test-current-file))))
(leaf go-gen-test
  :doc "Generate tests for go code"
  :url "https://github.com/s-kostyaev/go-gen-test"
  :ensure t)
(leaf go-eldoc
  :doc "Show eldoc for Go functions"
  :url "https://github.com/emacsorphanage/go-eldoc"
  :ensure t
  :hook (go-mode-hook . go-eldoc-setup))
(leaf go-tag
  :doc "Generate & Edit field tags for golang struct fields"
  :url "https://github.com/brantou/emacs-go-tag"
  :ensure t)

;; Python
(leaf python
  :doc "Python development environment"
  :url "https://wiki.python.org/moin/EmacsPythonMode"
  :mode ("\\.py\\'" . python-mode)
  :hook
  (python-mode-hook
   . (lambda ()
       (lsp-deferred)
       (add-hook 'before-save-hook #'lsp-organize-imports t t)))
  :preface
  (defun hack-open-browser () (interactive) (shell-command "hack o"))
  (defun hack-add-sample   () (interactive) (shell-command "hack add sample"))
  (defun hack-print-output () (interactive) (async-shell-command "hack t -CIDE --submit=false"))
  (defun hack-print-diff   () (interactive) (async-shell-command "hack t -CIOE --submit=false"))
  (defun hack-test-all     () (interactive) (async-shell-command "hack t -C"))
  (defun hack-test-one-sample ()
    (interactive)
    (let ((sample-id (read-string "sample ID: ")))
      (async-shell-command (concat "hack t -C " sample-id))))
  (defun go-abc-quiz ()
    "Initialize and go contest directory"
    (interactive)
    (let ((contest-id (read-string "Contest ID: "))
          (quiz-id (read-string "Quiz ID: ")))
      (progn
        (unless (file-exists-p
                 (shell-command-to-string (concat "hack g " contest-id)))
          (shell-command (concat "hack i " contest-id)))
        (find-file (concat
                    (shell-command-to-string
                     (concat "hack g " contest-id " " quiz-id))
                    "/main.py")))))
  (defun init-abc ()
    "Initialize and go contest directory"
    (interactive)
    (let ((contest-id (read-string "Contest ID: ")))
      (progn
        (shell-command (concat "hack i -l py " contest-id))
        (find-file (concat
                    (shell-command-to-string
                     (concat "hack g " contest-id " a"))
                    "/main.py"))
        (shell-command (concat "hack o " contest-id "a")))))
  :bind
  (:python-mode-map
   ("C-c C-n" . quickrun)
   ("C-c C-a" . quickrun-with-arg)
   ("C-c C-o" . hack-open-browser)
   ("C-c C-d" . hack-print-output)
   ("C-c C-l" . hack-print-diff)
   ("C-c RET" . hack-test-all)
   ("C-c t"   . hack-test-one-sample)))
(leaf lsp-pyright
  :doc "LSP mode with pyright"
  :url "https://emacs-lsp.github.io/lsp-pyright/"
  :ensure t
  :custom
  (python-shell-interpreter          . "python3")
  (lsp-pyright-python-executable-cmd . "python3")
  :require lsp-pyright)
(leaf yapfify
  :doc "Python formatter"
  :url "https://github.com/JorisE/yapfify"
  :ensure t
  :hook (python-mode-hook . yapf-mode))

;; C/C++/Objective-C
(leaf cc-mode
  :doc "Mode for C, C++, Objective-C, Java, CORBA IDL (and the variants PSDL and CIDL), Pike and AWK code"
  :url "https://www.gnu.org/software/emacs/manual/html_mono/ccmode.html"
  :ensure t
  :custom (c-base-offset . 4)
  :bind   (:c-mode-base-map ("C-c C-n" . compile))
  :hook   (c-mode-common-hook
           . (lambda ()
               (lsp-deferred)
               (c-set-style "stroustrup"))))
(leaf ccls
  :doc "ccls client"
  :url "https://github.com/emacs-lsp/emacs-ccls"
  :ensure t
  :require ccls
  :custom `((ccls-executable . ,(executable-find "ccls"))))
(leaf modern-cpp-font-lock
  :doc "Syntax highlighting support for `Modern C++' - until C++20 and Technical Specification"
  :url "https://github.com/ludwigpacifici/modern-cpp-font-lock"
  :ensure t
  :config (modern-c++-font-lock-global-mode t))

;; Javascript
(leaf js2-mode
  :doc "Improved JavaScript editing mode"
  :url "https://github.com/mooz/js2-mode"
  :ensure t
  :custom (js2-basic-offset . 2)
  :mode "\\.js\\'")
(leaf typescript-mode
  :doc "Major-mode for editing Typescript-files"
  :url "https://github.com/emacs-typescript/typescript.el"
  :ensure t
  :mode "\\.ts\\'")

;; Shell Script
(leaf fish-mode
  :doc "Major-mode for fish shell scripts"
  :url "https://github.com/wwwjfy/emacs-fish"
  :ensure t
  :mode "\\.fish\\'")

;; SASS/SCSS
(leaf less-css-mode
  :doc "Major-mode for LESS CSS (lesscss.org)"
  :ensure t
  :custom (css-indent-offset . 2)
  :mode ("\\.scss\\'" "\\.css\\'"))


;; -----------------------------------------------------------------------------------------
;;
;; Configuration Language
;;
;; -----------------------------------------------------------------------------------------

(leaf yaml-mode
  :doc "Major mode for editing files in the YAML data serialization format"
  :url "https://github.com/yoshiki/yaml-mode"
  :ensure t
  :mode ("\\.yaml\\'" "\\.yml\\'")
  :defvar yaml-file-threshold
  :custom
  (yaml-file-threshold . 100000)
  :hook
  (yaml-mode-hook
   . (lambda ()
       (if (< (buffer-size (current-buffer)) yaml-file-threshold)
           (progn
             (if (window-system)
                 (highlight-indent-guides-mode))
             (yas-minor-mode)
             (lsp-deferred)))))
  :custom-face
  (font-lock-variable-name-face . '((t (:foreground "violet")))))

(leaf systemd
  :doc "Major mode for editing systemd units"
  :url "https://github.com/holomorph/systemd-mode"
  :ensure t
  :mode
  ("\\.service\\'" "\\.timer\\'" "\\.target\\'" "\\.mount\\'"
   "\\.automount\\'" "\\.slice\\'" "\\.socket\\'" "\\.path\\'"
   "\\.netdev\\'" "\\.network\\'" "\\.link\\'"))

(leaf protobuf-mode
  :doc "Major mode for protobuf file editing"
  :url "https://github.com/protocolbuffers/protobuf/blob/master/editors/protobuf-mode.el"
  :ensure t
  :mode "\\.proto\\'")

(leaf dockerfile-mode
  :doc "Mode for handling Dockerfiles"
  :url "https://github.com/spotify/dockerfile-mode"
  :ensure t
  :mode "\\Dockerfile\\'")

(leaf terraform-mode
  :doc "Major mode of Terraform configuration file"
  :url "https://github.com/emacsorphanage/terraform-mode"
  :ensure t
  :mode "\\.tf\\'")

;; -----------------------------------------------------------------------------------------
;;
;; Drawing
;;
;; -----------------------------------------------------------------------------------------

(leaf gnuplot
  :doc "Major mode for Emacs for interacting with Gnuplot"
  :url "https://github.com/emacs-gnuplot/gnuplot"
  :ensure t
  :mode ("\\.gp\\'"))

;; -----------------------------------------------------------------------------------------
;;
;; Markdown
;;
;; -----------------------------------------------------------------------------------------

(leaf markdown-mode
  :doc "Major mode for editing Markdown-formatted text"
  :url "https://github.com/jrblevin/markdown-mode"
  :ensure t
  :mode
  (("\\.md\\'" . gfm-mode))
  :custom
  (markdown-hide-urls         . nil)
  (markdown-hide-markup       . nil)
  (markdown-list-item-bullets . '("•"))
  (markdown-fontify-code-blocks-natively . t)
  :custom-face
  (markdown-header-face-1         . '((t (:inherit outline-1 :weight bold   :height 1.5))))
  (markdown-header-face-2         . '((t (:inherit outline-1 :weight normal :height 1.2))))
  (markdown-header-face-3         . '((t (:inherit outline-1 :weight normal :height 1.1))))
  (markdown-header-face-4         . '((t (:inherit outline-1 :weight normal))))
  (markdown-bold-face             . '((t (:foreground "#f8f8f2" :weight bold))))
  (markdown-italic-face           . '((t (:foreground "#f8f8f2" :slant italic))))
  (markdown-header-delimiter-face . '((t (:foreground "#6272a4" :weight normal))))
  (markdown-link-face             . '((t (:foreground "#f1fa8c"))))
  (markdown-url-face              . '((t (:foreground "#6272a4"))))
  (markdown-list-face             . '((t (:foreground "#6272a4"))))
  (markdown-gfm-checkbox-face     . '((t (:foreground "#6272a4"))))
  (markdown-metadata-value-face   . '((t (:foreground "#8995ba"))))
  (markdown-metadata-key-face     . '((t (:foreground "#6272a4"))))
  (markdown-pre-face              . '((t (:foreground "#8be9fd")))))

(leaf markdown-toc
  :doc "Generate a TOC in markdown file"
  :url "https://github.com/ardumont/markdown-toc"
  :ensure t)

;; -----------------------------------------------------------------------------------------
;;
;; Org Mode
;;
;; -----------------------------------------------------------------------------------------

(leaf org
  :doc "Major mode for keeping notes, authoring documents, computational notebooks, literate programming, maintaining to-do lists, planning projects, and more"
  :url "https://orgmode.org/"
  :mode "\\.org\\'"
  :ensure t
  :init
  (setq org-directory   "~/ORG/"
        org-tpl-dir     "~/ORG/archetypes/"
        org-journal-dir (concat org-directory  "journal/")
        org-posts-dir   (concat org-directory  "posts/")
        org-agenda-dir  (concat org-directory  "agenda/")
        org-work-dir    (concat org-directory  "work/")
        org-books-dir   (concat org-directory  "books/")
        org-task-file   (concat org-agenda-dir "tasks.org")
        org-event-file  (concat org-agenda-dir "events.org")
        org-work-file   (concat org-work-dir   "tasks.org"))
  :bind
  ((:org-mode-map
    ("C-m"   . electric-newline-and-maybe-indent)
    ("C-j"   . newline-and-indent)
    ("C-M-m" . org-meta-return)
    ("C-c i" . org-clock-in)
    ("C-c o" . org-clock-out)
    ("C-c n" . org-narrow-to-subtree)
    ("C-c w" . widen)
    ("C-c e" . org-set-effort)
    ("C-c f" . org-footnote-new)
    ("C-c 0" . org-list-bullet-num)
    ("C-c -" . org-list-bullet-slash)
    ("C-c 1" . org-show-lv1)
    ("C-c 2" . org-show-lv2)))
  :custom
  (org-src-preserve-indentation     . nil)
  (org-edit-src-content-indentation . 0)
  (org-src-fontify-natively         . t)   ; enable syntax highlight for source block
  (org-image-actual-width           . 500) ; default size is too big
  (org-startup-folded               . 'content)
  ;; Disabled unused modules to speedup startup.
  (org-modules
   . (delete '(org-gnus org-w3m org-bbdb org-bibtex org-docview
                        org-info org-irc org-mhe org-rmail org-eww) org-modules))
  ;; Use slash(-) as bullets in lists when change the layer.
  (org-list-demote-modify-bullet
   . '(("+" . "-") ("*" . "-")
       ("1." . "-") ("1)" . "-")
       ("A)" . "-") ("B)" . "-") ("A." . "-") ("B." . "-")
       ("a)" . "-") ("b)" . "-") ("a." . "-") ("b." . "-")))
  :preface
  (defun org-show-lv1            () (interactive) (org-content 1))
  (defun org-show-lv2            () (interactive) (org-content 2))
  (defun org-list-bullet-num     () (interactive) (org-cycle-list-bullet 2))
  (defun org-list-bullet-num-lv2 () (interactive) (org-cycle-list-bullet 3))
  (defun org-list-bullet-slash   () (interactive) (org-cycle-list-bullet 0)))

;; Theme ----------------------------------------------------------------------------------

(leaf org-theme
  :doc "Theme for org-mode"
  :custom
  (org-todo-keyword-faces
   . '(("WAIT" . (:foreground "#6272a4" :weight bold :width condensed))
       ("NEXT" . (:foreground "#f1fa8c" :weight bold :width condensed))))
  :custom-face
  (org-level-1         . '((t (:inherit outline-1 :height 1.2))))
  (org-level-2         . '((t (:inherit outline-2 :weight normal))))
  (org-level-3         . '((t (:inherit outline-3 :weight normal))))
  (org-level-4         . '((t (:inherit outline-4 :weight normal))))
  (org-level-5         . '((t (:inherit outline-5 :weight normal))))
  (org-level-6         . '((t (:inherit outline-6 :weight normal))))
  (org-link            . '((t (:foreground "#f1fa8c" :underline nil :weight normal))))
  (org-document-title  . '((t (:foreground "#f8f8f2"))))
  (org-list-dt         . '((t (:foreground "#bd93f9"))))
  (org-footnote        . '((t (:foreground "#76e0f3"))))
  (org-special-keyword . '((t (:foreground "#6272a4"))))
  (org-drawer          . '((t (:foreground "#44475a"))))
  (org-checkbox        . '((t (:foreground "#bd93f9"))))
  (org-tag             . '((t (:foreground "#6272a4"))))
  (org-meta-line       . '((t (:foreground "#6272a4"))))
  (org-date            . '((t (:foreground "#8995ba"))))
  (org-priority        . '((t (:foreground "#ebe087"))))
  (org-todo            . '((t (:foreground "#51fa7b" :weight bold :width condensed))))
  (org-done            . '((t (:background "#373844" :foreground "#216933" :strike-through nil :weight bold :width condensed)))))

(leaf org-bullets
  :doc "Change bullet icons"
  :url "https://github.com/sabof/org-bullets"
  :ensure  t
  :hook   (org-mode-hook . org-bullets-mode)
  :custom (org-bullets-bullet-list . '("" "󰎥" "󰎨" "󰎫" "󰎲" "󰎯" "󰎴" "󰎷" "󰎺" "󰎽")))

(leaf org-modern
  :doc "To Be Modern Looks"
  :url "https://github.com/minad/org-modern"
  :ensure t
  :hook (org-mode-hook . org-modern-mode)
  :custom
  (org-modern-hide-stars     . nil)
  (org-modern-progress       . nil)
  (org-modern-todo           . nil)
  (org-modern-block          . nil)
  (org-modern-table-vertical . 1)
  (org-modern-timestamp      . t)
  ;; use nerd font icons
  (org-modern-star           . 'replace)
  (org-modern-replace-stars  . "󰎥󰎨󰎫󰎲󰎯󰎴󰎷󰎺󰎽")
  (org-modern-priority       . '((?A . "󰆥") (?B . "") (?C . "")))
  (org-modern-checkbox       . '((?X . "󰄬") (?- . "") (?\s . "󰄱")))
  :custom-face
  (org-modern-date-active   . '((t (:background "#373844" :foreground "#f8f8f2" :height 0.75 :weight light :width condensed))))
  (org-modern-time-active   . '((t (:background "#44475a" :foreground "#f8f8f2" :height 0.75 :weight light :width condensed))))
  (org-modern-date-inactive . '((t (:background "#373844" :foreground "#b0b8d1" :height 0.75 :weight light :width condensed))))
  (org-modern-time-inactive . '((t (:background "#44475a" :foreground "#b0b8d1" :height 0.75 :weight light :width condensed))))
  (org-modern-tag           . '((t (:background "#44475a" :foreground "#b0b8d1" :height 0.75 :weight light :width condensed))))
  (org-modern-statistics    . '((t (:foreground "#6272a4" :weight light :width condensed)))))

;; Agenda ----------------------------------------------------------------------------------

(leaf *org-agenda
  :doc "TODO & Schedule management system"
  :url "https://orgmode.org/manual/Agenda-Views.html"
  :after org
  :preface
  (defun org-clock-out-and-save ()
    "Save buffers and stop clocking."
    (ignore-errors (org-clock-out) t)
    (save-some-buffers t))
  (defun color-org-agenda-header (tag col)
    "Set s color to org-agenda header with the specified tag."
    (interactive)
    (goto-char (point-min))
    (while (re-search-forward tag nil t)
      (add-text-properties (match-beginning 0) (point-at-eol)
                           `(face (:foreground ,col)))))
  :hook
  (kill-emacs-hook . org-clock-out-and-save)
  (org-agenda-finalize-hook
   . (lambda ()
       (save-excursion
         (color-org-agenda-header "Event:"   "#76e0f3")
         (color-org-agenda-header "Routine:" "#f1fa8c"))))
  :custom
  (org-agenda-span                       . 'day)
  (org-agenda-current-time-string        . "← now")
  (org-clock-out-remove-zero-time-clocks . t)
  (org-agenda-log-mode-items             . (quote (closed clock)))
  (org-agenda-time-grid
   . '((daily today require-timed)
       (0900 01000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000 2100 2200 2300 2400)
       "-" "────────────────"))
  (org-agenda-files
   . '("~/ORG/doc/content/agenda/tasks.org"
       "~/ORG/doc/content/agenda/events.org"
       "~/ORG/doc/content/work/tasks.org"))
  :custom-face
  (org-scheduled-today . '((t (:foreground "#f8f8f2")))))

;; Babel ----------------------------------------------------------------------------------

(leaf org-babel
  :doc "Literate programming tools :: letting many different languages work together"
  :url "https://orgmode.org/worg/org-contrib/babel/intro.html"
  :custom
  (org-export-babel-evaluate                . nil)
  (org-confirm-babel-evaluate               . nil)
  (org-babel-default-header-args:emacs-lisp . nil)
  (org-babel-default-header-args:latex      . nil)
  ;; (org-babel-default-header-args:bash       . '((:details . "t")))
  (org-babel-default-header-args:bash       . '((:results . "output")))
  (org-babel-default-header-args:python     . '((:results . "output")))
  (org-babel-default-header-args:go         . '((:imports . '("\"fmt\""))))
  ;; Drawing
  (org-ditaa-jar-path    . "/usr/share/ditaa/ditaa.jar")
  (org-plantuml-jar-path . "~/.emacs.d/plantuml.jar")
  ;; Language extensions :: completion candidates for company-org
  (org-babel-tangle-lang-exts
   . '(("java" . "java") ("lisp" . "lisp") ("python" . "python") ("rust" . "rust")
       ("C++" . "cpp") ("go" . "go") ("emacs-lisp" . "emacs-lisp")
       ("fish" . "fish") ("bash" . "bash") ("diff" . "diff")
       ("terraform" . "terraform") ("dockerfile" . "dockerfile") ("conf" . "conf")
       ("yaml" . "yaml") ("json" . "json")
       ("sql" . "sql")
       ("html" . "html") ("css" . "css")
       ("markdown" . "markdown") ("text" . "text") ("latex" . "latex")))
  :preface
  (defun toggle-org-export-babel-evaluate ()
    (interactive)
    (if toggle-org-export-babel-evaluate
        (progn
          (setq toggle-org-export-babel-evaluate nil)
          (message "toggle-org-export-babel-evaluate disabled :-P"))
      (progn
        (setq toggle-org-export-babel-evaluate t)
        (message "toggle-org-export-babel-evaluate enabled :-)"))))
  :config
  ;; rust is enabled by rustic
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((plantuml . t) (dot      . t) (gnuplot  . t) (latex    . t)
     (go       . t) (C        . t) (python   . t)
     (shell    . t))))

(leaf ob-async
  :doc "Asynchronous src_block execution for org-babel"
  :url "https://github.com/astahlman/ob-async"
  :ensure t
  :custom
  (ob-async-no-async-languages-alist . '("python" "go")))

(leaf ob-go
  :doc "Org-Babel support for evaluating go code"
  :url "https://github.com/pope/ob-go"
  :ensure t)

;; Journal --------------------------------------------------------------------------------

(leaf org-journal
  :doc "A simple org-mode based journaling mode"
  :url "https://github.com/bastibe/org-journal"
  :ensure t
  :preface
  (defun org-journal-direct-open-entry (_arg &optional event)
    "Open journal entry for selected date for viewing"
    (interactive
     (list current-prefix-arg last-nonmenu-event))
    (let* ((time (org-journal--calendar-date->time
                  (calendar-cursor-to-date t event))))
      (find-file-other-window (org-journal--get-entry-path time))))
  (defun org-journal-file-header-func (&optional time)
    "Custom function to create journal header."
    (concat
     (pcase org-journal-file-type
       (`daily (format-time-string
                (concat
                 "#+title: %Y/%m/%d (%a)\n"
                 "#+date: [%Y-%m-%d %a %H:%M]\n"
                 "#+setupfile: ~/ORG/doc/setup.org")
                time))
       (`weekly "#+title: Weekly Journal\n %s")
       (`monthly "#+title: Monthly Journal\n")
       (`yearly "#+title: Yearly Journal\n"))))
  :bind
  ((:calendar-mode-map
    ("j" . org-journal-direct-open-entry)
    ("n" . org-journal-new-date-entry)))
  :custom
  (org-journal-enable-agenda-integration . t)
  (org-journal-file-header . 'org-journal-file-header-func)
  (org-journal-file-format . "%Y/%m/%d.org")
  (org-journal-date-format . "")
  (org-journal-time-prefix . "")
  :custom-face
  (org-journal-calendar-entry-face . '((t (:foreground "#ff79c6")))))

;; Capture --------------------------------------------------------------------------------

(leaf *org-capture
  :doc "Capture lets you quickly store notes with little interruption of your work flow"
  :url "https://orgmode.org/manual/Capture-templates.html#Capture-templates"
  :after org
  :preface
  (defun today-journal-file () (concat org-journal-dir (format-time-string org-journal-file-format (current-time))))
  (defun new-post-file     () (concat org-posts-dir (read-string "file name: ") ".org"))
  (defun new-book-file     () (concat org-books-dir (read-string "file name: ") ".org"))
  (defun new-qreview-file      () (concat org-work-dir
                                          (format-time-string "quarter-review-%Y-Q" (current-time))
                                          (- (string-to-number (format-time-string "%q" (current-time))) 1)
                                          ".org"))
  (defun new-mreview-file      () (concat org-work-dir (format-time-string "monthly-review-%Y-%m.org" (current-time))))
  (defun playground-file (lang ext) (format "%s/%s/%s/main.%s" playground-dir lang (format-time-string "%Y%m%d%H%M" (current-time)) ext))
  (defun go-playground-file     () (playground-file "go" "go"))
  (defun cpp-playground-file    () (playground-file "cpp" "cpp"))
  (defun rust-playground-file   () (playground-file "rust" "rs"))
  (defun python-playground-file () (playground-file "python" "py"))
  (defun org-code-capture-here ()
    "Register current subtree as a capture point."
    (interactive)
    (setq org-code-capture-store-file (buffer-file-name))
    (setq org-code-capture-store-point (point)))
  (defun org-code-info-store-point ()
    "Find registered capture point and move the cursor to it."
    (let ((filename (if (string= "" org-code-capture-store-file)
                        (format-time-string org-journal-file-format)
                      org-code-capture-store-file)))
      (set-buffer (org-capture-target-buffer filename)))
    (goto-char (point-min))
    (unless (derived-mode-p 'org-mode)
      (error
       "Target buffer \"%s\" for org-code-info-store-point should be in Org mode"
       (current-buffer))
      (current-buffer))
    (if (numberp org-code-capture-store-point)
        (goto-char org-code-capture-store-point)
      (goto-char (point-max))
      (or (bolp) (insert "\n")))
    (goto-char (point-at-bol)))
  :custom
  (org-capture-bookmark . nil)
  :config
  (setq org-capture-templates
        '(("h" "Create a new Post page." plain (file new-post-file) "%[~/ORG/doc/post.org]" :jump-to-captured t)
          ("b" "Create a new Book page." plain (file new-book-file) "%[~/ORG/doc/book.org]" :jump-to-captured t)
          ;; Today's Journal
          ("a" "Add a today's task."     entry (file+headline today-journal-file "Tasks") "* TODO %?\n")
          ("1" "Look back monthly work." plain (file new-mreview-file) "%[~/ORG/doc/review-monthly.org]" :immediate-finish t :jump-to-captured t)
          ("Q" "Look back quarter work." plain (file new-qreview-file) "%[~/ORG/doc/review-quarter.org]" :immediate-finish t :jump-to-captured t)
          ;; Task management
          ("i" "Add a private task to inbox." entry (file+headline org-task-file "Inbox") "* TODO %?\n")
          ("z" "Add a work task to inbox."    entry (file+headline org-work-file "Inbox") "* TODO %?\n")
          ;; Code Reading Notes
          ("c" "Immediately store code-reading links." plain (function org-code-info-store-point) "- %A\n" :immediate-finish t)
          ;; Coding Playground
          ("G" "Write a golang snippet code." plain (file go-playground-file)     "%[~/ORG/doc/playground.go]"  :immediate-finish t :jump-to-captured t)
          ("P" "Write a python snippet code." plain (file python-playground-file) "%[~/ORG/doc/playground.py]"  :immediate-finish t :jump-to-captured t)
          ("C" "Write a c++ snippet code."    plain (file cpp-playground-file)    "%[~/ORG/doc/playground.cpp]" :immediate-finish t :jump-to-captured t)
          ("R" "Write a rust snippet code."   plain (file rust-playground-file)   "%[~/ORG/doc/playground.rs]"  :immediate-finish t :jump-to-captured t))))

(leaf org-protocol
  :doc "Integrate with other applications"
  :url "https://orgmode.org/worg/org-contrib/org-protocol.html"
  :if (window-system)
  :require org-protocol)

;; Manage Image & Screenshot --------------------------------------------------------------

(leaf org-download
  :doc "Download drag and drop image"
  :url "https://github.com/abo-abo/org-download"
  :if (window-system)
  :ensure t
  :require org-download)
(leaf *org-screenshot
  :doc "org-download supports screenshot but it doesn't allow store path customization."
  :if (eq system-type 'darwin)
  :bind
  ((:org-mode-map
    :package org
    ("C-M-w" . org-yank-image-to-clipboard)
    ("C-M-y" . org-insert-clipboard-image)
    ("C-M-o" . org-image-open-in-finder)))
  :preface
  (defun org-insert-clipboard-image ()
    "Generate png file from a clipboard image and insert a link to current buffer."
    (interactive)
    (let* ((filename
            (concat (file-name-base (buffer-file-name))
                    "/"
                    (format-time-string "%Y%m%d_%H%M%S")
                    ".png")))
      (unless (file-exists-p (file-name-directory filename))
        (make-directory (file-name-directory filename)))
      (let* ((output-buffer (generate-new-buffer "*Async Image Generator*"))
             (proc (progn
                     (async-shell-command (concat "pngpastet " filename) output-buffer)
                     (get-buffer-process output-buffer))))
        (if (process-live-p proc)
            (set-process-sentinel proc #'org-display-inline-images)))
      (insert (concat
               "#+DOWNLOADED: clipboard @ "
               (format-time-string "%Y-%m-%d %H:%M:%S\n#+CAPTION: \n")
               "[[file:" filename "]]"))
      (forward-line -1)
      (end-of-line)))
  (defun org-yank-image-to-clipboard()
    (interactive)
    (let* ((linkp (bounds-of-thing-at-point 'sentence))
           (link (buffer-substring-no-properties (car linkp) (cdr linkp))))
      (shell-command
       (concat "pngcopy '"
               (replace-regexp-in-string
                "\\[\\[\\([^:]*:\\)?\\([^]]+\\)\\].*" "\\2" link)
               "'"))))
  (defun org-image-open-in-finder()
    (interactive)
    (let* ((linkp (bounds-of-thing-at-point 'sentence))
           (link (buffer-substring-no-properties (car linkp) (cdr linkp)))
           (filename
            (replace-regexp-in-string
             "\\[\\[\\([^:]*:\\)?\\([^]]+\\)\\].*" "\\2" link)))
      (shell-command (concat "open " (file-name-directory filename)))))
  :config
  (add-to-list 'display-buffer-alist '("^*Async Image Generator*" . (display-buffer-no-window))))

;; Input assistance -----------------------------------------------------------------------

(leaf company-org-block
  :doc "Insert Emacs org blocks via company"
  :url "https://github.com/xenodium/company-org-block"
  :ensure t
  :custom
  (company-org-block-edit-style . 'auto) ;; 'auto, 'prompt, or 'inline
  (org-structure-template-alist
   . '(("s" . "src") ("e" . "example")
       ("I" . "info") ("N" . "note") ("q" . "quote")
       ("g" . "goal") ("S" . "summary") ("D" . "details")))
  :hook
  (org-mode-hook . (lambda ()
                     (setq-local company-backends '(company-org-block))
                     (company-mode +1))))

(leaf *org-hydra
  :doc "Hydra template for org metadata"
  :bind
  ((:org-mode-map
    :package org
    ("#" . insert-or-open-org-hydra))
   (:mozc-mode-map
    :package mozc
    ("#" . *org-hydra/body)))
  :preface
  (defun insert-or-open-org-hydra ()
    (interactive)
    (if (or (region-active-p) (looking-back "^\s*" 1))
        (*org-hydra/body)
      (self-insert-command 1)))
  :pretty-hydra
  ((:title " Org Mode" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Header"
    (("t" (insert "#+title: ")       "title")
     ("l" (insert "#+lang: ")        "language")
     ("u" (insert "#+setupfile: ~/ORG/doc/setup.org") "setupfile")
     ("i" (insert "#+include: ")     "include")
     ("o" (insert "#+options: ")     "options")
     ("a" (insert (format-time-string "#+lastmod: [%Y-%m-%d %a %H:%M]" (current-time))) "lastmod"))
    "Book"
    (("p" (insert "#+progress: true") "progress")
     ("f" (insert "#+format: PDF")    "format"))
    "Inline"
    (("h" (insert "#+html: ")         "HTML")
     ("r" (insert "#+attr_html: ")    "attributes")
     ("c" (insert "#+caption: ")      "caption")
     ("n" (insert "#+name: ")         "name"))
    "Others"
    (("#" self-insert-command "#")
     ("." (insert (concat "#+" (read-string "metadata: ") ": ")) "#+<metadata>:")))))

;; -----------------------------------------------------------------------------------------
;;
;; Theme
;;
;; -----------------------------------------------------------------------------------------

(leaf doom-themes
  :doc "Megapack of themes"
  :url "https://github.com/doomemacs/themes"
  :ensure t
  :defer-config
  (let ((display-table (or standard-display-table (make-display-table))))
    (set-display-table-slot display-table 'vertical-border (make-glyph-code ?│))
    (setq standard-display-table display-table))
  :config
  (load-theme 'doom-dracula t)
  (doom-themes-org-config))

(leaf nano-modeline
  :doc "Nice and consistent look theme"
  ;; :url "https://github.com/rougier/nano-emacs"
  ;; :el-get "rougier/nano-emacs"
  :vc ( :url "https://github.com/rougier/nano-emacs" )
  :require nano-faces nano-modeline
  :custom
  (frame-background-mode . 'dark)
  (nano-color-foreground . "#f8f8f2")
  (nano-color-background . "#282a36")
  (nano-color-highlight  . "#373844")
  (nano-color-critical   . "#bd93f9")
  (nano-color-salient    . "#0189cc")
  (nano-color-strong     . "#e2e2dc")
  (nano-color-popout     . "#f8f8f2")
  (nano-color-subtle     . "#44475a")
  (nano-color-faded      . "#6272a4")
  :custom-face
  (hl-line                   . '((t (:background "#3B4252" :extend t ))))
  (vertical-border           . '((t (:background "#282a36" :foreground "#1E2029"))))
  (mode-line                 . '((t (:background "#282a36"))))
  (mode-line-inactive        . '((t (:background "#282a36"))))
  (nano-face-header-salient  . '((t (:foreground "#282a36" :background "#0189cc"))))
  (nano-face-header-popout   . '((t (:foreground "#282a36" :background "#f1fa8c"))))
  (nano-face-header-critical . '((t (:foreground "#282a36" :background "#bd93f9"))))
  (nano-face-header-faded    . '((t (:foreground "#282a36" :background "#6272a4"))))
  (nano-face-subtle          . '((t (:foreground "#282a36" :background "#44475a"))))
  (nano-face-header-default  . '((t (:foreground "#b0b8d1" :background "#44475a"))))
  (nano-face-header-strong   . '((t (:foreground "#f8f8f2" :background "#44475a" :weight bold)))))

(leaf *cursor-style
  :doc "Set cursor style and color"
  :if (window-system)
  :config
  (set-cursor-color "cyan")
  (add-to-list 'default-frame-alist '(cursor-type . bar)))

;; -----------------------------------------------------------------------------------------
;;
;; Widgets
;;
;; -----------------------------------------------------------------------------------------

(leaf nerd-icons
  :doc "A Library for Nerd Font icons"
  :ensure t
  :require t
  :config
  (nerd-icons-set-font))
(leaf nerd-icons-dired
  :ensure t
  :after nerd-icons
  :hook (dired-mode-hook . nerd-icons-dired-mode))

(leaf treemacs
  :doc "a tree layout file explorer"
  :url "https://github.com/Alexander-Miller/treemacs"
  :ensure t
  :bind
  ("<f9>" . treemacs)
  :config
  (treemacs-project-follow-mode 1)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (when treemacs-python-executable
    (treemacs-git-commit-diff-mode t))
  (pcase (cons (not (null (executable-find "git")))
               (not (null treemacs-python-executable)))
    (`(t . t)
     (treemacs-git-mode 'deferred))
    (`(t . _)
     (treemacs-git-mode 'simple)))
  (treemacs-hide-gitignored-files-mode nil)
  :hook (treemacs-mode-hook . treemacs-hide-nano-header)
  :preface
  (defun treemacs-hide-nano-header ()
    "Hide nano header."
    (interactive)
    (setq header-line-format "")))
(leaf treemacs-nerd-icons
  :doc "nerd-icons theme for treemacs"
  :url "https://github.com/rainstormstudio/treemacs-nerd-icons"
  :ensure t
  :after treemacs nerd-icons
  :require t
  :config (treemacs-load-theme "nerd-icons"))
(leaf treemacs-projectile
  :doc "rojectile integration for treemacs"
  :url "https://github.com/Alexander-Miller/treemacs"
  :ensure t
  :after treemacs projectile)
(leaf treemacs-magit
  :doc "Magit integration for treemacs"
  :url "https://github.com/Alexander-Miller/treemacs"
  :ensure t
  :after treemacs magit)

(leaf imenu-list
  :doc "Show the current buffer's imenu entries in a seperate buffer"
  :vc ( :url "https://github.com/Ladicle/imenu-list" )
  :bind ("<f10>" . imenu-list-smart-toggle)
  :custom
  (imenu-list-auto-resize . t)
  (imenu-list-focus-after-activation . t)
  (imenu-list-entry-prefix   . "•")
  (imenu-list-subtree-prefix . "•")
  :custom-face
  (imenu-list-entry-face-1          . '((t (:foreground "white"))))
  (imenu-list-entry-subalist-face-0 . '((nil (:weight normal))))
  (imenu-list-entry-subalist-face-1 . '((nil (:weight normal))))
  (imenu-list-entry-subalist-face-2 . '((nil (:weight normal))))
  (imenu-list-entry-subalist-face-3 . '((nil (:weight normal)))))

;; -----------------------------------------------------------------------------------------
;;
;; Accessibility
;;
;; -----------------------------------------------------------------------------------------

;; Input Assistance
(leaf *hydra-theme
  :doc "Make emacs bindings that stick around"
  :url "https://github.com/abo-abo/hydra"
  :custom-face
  (hydra-face-red      . '((t (:foreground "#bd93f9"))))
  (hydra-face-blue     . '((t (:foreground "#8be9fd"))))
  (hydra-face-pink     . '((t (:foreground "#ff79c6"))))
  (hydra-face-teal     . '((t (:foreground "#61bfff"))))
  (hydra-face-amaranth . '((t (:foreground "#f1fa8c")))))
(leaf major-mode-hydra
  :doc "Use pretty-hydra to define template easily"
  :url "https://github.com/jerrypnz/major-mode-hydra.el"
  :ensure t
  :require pretty-hydra)
(leaf hydra-posframe
  :doc "Show hidra hints on posframe"
  :if (window-system)
  :vc ( :url "https://github.com/Ladicle/hydra-posframe" )
  :global-minor-mode hydra-posframe-mode
  :custom
  (hydra-posframe-border-width . 5)
  (hydra-posframe-parameters   . '((left-fringe . 8) (right-fringe . 8)))
  :custom-face
  (hydra-posframe-border-face . '((t (:background "#323445")))))

(leaf which-key
  :doc "Displays available keybindings in popup"
  :url "https://github.com/justbur/emacs-which-key"
  :ensure t
  :global-minor-mode which-key-mode)

(leaf display-fill-column-indicator-mode
  :doc "Indicate maximum colum"
  :url "https://www.emacswiki.org/emacs/FillColumnIndicator"
  :hook ((markdown-mode-hook git-commit-mode-hook) . display-fill-column-indicator-mode))

(leaf display-line-numbers
  :doc "Display line number"
  :url "https://www.emacswiki.org/emacs/LineNumbers"
  :hook ((js2-mode-hook terraform-mode-hook rustic-mode-hook) . display-line-numbers-mode))

(leaf rainbow-mode
  :doc "Color letter that indicate the color"
  :url "https://elpa.gnu.org/packages/rainbow-mode.html"
  :ensure t
  :hook (emacs-lisp-mode-hook . rainbow-mode))

(leaf rainbow-delimiters
  :doc "Display brackets in rainbow"
  :url "https://www.emacswiki.org/emacs/RainbowDelimiters"
  :ensure t
  :hook (prog-mode-hook . rainbow-delimiters-mode))

;; -----------------------------------------------------------------------------------------
;;
;; Highlighting
;;
;; -----------------------------------------------------------------------------------------

(leaf *paren
  :doc "Hilight paired brackets"
  :url "https://www.emacswiki.org/emacs/ShowParenMode"
  :global-minor-mode show-paren-mode
  :custom
  (show-paren-style . 'mixed)
  (show-paren-when-point-inside-paren . t)
  (show-paren-when-point-in-periphery . t)
  :custom-face
  (show-paren-match . '((nil (:background "#44475a" :foreground "#f1fa8c")))))

(leaf highlight-symbol
  :doc "Automatic & Manual symbol highlighting"
  :url "https://github.com/nschum/highlight-symbol.el"
  :ensure t
  :bind
  (("M-p"   . highlight-symbol-prev)
   ("M-n"   . highlight-symbol-next)))

(leaf volatile-highlights
 :doc "Hilight the pasted region"
 :vc ( :url "https://github.com/k-talo/volatile-highlights.el" )
 :require volatile-highlights
 :global-minor-mode volatile-highlights-mode
 :custom-face
 (vhl/default-face . '((nil (:foreground "#FF3333" :background "#FFCDCD")))))

(leaf *highlight-whitespace
  :doc "Highligh trailing whitespace"
  :hook
  ((prog-mode-hook markdown-mode-hook)
   . (lambda ()
       (interactive)
       (setq show-trailing-whitespace t))))

(leaf highlight-indent-guides
  :doc "Display structure for easy viewing"
  :url "https://github.com/DarthFennec/highlight-indent-guides"
  :ensure t
  :hook (prog-mode-hook . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-auto-enabled . t)
  (highlight-indent-guides-responsive   . t)
  ;; (highlight-indent-guides-method . 'bitmap)
  (highlight-indent-guides-method . 'character)
  :config
  (highlight-indent-guides-auto-set-faces))

(leaf hl-todo
  :doc "Highlight TODO and similar keywords in comments and strings"
  :url "https://github.com/tarsius/hl-todo"
  :ensure t
  :hook (prog-mode-hook . hl-todo-mode))

(leaf beacon
  :doc "A light that follows your cursor around so you don't lose it!"
  :url "https://github.com/Malabarba/beacon"
  :ensure t
  :custom
  (beacon-color . "#f1fa8c")
  (beacon-mode  . t))

;; -----------------------------------------------------------------------------------------
;;
;; Search Interface
;;
;; -----------------------------------------------------------------------------------------

(leaf anzu
  :doc "Displays current match and total matches information"
  :url "https://github.com/emacsorphanage/anzu"
  :ensure t
  :bind ("M-r" . anzu-query-replace-regexp))

(leaf projectile
  :doc "Project navigation and management library"
  :url "https://github.com/bbatsov/projectile"
  :ensure t
  :global-minor-mode projectile-mode)

;; Vertico --------------------------------------------------------------------------------

(leaf vertico
  :doc "Completion interface"
  :url "https://github.com/minad/vertico/"
  :global-minor-mode vertico-mode
  :ensure t
  :custom
  (vertico-cycle . t)
  (vertico-count . 18))

(leaf vertico-directory
  :doc "Commands for Ido-like directory navigation"
  :after vertico
  ;; :ensure nil
  :bind
  ((:vertico-map
    :package vertico
   ("C-l" . vertico-directory-up)
   ("RET" . vertico-directory-enter)
   ("DEL" . vertico-directory-delete-char)
   ("M-DEL" . vertico-directory-delete-word))))

(leaf vertico-posframe
  :doc "Show Vertico in posframe"
  :url "https://github.com/tumashu/vertico-posframe"
  :global-minor-mode vertico-posframe-mode
  :ensure t
  :custom
  (vertico-posframe-poshandler . 'posframe-poshandler-window-bottom-left-corner)
  (vertico-posframe-border-width . 5)
  (vertico-posframe-parameters
   .  '((left-fringe . 8)
        (right-fringe . 8)))
  :custom-face
  (vertico-posframe-border . '((t (:background "#323445")))))

(leaf consult
  :doc "Generate completion candidates and provide commands for completion"
  :url "https://github.com/minad/consult"
  :ensure t
  :bind
  ("M-y"   . consult-yank-pop)
  ("C-M-s" . consult-line)
  :custom
  (consult-async-min-input . 1))

(leaf consult-flycheck
  :doc "Consult integration for Flycheck"
  :url "https://github.com/minad/consult-flycheck"
  :ensure t)
(leaf affe
  :doc "Asynchronous Fuzzy Finder"
  :url "https://github.com/minad/affe"
  :ensure t
  :custom
  (affe-grep-command . "rg --null --color=never --max-columns=1000 --no-heading --line-number -v --ignore-file .gitignore ^$")
  (affe-count . 100)
  :preface
  (defun affe-orderless-regexp-compiler (input _type _ignorecase)
    (setq input (orderless-pattern-compiler input))
    (cons input (apply-partially #'orderless--highlight input)))
  :config
  (setq affe-regexp-compiler #'affe-orderless-regexp-compiler))
(leaf consult-ghq
  :doc "Consult integration for ghq (with affe)"
  :url "https://github.com/tomoya/consult-ghq"
  :ensure t)
(leaf consult-custom
  :doc "Custom functions to search org documents"
  :after affe
  :require affe
  :preface
  (defun consult-find-doc ()
    "Search org files in the private document directory."
    (interactive)
    (let ((affe-find-command "fdfind --ignore-case --extension org --no-ignore ."))
      (funcall #'affe-find org-directory)))
  (defun consult-grep-doc ()
    "Search text in the private document directory"
    (interactive)
    (let ((affe-grep-command "rg --null --color=never --max-columns=1000 --ignore-case --no-ignore --no-heading --line-number -v ^$ ."))
      (funcall #'affe-grep org-directory))))
(leaf consult-ag
  :doc "Consult integration for ag"
  :url "https://github.com/yadex205/consult-ag"
  :ensure t
  :when (executable-find "ag"))

(leaf *consult-custom-binding-maps
  :init
  (define-key global-map (kbd "C-x C-b") 'consult-buffer)
  (define-key global-map (kbd "C-s") 'consult-line))

(leaf marginalia
  :doc "Explain details of the consult candidates"
  :url "https://github.com/minad/marginalia"
  :global-minor-mode marginalia-mode
  :ensure t
  :custom-face
  (marginalia-documentation . '((t (:foreground "#6272a4")))))

(leaf orderless
  :doc "Completion style that matches multiple regexps"
  :url "https://github.com/oantolin/orderless"
  :ensure t
  :preface
  (defun flex-if-apostrophe (pattern _index _total)
    (when (string-suffix-p "'" pattern)
      `(orderless-flex . ,(substring pattern 0 -1))))
  (defun without-if-bang (pattern _index _total)
    (cond
     ((equal "!" pattern)
      '(orderless-literal . ""))
     ((string-prefix-p "!" pattern)
      `(orderless-without-literal . ,(substring pattern 1)))))
  :custom
  (completion-styles           . '(orderless))
  (orderless-style-dispatchers . '(flex-if-apostrophe
                                   without-if-bang)))

(leaf embark
  :doc "Mini-Buffer Actions Rooted in Keymaps Resources"
  :url "https://github.com/oantolin/embark"
  :ensure t
  :bind*
  ("M-a" . embark-act)
  :custom
  (prefix-help-command . #'embark-prefix-help-command)
  :config
  (setq embark-action-indicator
        (lambda (map _target)
          (which-key--show-keymap "Embark" map nil nil 'no-paging)
          #'which-key--hide-popup-ignore-command)
        embark-become-indicator embark-action-indicator))
(leaf embark-consult
  :ensure t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(leaf wgrep
  :ensure t
  :custom ((wgrep-enable-key . "e")
           (wgrep-auto-save-buffer . t)
           (wgrep-change-readonly-file . t)))

;; -----------------------------------------------------------------------------------------
;;
;; Global Bindings
;;
;; -----------------------------------------------------------------------------------------

(leaf *global-bindings
  :init
  (define-key key-translation-map (kbd "C-h") (kbd "<DEL>"))
  :bind
  (("C-h" . delete-backward-char)
   ("C-m" . electric-newline-and-maybe-indent)
   ("C-j" . newline-and-indent)
   ("M-:" . comment-dwim)
   ;; Move Buffer
   ("M-," . previous-buffer)
   ("M-." . next-buffer)
   ;; Shell Command
   ("M-!" . async-shell-command)
   ("M-@" . shell-command)
   ;; Browse
   ("C-c C-o" . browse-url-or-copy)))

;; Hydra Templates -------------------------------------------------------------------------

(leaf *hydra-goto
  :doc "Search and move cursor"
  :bind ("M-j" . *hydra-goto/body)
  :pretty-hydra
  ((:title " Goto" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Got"
    (("i" avy-goto-char       "char")
     ("t" avy-goto-char-timer "timer")
     ("w" avy-goto-word-2     "word")
     ("j" avy-resume "resume"))
    "Line"
    (("h" avy-goto-line        "head")
     ("e" avy-goto-end-of-line "end")
     ("n" consult-goto-line    "number"))
    "Topic"
    (("o"  consult-outline      "outline")
     ("m"  consult-imenu        "imenu")
     ("gm" consult-global-imenu "global imenu"))
    "Error"
    ((","  flycheck-previous-error "previous" :exit nil)
     ("."  flycheck-next-error "next" :exit nil)
     ("l" consult-flycheck "list"))
    "Spell"
    ((">"  flyspell-goto-next-error "next" :exit nil)
     ("cc" flyspell-correct-at-point "correct" :exit nil)))))

(leaf *hydra-toggle
  :doc "Toggle functions"
  :bind ("M-t" . *hydra-toggle/body)
  :pretty-hydra
  ((:title " Toggle" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Basic"
    (("v" view-mode "view mode" :toggle t)
     ("w" whitespace-mode "whitespace" :toggle t)
     ("W" whitespace-cleanup "whitespace cleanup")
     ("r" rainbow-mode "rainbow" :toggle t)
     ("b" beacon-mode "beacon" :toggle t))
    "Line & Column"
    (("l" toggle-truncate-lines "truncate line" :toggle t)
     ("n" display-line-numbers-mode "line number" :toggle t)
     ("f" display-fill-column-indicator-mode "column indicator" :toggle t)
     ("c" visual-fill-column-mode "visual column" :toggle t))
    "Highlight"
    (("h" highlight-symbol "highligh symbol" :toggle t)
     ("L" hl-line-mode "line" :toggle t)
     ("t" hl-todo-mode "todo" :toggle t)
     ("g" git-gutter-mode "git gutter" :toggle t)
     ("i" highlight-indent-guides-mode "indent guide" :toggle t))
    "Window"
    (("t" toggle-window-transparency "transparency" :toggle t)
     ("m" toggle-window-maximize "maximize" :toggle t)
     ("p" presentation-mode "presentation" :toggle t)))))
(leaf *hydra-toggle-markdown1
  :doc "Toggle functions for Markdown"
  :bind
  (:markdown-mode-map
   :package markdown-mode
   ("M-t" . *hydra-toggle-markdown1/body))
  :pretty-hydra
  ((:title " Toggle" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Basic"
    (("w" whitespace-mode "whitespace" :toggle t)
     ("W" whitespace-cleanup "whitespace cleanup")
     ("l" hl-line-mode "line" :toggle t)
     ("g" git-gutter-mode "git gutter" :toggle t))
    "Markdown"
    (("v" markdown-view-mode "view mode")
     ("u" markdown-toggle-markup-hiding "markup hiding" :toggle t)
     ("l" markdown-toggle-url-hiding "url hiding" :toggle t))
    "Line & Column"
    (("l" toggle-truncate-lines "truncate line" :toggle t)
     ("i" display-fill-column-indicator-mode "column indicator" :toggle t)
     ("c" visual-fill-column-mode "visual column" :toggle t))
    "Window"
    (("t" toggle-window-transparency "transparency" :toggle t)
     ("m" toggle-window-maximize "maximize" :toggle t)
     ("p" presentation-mode "presentation" :toggle t)))))

(leaf *hydra-search
  :doc "Search functions"
  :bind
  ("M-s" . *hydra-search/body)
  :pretty-hydra
  ((:title " Search" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Buffer"
    (("l" consult-line "line")
     ("o" consult-outline "outline")
     ("m" consult-imenu "imenu"))
    "Project"
    (("f" affe-find "find")
     ("r" affe-grep "grep")
     ("a" consult-ag "ag"))
    "Document"
    (("df" consult-find-doc "find")
     ("dd" consult-grep-doc "grep")))))

(leaf *hydra-git
  :bind
  ("M-g" . *hydra-git/body)
  :pretty-hydra
  ((:title " Git" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Basic"
    (("w" magit-checkout "checkout")
     ("s" magit-status "status")
     ("b" magit-branch "branch")
     ("F" magit-pull "pull")
     ("f" magit-fetch "fetch")
     ("A" magit-apply "apply")
     ("c" magit-commit "commit")
     ("P" magit-push "push"))
    ""
    (("d" magit-diff "diff")
     ("l" magit-log "log")
     ("r" magit-rebase "rebase")
     ("z" magit-stash "stash")
     ("!" magit-run "run shell command")
     ("y" magit-show-refs "references"))
    "Hunk"
    (("," git-gutter:previous-hunk "previous" :exit nil)
     ("." git-gutter:next-hunk "next" :exit nil)
     ("g" git-gutter:stage-hunk "stage")
     ("v" git-gutter:revert-hunk "revert")
     ("p" git-gutter:popup-hunk "popup"))
    " GitHub"
    (("C" checkout-gh-pr "checkout PR")
     ("o" browse-at-remote-or-copy"browse at point")
     ("O" (shell-command "hub browse") "browse repository")))))

(leaf *hydra-shortcuts3
  :doc "General Shortcuts"
  :bind ("M-o" . *hydra-shortcuts3/body)
  :pretty-hydra
  ((:title " Shortcuts" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Size"
    (("<left>" (shrink-window-horizontally 3) "←" :exit nil)
     ("<up>"   (shrink-window 3) "↑" :exit nil)
     ("<down>" (enlarge-window 3) "↓" :exit nil)
     ("<right>"(enlarge-window-horizontally 3) "→" :exit nil))
    "Split"
    (("-" split-window-vertically "vertical")
     ("/" split-window-horizontally "horizontal"))
    "Window"
    (("o" other-window "other" :exit nil)
     ("d" kill-current-buffer "close")
     ("D" kill-buffer-and-window "kill")
     ("O" delete-other-windows "close others")
     ("s" ace-swap-window "swap")
     ("m" toggle-window-maximize "maximize")
     ("<SPC>" rotate-layout "rotate" :exit nil))
    "Buffer"
    (("b" consult-buffer "open")
     ("B" consult-buffer-other-window "open other")
     ("R" (switch-to-buffer (get-buffer-create "*scratch*")) "scratch")
     ("," previous-buffer "previous" :exit nil)
     ("." next-buffer "next" :exit nil))
    "File"
    (("r" consult-buffer "recent")
     ("f" consult-find "find")
     ("p" consult-ghq-find "ghq")
     ("@" projectile-run-shell-command-in-root "$run")
     ("!" projectile-run-async-shell-command-in-root "$async"))
    "Org"
    (("c" org-capture "capture")
     ("a" org-agenda "agenda")
     ("j" org-journal-new-entry "journal")
     ("t" (org-open-file org-task-file) "private")
     ("z" (org-open-file org-work-file) "work")
     ("l" calendar)))))

(provide 'init)
;;; init.el ends here
