;;; funcs.el --- d12-core layer funcs file for Spacemacs. -*- lexical-binding: t; -*-
;;
;;; Copyright (c) 2015-2017 Boris Buliga
;;
;;; Author: Boris Buliga <boris@d12frosted.io>
;;
;;; URL: https://github.com/d12frosted/environment/emacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3
;;
;;; Commentary:
;;
;;; Code:

(defun d12-key-bind (key-name command &optional keymap)
  "Bind KEY-NAME to COMMAND in the KEYMAP."
  (bind-key key-name command keymap))

(defun d12-key-unbind (key-name &optional keymap)
  "Unbind KEY-NAME in the KEYMAP."
  (unbind-key key-name keymap))

(defun d12-key-copy (key-name keymap-target &optional keymap-source)
  "Bind KEY-NAME in KEYMAP-TARGET to command from
  KEYMAP-SOURCE."
  (d12-key-bind key-name
                (lookup-key (or keymap-source
                                (current-global-map))
                            (kbd key-name))
                keymap-target))

;;; funcs.el ends here
