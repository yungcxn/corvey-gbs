#lang racket


(require web-server/servlet
         web-server/servlet-env)
(require racket/struct)
(require racket/date)
(require db)
(require racket/format)
(require racket/struct)
(require web-server/http/bindings)


(provide search-app)

(require "style.rkt")
(define aDB
  (sqlite3-connect #:database
      "gbs.db"
       #:mode 'read/write))

(define (request->post-data req)
  (fifth (struct->list req))
  )


(define (string_in_string? str1 str2)
 
  (cond
    ((equal? str2 "") #f)
    ((> (string-length str1) (string-length str2) ) #f)
    ((equal? (string-downcase str1) (string-downcase (substring str2 0 (string-length str1) ))) #t)
    (else (string_in_string? str1 (list->string (rest (string->list str2)))))
    ))


(define (get_fullname_list)
(query-rows aDB "select kind_id, kind_vorname, kind_nachname from kinder")
  )

(define (filter_fullname_list data query (build '()))
  (cond
    ((empty? data) (reverse build))
    ((string_in_string? query (vector-ref (first data) 1)) (filter_fullname_list (rest data) query (cons (first data) build)))
    ((string_in_string? query (vector-ref (first data) 2)) (filter_fullname_list (rest data) query (cons (first data) build)))
    (else (filter_fullname_list (rest data) query build))
    ))

(define (produce_result datavec)
  `(div ((id "result")) (a ((id "result")(href , (string-append "../info/" (number->string (vector-ref datavec 0))) )) ,(string-append (vector-ref datavec 1) " " (vector-ref datavec 2)) )))

(define (search-app req)

  (define get-data (request-bindings req))
  (define query-str (cdar get-data))
  (println query-str)
  (define dbdata (get_fullname_list))
  
  
  (response/xexpr 

  `(html
    (head (title "Corvey-GBS") (style
                           ,stylesheet
                           ))
    
    (body

     (header
      (img ([src "/logo.png"] [alt "corvey-logo"]))
      
      (h1 "Suchergebnisse")

      (form ((method "get") (action "")  (id "search" ))
                 (input ((type "text") (placeholder " Suche Kind") (id "search-field") (name "search-field")))
      )
      )

     (div ((id "results"))
      ,@(map produce_result (filter_fullname_list dbdata query-str)))

      (footer
    (p "\u00A9 Can Nayci") 
   )
  ))
)

)

