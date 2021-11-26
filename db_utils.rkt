#lang racket

(require db)
(require racket/date)
 (require racket/struct)

(define aDB
  (sqlite3-connect #:database
      "gbs.db"
       #:mode 'read/write))




(define (get_kind_data_by_id id)
  (query-row aDB "select * from kinder where kind_id = $1" id)
)

(define (get_kind_fullname_by_data data)
  (string-append (vector-ref data 0) " " (vector-ref data 1)))





(define (number_today)
  (define wrong_format (seventh (struct->list (current-date))))
  (if (and (> wrong_format 0) (> wrongformat 5)) (- wrongformat 1) 4 ) ;mo = 0, samstag = fr, sonntag = fr
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
  (if (> (length (for/list ((i (query-rows aDB "select * from anwesend_log where datum  = CURDATE()" )) #:when (= id (vector-ref i 1))) 1 )) 1) #t #f))
  

(define (heute_anwesend? id)
  (if (> (length (for/list ((i (query-rows aDB "select * from abholung_log where datum  = CURDATE()" )) #:when (= id (vector-ref i 1))) 1 )) 1) #t #f))
(define (heute_krank? id)
  (if (> (length (for/list ((i (query-rows aDB "select * from krank_log where datum  = CURDATE()" )) #:when (= id (vector-ref i 1))) 1 )) 1) #t #f))

(define (set_krank id bool)
  (cond
    ((bool)  (query-exec aDB "insert into krank_log values (CURDATE(), $1)" id)  )
    (else
     (query-exec aDB "delete from krank_log where kind_id = $1" id)
     ))) 
(define (set_anwesend id bool)(cond
    ((bool)  (query-exec aDB "insert into anwesend_log values (CURDATE(), $1)" id)  )
    (else
     (query-exec aDB "delete from anwesend_log where kind_id = $1" id)
     )) )
(define (set_abgeholt id bool)(cond
    ((bool)  (query-exec aDB "insert into abgeholt_log values (CURDATE(), $1, NOW())" id)  )
    (else
     (query-exec aDB "delete from abgeholt_log where kind_id = $1" id)
     )) )


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



