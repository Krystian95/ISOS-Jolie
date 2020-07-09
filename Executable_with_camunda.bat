cd ..\..\..\Desktop\CamundaEE\
start start-camunda.bat
cd ..\..\Documents\Progetti\ISOS-Jolie
start "ACME_gestione_ordini" jolie -C "AUTOMATIC_MODE=true" ACME_gestione_ordini.ol
start "GIS" jolie -C "AUTOMATIC_MODE=true" GIS.ol
start "ACME_magazzini_MP" jolie -C "AUTOMATIC_MODE=true" ACME_magazzini_MP.ol
start "ACME_magazzini_MS_1" jolie -C "AUTOMATIC_MODE=true" ACME_magazzini_MS_1.ol
start "ACME_magazzini_MS_2" jolie -C "AUTOMATIC_MODE=true" ACME_magazzini_MS_2.ol
start "ACME_magazzini_MS_3" jolie -C "AUTOMATIC_MODE=true" ACME_magazzini_MS_3.ol
start "Rivenditore1" jolie -C "AUTOMATIC_MODE=true" Rivenditore1.ol
start "Rivenditore2" jolie -C "AUTOMATIC_MODE=true" Rivenditore2.ol
start "Banca" jolie -C "AUTOMATIC_MODE=true" Banca.ol
start "Fornitore" jolie -C "AUTOMATIC_MODE=true" Fornitore.ol
start "Corriere" jolie -C "AUTOMATIC_MODE=true" Corriere.ol
exit
