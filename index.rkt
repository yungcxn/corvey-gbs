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
(require web-server/dispatchers/dispatch-log)
(require web-server/http/bindings)

(date-display-format 'german)
(require "info.rkt")
(require "search.rkt")
(require "style.rkt")
(require "edit.rkt")

(define (request->post-data req)
  (fifth (struct->list req))
  )



(define secondstamp (current-seconds))
(define 1day 86400)
(define days 0)
(define heute (seconds->date (+ secondstamp (* days 1day))))


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
  (define wrong_format (seventh (struct->list heute)))
  (if (and (> wrong_format 0) (< wrong_format 5)) (- wrong_format 1) 4 )
  )


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
  (define rowlist (query-rows aDB (string-append "select * from abholung_log where datum  = date('now', '" (number->string days) " day')")))
  (define times-found (apply + (for/list ((i rowlist) #:when (equal? id (vector-ref i 1))) 1 )))

  (if (> times-found 0) #t #f))
(define (heute_anwesend? id)
  (define rowlist (query-rows aDB (string-append "select * from anwesend_log where datum  = date('now', '" (number->string days) " day')")))
  (define times-found (apply + (for/list ((i rowlist) #:when (equal? id (vector-ref i 1))) 1 )))

  (if (> times-found 0) #t #f))
(define (heute_krank? id)
  (define rowlist (query-rows aDB (string-append "select * from krank_log where datum  = date('now', '" (number->string days) " day')")))
  (define times-found (apply +  (for/list ((i rowlist) #:when (equal? id (vector-ref i 1))) 1 )))

  (if (> times-found 0) #t #f))

(define (set_krank id bool) ;creates/deletes in db ;date

  (cond
    (bool  (query-exec aDB (string-append "insert into krank_log values ( date('now', '" (number->string days) " day')  , $1)") id)  )
    (else
     (query-exec aDB "delete from krank_log where kind_id = $1" id)
     ))) 
(define (set_anwesend id bool)

  (cond
   (bool  (query-exec aDB (string-append "insert into anwesend_log values ( date('now', '" (number->string days) " day')  , $1)") id)  )
    (else
     (query-exec aDB "delete from anwesend_log where kind_id = $1" id)
     )) );date und timestamp
(define (set_abgeholt id bool)

  (cond
    (bool  (query-exec aDB (string-append "insert into abholung_log values ( date('now', '" (number->string days) " day')  , $1, datetime('now', '"(number->string days)" days'))") id)  )
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

(define (update_kind_with_list contentlist)
;                    id                 vorname             nachname          geb                  klasse              strasse              plz                           notfallnummern                  specials                                                                                                                               
(update_kind (first contentlist) (second contentlist) (third contentlist) (fourth contentlist) (fifth contentlist) (sixth contentlist) (seventh contentlist) (eighth contentlist) (ninth contentlist) (tenth contentlist) (list-ref contentlist 10) (list-ref contentlist 11) (list-ref contentlist 12) (list-ref contentlist 13) (list-ref contentlist 14))
  )

(define (delete_kind id)
  (query-exec aDB "delete from kinder where kind_id = $1" id))


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

(p ((id "fullname")) ,fullname)


(section ((class "formsection") (id "abgeholt"))
 (p ((id "subtext")) "abgeholt?")
(form ((id "abgeholt_form") (method "post") (action "") (target "iframedummy"))
         (label ((class "switch"))
         (input ((name, (string-append "abgeholt-" (~v kindid))) (value "0")(type "hidden")
                                   (onchange , (on_button_change "abgeholt")) ))               
         (input ((class "abgeholt_button")(id , abgeholt_button_id)(name, (string-append "abgeholt-" (~v kindid))) (value "1")(type "checkbox") , (if abgeholt? `(checked "true") `(href "#") )
                                   (onchange , (on_button_change "abgeholt")) ))
         (span ((class "slider round")))))
)
(section ((class "formsection")(id "krank"))
(p ((id "subtext")) "krank?")
(form ((id "krank_form") (method "post") (action "") (target "iframedummy"))
         (label ((class "switch"))
         (input ((name, (string-append "krank-" (~v kindid))) (value "0")(type "hidden")
                                (onchange , (on_button_change "krank")) ))  
         (input ((class "krank_button")(id, krank_button_id)(name , (string-append "krank-" (~v kindid))) (value "1")(type "checkbox") , (if krank? `(checked "true") `(href "#") )
                                (onchange , (on_button_change "krank")) ))
         (span ((class "slider round")))))
)
(section ((class "formsection")(id "anwesend"))
(p ((id "subtext")) "anwesend?")
(form ((id "anwesend_form") (method "post") (action "") (target "iframedummy"))
         (label ((class "switch"))
         (input ((name, (string-append "anwesend-" (~v kindid))) (value "0")(type "hidden")
                                   (onchange , (on_button_change "anwesend")) ))  
         (input ((class "anwesend_button")(id, anwesend_button_id)(name ,(string-append "anwesend-" (~v kindid))) (value "1")(type "checkbox"), (if anwesend? `(checked "true") `(href "#") )
                                   (onchange , (on_button_change "anwesend")) ))
         (span ((class "slider round")))
         ))
)
(p ((id  "abholungsinfo")),(string-append "Abholung: " abholzeit))
 (a ((id "info") (href ,(string-append "/info/" (~v kindid)))) "i")
 
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
    
    (cond
      ((and (equal? state "anwesend") flag) (set_krank kindid0 #f) (set_anwesend kindid0 #t) (set_abgeholt kindid0 #f))
      ((and (equal? state "abgeholt") flag) (set_krank kindid0 #f) (set_anwesend kindid0 #f) (set_abgeholt kindid0 #t))
      ((and (equal? state "krank") flag) (set_krank kindid0 #t) (set_anwesend kindid0 #f) (set_abgeholt kindid0 #f))
      ((and (equal? state "anwesend") (not flag)) (set_anwesend kindid0 #f))
      ((and (equal? state "abgeholt") (not flag)) (set_abgeholt kindid0 #f))
      ((and (equal? state "krank") (not flag)) (set_krank kindid0 #f)))
      
    )

  
  
  (response/xexpr `(html
                    (head (title "Corvey-GBS")
                          (style
                           ,stylesheet
                           )
                          ;(link ((rel "stylesheet") (href "/style.css"))) ;klappt nicht
                          )
                    (body

                     (header
                      (a ((href "../today"))
                      (img ([src "/logo.png"] [alt "corvey-logo"])))

                      (h1 "Dashboard")

                      (form ((method "get") (action "/search")  (id "search" ))
                             (input ((type "text") (placeholder " Suche Kind") (id "search-field") (name "search-field")))
                
                      )
                      )

  (iframe ((name "iframedummy") (style "display: none")))

  

  (div ((class "panels"))

       (div ((id "datediv"))
       (a ((href "../-")) (i ((class "arrow left"))))
       (h2 ,(date->string heute))
       (a ((href "../+")) (i ((class "arrow right"))))
        
       )

       ,@(map kind_panel (get_all_kind_ids_heute) ))


  (div ((id "newdiv"))  (a ((id "new") (href "/create")) "+"))
  
  (footer
    (p "\u00A9 Can Nayci") 
   )
                   ))


  )

)

(define (sent-handler req)
  (define get-data (request-bindings req))
  (define content-list
    (for/list ((i get-data)) (cdr i)))

  (update_kind_with_list content-list)
  
  (index-start req)
  
)

(define (delete-handler req)
  (define get-data (request-bindings req))
  (define x (cdar get-data))
  (delete_kind x)
  (index-start req)
)

(define (create-handler req)
  (define new_id (add1 (vector-ref (last (query-rows aDB "select kind_id from kinder order by kind_id")) 0)))
  (create_kind "Neues" "Kind" "01.01.2000" "5a" "Musterstrasse 1" "22222 Hamburg" "0176 123" "/" "Allergien, etc." "13:00" "13:00" "13:00" "13:00" "13:00")
  (edit-app req new_id)
  )

;(define days 0)
;(define heute (seconds->date (+ secondstamp (* days 1day))))

(define (go1dayforth-handler req)

  (set! days (add1 days))
  (set! heute (seconds->date (+ secondstamp (* days 1day))))
  (index-start req)
  )

(define (go1dayback-handler req)

  (set! days (- days 1))
  (set! heute (seconds->date (+ secondstamp (* days 1day))))
  (index-start req)
  )

(define (today-handler req)
(set! days 0)
(set! heute (seconds->date (+ secondstamp (* days 1day))))
(index-start req)
  )


(define-values (dispatch input-url)
  (dispatch-rules
   (("info" (integer-arg)) info-app)
   (("search") search-app)
   (("edit" (integer-arg)) edit-app)
   (("sent") sent-handler)
   (("delete") delete-handler)
   (("create") create-handler)
   (("+") go1dayforth-handler)
   (("-") go1dayback-handler)
   (("today") today-handler)
   (("") index-start)
   (else index-start)
   ))

(serve/servlet dispatch
 #:servlet-path "/"
 #:server-root-path (current-directory)
  #:servlet-regexp #rx""
)