;;; packages.el --- d12frosted-core layer packages file for Spacemacs.
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

(defconst d12frosted-core-packages
  '(
    ;; utils
    ranger
    google-translate
    projectile
    magit
    (magit-gcm :location
               (recipe
                :fetcher github
                :repo "d12frosted/git-config-manager"
                :files ("elisp/magit-gcm.el")))
    git-messenger
    bpr
    zoom-frm
    god-mode
    ace-window
    move-text
    alert
    comment-dwim-2
    (composable :location (recipe
                           :fetcher github
                           :repo "paldepind/composable.el"))
    (counsel-osx-app :location (recipe
                                :fetcher github
                                :repo "d12frosted/counsel-osx-app"))
    cider ;; it's used as utility
    term-projectile
    (smart-ops :location local)
    (fill-unfill :location local)
    persp-mode
    (mobile-app-installer :location local)
    (d12-files :location local)
    (d12-dir-settings :location local)
    (d12-copy-paste :location local)
    (d12-comment :location local)
    (d12-eww :location local)
    (d12-ukrainian-input-method :location local)
    (d12-interesting-files :location local)
    elpa-mirror

    ;; completion
    helm
    ivy

    ;; flyspell / flycheck
    flycheck-package

    ;; other
    mu4e
    elfeed
    elfeed-goodies))

(defun d12frosted-core/pre-init-ranger ()
  (use-package ranger
    :defer t
    :init
    (setq-default ranger-override-dired t
                  ranger-show-literal nil)))

(defun d12frosted-core/post-init-google-translate ()
  (use-package google-translate
    :defer t
    :config
    (setq google-translate-default-source-language "uk"
          google-translate-default-target-language "en")))

(defun d12frosted-core/pre-init-projectile ()
  (use-package projectile
    :defer t
    :init
    (setq projectile-enable-caching nil)
    (when (configuration-layer/layer-usedp 'helm)
      (helm-projectile-on))))

(defun d12frosted-core/post-init-projectile ()
  (use-package projectile
    :defer t
    :config
    (defun d12-projectile/open-root-in-finder ()
      (interactive)
      (shell-command (format "open '%s'" (projectile-project-root))))
    (spacemacs/set-leader-keys "pO" #'d12-projectile/open-root-in-finder)
    (setq projectile-switch-project-action #'projectile-find-file)
    (def-projectile-commander-method ?s
      "Open a *shell* buffer for the project."
      (shell (get-buffer-create
              (format "*shell %s*"
                      (projectile-project-name)))))
    (def-projectile-commander-method ?c
      "Run `compile' in the project."
      (call-interactively #'compile))
    (def-projectile-commander-method ?\C-?
      "Go back to project selection."
      (projectile-switch-project))
    (def-projectile-commander-method ?d
      "Open project root in dired."
      (projectile-dired))))

(defun d12frosted-core/post-init-magit ()
  (use-package magit
    :defer t
    :init
    (setq magit-repo-dirs `(,d12-path/developer))
    (defun d12-magit/push-all ()
      (interactive)
      (let ((bpr-on-success #'magit-refresh))
        (bpr-spawn "git pushall")))))

(defun d12frosted-core/init-magit-gcm ()
  (use-package magit-gcm
      :defer (turn-on-magit-gcm)
      :init
      (setq-default magit-gcm-mode-lighter "")
      (add-hook 'magit-mode-hook 'turn-on-magit-gcm)))

(defun d12frosted-core/post-init-git-messenger ()
  (use-package git-messenger
    :defer t
    :config
    (setq git-messenger:show-detail t)))

(defun d12frosted-core/init-bpr ()
  (use-package bpr
    :commands (bpr-spawn bpr-open-last-buffer)
    :config
    (setq bpr-colorize-output t)
    (setq bpr-close-after-success t)
    (defvar bpr-cmd-and-separator (pcase d12-env-shell-type
                                    ('fish "; and ")
                                    (t " && ")))
    (defvar bpr-cmd-or-separator(pcase d12-env-shell-type
                                  ('fish "; or ")
                                  (t " || ")))
    (defun bpr-cmd-and (&rest cmds)
      (mapconcat 'identity cmds bpr-cmd-and-separator))
    (defun bpr-cmd-or (&rest cmds)
      (mapconcat 'identity cmds bpr-cmd-or-separator))
    (defun bpr-cmd-cd (dir)
      (format "cd '%s'" dir))))

(defun d12frosted-core/post-init-zoom-frm ()
  (use-package zoom-frm
    :defer t
    :config
    ;; remove some crazy bindings
    (unbind-key "<C-wheel-down>")
    (unbind-key "<C-wheel-up>")))

(defun d12frosted-core/init-god-mode ()
  (use-package god-mode
    :commands (god-local-mode)
    :bind ("<escape>" . god-local-mode)
    :config
    (spacemacs|diminish god-local-mode)))

(defun d12frosted-core/post-init-ace-window ()
  (use-package ace-window
    :defer t
    :init
    (bind-key "M-\\" 'ace-window)))

(defun d12frosted-core/post-init-move-text ()
  (use-package move-text
    :defer t
    :config
    (bind-key "<M-down>" 'move-text-down prog-mode-map)
    (bind-key "<M-up>" 'move-text-up prog-mode-map)))

(defun d12frosted-core/init-alert ()
  (use-package alert
    :commands (alert)
    :init
    (setq alert-default-style 'notifier)))

(defun d12frosted-core/init-comment-dwim-2 ()
  (use-package comment-dwim-2
    :commands (comment-dwim-2)
    :init
    (bind-key "C-M-;" 'comment-dwim-2)))

(defun d12frosted-core/init-composable ()
  (use-package composable
    :commands (composable-mode)
    :init
    (progn
      (composable-mode)
      (composable-def '(delete-region))
      (spacemacs|diminish composable-mode)
      (defun d12-composable/mark-word (arg)
        "Mark ARG words.
Supports negative arguments and repeating."
        (interactive "P")
        (composable--mark-with-forward 'forward-word arg))
      (bind-key "C-M-w" 'composable-delete-region composable-mode-map)
      (bind-key "w" 'd12-composable/mark-word composable-object-mode-map))))

(defun d12frosted-core/init-counsel-osx-app ()
  (use-package counsel-osx-app
    :if (configuration-layer/layer-usedp 'ivy)
    :commands (counsel-osx-app)
    :init
    (setq counsel-osx-app-location
          `("/Applications"
            ,(concat user-home-directory "Applications")))
    (bind-key "M-<f12>" 'counsel-osx-app)))

(defun d12frosted-core/init-cider ()
  (use-package cider
    :commands (cider--make-result-overlay)
    :init
    (defun d12/eval-overlay (value point)
      (cider--make-result-overlay (format "%S" value)
        :where point
        :duration 'command)
      ;; Preserve the return value.
      value)

    (advice-add 'eval-region :around
                (lambda (f beg end &rest r)
                  (d12/eval-overlay
                   (apply f beg end r)
                   end)))

    (advice-add 'eval-last-sexp :filter-return
                (lambda (r)
                  (d12/eval-overlay r (point))))

    (advice-add 'eval-defun :filter-return
                (lambda (r)
                  (d12/eval-overlay
                   r
                   (save-excursion
                     (end-of-defun)
                     (point)))))))

(defun d12frosted-core/init-term-projectile ()
  (use-package term-projectile
    :commands (term-projectile-forward
               term-projectile-backward
               term-projectile-create-new)))

(defun d12frosted-core/init-smart-ops ()
  (use-package smart-ops
    :diminish smart-ops-mode
    :config
    (smart-ops-global-mode)))

(defun d12frosted-core/init-fill-unfill ()
  (use-package fill-unfill))

(defun d12frosted-core/post-init-persp-mode ()
  (use-package persp-mode
    :defer t
    :init
    (spacemacs|define-custom-layout "@Spacemacs"
      :binding "s"
      :body
      (find-file-existing user-init-file))
    (spacemacs|define-custom-layout "@Env"
      :binding "e"
      :body
      (find-file-existing d12-path/d12frosted-init))))

(defun d12frosted-core/init-mobile-app-installer ()
  (use-package mobile-app-installer
    :defer t
    :commands (mai mai-install)
    :config
    (when (fboundp 'd12-private/setup-mai)
      (d12-private/setup-mai))))

(defun d12frosted-core/init-d12-files ()
  (use-package d12-files))

(defun d12frosted-core/init-d12-dir-settings ()
  (use-package d12-dir-settings))

(defun d12frosted-core/init-d12-copy-paste ()
  (use-package d12-copy-paste))

(defun d12frosted-core/init-d12-comment ()
  (use-package d12-comment))

(defun d12frosted-core/init-d12-eww ()
  (use-package d12-eww))

(defun d12frosted-core/init-d12-ukrainian-input-method ()
  (use-package d12-ukrainian-input-method))

(defun d12frosted-core/init-d12-interesting-files ()
  (use-package d12-interesting-files
    :config
    (setq d12-interesting-files-interface
      (cond
       ((configuration-layer/layer-usedp 'helm) #'d12-interesting-files-helm)
       ((configuration-layer/layer-usedp 'ivy) #'d12-interesting-files-ivy)
       (t #'d12-interesting-files-default)))

    (d12-interesting-files-add
     `(,d12-path/spacemacs-user-config
       ,d12-path/d12frosted-init
       ,d12-path/spacemacs-init
       ,(concat d12-path/emacs-private "private.el")
       ,(concat d12-path/fish-public "config.fish")
       ,(concat d12-path/fish-private "preconfig.fish")
       ,(concat d12-path/fish-private "postconfig.fish")))))

(defun d12frosted-core/init-elpa-mirror ()
  (use-package elpa-mirror
    :commands (elpamr-create-mirror-for-installed)))

(when (configuration-layer/layer-usedp 'helm)
  (defun d12frosted-core/post-init-helm ()
    (use-package helm
      :defer t
      :config
      ;; Disable fuzzy matching to make mdfind work with helm-locate
      (setq helm-locate-fuzzy-match nil)
      (setq helm-locate-command "mdfind -name %s %s")
      (bind-key "C-s" 'helm-swoop)
      (bind-key "C-S-s" 'spacemacs/helm-swoop-region-or-symbol))))

(when (configuration-layer/layer-usedp 'ivy)
  (defun d12frosted-core/post-init-ivy ()
    (use-package ivy
      :defer t
      :config
      (bind-key "C-S-s" 'spacemacs/swiper-region-or-symbol))))

(when (configuration-layer/layer-usedp 'syntax-checking)
  (defun d12frosted-core/init-flycheck-package ()
    (use-package flycheck-package
      :if (configuration-layer/package-usedp 'flycheck)
      :commands flycheck-package-setup
      :init (eval-after-load 'flycheck
              '(flycheck-package-setup)))))

;;; packages.el ends here
