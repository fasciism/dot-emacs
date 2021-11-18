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
(let ((min-ver "27.1")
      (cur-ver emacs-version))
  (if (version< cur-ver min-ver)
      (error "This configuration requires Emacs v%s or above, but v%s found." min-ver cur-ver)))

;; Create a build directory so .el files don't clutter the repo.
(defvar mak::el-build-dir (concat user-emacs-directory "build/"))

;; This is a customized implementation of org-babel-load-file.
(defun mak::execute-blog-post (org-file)
  "Tangle, byte-compile, and load a blog post."
  (let* ((file-rel (file-relative-name (file-name-sans-extension org-file) user-emacs-directory))
         ;; Store derived files within the build directory matching their
         ;; location in the configuration directory. For example:
         ;; emacs/path/to/foo.org -> emacs/build/path/to/foo.el)
         (dest-dir (file-name-directory (concat mak::el-build-dir file-rel)))
         (el-file (concat mak::el-build-dir file-rel ".el"))
         (elc-file (concat mak::el-build-dir file-rel ".elc")))
    (make-directory dest-dir t)

    ;; Tangle file (.org -> .el) if the .org is newer.
    (if (file-newer-than-file-p org-file el-file)
      (org-babel-tangle-file org-file el-file "emacs-lisp"))

    ;; Compile file (.el -> .elc) if the .el is newer.
    (if (file-newer-than-file-p el-file elc-file)
      (byte-compile-file el-file))

    ;; Some blog posts don't have any runnable code, and so do not produce a
    ;; file when tangled.
    (if (file-exists-p elc-file)
        (load-file elc-file))))

(defun mak::load-literate-config (dir &optional regex)
  "Load and evaluate the files in dir matching regex, except blacklisted files."
  (setq regex (or regex ""))
  (dolist (org-file (directory-files (concat user-emacs-directory dir) t (concat regex ".*\\.org$")))
    (mak::execute-blog-post org-file)))

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
(setq custom-file (concat user-emacs-directory "private/custom.el"))
(load custom-file 'noerror)

;; Load up all literate org-mode files matching the regex in each directory.
(mak::load-literate-config "posts" "\[0-9\]\\{4\\}-\[0-9\]\\{2\\}-\[0-9\]\\{2\\}-")
(mak::load-literate-config "drafts" "YYYY-MM-DD-")
(mak::load-literate-config "private")
