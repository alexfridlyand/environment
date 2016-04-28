;;; config.el --- d12frosted-org layer config file for Spacemacs.
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Boris Buliga <d12frosted@d12frosted.local>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;;; Code:

(defvar d12-org/files-list
  '()
  "List of interesting org files.")

(when (configuration-layer/layer-usedp 'spacemacs-helm)
  (add-to-list 'd12-helm/sources 'd12-helm/gtd-source))

;;; config.el ends here
