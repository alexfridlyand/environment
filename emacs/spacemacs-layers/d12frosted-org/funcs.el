;;; funcs.el --- d12frosted-org Layer funcs File for Spacemacs
;;
;; Copyright (c) 2014-2015 Boris Buliga
;;
;; Author: Boris Buliga <d12frosted@icloud.com>
;; URL: https://github.com/d12frosted/environment
;;
;; This file is not part of GNU Emacs.
;;
;;; License: MIT

(defun gtd ()
   (interactive)
   (find-file (d12frosted/concat-path d12frosted/org-home-path "gtd/gtd.org")))

(defun d12frosted/org-files-in-folder (folder)
  (directory-files folder t ".*\.org$"))

(defun d12frosted/org-insert-block-template ()
  "Insert block template at point."
  (interactive)
  (if (org-at-table-p)
      (call-interactively 'org-table-rotate-recalc-marks)
    (let* ((choices '(("s" . "SRC")
                      ("e" . "EXAMPLE")
                      ("h" . "HTML")
                      ("q" . "QUOTE")
                      ("c" . "CENTER")))
           (key
            (key-description
             (vector
              (read-key
               (concat (propertize "Template type: " 'face 'minibuffer-prompt)
                       (mapconcat (lambda (choice)
                                    (concat (propertize (car choice) 'face 'font-lock-type-face)
                                            ": "
                                            (cdr choice)))
                                  choices
                                  ", ")))))))
      (let ((result (assoc key choices)))
        (when result
          (let ((choice (cdr result)))
            (cond
             ((region-active-p)
              (let ((start (region-beginning))
                    (end (region-end)))
                (goto-char end)
                (insert "\n#+END_" choice)
                (goto-char start)
                (insert "#+BEGIN_" choice "\n")))
             (t
              (insert "#+BEGIN_" choice "\n")
              (save-excursion (insert "\n#+END_" choice))))))))))

(defun d12frosted/org-new-file-template ()
  "Create template for new org file."
  (let ((option-key-width 16)
        (bname (buffer-name))
        (title (if (boundp 'bname)
                  (if (s-suffix? ".org" bname)
                      (substring bname 0 -4)
                    bname)
                "Yet another org file"))
        (author "Boris Buliga <d12frosted@icloud.com>")
        (email "d12frosted@icloud.com")
        (date (format-time-string "%Y-%m-%d")))
    (s-join "\n" (list (d12frosted/org-option option-key-width "TITLE" title)
                       (d12frosted/org-option option-key-width "AUTHOR" author)
                       (d12frosted/org-option option-key-width "EMAIL" email)
                       (d12frosted/org-option option-key-width "DATE" date)
                       (d12frosted/org-option option-key-width "STARTUP" "showeverything")
                       (d12frosted/org-option option-key-width "OPTIONS" "toc:nil")))))

(defun d12frosted/org-option (width key value)
  "Create an option string for org file."
  (s-append value (s-pad-right width " " (s-concat "#+" key ":"))))

(defun d12frosted/org-auto-insert-template ()
  "Insert template for the newly created buffer."
  (interactive)
  (when (and (= (point-min)
                (point-max))
             (buffer-file-name))
    (insert (d12frosted/org-new-file-template))
    (goto-char (point-max))))

(defun d12frosted/org-sort-current-level ()
  "Sort current level by TODO."
  (interactive)
  (org-sort-entries nil ?o))

(defun d12frosted/org-sort-upper-level ()
  "Go to upper level and sort it by TODO."
  (interactive)
  (progn (outline-up-heading 1)
         (d12frosted/org-sort-current-level)))
