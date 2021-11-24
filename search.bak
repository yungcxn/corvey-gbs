#lang racket


(require web-server/servlet
         web-server/servlet-env)
(require racket/struct)
(require racket/date)
(require db)
(require racket/format)
(require racket/struct)


(provide search-app)


(define aDB
  (sqlite3-connect #:database
      "gbs.db"
       #:mode 'read/write))

(define (request->post-data req)
  (fifth (struct->list req))
  )


(define (search-app req)

  
  
  (define post-data (request->post-data req))
  
  (when (bytes? post-data)
    
    (define post-string (bytes->string/utf-8  post-data))
    (println post-string)
    
  )
  
  (response/xexpr 

  `(html
    (title "Suche")
    (body 
      (p "Suchergebnisse")
  ))
)

)

