#!/bin/env newlisp

(load "cgi.lsp")

(setq server "127.0.0.1")  (setq port 4711)  ;;; for tcp and serial server
(print "Access-Control-Allow-Origin:*\r\n")
(print "Content-type: text/html\r\n\r\n")


;(sleep 3000)

(if-not (nil? (CGI:get "cmd"))
	(begin
		(setq evl_str (format "(net-eval \"%s\" %d \"(test \\\"%s\\\" 500 )\" 4000)" 
				server port (CGI:get "cmd")))
	
		(print (eval-string evl_str))
	)
)



(if-not (nil? (CGI:get "test"))
    (begin
        (print "Test" (CGI:get "test"))
    )
)


