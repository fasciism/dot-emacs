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

(defun mak::load-literate-config (dir &optional regex)
  "Load and evaluate the files in dir matching regex, except blacklisted files."
  (unless regex
    (setq regex ""))
  (dolist (org (directory-files dir t (concat regex ".*\\.org$")))
    (org-babel-load-file org)))

(setq dotfiles-dir (file-name-directory (or (buffer-file-name) load-file-name)))

(let* ((org-dir (expand-file-name "lisp"
        (expand-file-name "org"
         (expand-file-name "src"
          dotfiles-dir))))
       (org-contrib-dir (expand-file-name "lisp"
        (expand-file-name "contrib"
         (expand-file-name ".."
          org-dir))))
       (load-path (append (list org-dir org-contrib-dir)
                          (or load-path nil))))
  ;; Load up Org-mode and Org-babel.
  (require 'org-install)
  (require 'ob-tangle))

;; Load the customization variables from another file.
(setq custom-file "~/.emacs.p/custom.el")
(load custom-file 'noerror)

;; Load up all literate org-mode files matching the regex in each directory.
(mak::load-literate-config "~/.emacs.d" "\[0-9\]\\{4\\}-\[0-9\]\\{2\\}-\[0-9\]\\{2\\}-")
(mak::load-literate-config "~/.emacs.d/drafts" "YYYY-MM-DD-")
(mak::load-literate-config "~/.emacs.p")
