start "ACME_gestione_ordini" jolie -C "AUTOMATIC_MODE=true" ACME_gestione_ordini.ol
waitfor /T 1 pause 2>NULL
start "ACME_magazzini_MP" jolie -C "AUTOMATIC_MODE=true" ACME_magazzini_MP.ol
waitfor /T 1 pause 2>NULL
start "ACME_magazzini_MS_1" jolie -C "AUTOMATIC_MODE=true" ACME_magazzini_MS_1.ol
waitfor /T 1 pause 2>NULL
start "ACME_magazzini_MS_2" jolie -C "AUTOMATIC_MODE=true" ACME_magazzini_MS_2.ol
waitfor /T 1 pause 2>NULL
start "ACME_magazzini_MS_3" jolie -C "AUTOMATIC_MODE=true" ACME_magazzini_MS_3.ol
waitfor /T 1 pause 2>NULL
start "rivenditore1" jolie -C "AUTOMATIC_MODE=true" rivenditore1.ol
waitfor /T 1 pause 2>NULL
start "GIS" jolie -C "AUTOMATIC_MODE=true" GIS.ol
exit
