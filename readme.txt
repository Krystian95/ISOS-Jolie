jolie2wsdl --namespace mytest.test.com --portName ACMEGestioneOrdini --portAddr http://localhost:8000 --o wsdlACMEGestioneOrdini.wsdl ACME_gestione_ordini.ol

----jolie2wsdl --namespace mytest.test.com --portName RivenditoreACMEService --portAddr http://localhost:8004 --o wsdlRivenditore1.wsdl rivenditore1.ol

_______________________________________________________________________________________________________________________________________________________________________________________________

wsimport -s src -p org.camunda.bpm.acme.generated.gestione_ordini -Xnocompile -b bindingACMEGestioneOrdini.xml wsdlACMEGestioneOrdini.wsdl

-----wsimport -s src -p org.camunda.bpm.acme.generated.rivenditore1 -Xnocompile -b bindingRivenditore1.xml wsdlRivenditore1.wsdl
