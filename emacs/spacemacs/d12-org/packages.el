;;; packages.el --- d12-org layer packages file for Spacemacs. -*- lexical-binding: t; -*-
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

(defconst d12-org-packages
  '((flyspell :toggle (configuration-layer/layer-usedp 'spell-checking))
    (org-plus-contrib :step pre)
    org
    worf
    (org-query
     :location
     (recipe
      :fetcher github
      :repo "remyhonig/org-query"
      :files ("org-query.el"
              "org-query-gtd.el")))
    )
  "The list of Lisp packages required by the d12-org layer.")

(defun d12-org/post-init-flyspell ()
  (spell-checking/add-flyspell-hook 'org-mode-hook))

;; dummy init function to force installation of `org-plus-contrib'
(defun d12-org/init-org-plus-contrib ())

(defun d12-org/init-org ()
  (use-package org
    :commands (orgtbl-mode org-mobile-push org-mobile-pull)
    :init
    ;; Setup directory for all org files
    (setq org-directory d12-path-org-home)

    ;; Setup useful global key bindings.
    (d12-key-bind "C-c c" 'org-capture)
    (d12-key-bind "C-c b" 'org-iswitchb)
    (d12-key-bind "C-c l" 'org-store-link)
    (d12-key-bind "<f9> c" 'calendar)
    (d12-key-bind "<f9> h" 'd12-org/hide-other)
    (d12-key-bind "<f9> i" 'org-toggle-inline-images)
    (d12-key-bind "<f9> l" 'org-toggle-link-display)
    (d12-key-bind "<f9> v" 'visible-mode)
    (d12-key-bind "C-<f11>" 'org-clock-in)
    (d12-key-bind "<f11>" 'org-clock-goto)
    (d12-key-bind "<f12>" 'org-agenda)

    ;; Setup indent mode
    (setq org-startup-indented t)

    ;; Setup org-mobile
    (setq org-mobile-directory (concat d12-path-dropbox "Apps/d12-mobile-org/"))
    (setq org-mobile-inbox-for-pull (d12-path/get-org-file "mobile-inbox"))

    ;; Setup `org-agenda-files'. Prefer using directories as files add to them
    ;; will automatically get into `org-agenda-files'.
    (setq org-agenda-files `(,d12-path-org-home
                             ,(d12-path/get-org-dir "personal")
                             ,(d12-path/get-org-dir "work")))

    ;; Setup `org-todo-keywords'.
    (setq org-todo-keywords
          '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
            (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "PHONE" "MEETING")))

    ;; Enable fast todo selection.
    (setq org-use-fast-todo-selection t)

    ;; Allow to fast fix todo state without triggering anything.
    (setq org-treat-S-cursor-todo-selection-as-state-change nil)

    ;; Setup state triggers.
    (setq org-todo-state-tags-triggers
          '(("CANCELLED" ("CANCELLED" . t))
            ("WAITING" ("WAITING" . t))
            ("HOLD" ("WAITING") ("HOLD" . t))
            (done ("WAITING") ("HOLD"))
            ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
            ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
            ("DONE" ("WAITING") ("CANCELLED") ("HOLD"))))

    ;; Setup capture templates.
    (setq org-capture-templates
          `(("t" "todo" plain (file ,(d12-path/get-org-file "inbox"))
             "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
            ("j" "Journal" entry (file+datetree+prompt ,(d12-path/get-org-file "journal"))
             "* %?\n%U\n" :clock-in t :clock-resume t)
            ("r" "respond" entry (file ,(d12-path/get-org-file "inbox"))
             "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
            ("n" "note" entry (file ,(d12-path/get-org-file "inbox"))
             "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
            ("w" "org-protocol" entry (file ,(d12-path/get-org-file "inbox"))
             "* TODO Review %c\n%U\n" :immediate-finish t)
            ("m" "Meeting" entry (file ,(d12-path/get-org-file "inbox"))
             "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
            ("p" "Phone call" entry (file ,(d12-path/get-org-file "inbox"))
             "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
            ("h" "Habit" entry (file ,(d12-path/get-org-file "inbox"))
             "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n")))

    ;; Remove empty LOGBOOK drawers on clock out
    (defun d12-org/remove-empty-drawer-on-clock-out ()
      (interactive)
      (save-excursion
        (beginning-of-line 0)
        (org-remove-empty-drawer-at "LOGBOOK" (point))))
    (add-hook 'org-clock-out-hook 'd12-org/remove-empty-drawer-on-clock-out 'append)

    ;; Refiling
    (setq org-refile-targets
          '((nil :maxlevel . 9)
            (org-agenda-files :maxlevel . 9)))
    (setq org-refile-use-outline-path t)
    (setq org-outline-path-complete-in-steps nil)
    (setq org-refile-allow-creating-parent-nodes 'confirm)
    (setq org-indirect-buffer-display 'current-window)
    (defun d12-org--verify-refile-target ()
      "Exclude todo keywords with a done state from refile targets"
      (let ((tags-at (org-get-tags-at)))
        (and
         ;; doesn't have done keyword
         (not (member (nth 2 (org-heading-components)) org-done-keywords))

         ;; doesn't have blacklisted tag
         (or (null tags-at)
             (member-if-not
              (lambda (x)
                (member (if (listp x) (car x) x) d12-org-refile-ignore-tags))
              tags-at)))))
    (setq org-refile-target-verify-function 'd12-org--verify-refile-target)

    ;; Do not dim blocked tasks
    (setq org-agenda-dim-blocked-tasks nil)

    ;; Compact the block agenda view
    (setq org-agenda-compact-blocks t)

    ;; Show day agenda by default
    (setq org-agenda-span 'day)

    ;; Custom agenda command definitions
    (setq org-agenda-custom-commands
          `((" " "Agenda"
             (
              (agenda "" nil)
              (tags "REFILE"
                    ((org-agenda-overriding-header "Tasks to Refile")
                     (org-tags-match-list-sublevels nil)))
              (tags-todo "-CANCELLED/!"
                         ((org-agenda-overriding-header "Stuck Projects")
                          (org-agenda-skip-function 'd12-org--skip-non-stuck-projects)
                          (org-agenda-sorting-strategy
                           '(category-keep))))
              (tags-todo "-HOLD-CANCELLED/!"
                         ((org-agenda-overriding-header "Projects")
                          (org-agenda-skip-function 'd12-org--skip-non-projects)
                          (org-tags-match-list-sublevels 'indented)
                          (org-agenda-sorting-strategy
                           '(category-keep))))
              (tags-todo "-CANCELLED/!NEXT"
                         ((org-agenda-overriding-header
                           (concat "Project Next Tasks"
                                   (if d12-org-hide-scheduled-and-waiting-next-tasks
                                       ""
                                     " (including WAITING and SCHEDULED tasks)")))
                          (org-agenda-skip-function 'd12-org--skip-projects-and-habits-and-single-tasks)
                          (org-tags-match-list-sublevels t)
                          (org-agenda-todo-ignore-scheduled d12-org-hide-scheduled-and-waiting-next-tasks)
                          (org-agenda-todo-ignore-deadlines d12-org-hide-scheduled-and-waiting-next-tasks)
                          (org-agenda-todo-ignore-with-date d12-org-hide-scheduled-and-waiting-next-tasks)
                          (org-agenda-sorting-strategy
                           '(todo-state-down effort-up category-keep))))
              (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                         ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                (if d12-org-hide-scheduled-and-waiting-next-tasks
                                                                    ""
                                                                  " (including WAITING and SCHEDULED tasks)")))
                          (org-agenda-skip-function 'd12-org--skip-non-project-tasks)
                          (org-agenda-todo-ignore-scheduled d12-org-hide-scheduled-and-waiting-next-tasks)
                          (org-agenda-todo-ignore-deadlines d12-org-hide-scheduled-and-waiting-next-tasks)
                          (org-agenda-todo-ignore-with-date d12-org-hide-scheduled-and-waiting-next-tasks)
                          (org-agenda-sorting-strategy
                           '(category-keep))))
              (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                         ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                (if d12-org-hide-scheduled-and-waiting-next-tasks
                                                                    ""
                                                                  " (including WAITING and SCHEDULED tasks)")))
                          (org-agenda-skip-function 'd12-org--skip-project-tasks)
                          (org-agenda-todo-ignore-scheduled d12-org-hide-scheduled-and-waiting-next-tasks)
                          (org-agenda-todo-ignore-deadlines d12-org-hide-scheduled-and-waiting-next-tasks)
                          (org-agenda-todo-ignore-with-date d12-org-hide-scheduled-and-waiting-next-tasks)
                          (org-agenda-sorting-strategy
                           '(category-keep))))
              (tags-todo "-CANCELLED+WAITING|HOLD/!"
                         ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                (if d12-org-hide-scheduled-and-waiting-next-tasks
                                                                    ""
                                                                  " (including WAITING and SCHEDULED tasks)")))
                          (org-agenda-skip-function 'd12-org--skip-non-tasks)
                          (org-tags-match-list-sublevels nil)
                          (org-agenda-todo-ignore-scheduled d12-org-hide-scheduled-and-waiting-next-tasks)
                          (org-agenda-todo-ignore-deadlines d12-org-hide-scheduled-and-waiting-next-tasks)))
              (tags "-REFILE/"
                    ((org-agenda-overriding-header "Tasks to Archive")
                     (org-agenda-skip-function 'd12-org--skip-non-archivable-tasks)
                     (org-tags-match-list-sublevels nil)))
              )
             nil)
            ))

    :config
    ;; setup org modules
    (add-to-list 'org-modules 'org-habit)
    ))

(defun d12-org/init-worf ()
  (use-package worf
    :defer t
    :init
    (add-hook 'org-mode-hook 'worf-mode)
    (add-hook 'org-capture-mode-hook (lambda () (worf-mode -1)))))

(defun d12-org/init-org-query ()
  (use-package org-query
    :commands (org-query-select)
    :config
    (require 'org-query-gtd)))


;;; packages.el ends here
