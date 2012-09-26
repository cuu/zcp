(context 'CGI)

(define (put-page file-name , page start end)
    (set 'page (read-file file-name))
    (set 'start (find "<%" page))
    (set 'end (find "%>" page))
    (while (and start end)
        (print (slice page 0 start))
        (eval-string (slice page (+ start 2) (- end start 2)) MAIN)
        (set 'page (slice page (+ end 2)))
        (set 'start (find "<%" page))
        (set 'end (find "%>" page)))
    (print page))


(define (url-translate str)
   (replace "+" str " ")
   (replace "%([0-9A-F][0-9A-F])" str (format "%c" (int (append "0x" $1))) 1))


 
(define (get-vars input , var value var-value)
    (set 'vars (parse input "&"))
    (dolist (elmnt vars) 
	(if (find "=" elmnt) 
	    (begin
              (set 'var (first (parse elmnt "=")))
              (set 'value ((+ (find "=" elmnt) 1) elmnt)))
	    (begin
	      (set 'var elmnt)
	      (set 'value "")))
	(push (list var (url-translate value)) var-value))
    var-value) ; no necessary after v.9.9.5


; get QUERY_STRING parameters from GET method if present
;
(set 'params (env "QUERY_STRING"))
(if (not params) (set 'params ""))
(if params
	(set 'params (get-vars params)))

; get POST data if present, use CONTENT_LENGTH variable
; if available
(if (env "CONTENT_LENGTH")
	(when (= (env "REQUEST_METHOD") "POST")
  		(read (device) post-data (int (env "CONTENT_LENGTH")))
  		(set 'params (get-vars post-data)))
	(begin
		(set 'inline (read-line))
		(when inline 
			(set 'params (get-vars inline)))
	)
)
 
(if (not params) (set 'params '()))


; get cookies
;
(if (and (env "HTTP_COOKIE") (not (empty? (env "HTTP_COOKIE"))))
    (dolist (elmnt (parse (env "HTTP_COOKIE") ";"))
		(set 'var (trim (first (parse elmnt "="))))
		(set 'value (slice elmnt (+ 1 (find "=" elmnt))))
		(push (list var value) cookies))
    (set 'cookies '()))


(define (set-cookie var value domain path)
    (set 'value (string value))
    (print (format "Set-Cookie: %s=%s; domain=.%s; path=%s;\n" var value domain path)))



(define (get-cookie keystr)
	(lookup keystr cookies) )


(define (get keystr)
   (lookup keystr params))



(context 'MAIN)

; eof ;
