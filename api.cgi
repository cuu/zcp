#!/bin/env newlisp

(load "util.lsp")
(load "cgi.lsp")
(load "json.lsp")

;;(setq server "127.0.0.1")  (setq port 4711)

(print "Content-type: text/html;charset=utf8\r\n\r\n")


;(sleep 3000)

(if-not (nil? (CGI:get "count"))
	(begin
		(load "CKV.lsp")
		(setq ccount 0)
		(dolist (x (CKV))
				(if-not (nil? (nth 0 x))
					(inc ccount)
				)
		)	
		(print ccount)
		(exit)
	)
)

(if-not (nil? (CGI:get "child"))
	(begin
		(setq cn (int (CGI:get "child")))
		(if (nil? cn) (exit))
		(setq num 0)
		(load "CKV.lsp")
		(load "newlisp-projects/nldb/nldb.lsp");; nldb database support
		(load "tables.nldb")
		(dolist (x (CKV)
				(if (= cn num)
					(begin
						(setq _til (nldb:select-rows 'alias '(= mac (nth 0 (nth 1 x)))))
						(if-not (empty? _til)
							(begin
								(print (Json:lisp->json	  (list x (nth 1 (nth 0 _til))   (nth 2 (nth 0 _til)) ) ))
								
							)
							(begin
								(print (Json:lisp->json  (list x "")))
							)
						)
					true
					) )) (inc num))
		(exit)
	)
)

(if-not (nil? (CGI:get "allchild"))
    (begin
        (load "CKV.lsp")
		(load "newlisp-projects/nldb/nldb.lsp")
		(load "tables.nldb")
		(setq ret '() )
        (dolist (x (CKV))
						(setq _til (nldb:select-rows 'alias '(= mac (nth 0 (nth 1 x)))))
						(if-not (empty? _til)
							(begin
	                    		(push (list x (nth 1 (nth 0 _til)) (nth 2 (nth 0 _til))   ) ret -1 )
	                    		
	                    	)
							(push (list x "") ret -1 )
						)

        )

		(print (Json:lisp->json ret))
        (exit)
    )
)


(if-not (nil? (CGI:get "allnodes"))
    (begin
        (load "CKV.lsp")
		(load "NICKS.lsp")
        (setq ret '() )
        (dolist (x (CKV))
						(setq short_addr (nth 0 x))
						(setq mac_addr (nth 0 (nth 1 x)))

;						(print (nth 0 (nth 1 x)) "<br />")
;						(print _til "<br />")
;                        (if-not (empty? _til)
;                            (begin
;                                (push (list x (nth 1 (nth 0 _til)) (nth 2 (nth 0 _til))   ) ret -1 )
;    
;                            )   
;                            (push (list x "") ret -1 )
;                        )

				(print (nth 0 (NICKS mac_addr)) (nth 1 (NICKS mac_addr)) "|"  "d8 " short_addr " ed fc 02" "\n")
        )   
;       (print (Json:lisp->json ret))
        (exit)
    )   
)







(print "Web api interface 1.0")


