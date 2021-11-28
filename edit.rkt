#lang racket

(require web-server/servlet
         web-server/servlet-env)
(require racket/struct)
(require racket/date)
(require db)
(require racket/format)
(require xml)

(provide edit-app)

(require "style.rkt")

(define (number_today)
  (define wrong_format (seventh (struct->list (current-date))))
  (if (and (> wrong_format 0) (< wrong_format 5)) (- wrong_format 1) 4 ) ;mo = 0, samstag = fr, sonntag = fr
  )


(define aDB
  (sqlite3-connect #:database
      "gbs.db"
       #:mode 'read/write))

(define (get_kind_data_by_id id)
  (query-row aDB "select * from kinder where kind_id = $1" id)
)

(define (edit-app req kindid)

  (define kindid_str (~v kindid))

  (define highest_id (vector-ref (last (query-rows aDB "select kind_id from kinder order by kind_id")) 0))

  (when (or (> kindid highest_id) (< kindid 0))
    (response/xexpr
   `(html (head (title "Corvey-GBS")
                (style
                           ,stylesheet
                           ))
          (body
(header

            (img ([src "/logo.png"] [alt "corvey-logo"]))
            
           (h1 "Bearbeite Kind")

           (form ((method "get") (action "../search")  (id "search" ))
                 (input ((type "text") (placeholder " Suche Kind") (id "search-field") (name "search-field")))
                
                 )

           )
           (p  "Dieses Kind ist nicht registriert!"))))

    ); error handling
  
  (define kind_data (get_kind_data_by_id kindid))

  (define vorname (vector-ref kind_data 1))
  (define nachname (vector-ref kind_data 2))
  (define geburtstag (vector-ref kind_data 3))
  (define klasse (vector-ref kind_data 4))
  (define strasse (vector-ref kind_data 5))
  (define plz (vector-ref kind_data 6))
  (define notfallnr1 (vector-ref kind_data 7))
  (define notfallnr2 (vector-ref kind_data 8))
  (define specials (vector-ref kind_data 9))
  (define mo_ab (vector-ref kind_data 10))
  (define di_ab (vector-ref kind_data 11))
  (define mi_ab (vector-ref kind_data 12))
  (define do_ab (vector-ref kind_data 13))
  (define fr_ab (vector-ref kind_data 14))


  (define zahl_heute (number_today)) ;mo 0, di 1 mi 2 do 3 fr 4 sa fr so fr

 (println (format
 "from edit.rkt: ~s\n"
 (list 'from (request-client-ip req)
       'to (request-host-ip req)
       'for (url->string (request-uri req)) 'at
       (date->string
        (seconds->date (current-seconds)) #t)))
)

  
  
  (response/xexpr
   
   `(html (head (title "Corvey-GBS")
                (style
                           ,stylesheet
                           )
                )
          
          (body

           

           

           (header

            (img ([src "/logo.png"] [alt "corvey-logo"]))
            
           (h1 "Bearbeite Kind")

           (form ((method "get") (action "../search")  (id "search" ))
                 (input ((type "text") (placeholder " Suche Kind") (id "search-field") (name "search-field")))
                
                 )

           )
           
           (p  ((id "fullnameinfo")) , (string-append vorname " " nachname))
           (form ((method "get") (action "../sent")(id "info"))
                (section ((id "infosection"))
                  (div ((id "infodiv")) (p "Vorname: ")
                       (input ((type "text") (name "vorname") (id "info-input") (value ,vorname))))
                  (div ((id "infodiv")) (p "Nachname: ")
                       (input ((type "text") (name "nachname") (id "info-input") (value ,nachname))))
                  (div ((id "infodiv")) (p "Klasse: ")
                       (input ((type "text") (name "klasse") (id "info-input") (value ,klasse))))
                  (div ((id "infodiv")) (p "Strasse: ")
                       (input ((type "text") (name "strasse") (id "info-input") (value ,strasse))))
                  (div ((id "infodiv")) (p "PLZ: ")
                       (input ((type "text") (name "plz") (id "info-input") (value ,plz))))
                  (div ((id "infodiv")) (p "Notfallnummer 1: ")
                       (input ((type "text") (name "notfallnr1") (id "info-input") (value ,notfallnr1))))
                  (div ((id "infodiv")) (p "Notfallnummer 2: ")
                       (input ((type "text") (name "notfallnr2") (id "info-input") (value ,notfallnr2))))
                  (div ((id "infodiv")) (p "Besonderes: ")
                       (input ((type "text") (name "specials") (id "info-input") (value ,specials))))
                )
                (table ((id "abholungstable"))
                       (colgroup
                        (col ((style "background-color:#97DB9A;")))
                        (col ((style "background-color: #E2E2E2;")))
                        )
                       (tr
                        (th "Tag")
                        (th "Uhrzeit")
                        )
                       (tr
                        (td ((style , (if (equal? mo_ab "") "background-color:#FF5959;" "") )) "Montag")
                        (td ((style , (if (equal? zahl_heute 0) "background-color:#FFE047;" "")))
                            (input ((type "text") (name "mo_ab") (id "info-input") (value ,mo_ab))))
                        )
                       (tr
                        (td ((style , (if (equal? di_ab "") "background-color:#FF5959;" "") )) "Dienstag")
                        (td ((style , (if (equal? zahl_heute 1) "background-color:#FFE047;" "")))
                            (input ((type "text") (name "di_ab") (id "info-input") (value ,di_ab))))
                        )
                       (tr
                        (td ((style , (if (equal? mi_ab "") "background-color:#FF5959;" "") )) "Mittwoch")
                        (td ((style , (if (equal? zahl_heute 2) "background-color:#FFE047;" "")))
                            (input ((type "text") (name "mi_ab") (id "info-input") (value ,mi_ab))))
                        )
                       (tr
                        (td ((style , (if (equal? do_ab "") "background-color:#FF5959;" "") )) "Donnerstag")
                        (td ((style , (if (equal? zahl_heute 3) "background-color:#FFE047;" "")))
                            (input ((type "text") (name "do_ab") (id "info-input") (value ,do_ab))))
                        )
                       (tr
                        (td ((style , (if (equal? fr_ab "") "background-color:#FF5959;" "") )) "Freitag")
                        (td ((style , (if (equal? zahl_heute 4) "background-color:#FFE047;" "")))
                            (input ((type "text") (name "fr_ab") (id "info-input") (value ,fr_ab))))
                        )
                 )
                
                (div ((id "spacer")) (button ((type "submit") (id "submitbutton") )  "Fertig"))
                )

           (br)
           (footer
    (p "\u00A9 Can Nayci") 
   )
            

           ))))

;FFE047