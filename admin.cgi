#!/usr/bin/newlisp

(load "cgi.lsp")

(print "Content-type: text/html\r\n\r\n")

(if-not (file? "NICKS.lsp")
	(begin
		(print "Database not corrupt<br />")
		(exit)
	)
)
		
(load "CKV.lsp")
(load "NICKS.lsp")


(if-not (nil? (CGI:get "cmd"))
    (begin
			(setq title (CGI:get "cmd"))
			(setq vmac (CGI:get "mac"))
			(setq room (CGI:get "room"))
			
			(if  (not (nil? vmac))
				(begin	
;					(setq mac_here nil)
;					(dolist (x (CKV) (if (= vmac (nth 0 (nth 1 x))) (begin (setq mac_here true) true))  ) )
					(setq mac_here (NICKS vmac))			
					(if (true? mac_here)
						(begin					
;							(if-not (nil? (NICKS vmac))
;								(begin	
									(NICKS vmac (list title room))
									(save "NICKS.lsp" 'NICKS)
									(print "set ok")
									(exit)
;								)
;							)
						)
						(print "mac address not ok") (exit)
					)
				)
				(print "input error") (exit)
			)
			(exit)
    )

)

(CGI:put-page "two.html")


