;;; gnus-unread.el -- Gnus unread in mode line -*- lexical-binding: t -*-

;; Copyright (C) 2023  Free Software Foundation, Inc.

;; Author: Daniel Pettersson
;; Maintainer: Daniel Pettersson <daniel@dpettersson.net>
;; Created: 2023
;; License: GPL-3.0-or-later
;; Version: 0.0.1
;; Homepage: https://github.com/svaante/gnus-unread
;; Package-Requires: ((emacs "29.1"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Mode-line notification for displaying unread `gnus' groups.
;; Enable with `gnus-unread-mode'

;;; Code:

(require 'gnus)
(require 'time)
(require 'cl-macs)

(defgroup gnus-unread nil
  "Mode line notifications for `gnus'."
  :prefix "gnus-"
  :group 'mail)

(defcustom gnus-unread-group ".*"
  "Regex for matching group(s) name."
  :type 'regexp)

(defcustom gnus-unread-forms
  '((unless (zerop unread)
      (propertize display-time-mail-string
	          'display display-time-mail-icon
                  'help-echo (format "%s unread in %s" unread gnus-unread-group)
                  'face 'gnus-unread-face))
    " ")
  "Forms evaled to construct `gnus-unread-mode-line'."
  :type '(repeat sexp))

(defface gnus-unread-face '((t :inherit mode-line-emphasis))
  "Face used for mode-line notification.")

(defvar gnus-unread-mode-line nil)
(put 'gnus-unread-mode-line 'risky-local-variable t)
(add-to-list 'mode-line-misc-info 'gnus-unread-mode-line t)

(defun gnus-unread-mode-line-update ()
  "Update gnus unread `gnus-unread-mode-line'."
  (with-no-warnings
    (defvar unread))
  (setq gnus-unread-mode-line
        (let* ((unread
                (cl-loop for group in gnus-group-list
                         when (string-match-p gnus-unread-group group)
                         sum (or (gnus-group-unread group) 0))))
          (mapconcat 'eval gnus-unread-forms ""))))

(defvar gnus-unread--hooks
  '(gnus-group-update-hook
    gnus-group-update-hook
    gnus-summary-update-hook
    gnus-group-update-group-hook
    gnus-after-getting-new-news-hook))

(define-minor-mode gnus-unread-mode
  "Show unread `gnus' messages in mode line."
  :global t
  :lighter ""
  (cond
   (gnus-unread-mode
    (dolist (hook gnus-unread--hooks)
      (add-hook hook #'gnus-unread-mode-line-update)))
   ((dolist (hook gnus-unread--hooks)
      (remove-hook hook #'gnus-unread-mode-line-update))
    (setq gnus-unread-mode-line nil))))

(provide 'gnus-unread)
;;; gnus-unread.el ends here
