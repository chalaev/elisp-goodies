(defvar *log-level* 0)

(defvar *log-buffer* nil)

(let (last-FLD); saves last day printed to the log file
(defun log-flush()
  "save log messages to file for debugging"
  (when (= 0 *log-level*)
    (with-temp-buffer
      (let ((today-str (format-time-string "%04Y-%02m-%02d" (current-time))))
	(unless (string= today-str last-FLD)
	  (setf last-FLD today-str)
	  (insert today-str) (newline))
	(dolist (msg (reverse *log-buffer*))
	  (insert msg) (newline)))
      (append-to-file (point-min) (point-max) (concat emacs-d "elisp.log")))
    (setf *log-buffer* nil))))

(defun clog(level fstr &rest args)
  "simple logging function" ; level is one of → :debug :info :warning :error
(let ((log-push (lambda(msg)
  (push msg *log-buffer*)
  (when (< 30 (length *log-buffer*)) (log-flush)))))

(when (<= *log-level* (or (pos level '(:debug :info :warning :error)) 0))
  (let ((log-msg
	   (cons
	    (concat "%s " (format-time-string "%H:%M:%S "
(apply 'encode-time (butlast (decode-time (current-time)) 3)))
		    fstr)
	    (cons (symbol-name level) args))))
      (funcall log-push (apply #'format log-msg))
      (apply #'message log-msg)))
 nil))

(defun on-emacs-exit()
  (clog :debug "flushing comments before quiting emacs")
  (log-flush))

(add-hook 'kill-emacs-hook 'on-emacs-exit)
