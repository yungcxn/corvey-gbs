#lang racket
(require db)

;datei kreiert db

(define aDB
  (sqlite3-connect #:database
      "gbs.db"
       #:mode 'create))

(query-exec aDB

"create table kinder (kind_id integer PRIMARY KEY, kind_vorname varchar(20), kind_nachname varchar(20),
kind_geb date, kind_klasse varchar(5), kind_strasse_hnummer varchar(30), kind_plz_ort varchar(20),
kind_notfallnummer1 varchar(20), kind_notfallnummer2 varchar(20), kind_specials varchar(20),
kind_abholung_mo time, kind_abholung_di time, kind_abholung_mi time, kind_abholung_do time, kind_abholung_fr time)")

(query-exec aDB "create table anwesend_log (datum date, kind_id integer)")

(query-exec aDB "create table abholung_log (datum date, kind_id integer, stamp timestamp)")

(query-exec aDB "create table krank_log (datum date, kind_id integer)")

