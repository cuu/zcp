
(println (main-args) )
(setq create nil)

(dolist (x (main-args) (if (= x "-r") (begin (setq create true) true)) ))
	
(println create)
	
(define (test str)
	(setq str_lst (parse str " "))
	(setq ret "")
	(dolist (x str_lst)
		(setq tmp_str (slice x 0 2)) ;; force the input to be XX
		(extend ret (char (int tmp_str 0 16)))
	)

	ret	
)

(exit)

