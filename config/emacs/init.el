	;;; Emacs config - LFour-CN@github
	;;; 2025-6-17
	;;; Code start here:

	;; ======================
	;; Core Initialization
	;; ======================
	(setq inhibit-startup-screen t                                                 ; Disable splash screen
      		initial-scratch-message nil                                              ; Clean scratch buffer
      		package-enable-at-startup nil                                            ; Defer package loading
      		gc-cons-threshold 402653184                                              ; 400MB GC threshold during init
      		gc-cons-percentage 0.6                                                   ; Reduce GC frequency
	)
	;; Only the minimum necessary components are loaded at startup, and other functions are deferred for initialization
	(defvar my/minimal-init t)                                                     ; Mark the initial startup phase
	(add-hook 'after-init-hook (lambda () (setq my/minimal-init nil)))             ; Clear the marker after initialization is complete

	;; Preserve original file handlers
	(defvar my-file-handler-alist file-name-handler-alist)
	(setq file-name-handler-alist nil)

	;; Package system configuration
	(require 'package)
  	(setq package-archives
        	'(("melpa"   . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
          	("gnu"     . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
          	("nongnu"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
        	)
  	)
  	(setq package-archive-priorities '(("melpa" . 10) ("gnu" . 20) ("nongnu" . 30)) ; Reduce the time required for image selection
        	package-quickstart t                                                      ; Skip unnecessary package metadata validation
        	use-package-always-ensure nil                                             ; Install packages only when needed (no mandatory checks on startup)
        	use-package-compute-statistics nil                                        ; Disable statistics collection
  	)
	(package-initialize)

	;; Bootstrap use-package
	;;(unless (package-installed-p 'use-package)
  	;;(package-refresh-contents)
  	;;(package-install 'use-package)
	;;)

	(require 'use-package)
  		(setq use-package-always-ensure t
      		use-package-verbose nil
  	)

	;; Backup file generation is prohibited
	(setq make-backup-files nil)
	;; Turn off auto-save temporary files (e.g. #filename#)
	(setq auto-save-default nil)

	;; ======================
	;; Evil Mode Configuration
	;; ======================
	(use-package evil
  		:init
			(setq evil-want-integration t
        		evil-want-keybinding nil
        		evil-undo-system 'undo-redo
  		)
  		:config
  		(evil-mode 1)
  		;; Optimized performance flags
  		(
			setq evil-move-beyond-eol t
        		evil-respect-visual-line-mode t
        		evil-want-fine-undo t
		)
	)


	;; ======================
	;; Productivity Suite
	;; ======================
	(use-package magit                     ; Git integration
  		:bind ("C-x g" . magit-status)
  		:defer 2                             ; Delay loading
  		:config (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
	)

	(use-package projectile                ; Project navigation
  		:defer 2
  		:config 
  		(projectile-mode 1)
  		(setq projectile-project-search-path '("~/.emacs.d/projects/"))
	)

	;; ======================
	;; Interface Enhancements
	;; ======================
	(setq gdb-many-windows t)
	(setq gdb-show-main t)
	(winner-mode 1)

	(use-package ace-window
		:ensure t
		:bind ("M-a" . ace-window)
	)

	(use-package company
  		:ensure t
  		:init (global-company-mode)
  		:config
  		(setq company-minimum-prefix-length 1)
  		(setq company-tooltip-align-annotations t)
  		(setq company-idle-delay 0.0)
  		(setq company-show-numbers t)
  		(setq company-selection-wrap-around t)
  		(setq company-transformers '(company-sort-by-occurrence))
	)

	(use-package company-box
  		:ensure t
  		:if window-system
  		:hook (company-mode . company-box-mode)
	)

	(use-package flycheck
  		:config
  		(
			setq flycheck-idle-change-delay 1.8  ; Reduced CPU usage
        		flycheck-check-syntax-automatically '(save mode-enabled)
  		)
	)

	(use-package yasnippet
  		:ensure t
  		:hook
  		(prog-mode . yas-minor-mode)
  		:config
  		(yas-reload-all)
  		;; add company-yasnippet to company-backends
  		(defun company-mode/backend-with-yas (backend)
    			(if (and (listp backend) (member 'company-yasnippet backend))
		backend
      		(append (if (consp backend) backend (list backend))
              '(:with company-yasnippet))
	      		)
	      )
  		(setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))
	)

	(use-package yasnippet-snippets
  		:ensure t
  		:after yasnippet
	)

	;; ======================
	;; LSP Configuration
	;; ======================
	(use-package lsp-mode
  		:ensure t
  		:init
  		;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  		(setq lsp-keymap-prefix "C-c l"
		lsp-file-watch-threshold 500)
  		:hook 
  		(lsp-mode . lsp-enable-which-key-integration) ; which-key integration
  		:commands (lsp lsp-deferred)
  		:config
  		(setq lsp-completion-provider :none)
  		(setq lsp-headerline-breadcrumb-enable t)
  		:bind
  		("C-c l s" . lsp-ivy-workspace-symbol)
  	)

	;; Enhanced UI Components
	(use-package lsp-ui
  		:after lsp-mode
  		:config
  		(
			setq lsp-ui-doc-position 'at-point          ; Context-aware documentation
        		lsp-ui-sideline-show-code-actions nil  ; Reduce visual clutter
        		lsp-ui-peek-fontify 'always            ; Maintain syntax highlighting
  		)
	)

	;; ======================
	;; Memory Optimization
	;; ======================
	(defun my/lsp-memory-profile ()
  		"Display LSP memory consumption statistics."
  		(interactive)
  		(
			message "Active workspaces: %d | Memory usage: %.2fMB"
           		(hash-table-count lsp--buffer-workspaces)
           		(/ (garbage-collect) 1048576.0)
  		)
	)

	;; Post-init GC tuning
	(add-hook 'emacs-startup-hook
          	(lambda ()
            	(
			setq gc-cons-threshold 16777216                  ; 16MB after initialization
                  	read-process-output-max (* 4 1024 1024)     ; Improve IPC throughput
	    	)
	  	)
	)

	;; Alternative 1: Eglot (Lightweight LSP Client)
	(when nil ; Enable by removing nil
  	(use-package eglot
    		:hook (prog-mode . eglot-ensure)
    		:config
    		(
			setq eglot-sync-connect-timeout 30
          		eglot-autoshutdown t
          		eglot-events-buffer-size 0
    		)
  	)
	)

	;; Alternative 2: Debug Adapter Protocol
	(use-package dap-mode
  		:after lsp-mode
  		:config
  		(dap-mode 1)
  		(dap-ui-mode 1)
  		(setq dap-auto-configure-features '(controls locals tooltip))
	)

	;; ======================
	;; Org-mode Ecosystem
	;; ======================
	(use-package org
  		:config
  		(
			setq org-directory "~/.emacs.d/org/"
        		org-agenda-files '("~/.emacs.d/org/")
  		)
  		(
			unless (file-exists-p org-directory)
          		(make-directory org-directory t)
  		)
  		(global-set-key (kbd "C-c c") 'org-capture)
  		(global-set-key (kbd "C-c a") 'org-agenda)
	)

	;; ======================
	;; Visual Configuration
	;; ======================
	(use-package doom-themes                 ; Modern theme
  		:config 
  		(load-theme 'doom-dracula t)
  		(
			setq doom-themes-enable-bold t
        		doom-themes-enable-italic t
		)
	)

	(use-package rainbow-delimiters          ; Syntax visualization
  		:hook (prog-mode . rainbow-delimiters-mode)
	)


	(use-package dashboard
  		:ensure t
  		:config
  		(dashboard-setup-startup-hook)
      (setq initial-buffer-choice (lambda () 
            (get-buffer-create dashboard-buffer-name))
      )
      (setq dashboard-banner-logo-title "Welcome to FreeBSD Emacs")
      (setq dashboard-center-content t)
      (setq dashboard-vertically-center-content t)
      (setq dashboard-show-shortcuts nil)
      (setq dashboard-navigation-cycle t)
      (setq dashboard-set-heading-icons t)
      (setq dashboard-set-file-icons t)
      (setq dashboard-icon-file-height 1.75)
      (setq dashboard-icon-file-v-adjust -0.125)
      (setq dashboard-heading-icon-height 1.75)
      (setq dashboard-heading-icon-v-adjust -0.125)
      (setq dashboard-items '((recents   . 5)
                        (bookmarks . 5)
                        (projects  . 5)
                        (agenda    . 5)
                        (registers . 5))
      )
	)

	;; Install required fonts for icons
	(use-package all-the-icons
  		:if (display-graphic-p)
	)

	(use-package ivy                         ; Completion framework
  		:config
  		(ivy-mode 1)
  		(
			setq ivy-use-virtual-buffers t
        		ivy-count-format "(%d/%d) "
  		)
	)

	(use-package counsel                     ; Enhanced search
  		:after ivy
  		:bind
		(
			("M-x" . counsel-M-x)
         		("C-s" . counsel-grep-or-swiper)
         		("C-x C-f" . counsel-find-file)
		)
  		:config
  		(setq counsel-rg-base-command "rg -S --no-heading --line-number --color never %s")
	)

	(use-package treemacs
  		:ensure t
  		:defer t                                    ; Lazy-load to preserve startup speed
  		:commands (treemacs treemacs-projectile)
  		:config
  		(
			setq treemacs-width 24                  ; Compact sidebar width
        		treemacs-collapse-dirs 3              	; Simplify directory nesting
       			treemacs-silent-refresh t             	; Disable auto-refresh
        		treemacs-filewatch-mode nil		; Reduce system resource usage
		)          

  		;; Project integration with existing projectile setup
  		(use-package treemacs-projectile
    			:after (treemacs projectile)
    			:config (treemacs-project-follow-mode 1)
  		)
	)

	(use-package which-key                   ; Key discovery
  		:config 
  		(which-key-mode)
  		(setq which-key-idle-delay 0.5)
	)

	(use-package highlight-indent-guides
  		:hook (prog-mode . highlight-indent-guides-mode)
  		:defer t
  		:config
  		;; Basic configuration
  		(
			setq highlight-indent-guides-method 'character
        		highlight-indent-guides-delay 0.1
        		highlight-indent-guides-responsive 'top
       			highlight-indent-guides-auto-enabled nil) ; Turn off automatic global highlighting
  		;; Color customization
  		(custom-set-faces
   			'(highlight-indent-guides-character-face
     			((t :foreground "#555555")))
   			'(
				highlight-indent-guides-top-character-face
     				((t :foreground "#0099ff" :weight bold))
    			)
  		)

  		;; Dynamic response logic (and security checks)
  		(defun my/highlight-indent-on-cursor-move ()
    			(when (and (bound-and-true-p highlight-indent-guides-mode)
               			(fboundp 'highlight-indent-guides--highlighter))
      				(let ((current-indent (current-indentation)))
        				(ignore-errors ; Prevent accidental errors from blocking subsequent operations
          					(highlight-indent-guides--set-overlays 
           						(save-excursion
             							(move-beginning-of-line nil)
             							(current-indentation)
							)
						)
          					(highlight-indent-guides--highlighter)
					)
      				)
    			)
  		)

  		;; Use idle delays to avoid high-frequency triggering
  		(run-with-idle-timer 0.1 t #'my/highlight-indent-on-cursor-move)

 		;; Defensive loading (ensures that the theme is executed after loading)
  		(with-eval-after-load 'doom-themes
    			(set-face-foreground 'highlight-indent-guides-character-face "#555555")
    			(set-face-foreground 'highlight-indent-guides-top-character-face "#0099ff")
  		)
	)

	;; show relative number
	(setq display-line-numbers-type 'relative)
	(global-display-line-numbers-mode 1)

	;; set font
	(set-face-attribute 'default nil :font "Maple Mono NF CN" :height 128)

	;; ======================
	;; Global keybindings
	;; ======================
	(global-set-key (kbd "M-z") 'eshell-command)
	(global-set-key (kbd "C-c h") 'highlight-indent-guides-mode) ;; Turn on or turn off the indent line
	(global-set-key (kbd "C-c t") 'treemacs)
	(global-set-key (kbd "C-c c") 'compile)
	(global-set-key (kbd "C-c d") 'gdb)
	(global-set-key (kbd "C-c C-t") 
                (lambda () (interactive) 
                  (treemacs-select-window)
		  )
	)
	(global-set-key (kbd "C-c g") 'treemacs-toggle)
	(global-set-key (kbd "C-c C-<left>") 'winner-undo)
	(global-set-key (kbd "C-c C-<right>") 'winner-redo)

	;; ======================
	;; System Integration
	;; ======================
	(use-package services
  		:ensure t
  		:config
	)

	(require 'server)                        ; Daemon setup
	(unless (server-running-p)
  		(server-start)
	)

	;; Clean interface
	(dolist (mode '(menu-bar-mode tool-bar-mode scroll-bar-mode))
  		(when (fboundp mode) (funcall mode -1))
	)

	;; ======================
	;; Performance Management
	;; ======================
	(add-hook 'after-init-hook
         	(lambda ()
            		(
				setq gc-cons-threshold 16777216 ; 16MB after init
                  		file-name-handler-alist my-file-handler-alist
	    		)
	  	)
	)

	;; Prevent indent highlight memory leaks
	(add-hook 'after-change-major-mode-hook
          	(lambda ()
            		(when (derived-mode-p 'prog-mode)
              		(highlight-indent-guides-mode 1)
	    		)
	  	)
	)

	;; ======================
	;; Diagnostic Tools
	;; ======================
	;;(defun my/memory-usage ()
  	;;	"Get accurate memory usage via procfs"
  	;;	(with-temp-buffer
    	;;		(insert-file-contents "/proc/self/statm")
    	;;		(/ (string-to-number (car (split-string (buffer-string)))) 256.0)
  	;;	)
	;;)

	;;(add-hook 'emacs-startup-hook
        ;;  	(lambda ()
        ;;    		(
	;;			message "Emacs ready in %.2fs | Memory: %.2fMB" 
        ;;             		(float-time (time-subtract after-init-time before-init-time))
        ;;             		(my/memory-usage)
        ;;    		)
	;;  	)
	;;)

	;;; Code end here

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(highlight-indent-guides-character-face ((t :foreground "#555555")))
 '(highlight-indent-guides-top-character-face ((t :foreground "#0099ff" :weight bold))))