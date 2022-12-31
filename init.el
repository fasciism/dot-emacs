;;; init.el --- Where all the magic begins
;;
;; Originally from:
;;     http://orgmode.org/worg/org-contrib/babel/intro.html#literate-emacs-init
;;
;; This file loads Org-mode and then loads the rest of our Emacs initialization
;; from Emacs lisp embedded in literate Org-mode files.

;; Load up Org Mode and (now included) Org Babel for elisp embedded in Org Mode
;; files.

;; Enforce a minimum Emacs version.
(let ((min-ver "29.0")
      (cur-ver emacs-version))
  (if (version< cur-ver min-ver)
      (error "This configuration requires Emacs v%s or above, but v%s found." min-ver cur-ver)))

;; This is at the very start of my startup because my work laptops are always
;; MacBooks, and if there is any configuration error with Emacs it renders the
;; built-in keyboard absolutely unusable to me if these settings have not yet
;; been applied.
;;
;; In addition to these settings, I need caps lock to be set as control in the
;; MacBook's system preferences.
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-key-is-meta nil)
(setq mac-option-modifier nil)

;; Create a build directory so .el files don't clutter the repo.
(defvar mak::el-build-dir (expand-file-name "build" user-emacs-directory))

;; This is a customized implementation of org-babel-load-file.
(defun mak::execute-blog-post (org-file)
  "Tangle and load a blog post."
  (let* ((base (file-name-base org-file))
	 (src-abs-dir (directory-file-name (file-name-directory org-file)))
	 (src-rel-dir (file-relative-name src-abs-dir user-emacs-directory))
         (dst-abs-dir (expand-file-name src-rel-dir mak::el-build-dir))
         (el-file (expand-file-name (concat base ".el") dst-abs-dir)))
    (make-directory dst-abs-dir t)
    ;; Tangle file (.org -> .el) if the .org is newer.
    (if (file-newer-than-file-p org-file el-file)
	(org-babel-tangle-file org-file el-file "emacs-lisp"))
    ;; Some blog posts don't have any runnable code, and so do not produce a
    ;; file when tangled.
    (if (file-exists-p el-file)
	(load-file el-file))))

(defun mak::load-literate-config (dir &optional regex)
  "Load and evaluate the files in dir matching regex, except .org files."
  (unless regex (setq regex ""))
  (let* ((path (expand-file-name dir user-emacs-directory))
	 (regex (concat regex ".*\\.org$"))
	 (files (directory-files path t regex)))
    (dolist (org-file files)
      (message "Loading %s..." org-file)
      (mak::execute-blog-post org-file)
      (message "Loaded %s." org-file))))

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

;; Create a private directory in which I will keep all files that I intend to
;; open with Emacs but do not want to publish. Examples include private Eshell
;; aliases and Gnus configurations.
(setq private-emacs-directory (expand-file-name "private" user-emacs-directory))

;; Create a state directory in which I will keep all files that I do not intend
;; to open with Emacs. Examples include key frequency data and Eshell history.
(setq state-emacs-directory (expand-file-name "state" user-emacs-directory))

;; Load the customization variables from another file.
(setq custom-file (expand-file-name "custom.el" private-emacs-directory))
(load custom-file 'noerror)

;; Load up all literate org-mode files matching the regex in each directory.
(mak::load-literate-config "posts" "\[0-9\]\\{4\\}-\[0-9\]\\{2\\}-\[0-9\]\\{2\\}-")
(mak::load-literate-config "drafts" "YYYY-MM-DD-")
(mak::load-literate-config "private")
