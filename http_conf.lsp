;; httpd-conf.lsp
;;
;; filter and translate HTTP requests for newLISP
;; -c or -http server modes
;; reject query commands using CGI with .exe files


;(load "cgi.lsp")

;; instead ,I can start stty set the serial port

(command-event (fn (s)
    (local (request)
        (if (find "?" s) ; is this a query
            (begin
                (set 'request (first (parse s "?")))
                ; discover illegal extension in queries
                (if (ends-with request ".exe") 
                    (set 'request "GET /errorpage.html")
                    (set 'request s)))
            (set 'request s))
        request)
))

