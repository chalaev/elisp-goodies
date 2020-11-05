;; -*- mode: Emacs-Lisp;  lexical-binding: t; -*-
;; generated from https://notabug.org/shalaev/elisp-goodies/src/master/goodies.org
(defmacro case* (expr test &rest cases)
  "case with arbitrary test function"
  (let ((v (gensym "v")))
    `(let ((,v ,expr))
       (cond
        ,@(mapcar #'(lambda (VR)
(let ((val (car VR)) (rest (cdr VR)))
  (if (eql val 'otherwise)
      `(t ,@rest)
    `((,test ,v ,val) ,@rest))))
 cases)))))

(defmacro when-let (vars &rest body)
  "when with let using stndard let-notation"
  (if (caar vars)
  `(let ((,(caar vars) ,(cadar vars)))
     ,(if (cdr vars)
	  `(when ,(caar vars)
	     ,(macroexpand-1 `(when-let ,(cdr vars) ,@body)))
	(append `(when ,(caar vars)) body)))
  (if (cdr vars)
      `(when ,(cadar vars)
	     ,(macroexpand-1 `(when-let ,(cdr vars) ,@body)))
    (append `(when ,(cadar vars)) body))))

(defmacro when-set (vars &rest body)
  "when-let using global variable instead of defining local one"
(let ((GV (gensym)))
  `(let ((,GV ,(cadar vars)))
     ,(if (cdr vars)
	  `(when ,GV
              (setf ,(caar vars) ,GV)
	     ,(macroexpand-1 `(when-set ,(cdr vars) ,@body)))
	(append `(when ,GV (setf ,(caar vars) ,GV)) body)))))

(defmacro unless-set (vars &rest body)
  "unless-let using global variable instead of defining local one"
(let ((GV (gensym)))
  `(let ((,GV ,(cadar vars)))
     ,(if (cdr vars)
	  `(if ,GV
              (setf ,(caar vars) ,GV)
	     ,(macroexpand-1 `(unless-set ,(cdr vars) ,@body)))
	(append `(if ,GV (setf ,(caar vars) ,GV)) body)))))

(defmacro if-let (vars &rest body)
  "if with let using stndard let-notation"
  (let ((if-true (gensym "it")) (result (gensym "r")))
    `(let (,if-true ,result)
       (when-let ,vars
		 (setf ,if-true t)
		 (setf ,result ,(car body)))
       (if ,if-true
	   ,result
	 ,@(cdr body)))))

(defmacro ifn-let (vars &rest body)
  `(if-let ,vars
      ,(cons 'progn (cdr body))
    ,(car body)))

(defmacro ifn-set (vars &rest body)
  `(if-set ,vars
      ,(cons 'progn (cdr body))
    ,(car body)))

(defmacro if-set (vars &rest body)
  (let ((if-true (gensym "it")) (result (gensym "r")))
    `(let (,if-true ,result)
       (setf ,result (when-set ,vars
		  (setf ,if-true t)
		  ,(car body)))
       (if ,if-true ,result
	 ,@(cdr body)))))

(defmacro cond-let (&rest conds)
  "cond with let"
  (let ((c (car conds)) (r (cdr conds)))
    (if (equal (car c) 'otherwise) (cons 'progn (cdr c))
    (if r
	`(if-let ,(car c) ,(cons 'progn (cdr c)) ,(macroexpand-1 `(cond-let ,@r)))
	`(when-let ,(car c) ,@(cdr c))))))

(defmacro needs (vardefs &rest body)
  "unifying when-let and if-let"
  (let ((vardef (car vardefs)))
    (if (and (listp vardef) (not (or (special-form-p (car vardef)) (functionp (car vardef)) (macrop (car vardef)))))
    `(let ((,(car vardef) ,(cadr vardef)))
       ,(if (cddr vardef)
	    `(if ,(car vardef)
		,(if (cdr vardefs)
		     (macroexpand-1 `(needs ,(cdr vardefs) ,@body))
		   `(progn ,@body))
	       ,(car (cddr vardef)))
	  (append `(when ,(car vardef))
		  (if (cdr vardefs)
		      (list (macroexpand-1 `(needs ,(cdr vardefs) ,@body)))
		    body))))
    (append `(when ,vardef)
		  (if (cdr vardefs)
		      (list (macroexpand-1 `(needs ,(cdr vardefs) ,@body)))
		    body)))))

(defmacro first2(ll) `(firstN ,ll 2))
(defmacro needs-set (vardefs &rest body)
  "needs with 'let' being replaced with 'setf'"
  (let ((vardef (car vardefs)))
    (if (cddr vardef)
      `(if-set (,(first2 vardef))
	  ,(if (cdr vardefs)
	       (macroexpand-1 `(needs-set ,(cdr vardefs) ,@body))
	     (cons 'progn body))
	  ,(caddr vardef))
      `(when-set (,(car vardefs))
	   ,(if (cdr vardefs)
	       (macroexpand-1 `(needs-set ,(cdr vardefs) ,@body))
	      (cons 'progn body))))))

(defmacro directory-lock(locked-dir by &rest body)
(let ((LD (gensym "ld")) (lock-file (gensym "lf")) (mkdir (gensym "md")) (result (gensym "r")) (unlock (gensym "u")))
`(let* ((,LD (file-name-as-directory ,locked-dir))
        (,lock-file (concat ,LD "by"))
        (,mkdir (safe-mkdir ,LD)))
  (ifn (car ,mkdir) (cons nil (cons :lock ,mkdir))
  (write-region ,by nil ,lock-file)
  (let ((,result (progn ,@body)))
    (if-let ((,unlock (and (safe-delete-file ,lock-file) (safe-delete-dir ,LD))))
      (cons t ,result)
      (cons nil (cons :unlock (cons ,unlock ,result)))))))))

(defmacro ifn (test ifnot &rest ifyes)
`(if (not ,test) ,ifnot ,@ifyes))
