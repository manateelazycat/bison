;;; bision.el --- Editing bision source code.

;; Filename: bision.el
;; Description: Editing bision source code.
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2018, Andy Stewart, all rights reserved.
;; Created: 2018-10-06 11:59:10
;; Version: 0.1
;; Last-Updated: 2018-10-06 11:59:10
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/bision.el
;; Keywords:
;; Compatibility: GNU Emacs 27.0.50
;;
;; Features that might be required by this library:
;;
;;
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Editing bision source code.
;;

;;; Installation:
;;
;; Put bision.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'bision)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET bision RET
;;

;;; Change log:
;;
;; 2018/10/06
;;      * First released.
;;

;;; Acknowledgements:
;;
;;
;;

;;; TODO
;;
;;
;;

;;; Require
(require 'derived)


;;; Code:
(defgroup bision nil
  "Editing bision files."
  :group 'bision)

(defface bision-font-lock-declare-delimiter-face
  '((t (:foreground "gray35")))
  "Color for declare delimiter."
  :group 'bision)

(defface bision-font-lock-pattern-delimiter-face
  '((t (:foreground "gray35")))
  "Color for pattern delimiter."
  :group 'bision)

(defface bision-font-lock-rule-face
  '((t (:foreground "Purple")))
  "Color for rule."
  :group 'bision)

(defcustom bision-mode-hook '()
  "bision mode hook."
  :type 'hook
  :group 'bision)

(defcustom bison-declarers
  '("%union" "%token" "%type" "%left" "%right" "%nonassoc")
  "commands which can declare a token or state type"
  :type 'list
  :group 'bison)

(define-derived-mode bision-mode c-mode "Bision"
  "Major mode for editing bision files"
  ;; Try to set the indentation correctly.
  (setq-default c-basic-offset 4)
  (make-variable-buffer-local 'c-basic-offset)
  (c-set-offset 'knr-argdecl-intro 0)
  (make-variable-buffer-local 'c-offsets-alist)

  ;; Remove auto and hungry anything.
  (c-toggle-auto-hungry-state -1)
  (c-toggle-auto-state -1)
  (c-toggle-hungry-state -1)

  ;; Load keymap.
  (use-local-map bision-mode-map)
  (define-key bision-mode-map [tab] 'bision-indent-command)

  ;; Set comment strings.
  (setq comment-start "/*"
        comment-end "*/")

  ;; Highlight keywords.
  (bision-highlight-keywords)

  ;; Run hooks.
  (run-hooks 'bision-mode-hook)
  )

(defun bision-highlight-keywords ()
  "Highlight keywords."
  ;; Add keywords for highlight.
  (font-lock-add-keywords
   nil
   '(
     ("\\(^\\(%{\\|%}\\)\\)" 1 'bision-font-lock-declare-delimiter-face)
     ("\\(^%%\\)" 1 'bision-font-lock-pattern-delimiter-face)
     ("^\\(.*\\):.*\n|" 1 'bision-font-lock-rule-face)
     ((concat "^\\(" (regexp-opt bison-declarers) "\\)") 1 'font-lock-keyword-face)
     ))
  (set (make-local-variable 'font-lock-keywords-only) t)
  (font-lock-mode 1))

(defun bision-indent-command (&optional arg)
  (interactive "P")
  (if (equal arg '(4))
      (c-indent-command)
    (save-excursion
      (beginning-of-line)
      (if (looking-at "^\\s-*\\(%}\\|%{\\|%%\\)\\s-*")
          (let (start end)
            (setq start (point))
            (end-of-line)
            (setq end (point))
            (kill-region start
                         (save-excursion
                           (beginning-of-line)
                           (if (search-forward-regexp "\\s-*" end t)
                               (point)
                             start)
                           )))
        (c-indent-command)))))

(provide 'bision)

;;; bision.el ends here
