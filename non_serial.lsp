(constant 'SIGINT 2) ;; on unix system
(constant 'RMAX 128) ;; read max 

;(trace true) 

(define (get-pid) (sys-info 6))

(setq create nil)

(dolist (x (main-args) (if (= x "-r") (begin (setq create true) true)) ))

;;https://github.com/cormullion/newlisp-projects
(load "newlisp-projects/nldb/nldb.lsp");; nldb database support
(load "func.lsp") ;; some predefined functions

;(import "libc.so.6"  "select")

(define (myexit n)
;;    (abort)
    (newlisp_exit n)
)

(define (assert str)
	(write 1 str)
)

(constant 'newlisp_exit exit)
(constant 'exit myexit)

(setq stop_flag 0)

(if (or (= ostype "Win32") (= ostype "Cygwin"))
	(setq dev "/dev/ttyS10") ;; on win32 with cygwin!
	(setq dev "/dev/ttyUSB0") ;; all linux platform
)

(if-not (file? dev)
	(begin
		(println "no tty found")
		(exit 0)
	)
)
;;;;
(define (init_kv)
	(new Tree 'CKV)
	(save "CKV.lsp" 'CKV);;; CUU KEY-VALUE database	
)

(define (init_io8) ;; init io opera database
	(new Tree 'IO8)
	(save "IO8.lsp" 'IO8)
)

(define (init_errors)
	(nldb:create-table 'errors '(saddr error_type timestamp)) ;;; error_type forexample 1: adc error 2:.... 
	(nldb:save-db "errors.lsp")
)

(define (init_nicks);; for nick names tables,alias names,etc
	(new Tree 'NICKS)
	(save "NICKS.lsp" 'NICKS)
)

(define (init_main_error) ;; simple just check if the zigbee module is working well
	(new Tree 'MAIN_ERROR)
	(save "main_error.lsp" 'MAIN_ERROR)
)

(if-not (file? "CKV.lsp")
	(init_kv);;init databases
;	(load "addrs.nldb")
)
(if-not (file? "IO8.lsp")
	(init_io8)
)

(if-not (file? "errors.lsp")
	(init_errors);;; errors.lsp store error reports
)

(if-not (file? "NICKS.lsp")
		(init_nicks)
)

(if-not (file? "main_error.lsp")
	(init_main_error)
)

(load "CKV.lsp")
(load "IO8.lsp")
(load "errors.lsp") ;; log for errors
(load "main_error.lsp")
(load "NICKS.lsp")
;;;;

(set 'talk (share))     (share talk 0)
(set 'content (share))  (share content "")

(setq cur_par "0")

(setq rw_iner 200)

(setq baud 38400)

(if (or (= ostype "Win32") (= ostype "Cygwin"))
	(setq cmd (string "stty -F " dev " cs8 " baud " -ixon -icanon  min 0 time 30") )
	(setq cmd (string "stty -F " dev " cs8 " baud " ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke noflsh -ixon -crtscts min 0 time 30"))
)

;; time 30 == 3 secs ,read timeout 
;(println cmd)
(exec cmd)
(sleep 3000)
;(setq usbdev (open dev "u"))
;(close usbdev)
(println dev " ready")


;(setq rusbdev (open dev "r" "n"))
;(if (nil? rusbdev)
;	(begin
;		(println "open " dev " read failed")
;		(exit rusbdev)
;	)
;)

(setq wusbdev (open dev "w" "n"))
(if (nil? wusbdev)
	(begin
		(println "open " dev " for write failed")
		(exit wusbdev)
	)
)

(define (read_serial read_fd)
    (setq ret "read has no return ")
    (setq nr 0)

    (setq nr (read read_fd buff (peek read_fd)))
	
;	(println "nr " nr)	
	(if (> nr 0)
		(begin
			(setq ret "")
			(share talk 1) ;; has return
;			(println "set talk to " (share talk))
		)
	)	
    (while (> nr 0)
;;       		(while (not (net-select read_fd "read" 10000) )) 

            (setq upk_str (dup "b "  nr ))
            (setq upk_lst (unpack upk_str buff))

            (dolist (y upk_lst)
                (extend ret (format "%x " y))
            )
			(setq nr (read read_fd buff (peek read_fd)))
;;			(chop ret 1)
    )

;;	(chop ret 1)
	ret
)

(define (run_serial query len timeout)
	(setq ret "")
	(share content "")
	(setq nw (write wusbdev query  len))
;;	(let tmp_lst nil)

	(println "into run_serial " query)
	(sleep timeout);; give enough time for reading data to share mem
;;	(println "sleeped" timeout)
	(if-not (nil? nw)
		(begin
;			(println (share talk))	
			(if (= (share talk) 1) ;; read process has something to return
					(begin
						(share talk 0)
						
						(setq ret (share content))
						;(println "1st " (share content))
						(if (and (= (nth 0 (share content)) "c" ) (= (nth 1 (share content)) "e"))
							(begin
								(assert "dealing with 0xce")
								
;								(if (= (length query) 1);; ca
;										(setq  cur_par "00 00")			
;									(= (length query) 3);; caxxxx
;										(setq cur_par (string (format "%x" (char (nth 1 query))) " " (format "%x" (char (nth 2 query)))) )
;								)
								;(println "cur_par " cur_par)
								(let (tmp_lst (parse (share content) " "));;;

                                (if (= (length query) 1);; ca
                                        (setq  cur_par "00 00")    
                                    (= (length query) 3);; caxxxx
                                        (setq cur_par (string (format "%x" (char (nth 1 query))) " " (format "%x" (char (nth 2 query)))) )
                                )  

								;(println tmp_lst)
								(if (> (int (nth 1 tmp_lst) 0 16) 0)
									(begin
										(println "1st tmp_lst > 0 " tmp_lst)
										(for (x 2 (- (length tmp_lst) 1) 2  (>= x (- (length tmp_lst) 1)) )
											(println "x= " x)
											(println tmp_lst)
											(setq short_addr (string (nth x tmp_lst) " " (nth (+ x 1) tmp_lst)) )
											
										;;	(if (nil? (CKV short_addr) )
												(CKV short_addr (list nil cur_par (date-value)) )
										;;	)
											(println " spawn ca " short_addr)
											(test (string "ca " short_addr) rw_iner)
											(println "af x= " x)	
										)
											
									)
									(println "1st tmp_lst <= 0")
								)
								)
								(save "CKV.lsp" 'CKV);;; next time,use (CKV) for all short address,then get live mac address, stored in CKV,the all macs 
								;; can be listed to users;; or! still use short address to be listed, both ways can work
							)
						)
						(if (and (= (nth 0 (share content)) "a") (= (nth 1 (share content)) "c")) ;; ac is response for "m" which is 0x6d
							(begin
								(setq tmp_lst (parse (share content) " "))
								(setq short_addr (string (nth 1 tmp_lst) " " (nth 2 tmp_lst)))
								(setq short_addr_ckv (CKV short_addr))
								(setq (nth 0  short_addr_ckv) (chop  (join (map string (slice tmp_lst 3) ) " ") 1) )
								(CKV short_addr short_addr_ckv)
								(save "CKV.lsp" 'CKV)
							)
						)
						;(println "in the last")	
						(share content "")
						ret
					)
					"talk is 0"
			)
		)
		"wrote nothing"	
	)
)

(define (server_exit)
	(if (nil? (close wusbdev) )
			(close wusbdev)
	)
	(print "bye")
	;(exit)
)

(define (test str time_out)
	;; non_block read process
	(if (nil? time_out)
			(setq time_out 500)
	)
	(assert str)
;	(println str " + " time_out)
	(setq str (replace "  " str " "))	
    (setq str_lst (parse str " "))
	(setq len (length str_lst))
    (setq ret "")
    (dolist (x str_lst)
       ; (setq tmp_str (slice x 0 2)) ;; force the input to be XX
        (extend ret (char (int x 0 16)))
    )
;	(println "run_serial")
	
    (run_serial ret len time_out)

;;	(share content "")
	(if (> (get-pid) 0)
		(begin
			(println "exiting now "  (getpid))
		;;	(abort (getpid))
		)
	)
)


(define (ctrlC-handler)
;;  (signal SIGINT "reset")
;   (sleep 500)
    (server_exit)
 ;   (sleep 400)
;	(signal SIGINT "reset")
	(share talk 3)
    (exit 0)
)

;;(signal SIGINT ctrlC-handler);; you know it 

(define (read_proc)

	(setq rusbdev (open dev "r" "n"))
	(if (nil? rusbdev)
   		(begin
       		(println "open " dev " read failed")
       		(exit rusbdev)
	   )
	)

    (until  (= (share talk) 3)  ;; for stoping and exiting
	;;		(while (and (net-select rusbdev "read" 10000) (<= (peek rusbdev) 0) )
			(while (not (net-select rusbdev "read" 10000) ))
			;;	(println "net-select")
;;				(sleep 30)
;			)
;			(while (= (peek rusbdev) 0)
;				(sleep 30)
;			)
				(if-not (file? dev)
						(share talk 3)
						
				)
				(setq read_ret (read_serial rusbdev) )
				;;check commands
					
	           	(share content (append (share content) read_ret) )
            	(println "in read_proc " (date-value) " "  (share content))
;;			)
;;			(sleep rw_iner)
    )
	(close rusbdev)
    (exit 0)
)

;(setq cpid (fork (read_proc)) )
;(print cpid)
;(spawn 'cpid (read_proc))
;(print cpid)

;(wait-pid cpid)
;(sleep 3000)
;(println "final: " (test "fe 00 21 01 20" 100) )

;(println "final: " (test "fe 00 21 01 20" 100) )

;(println "final: " (test "fe 00 21 01 20" 100) )

;(share talk 3) (wait-pid cpid)
(define (get_all_macs)
	(dolist (x (CKV))
		(test (string "6d " (nth 0 x))  500)
	)
)

(define (insert_to_nicks)
	(dolist (x (CKV))
		(setq mac (nth 0 (nth 1 x)))
		(if-not (nil? mac)
			(NICKS mac (list "" ""))
		)
	)
	(save "NICKS.lsp" 'NICKS)

)

(define (cmd_pro pid1)

	(while (read-line)
		(if (= (current-line) "quit")
			(begin
				(share talk 3)
				(server_exit)
			
				(destroy pid1)
				(destroy (get-pid))
				(newlisp_exit)
				
			)
		)

		(print (current-line))
	)	
)

(if (= (get-pid) 0)
	(begin
		(println "parent process")
		(setq cpid (fork (read_proc)) )
		(print cpid)
		(spawn 'cpid2 (cmd_pro cpid))
		(println cpid2)
	)
	(println "not 0 " (get-pid))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; last part
(if (true? create)
    (begin
        (test "ca" 500)
        (sleep 8000);;
        (println "test ca is over")
        (get_all_macs)
		(insert_to_nicks)
    )   
)


