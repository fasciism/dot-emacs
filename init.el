;;; init.el --- Where all the magic begins
;;
;; Originally from:
;;     http://orgmode.org/worg/org-contrib/babel/intro.html#literate-emacs-init
;;
;; This file loads Org-mode and then loads the rest of our Emacs initialization
;; from Emacs lisp embedded in literate Org-mode files.

;; Load up Org Mode and (now included) Org Babel for elisp embedded in Org Mode
;; files.

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(setq dotfiles-dir (file-name-directory (or (buffer-file-name) load-file-name)))

(let* ((org-dir (expand-file-name
		 "lisp" (expand-file-name
			 "org" (expand-file-name
				"src" dotfiles-dir))))
       (org-contrib-dir (expand-file-name
			 "lisp" (expand-file-name
				 "contrib" (expand-file-name
					    ".." org-dir))))
       (load-path (append (list org-dir org-contrib-dir)
			  (or load-path nil))))
  ;; Load up Org-mode and Org-babel.
  (require 'org-install)
  (require 'ob-tangle))

;; Load up all literate org-mode files in this directory.
(mapc #'org-babel-load-file (directory-files "~/.emacs.d" t "\[0-9\]\\{4\\}-\[0-9\]\\{2\\}-\[0-9\]\\{2\\}-.*\\.org$"))
(mapc #'org-babel-load-file (directory-files "~/.emacs.d/buffer" t "\[0-9\]\\{4\\}-\[0-9\]\\{2\\}-\[0-9\]\\{2\\}-.*\\.org$"))
(mapc #'org-babel-load-file (directory-files "~/.emacs.d/drafts" t "YYYY-MM-DD-.*\\.org$"))
(mapc #'org-babel-load-file (directory-files "~/.emacs.p" t "\\.org$"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "a8245b7cc985a0610d71f9852e9f2767ad1b852c2bdea6f4aadc12cce9c4d6d0" default)))
 '(org-agenda-files (quote ("~/obs/openstack.org" "~/org/test.org")))
 '(org-hide-emphasis-markers t)
 '(org-hide-leading-stars t)
 '(org-src-fontify-natively t)
 '(package-selected-packages
   (quote
    (ace-window helm bbdb beacon htmlize elfeed guide-key browse-kill-ring undo-tree avy powerline solarized-theme use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
