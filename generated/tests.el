;; -*- mode: Emacs-Lisp;  lexical-binding: t; -*-
(declaim (notinline id))
(defun id(x) x)

(ert-deftest s-find()
  (should (equal '(3 4) (s-find 4 '((1 2) (3 4) (5 6)) #'cadr)))
  (should (= 3 (s-find 3 '(1 2 3 4 5))))
(let ((cumbersome-list '(141 142 143 144)))
  (should (= (s-find (* 12 12) cumbersome-list nil #'=) 144))
  (should (= (s-find (/ 144 2) cumbersome-list nil #'(lambda(x y) (= (* 2 x) y))) 144))
  (should (= (s-find 12 cumbersome-list nil #'(lambda(x y) (= (* x x) y))) 144)))
(let ((cumbersome-list '((141 142) (143 144))))
  (should (equal (s-find 12 cumbersome-list #'cadr #'(lambda(x y) (= y (* x x)))) '(143 144)))))

(ert-deftest select()
(let ((test-list  '(4 22 11 33 12 24 77)))
  (should (not (car (select test-list #'zerop))))
  (should (equal '(11 33 77) (car (select test-list #'oddp))))
  (should (equal '(4 22 12 24) (car (select test-list #'evenp))))))

(ert-deftest without()
(let ((test-list  '(4 22 11 33 12 24 77)))
  (should (equal '(4 22 11 33 77) (without test-list 12 24)))))

(ert-deftest drop()
(let ((test-list  '(4 22 11 33 12 24 77)))
  (drop test-list 12 24)
  (should (equal '(4 22 11 33 77) test-list))))

(ert-deftest define-vars()
(should(string= "(progn (defvar a nil) (defvar b nil))" (string-from-macro '(define-vars (a b)))))
(should(string= "(progn (defvar a 1) (defvar b nil) (defvar c 2))" (string-from-macro '(define-vars ((a 1) b (c 2)))))))

(ert-deftest perms-from-str()
  (should (= 432 (perms-from-str "-rw-rw----"))))

(ert-deftest perms-to-str()
  (should (string= "rw-rw-rwx" (perms-to-str #o667))))

(ert-deftest end-push()
(should (equal '(1)
(let (container)
  (end-push 1 container)
  container)))
(should (equal '(1 2)
(let (container)
  (end-push 1 container)
  (end-push 2 container)
  container))))

(ert-deftest land()
  (should (land '(t t t t 1 2)))
  (should (not (land '(t t t nil 1 2)))))
