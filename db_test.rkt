#lang racket

(require db)

(define aDB
  (sqlite3-connect #:database
      "gbs.db"
       #:mode 'read/write))

(define (create_kind vorname nachname geb klasse strasse_hnummer plz_ort notfallnummer1 notfallnummer2 specials abholungmo abholungdi abholungmi abholungdo abholungfr)
  (define kinder_list (query-rows aDB "select kind_id from kinder order by kind_id"))
  
  (define new_id (if (empty? kinder_list) 0 (add1 (vector-ref (last kinder_list) 0))))
  (query-exec aDB "insert into kinder values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)"
              new_id vorname nachname geb klasse strasse_hnummer plz_ort notfallnummer1 notfallnummer2 specials abholungmo abholungdi abholungmi abholungdo abholungfr )
  )

(create_kind "Hans" "Peter" "01.01.2010" "5d" "Musterstrasse 10" "22222 Hamburg" "0176 12345677" "/" "Nussallergie, Einäugig, laktoseintolerant" "17:30" "15:30" "14:22" "" "15:20")
(create_kind "Kevin" "Hund" "02.01.2010" "7d" "Musterstrasse 11" "21222 Hamburg" "0176 666666" "/" "Nussallergie, Einäugig" "17:31" "15:31" "14:23" "" "15:25")
(create_kind "Clown" "Petersen" "01.01.2004" "6d" "Musterstrasse 12" "22422 Hamburg" "0176 838388" "/" "Nussallergie, laktoseintolerant" "17:34" "15:35" "" "" "15:27")