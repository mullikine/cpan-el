;;; cpan.el -- Drive CPAN from Emacs

;; Copyright (c) 2016, Richard Loveland

;; Author: Richard Loveland <r@rmloveland.com>

;; This file is NOT part of GNU Emacs.

;; Commentary:

;; This code was modified from the built-in shell.el.  There is
;; probably a lot more work needed to get this up to snuff, but it
;; basically "works" on Windows, and "should" work on Linux/Mac.

;; To use it, run `M-x cpan`

(require 'comint)

(defgroup cpan nil
  "Running CPAN from within an Emacs buffer."
  :group 'processes)

(defcustom cpan-prompt-pattern "cpan\> "
  ""
  :type 'regexp
  :group 'cpan)

(defvar cpan-file-name "cpan")

(defvar cpan-mode-map
  (let ((map (nconc (make-sparse-keymap) comint-mode-map)))
    (define-key map "\C-c\C-f" 'cpan-forward-command)
    (define-key map "\C-c\C-b" 'cpan-backward-command)
    map))

(defcustom cpan-mode-hook '()
  "Hook for customizing CPAN mode."
  :type 'hook
  :group 'cpan)

(defvar cpan-font-lock-keywords
  '(("[ \t]\\([+-][^ \t\n]+\\)" 1 font-lock-comment-face)
    ("^[^ \t\n]+:.*" . font-lock-string-face)
    ("^\\[[1-9][0-9]*\\]" . font-lock-string-face))
  "Additional expressions to highlight in CPAN mode.")

(defcustom explicit-cpan-file-name "cpan"
  "If non-nil, is file name to use for the CPAN client."
  :type '(choice (const :tag "None" nil) file)
  :group 'cpan)

(define-derived-mode cpan-mode comint-mode "CPAN"
  ""
  (setq comint-prompt-regexp cpan-prompt-pattern)
  (set (make-local-variable 'paragraph-separate) "\\'")
  (set (make-local-variable 'paragraph-start) comint-prompt-regexp)
  (set (make-local-variable 'font-lock-defaults) '(cpan-font-lock-keywords t)))

(defun cpan-write-history-on-exit (process event)
  "Called when the CPAN process is stopped.

Writes the input history to a history file
`comint-input-ring-file-name' using `comint-write-input-ring'
and inserts a short message in the CPAN buffer.

This function is a sentinel watching the CPAN interpreter process.
Sentinels will always get the two parameters PROCESS and EVENT."
  ;; Write history.
  (comint-write-input-ring)
  (let ((buf (process-buffer process)))
    (when (buffer-live-p buf)
      (with-current-buffer buf
        (insert (format "\nProcess %s %s\n" process event))))))

;;;###autoload
(defun cpan (&optional buffer)
  "Run an inferior cpan, with I/O through BUFFER (which defaults to `*cpan*').
Interactively, a prefix arg means to prompt for BUFFER.
If `default-directory' is a remote file name, it is also prompted
to change if called with a prefix arg.

If BUFFER exists but cpan process is not running, make new cpan.
If BUFFER exists and cpan process is running, just switch to BUFFER.

Program used comes from variable `explicit-cpan-file-name',
or (if that is nil) from `cpan-file-name'.

The buffer is put in CPAN mode.  See `cpan-mode'.

See also the variable `cpan-prompt-pattern'.

\(Type \\[describe-mode] in the CPAN buffer for a list of commands.)"
  (interactive
   (list
    (and current-prefix-arg
	 (prog1
	     (read-buffer "CPAN buffer: "
			  ;; If the current buffer is an inactive
			  ;; CPAN buffer, use it as the default.
			  (if (and (eq major-mode 'cpan-mode)
				   (null (get-buffer-process (current-buffer))))
			      (buffer-name)
			    (generate-new-buffer-name "*cpan*")))
	   (if (file-remote-p default-directory)
	       ;; It must be possible to declare a local default-directory.
           ;; FIXME: This can't be right: it changes the default-directory
           ;; of the current-buffer rather than of the *cpan* buffer.
	       (setq default-directory
		     (expand-file-name
		      (read-directory-name
		       "Default directory: " default-directory default-directory
		       t nil))))))))
  (setq buffer (if (or buffer (not (derived-mode-p 'cpan-mode))
                       (comint-check-proc (current-buffer)))
                   (get-buffer-create (or buffer "*cpan*"))
                 ;; If the current buffer is a dead CPAN buffer, use it.
                 (current-buffer)))

  ;; The buffer's window must be correctly set when we call comint (so
  ;; that comint sets the COLUMNS env var properly).
  (pop-to-buffer buffer)
  (unless (comint-check-proc buffer)
    (let* ((prog (or explicit-cpan-file-name cpan-file-name))
           (name (file-name-nondirectory prog))
           (process-environment
            ;; We must munge the process environment on Windows to
            ;; avoid using the cmdproxy.exe that ships with Emacs,
            ;; since it breaks the `cpan` command.
            (if (eq system-type 'windows-nt)
                (mapcar (lambda (x) (if (string-match-p "^SHELL=C:" x) "SHELL=C:\\WINDOWS\\system32\\cmd.exe" x)) process-environment)
              process-environment)))
      (make-comint-in-buffer "cpan" buffer prog)
      (cpan-mode)))
  buffer)

(provide 'cpan)

;;; cpan.el ends here
