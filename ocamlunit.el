;;; ocamlunit.el --- `dune test' runner -*- lexical-binding: t -*-

;; Copyright (C) 2020 Manfred Bergmann.

;; Author: Manfred Bergmann <manfred.bergmann@me.com>
;; URL: http://github.com/mdbergmann/ocamlunit
;; Version: 0.1
;; Keywords: processes ocaml ounit2 ounit
;; Package-Requires: ((emacs "24.3"))

;; This program is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Provides commands to run tests that are run with `dune test'.

;;; Code:

(make-variable-buffer-local
 (defvar ocamlunit-mode))

(defvar ocamlunit-test-failure-hook nil)
(defvar ocamlunit-test-success-hook nil)

(defvar-local *ocamlunit-output-buf-name* "OCamlUnit output")

(defun ocamlunit-execute-test ()
  "Call OCaml test via 'dune'."
  (let* ((test-cmd-args (list "opam" "exec" "dune" "test"))
         (call-args
          (append (list (car test-cmd-args) nil *ocamlunit-output-buf-name* t)
                  (cdr test-cmd-args))))
    (message "calling: %s" call-args)
    (let* ((default-directory (locate-dominating-file default-directory "dune-project"))
           (call-result (apply 'call-process call-args)))
      (message "cwd: %s" default-directory)
      (message "test call result: %s" call-result)
      call-result)))

(defun ocamlunit-handle-successful-test-result ()
  "Do some stuff when the test ran OK."
  (message "OCAMLUNIT: running commit hook.")
  (run-hooks 'ocamlunit-test-success-hook)
  (message "%s" (propertize "Tests OK" 'face '(:foreground "green"))))

(defun ocamlunit-handle-unsuccessful-test-result ()
  "Do some stuff when the test ran NOK."
  (message "OCAMLUNIT: running revert hook.")
  (run-hooks 'ocamlunit-test-failure-hook)
  (message "%s" (propertize "Tests failed!" 'face '(:foreground "red"))))

(defun ocamlunit-after-save-action ()
  "Execute the test."
  (message "ocamlunit: after save action from in: %s" major-mode)

  (with-current-buffer *ocamlunit-output-buf-name*
    (erase-buffer))
  
  (let ((test-result (cond
                      ((string-equal "tuareg-mode" major-mode)
                       (ocamlunit-execute-test))
                      (t (progn (message "Unknown mode!")
                                nil)))))

    (unless (eq test-result nil)
      (if (= test-result 0)
          (ocamlunit-handle-successful-test-result)
        (ocamlunit-handle-unsuccessful-test-result)))))

(defun ocamlunit-execute ()
  "Save buffers and execute dune to run the test."
  (interactive)
  (save-buffer)
  (save-some-buffers)
  (ocamlunit-after-save-action))

(define-minor-mode ocamlunit-mode
  "OCaml - OUnit/OUnit2 test runner. Actually `dune test' is run.
So this might catch more tests than only OUnit"
  :lighter " OCamlUnit"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c t") 'ocamlunit-execute)
            map))

(provide 'ocamlunit)
;;; ocamlunit.el ends here
