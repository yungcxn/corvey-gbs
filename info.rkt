#lang racket

(require web-server/servlet
         web-server/servlet-env)
(require racket/struct)
(require racket/date)
(require db)
(require racket/format)


(provide info-app)


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

(define (info-app req kindid)

  (define kindid_str (~v kindid))

  (define highest_id (vector-ref (last (query-rows aDB "select kind_id from kinder order by kind_id")) 0))

  (when (> kindid highest_id)
    (response/xexpr
   `(html (head (title "Info"))
          (body (p  "Dieses Kind ist nicht registriert!"))))

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
  
  (response/xexpr
   `(html (head (title "Info"))
          (body

           (h1 "Information")
           (p , (string-append vorname " " nachname))
           (div ((id "info"))

                (p , (string-append "Vorname: " vorname))
                (p , (string-append "Nachname: " nachname))
                (p , (string-append "Geburtstag:  " geburtstag))
                (p , (string-append "Klasse:  " klasse))
                (p , (string-append "Strasse:  " strasse))
                (p , (string-append "PLZ:  " plz))
                (p , (string-append "Notfallnummer 1: " notfallnr1))
                (p , (string-append "Notfallnummer 2: " notfallnr2))
                (p , (string-append "Besonderes:  " specials))

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
                        (td ((style , (if (equal? zahl_heute 0) "background-color:#FFE047;" ""))) , mo_ab)
                        )
                       (tr
                        (td ((style , (if (equal? di_ab "") "background-color:#FF5959;" "") )) "Dienstag")
                        (td ((style , (if (equal? zahl_heute 1) "background-color:#FFE047;" ""))) , di_ab)
                        )
                       (tr
                        (td ((style , (if (equal? mi_ab "") "background-color:#FF5959;" "") )) "Mittwoch")
                        (td ((style , (if (equal? zahl_heute 2) "background-color:#FFE047;" ""))) , mi_ab)
                        )
                       (tr
                        (td ((style , (if (equal? do_ab "") "background-color:#FF5959;" "") )) "Donnerstag")
                        (td ((style , (if (equal? zahl_heute 3) "background-color:#FFE047;" ""))) , do_ab)
                        )
                       (tr
                        (td ((style , (if (equal? fr_ab "") "background-color:#FF5959;" "") )) "Freitag")
                        (td ((style , (if (equal? zahl_heute 4) "background-color:#FFE047;" ""))) , fr_ab)
                        )
                 )
                
                
                )
            

           ))))

;FFE047