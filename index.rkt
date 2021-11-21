#lang racket

(require web-server/web-server
         web-server/dispatch
         web-server/servlet-env
         web-server/servlet)
(require web-server/http/redirect)
(require racket/list   web-server/templates)
(require xml)
(require racket/struct)
(require racket/date)
(require db)
(require racket/format)


(require "info.rkt")

(define (request->post-data req)
  (fifth (struct->list req))
  )




#|

TODO

post-handling
turning other buttons off when anwesend/krank/abgeholt
dispatch rules zu info page
datum changeability

|#




;
;  db_utils start
;

(define aDB
  (sqlite3-connect #:database
      "gbs.db"
       #:mode 'read/write))




(define (get_kind_data_by_id id)
  (query-row aDB "select * from kinder where kind_id = $1" id)
)


(define (get_kind_fullname_by_data data)
  (string-append (vector-ref data 1) " " (vector-ref data 2)))

(define (number_today)
  (define wrong_format (seventh (struct->list (current-date))))
  (if (and (> wrong_format 0) (< wrong_format 5)) (- wrong_format 1) 4 ) ;mo = 0, samstag = fr, sonntag = fr
  )

;10th = monday
(define (get_abholung_heute data number_today)
  (vector-ref data
              (+ number_today 10)
              )
  )


(define (get_all_kind_ids_heute (table (query-rows aDB "select * from kinder")) (build '()))

   (cond
     ((empty? table) (reverse build))
     ((not (equal? (get_abholung_heute (first table) (number_today)) "")) (get_all_kind_ids_heute (rest table) (cons (vector-ref (first table) 0) build)) )
     (else (get_all_kind_ids_heute (rest table) build))
     ))

(define (heute_abgeholt? id)
  (define rowlist (query-rows aDB "select * from abholung_log where datum  = date()" ))
  (define times-found (apply + (for/list ((i rowlist) #:when (equal? id (vector-ref i 1))) 1 )))
  (printf "~s abgeholt row-list ~s ; ~s ~n" id rowlist times-found )
  (if (> times-found 0) #t #f))
(define (heute_anwesend? id)
  (define rowlist (query-rows aDB "select * from anwesend_log where datum  = date()" ))
  (define times-found (apply + (for/list ((i rowlist) #:when (equal? id (vector-ref i 1))) 1 )))
  (printf "~s anwesend row-list ~s ; ~s ~n" id rowlist times-found)
  (if (> times-found 0) #t #f))
(define (heute_krank? id)
  (define rowlist (query-rows aDB "select * from krank_log where datum  = date()" ))
  (define times-found (apply +  (for/list ((i rowlist) #:when (equal? id (vector-ref i 1))) 1 )))
  (printf "~s krank row-list ~s ; ~s ~n" id rowlist times-found)
  (if (> times-found 0) #t #f))

(define (set_krank id bool) ;creates/deletes in db ;date

  (cond
    (bool  (query-exec aDB "insert into krank_log values (date(), $1)" id)  )
    (else
     (query-exec aDB "delete from krank_log where kind_id = $1" id)
     ))) 
(define (set_anwesend id bool)

  (cond
    (bool  (query-exec aDB "insert into anwesend_log values (date(), $1)" id)  )
    (else
     (query-exec aDB "delete from anwesend_log where kind_id = $1" id)
     )) );date und timestamp
(define (set_abgeholt id bool)

  (cond
    (bool  (query-exec aDB "insert into abholung_log values (date(), $1, datetime('now'))" id)  )
    (else
     (query-exec aDB "delete from abholung_log where kind_id = $1" id)
     )) );date


(define (create_kind vorname nachname geb klasse strasse_hnummer plz_ort notfallnummer1 notfallnummer2 specials abholungmo abholungdi abholungmi abholungdo abholungfr)
  (define new_id (add1 (vector-ref (last (query-rows aDB "select kind_id from kinder order by kind_id")) 0)))
  (query-exec aDB "insert into kinder values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)"
              new_id vorname nachname geb klasse strasse_hnummer plz_ort notfallnummer1 notfallnummer2 specials abholungmo abholungdi abholungmi abholungdo abholungfr )
  )

(define (update_kind id vorname nachname geb klasse strasse_hnummer plz_ort notfallnummer1 notfallnummer2 specials abholungmo abholungdi abholungmi abholungdo abholungfr)
  (query-exec aDB "delete from kinder where kind_id = $1" id)
  (query-exec aDB "insert into kinder values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)"
              id vorname nachname geb klasse strasse_hnummer plz_ort notfallnummer1 notfallnummer2 specials abholungmo abholungdi abholungmi abholungdo abholungfr )
  )


;
;  db_utils ende
;
;


(define (kind_panel kindid)
  
(define kinddata (get_kind_data_by_id kindid))
(define fullname (get_kind_fullname_by_data kinddata))
(define abgeholt? (heute_abgeholt? kindid))
(define krank? (heute_krank? kindid))
(define anwesend? (heute_anwesend? kindid))

(printf "kindid: abgeholt? ~s krank? ~s anwesend? ~s ~n" abgeholt? krank? anwesend?)
  
(define abholzeit (get_abholung_heute kinddata (number_today)))
(define abgeholt_button_id (string-append "abgeholt_button-" (~v kindid)))
(define krank_button_id (string-append "krank_button-" (~v kindid)))
(define anwesend_button_id (string-append "anwesend_button-" (~v kindid)))
(define (on_button_change str)
  (define str1 "")
  (define str2 "")
  (cond
    ((equal? str "abgeholt") (set! str1 krank_button_id) (set! str2 anwesend_button_id))
    ((equal? str "krank") (set! str1 abgeholt_button_id) (set! str2 anwesend_button_id))
    ((equal? str "anwesend") (set! str1 abgeholt_button_id) (set! str2 krank_button_id))
)
(format "this.form.submit(); document.getElementById(~s).checked = false; document.getElementById(~s).checked = false; " str1 str2 )
               
  )
  
  `(div ((class "kindpanel") (id ,(string-append "kindpanel-" (~v kindid))))

(p ,fullname)

 (p ((id "subtext")) "abgeholt?")
(form ((id "abgeholt_form") (method "post") (action "") (target "iframedummy"))
         (label ((class "switch"))
         (input ((name, (string-append "abgeholt-" (~v kindid))) (value "0")(type "hidden")
                                   (onchange , (on_button_change "abgeholt")) ))               
         (input ((id , abgeholt_button_id)(name, (string-append "abgeholt-" (~v kindid))) (value "1")(type "checkbox") , (if abgeholt? `(checked "true") `(href "#") )
                                   (onchange , (on_button_change "abgeholt")) ))
         (span ((class "slider round")))))

(p ((id "subtext")) "krank?")
(form ((id "krank_form") (method "post") (action "") (target "iframedummy"))
         (label ((class "switch"))
         (input ((name, (string-append "krank-" (~v kindid))) (value "0")(type "hidden")
                                (onchange , (on_button_change "krank")) ))  
         (input ((id, krank_button_id)(name , (string-append "krank-" (~v kindid))) (value "1")(type "checkbox") , (if krank? `(checked "true") `(href "#") )
                                (onchange , (on_button_change "krank")) ))
         (span ((class "slider round")))))

(p ((id "subtext")) "anwesend?")
(form ((id "anwesend_form") (method "post") (action "") (target "iframedummy"))
         (label ((class "switch"))
         (input ((name, (string-append "anwesend-" (~v kindid))) (value "0")(type "hidden")
                                   (onchange , (on_button_change "anwesend")) ))  
         (input ((id, anwesend_button_id)(name ,(string-append "anwesend-" (~v kindid))) (value "1")(type "checkbox"), (if anwesend? `(checked "true") `(href "#") )
                                   (onchange , (on_button_change "anwesend")) ))
         (span ((class "slider round")))
         ))

(p ,(string-append "Abholung: " abholzeit))
 (a ((href ,(string-append "/info/" (~v kindid)))) "i")
 
        )

  )



(define (index-start req)

  (define post-data (request->post-data req))
  
  (when (bytes? post-data)
    
    (define post-string (bytes->string/utf-8  post-data))

    
    (define arglist (string-split post-string "&"))
    (define flag (equal? (length arglist) 2)) ;wenn 2 argumente, dann wurde angeschaltet.
    (define state (first (string-split post-string "-")))
    (define kindid0 (string->number (first (string-split (second (string-split post-string "-")) "="))))

    (printf "post-string: ~s; arglist: ~s; flag: ~s; state: ~s; id: ~s; ~n" post-string arglist flag state kindid0)
    
    (cond
      ((and (equal? state "anwesend") flag) (set_krank kindid0 #f) (set_anwesend kindid0 #t) (set_abgeholt kindid0 #f))
      ((and (equal? state "abgeholt") flag) (set_krank kindid0 #f) (set_anwesend kindid0 #f) (set_abgeholt kindid0 #t))
      ((and (equal? state "krank") flag) (set_krank kindid0 #t) (set_anwesend kindid0 #f) (set_abgeholt kindid0 #f))
      ((and (equal? state "anwesend") (not flag)) (set_anwesend kindid0 #f))
      ((and (equal? state "abgeholt") (not flag)) (set_abgeholt kindid0 #f))
      ((and (equal? state "krank") (not flag)) (set_krank kindid0 #f)))
      
    )
  
  
  (response/xexpr `(html
                    (head (title Corvey-GBS)
                          (link ((rel "stylesheet") (href "style.css"))))
                    (body

  (img ([src "/logo.png"] [alt "corvey-logo"]))
  (p "Hi")

  (iframe ((name "iframedummy") (style "display: none")))

  '(div ((class "panels")) ,@(map kind_panel (get_all_kind_ids_heute) ))
  
  
                     )))

  )





(define-values (dispatch input-url)
  (dispatch-rules
   (("info" (integer-arg)) info-app)
   (("") index-start)
   (else index-start)))

  


(serve/servlet dispatch
 #:servlet-path "/"
 #:server-root-path (current-directory)
  #:servlet-regexp #rx""
)