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
    ((equal? (string-downcase str1) (string-downcase (substring str2 0 (string-length str1) ))) #t)
    (else (string_in_string? str1 (list->string (rest (string->list str2)))))
    ))


(define (get_fullname_list query))



(define (search-app req)

  (define get-data (request-bindings req))
  (define query-data (cdar get-data))
  (println query-data)
  
  (response/xexpr 

  `(html
    (title "Suche")
    (body 
      (h1 "Suchergebnisse")

      (form ((method "get") (action "")  (id "search" ))
                 (label ((for "search-field")) "Suche Kind: ")
                 (input ((type "text") (id "search-field") (name "search-field")))
                
      )
  ))
)

)

