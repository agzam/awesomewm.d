;;; awesome-wm-helpers.el --- Emacs AwesomeWM helpers -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2024 Ag Ibragimov
;;
;; Author: Ag Ibragimov <agzam.ibragimov@gmail.com>
;; Maintainer: Ag Ibragimov <agzam.ibragimov@gmail.com>
;; Created: January 16, 2024
;; Modified: January 16, 2024
;; Version: 0.0.1
;; Homepage: https://github.com/agzam/edit-with-emacs
;; Package-Requires: ((emacs "30"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

(require 'cl-lib)
(require 'subr-x)
(require 'markdown-mode)
(require 'evil)

(defvar awesome-edit-with-emacs-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") #'awesome-finish-edit-with-emacs)
    (define-key map (kbd "C-c C-k") #'awesome-cancel-edit-with-emacs)
    map))

(define-minor-mode awesome-edit-with-emacs-mode
  "Minor mode enabled on buffers opened by awesome-edit-by-emacs."
  :init-value nil
  :lighter " editwithemacs"
  :keymap awesome-edit-with-emacs-mode-map
  :group 'awesomewm)

(defun awesome--turn-on-edit-with-emacs-mode ()
  "Turn on `awesome-edit-with-emacs-mode' if the buffer derives from that mode."
  (when (string-match-p "* awesome-edit " (buffer-name (current-buffer)))
    (awesome-edit-with-emacs-mode t)))

(define-global-minor-mode awesome-global-edit-with-emacs-mode
  awesome-edit-with-emacs-mode awesome--turn-on-edit-with-emacs-mode
  :group 'awesomewm)

(defvar awesome-edit-with-emacs-hook nil
  "Hook for when edit-with-emacs buffer gets activated.

Hook function must accept arguments:
- `buffer-name' - the name of the edit buffer
- `pid'         - PID of the app that invoked Edit-with-Emacs
- `title'       - title of the app that invoked Edit-with-Emacs")

(defvar awesome-before-finish-edit-with-emacs-hook nil
  "Fires when editing is done and the dedicated buffer is about be killed.

Hook function must accept arguments:
- `buffer-name' - the name of the edit buffer
- `pid'         - PID of the app that invoked Edit-with-Emacs")

(defvar awesome-before-cancel-edit-with-emacs-hook nil
  "Fires when editing is canceled and the dedicated buffer is about to be killed.

Hook function must accept arguments:
- `buffer-name' - the name of the edit buffer
- `pid'         - PID of the app that invoked Edit-with-Emacs")

(defvar awesome--caller-pid nil
  "Buffer local var to store the pid of the app that invoked the edit buffer.")

(defun awesome--find-buffer-by-name-prefix (prefix)
  "Find the first buffer with a name that has PREFIX."
  (let ((buffer-list (buffer-list)))
    (cl-find-if (lambda (buffer)
                  (string-prefix-p prefix (buffer-name buffer)))
                buffer-list)))

(defun awesome-edit-with-emacs (&optional pid title)
  "Edit anything with Emacs.
The caller is responsible for setting up the arguments.
PID - process ID of the caller app.
TITLE - title of the window."
  (run-hook-with-args 'awesome-before-edit-with-emacs-hook pid title)
  (let* ((buf-name (concat "* awesome-edit " title " *"))
         ;; hook functions later could modify the buffer name, you can't expect to always
         ;; find the buffer originating from the same app using its full-name, but prefix
         ;; search would work
         (buffer (or (awesome--find-buffer-by-name-prefix buf-name)
                     (get-buffer-create buf-name))))
    (unless (bound-and-true-p awesome-global-edit-with-emacs-mode)
      (awesome-global-edit-with-emacs-mode +1))
    (run-with-timer
     0.1 nil
     (lambda ()
       (with-current-buffer buffer
         (put 'awesome--caller-pid 'permanent-local t)
         (setq-local awesome--caller-pid pid)
         (clipboard-yank)
         (deactivate-mark)
         (awesome-edit-with-emacs-mode +1))
       (pop-to-buffer buffer)
       (run-hook-with-args 'awesome-edit-with-emacs-hook buf-name pid title)))))

(defun awesome-finish-edit-with-emacs ()
  "Invoke this command when done editing."
  (interactive)
  (let ((awesome-client (executable-find "awesome-client")))
    (unless awesome-client
      (user-error "Err. awesome-client not found"))
    (when (boundp 'awesome--caller-pid)
      (let ((pid (buffer-local-value 'awesome--caller-pid (current-buffer))))
        (run-hook-with-args
         'awesome-before-finish-edit-with-emacs-hook
         (buffer-name (current-buffer)) pid)
        (clipboard-kill-ring-save (point-min) (point-max))
        (if (one-window-p)
            (kill-buffer)
          (kill-buffer-and-window))
        (call-process-shell-command
         (format
          "%s 'require(\"emacs\").switch_to_client_and_paste(%s)'"
          awesome-client pid))))))

(defun awesome-switch-to-app (pid)
  "Switch to app with the given PID."
  (let ((awesome-client (executable-find "awesome-client")))
    (unless awesome-client (user-error "Err. awesome-client not found"))
    (call-process-shell-command
     (format
      "%s 'require(\"emacs\").switch_to_app(%s)'"
      awesome-client pid))))

(defun awesome-get-default-browser ()
  "Determine default browser class."
  (if-let* ((xdg-setttins (executable-find "xdg-settings"))
            (browser-class (thread-last
                             (shell-command-to-string
                              (concat xdg-setttins " get default-web-browser"))
                             (replace-regexp-in-string "\\(\n\\|\\.desktop\\)" ""))))
      browser-class
    (user-error "Err. xdg-settings failed to determine the browser, or xdotool not found")))

(defun awesome-switch-to-prev-app-and-type (&optional text)
  "Find previously focused app and type given TEXT.
Useful for sending text from Emacs to text input of the app."
  (let ((awesome-client (executable-find "awesome-client"))
        (script (format "cur_win_id=$(%1$s getactivewindow);
                         %1$s search --onlyvisible --class %2$s windowactivate --sync key --clearmodifiers ctrl+v sleep 0.1;
                         %1$s key --clearmodifiers Tab sleep 0.1;
                         %1$s windowactivate $cur_win_id"
                        (executable-find "xdotool")
                        (awesome-get-default-browser))))
    (unless awesome-client
      (user-error "Err. awesome-client not found"))
    (if (use-region-p)
        (clipboard-kill-ring-save (region-beginning) (region-end))
      (kill-new text))
    (call-process "/bin/sh" nil (current-buffer) nil "-c" script)))

(defun awesome-cancel-edit-with-emacs ()
  "Invoke it to cancel previous editing session."
  (interactive)
  (when (boundp 'awesome--caller-pid)
    (let ((pid (buffer-local-value 'awesome--caller-pid (current-buffer))))
      (run-hook-with-args
       'awesome-before-cancel-edit-with-emacs-hook
       (buffer-name (current-buffer)) pid)
      (kill-buffer-and-window)
      (awesome-switch-to-app pid))))

(defun awesome-edit-with-emacs-h (buffer-name pid title)
  (with-current-buffer (get-buffer buffer-name)
    ;; need to set a filename, otherwise things like lsp and grip
    ;; in that buffer won't work
    (let ((fname (thread-last
                   (format "%s_%s" pid title)
                   (replace-regexp-in-string "[<>\\|?*%/\":]" "_")
                   (format "/tmp/%s"))))
      (set-visited-file-name fname)
      ;; setting filename renames the buffer, we can't afford that,
      ;; otherwise running edit fn again won't find it
      (rename-buffer buffer-name))
    (set-buffer-modified-p nil)
    (markdown-mode)
    (awesome-edit-with-emacs-mode)
    (setq-local awesome--caller-pid pid)
    (evil-insert +1)))

(defun awesome--display-buffer-opposite-side ()
  "Return `left' or `right' based on current affinity of the frame position."
  (let* ((frame-geometry (frame-monitor-geometry))
         (frame-x (car (frame-position)))
         (monitor-width (nth 2 frame-geometry))
         (left-side (- frame-x (car frame-geometry))))
    ;; we want window appear on the right side, when Emacs frame is on the left and vice-versa
    (if (< (/ monitor-width 3) left-side)
        'left
      'right)))

(defun awesome--set-display-buffer-alist-h (_ _)
  (let ((pattern "\\* awesome-edit.*"))
    ;; remove previous value
    (setq display-buffer-alist (delq (assoc pattern display-buffer-alist) display-buffer-alist))
    (add-to-list
     'display-buffer-alist
     `(,pattern
       (display-buffer-reuse-window
        display-buffer-in-direction)
       (direction . ,(awesome--display-buffer-opposite-side))
       (window . root)
       (window-width . 0.30)))))

(defun awesome-before-finish-edit-with-emacs-h (bufname pid)
  (with-current-buffer bufname
    (set-buffer-modified-p nil)))

(add-hook 'awesome-before-edit-with-emacs-hook #'awesome--set-display-buffer-alist-h)
(add-hook 'awesome-edit-with-emacs-hook #'awesome-edit-with-emacs-h)
(add-hook 'awesome-before-finish-edit-with-emacs-hook #'awesome-before-finish-edit-with-emacs-h)

(provide 'awesome-wm-helpers)
;;; awesome-wm-helpers.el ends here
