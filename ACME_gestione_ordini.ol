
include "console.iol"
include "database.iol"
include "string_utils.iol"
include "time.iol"
include "math.iol"

include "interfaces/CamundaInterface.iol"
include "interfaces/ACMEGestioneOrdiniInterface.iol"
include "interfaces/ACMERivenditoreInterface.iol"
include "interfaces/RivenditoreInterface.iol"
include "interfaces/ACMEMagazzinoInterface.iol"
include "interfaces/BancaInterface.iol"
include "interfaces/FornitoreInterface.iol"

// Porta Rivenditore 1 -> ACME Gestione Ordini
inputPort ACMEGestioneOrdiniRivenditore1 {
	Location: "socket://localhost:8001"
	Protocol: soap
	Interfaces: ACMERivenditoreInterface
}

// Porta ACME Gestione Ordini -> Rivenditore 1
outputPort Rivenditore1 {
	Location: "socket://localhost:8002"
	Protocol: soap
	Interfaces: RivenditoreInterface
}
// Porta Rivenditore 2 -> ACME Gestione Ordini
inputPort ACMEGestioneOrdiniRivenditore2 {
	Location: "socket://localhost:8010"
	Protocol: soap
	Interfaces: ACMERivenditoreInterface
}

// Porta ACME Gestione Ordini -> Rivenditore 2
outputPort Rivenditore2 {
	Location: "socket://localhost:8011"
	Protocol: soap
	Interfaces: RivenditoreInterface
}

// Porta ACME Gestione Ordini -> ACME Magazzino Principale
outputPort MagazzinoPrincipale {
	Location: "socket://localhost:8006"
	Protocol: soap
	Interfaces: ACMEMagazzinoInterface
}

// Porta ACME Gestione Ordini -> ACME Magazzino Secondario 1
outputPort MagazzinoSecondario1 {
	Location: "socket://localhost:8007"
	Protocol: soap
	Interfaces: ACMEMagazzinoInterface
}

// Porta ACME Gestione Ordini -> ACME Magazzino Secondario 2
outputPort MagazzinoSecondario2 {
	Location: "socket://localhost:8008"
	Protocol: soap
	Interfaces: ACMEMagazzinoInterface
}

// Porta ACME Gestione Ordini -> ACME Magazzino Secondario 3
outputPort MagazzinoSecondario3 {
	Location: "socket://localhost:8009"
	Protocol: soap
	Interfaces: ACMEMagazzinoInterface
}

// Porta [TEST] Test -> ACME Gestione Ordini
inputPort ACMETest {
	Location: "socket://localhost:8003"
	Protocol: soap
	Interfaces: ACMEGestioneOrdiniInterface
}

/*
outputPort ACMEGestioneOrdini {
	Location: "socket://localhost:8002"
    Protocol: soap {
        .wsdl = "./wsdlRivenditore1.wsdl";
        .wsdl.port = "ACMEGestioneOrdini";
        .dropRootValue = true
    }
    Interfaces: ACMEGestioneOrdiniInterface
}*/

// Porta CAMUNDA -> ACME Gestione Ordini
inputPort ACMEGestioneOrdini {
    Location: "socket://localhost:8000"
    Protocol: soap {
        .wsdl = "./wsdl/wsdlACMEGestioneOrdini.wsdl";
        .wsdl.port = "ACMEGestioneOrdini";
        .dropRootValue = true
    }
    Interfaces: ACMEGestioneOrdiniInterface
}

// Porta ACME Gestione Ordini -> CAMUNDA
outputPort CamundaPort {
    Location: "socket://localhost:8080/engine-rest/"
    Protocol: http {
        .method = "post";
        .contentType = "application/json";
        .format = "json"
    }
    Interfaces: CamundaInterface
}

// Porta ACME Gestione Ordini -> Banca
outputPort Banca {
	Location: "socket://localhost:8017"
	Protocol: soap
	Interfaces: BancaInterface
}

// Porta ACME Gestione Ordini -> Fornitore
outputPort Fornitore {
	Location: "socket://localhost:8018"
	Protocol: soap
	Interfaces: FornitoreInterface
}

execution { concurrent }

constants {
	DEBUG = true,
	PERCENTAGE_ANTICIPO = 20,
	PERCENTAGE_SALDO = 80
}

init {
    with(connectionInfo) {
        .host = "127.0.0.1";
        .driver = "mysql";
        .port = 3306;
        .database = "acme?serverTimezone=Europe/Rome";
        .username = "root";
        .password = "root"
    };

    connect@Database(connectionInfo)();
    println@Console("\nConnection to database: SUCCESS")();

    println@Console("\nACME is running...\n")()
}

main
{
	[
		richiediListino( void )( listino ) {

			// Cicli
			query = "SELECT idCiclo, modello, colorazione
					 FROM ciclo";
        	query@Database( query )( resultCicli );

	        for ( i = 0, i < #resultCicli.row, i++ ) {
	            listino.cicli[i].idCiclo = resultCicli.row[i].idCiclo;
	            listino.cicli[i].modello = resultCicli.row[i].modello;
	            listino.cicli[i].colorazione = resultCicli.row[i].colorazione
	        }

			// Customizzazioni
			query = "SELECT idCustomizzazione, tipologia, descrizione
					 FROM customizzazione";
        	query@Database( query )( resultCustomizzazioni );

	        for ( i = 0, i < #resultCustomizzazioni.row, i++ ) {
	            listino.customizzazioni[i].idCustomizzazione = resultCustomizzazioni.row[i].idCustomizzazione;
	            listino.customizzazioni[i].tipologia = resultCustomizzazioni.row[i].tipologia;
	            listino.customizzazioni[i].descrizione = resultCustomizzazioni.row[i].descrizione
	        }

			// Accessori
			query = "SELECT idAccessorio, nome
					 FROM accessorio";
        	query@Database( query )( resultAccessori );

	        for ( i = 0, i < #resultAccessori.row, i++ ) {
	            listino.accessori[i].idAccessorio = resultAccessori.row[i].idAccessorio;
	            listino.accessori[i].nome = resultAccessori.row[i].nome
	        }
	    }
	] {
		println@Console("\n[richiediListino] COMPLETED\n")()
	}

	[
		inviaOrdine( ordine )
	] {
		install (
			// TODO remove print and leave blank
			Timeout => println@Console("")(),
			TypeMismatch => println@Console("")()
		);

		// Inserimento ordine nel db
		if(#ordine.cicli > 0 || #ordine.accessori > 0) {
			scope ( insertOrdine ) {
	        	install ( SQLException => println@Console("\n[!] ERRORE nell'inserimento ordine nel db\n")() );

				query = "INSERT INTO ordine (idRivenditore) VALUES (" + ordine.idRivenditore + ")";
				update@Database( query )( responseNewOrdine );

				query = "SELECT idOrdine
						 FROM ordine
						 WHERE idOrdine = (
						 	SELECT MAX(idOrdine)
						 	FROM ordine
						 )";
				query@Database( query )( responseNewOrdine );
				ordine.idOrdine = responseNewOrdine.row[0].idOrdine;
				println@Console("Ordine #" + ordine.idOrdine + " inserito")()
			};

			// Inserimento Cicli Ordine nel db
			if(#ordine.cicli > 0) {
				scope ( insertCicliOrdine ) {
			       	install ( SQLException => println@Console("\n[!] ERRORE nell'inserimento ciclo ordine nel db\n")() );

					query = "INSERT INTO ordine_has_ciclo (idOrdine, idCiclo, quantitaCiclo) VALUES ";

					for ( i = 0, i < #ordine.cicli, i++ ) {
						idCiclo = ordine.cicli[i].idCiclo;
						quantitaCiclo = ordine.cicli[i].qta;
						query += "(" + ordine.idOrdine + ", " + idCiclo + ", " + quantitaCiclo + "),"
					}

					query_raw = query;
					query_raw.begin = 0;
					length@StringUtils( query )( queryLength );
					query_raw.end = queryLength - 1;
					substring@StringUtils( query_raw )( substringResponse );
					query = substringResponse + ";";

			    	update@Database( query )( responseNewCicloOrdine );
			        println@Console("Cicli Ordine inseriti")()
		        }

				    // Inserimento Customizzazioni Cicli Ordine nel db
				scope ( insertCustomizzazioniCicliOrdine ) {
					install ( SQLException => println@Console("\n[!] ERRORE nell'inserimento customizzazioni cicli ordine nel db\n")() );

					query = "INSERT INTO ordine_has_ciclo_has_customizzazione (idOrdine, idCiclo, idCustomizzazione) VALUES ";

					for ( i = 0, i < #ordine.customizzazioni[i], i++ ) {
						idCiclo = ordine.customizzazioni[i].idCiclo;
						idCustomizzazione = ordine.customizzazioni[i].idCustomizzazione;
						query += "(" + ordine.idOrdine + ", " + idCiclo + ", " + idCustomizzazione + "),"
					}

					query_raw = query;
					query_raw.begin = 0;
					length@StringUtils( query )( queryLength );
					query_raw.end = queryLength - 1;
					substring@StringUtils( query_raw )( substringResponse );
					query = substringResponse + ";";

			           update@Database( query )( responseNewCustomizzazioneCicloOrdine );
			           println@Console("Customizzazione Ciclo Ordine inserita")()
			    }
	        }

			// Inserimento Accessori Ordine nel db
			if(#ordine.accessori > 0) {
				scope ( insertAccessoriOrdine ) {
			        install ( SQLException => println@Console("\n[!] ERRORE nell'inserimento accessorio ordine nel db\n")() );

					query = "INSERT INTO ordine_has_accessorio (idOrdine, idAccessorio, quantitaAccessorio) VALUES ";

					for ( i = 0, i < #ordine.accessori, i++ ) {
						idAccessorio = ordine.accessori[i].idAccessorio;
						quantitaAccessorio = ordine.accessori[i].qta;
						query += "(" + ordine.idOrdine + ", " + idAccessorio + ", " + quantitaAccessorio + "),"
					}

					query_raw = query;
					query_raw.begin = 0;
					length@StringUtils( query )( queryLength );
					query_raw.end = queryLength - 1;
					substring@StringUtils( query_raw )( substringResponse );
					query = substringResponse + ";";

			        update@Database( query )( responseNewAccessorioOrdine );
			        println@Console("Accessori Ordine inseriti")()
		        }
	        }

	        global.ordini.(ordine.idOrdine) << ordine;
	        global.lastIdOrdine = ordine.idOrdine;
	        undef(ordine);

			// Message
			message.messageName = "Ordine";
			message.processVariables.ordine.value = string( global.ordini.(ordine.idOrdine).idOrdine );
			message.processVariables.ordine.type = "String";
			message@CamundaPort(message)(rit)
        }

		println@Console("\n[inviaOrdine] COMPLETED\n")()
	}

	[
		getIdOrdine( void )( idOrdine ) {

			idOrdine.idOrdine = string( global.ordini.(global.lastIdOrdine).idOrdine )
	    }
	] {
		println@Console("\n[getIdOrdine] COMPLETED\n")()
	}

	[
		getIdRivenditore( idOrdine )( idRivenditore ) {

			idRivenditore.idRivenditore = string( global.ordini.(idOrdine.idOrdine).idRivenditore )
	    }
	] {
		println@Console("\n[getIdRivenditore] COMPLETED\n")()
	}

	[
		verificaCustomizzazioni( idOrdine )( esitoVerificaCustomizzazioni ) {

			// Customizzazioni realizzabili oppure no

			query = "SELECT DISTINCT idCustomizzazione
					 FROM customizzazione
					 WHERE idCustomizzazione IN (
					 	SELECT idCustomizzazione
					 	FROM ordine_has_ciclo_has_customizzazione
					 	WHERE idOrdine = " + idOrdine.idOrdine +
					") AND disponibilita = 0";
        	query@Database( query )( resultCustomizzazioniNonRealizzabili );

	        if ( #resultCustomizzazioniNonRealizzabili.row == 0 ) {
	        	esitoVerificaCustomizzazioni.customizzazioniPossibili = true
	        } else {
				esitoVerificaCustomizzazioni.customizzazioniPossibili = false
	        }

	        // Accessori da non assemblare/assemblare facilmente

			query = "SELECT *
					 FROM Ordine_has_Accessorio
					 LEFT JOIN Accessorio ON Ordine_has_Accessorio.idAccessorio = Accessorio.idAccessorio
					 WHERE idOrdine = " + idOrdine.idOrdine + " AND tipologia IN ('Non assemblabile', 'Assemblabile facilmente')";
        	query@Database( query )( resultAccessoriNonAssemblare );

        	if ( #resultAccessoriNonAssemblare.row > 0 ) {
	        	esitoVerificaCustomizzazioni.ordineContieneAccessoriDaNonAssemblare = true
	        } else {
				esitoVerificaCustomizzazioni.ordineContieneAccessoriDaNonAssemblare = false
	        }

	        global.ordini.(idOrdine.idOrdine).ordineContieneAccessoriDaNonAssemblare = esitoVerificaCustomizzazioni.ordineContieneAccessoriDaNonAssemblare;

			if(DEBUG){
				println@Console("global.ordini.("+idOrdine.idOrdine+").ordineContieneAccessoriDaNonAssemblare = " + global.ordini.(idOrdine.idOrdine).ordineContieneAccessoriDaNonAssemblare)()
			}

	        esitoVerificaCustomizzazioni.ordineContieneComponentiAccessoriDaAssemblare = true
	    }
	] {
		println@Console("\n[verificaCustomizzazioni] COMPLETED\n")()
	}

	[
		notificaCustomizzazioniNonRealizzabili ( notificaCustomizzazioniNonRealizzabili )( response ) {

			idRivenditore = notificaCustomizzazioniNonRealizzabili.idRivenditore;
			idOrdine = notificaCustomizzazioniNonRealizzabili.idOrdine;

			if (idRivenditore == 1) {
				notificaCustomizzazioniNonRealizzabili@Rivenditore1( idOrdine )
	        } else if(idRivenditore == 2){
	            notificaCustomizzazioniNonRealizzabili@Rivenditore2( idOrdine )
	        }

			response.message = "Notifica customizzazioni NON realizzabili inviata al rivenditore #" + idRivenditore + " per l'ordine #" + idOrdine;
			println@Console(response.message)()
	    }
	] {
		println@Console("\n[notificaCustomizzazioniNonRealizzabili] COMPLETED\n")()
	}

	[
		prenotazioneMaterialiPresentiMP ( params )( response ) {

			verificaDisponibilitaComponentiAccessori@MagazzinoPrincipale( params )( responseMagazzino );
			response.tuttiMaterialiRichiestiPresentiMP = responseMagazzino.tuttiMaterialiRichiestiPresenti;
			response.message = responseMagazzino.message;
			println@Console(response.message)()
	    }
	] {
		println@Console("\n[prenotazioneMaterialiPresentiMP] COMPLETED\n")()
	}

	[
		prenotazioneMaterialiPresentiMS ( params )( response ) {

			query = "SELECT idMagazzino
					 FROM Magazzino
					 WHERE tipologia = 'Secondario'";
        	query@Database( query )( magazziniSecondari );

	        for ( i = 0, i < #magazziniSecondari.row, i++ ) {
	            idMagazzino = magazziniSecondari.row[i].idMagazzino;

	            if(idMagazzino == 2) {
					verificaDisponibilitaComponentiAccessori@MagazzinoSecondario1( params )( responseMagazzino )
	            } else if(idMagazzino == 3){
	            	verificaDisponibilitaComponentiAccessori@MagazzinoSecondario2( params )( responseMagazzino )
	            } else if(idMagazzino == 4){
	            	verificaDisponibilitaComponentiAccessori@MagazzinoSecondario3( params )( responseMagazzino )
	            }
	        }

	        response.message = "Tutti i magazzini secondari sono stati interrogati"
	    }
	] {
		println@Console("\n[prenotazioneMaterialiPresentiMS] COMPLETED\n")()
	}

	[
		generazioneListaAccessoriPresentiMagazzini ( params )( response ) {

			query = "SELECT Rivenditore.indirizzo,
							Ordine.idRivenditore
					 FROM Ordine
					 LEFT JOIN Rivenditore ON Ordine.idRivenditore = Rivenditore.idRivenditore
					 WHERE Ordine.idOrdine = " + params.idOrdine;
        	query@Database( query )( resultRivenditore );
        	indirizzoRivenditore = resultRivenditore.row[0].indirizzo;
        	idRivenditore = resultRivenditore.row[0].idRivenditore;
        	println@Console("indirizzoRivenditore = " + indirizzoRivenditore)();

        	// Distance from Magazzini

        	query = "DELETE
        			 FROM temp_distanze_rivenditore_magazzini
        			 WHERE idRivenditore = " + idRivenditore;
        	update@Database( query )( resultClear );

        	{
				distanceFromRivenditore@MagazzinoPrincipale(indirizzoRivenditore)(distanceMagazzino1)  |
				distanceFromRivenditore@MagazzinoSecondario1(indirizzoRivenditore)(distanceMagazzino2) |
	            distanceFromRivenditore@MagazzinoSecondario2(indirizzoRivenditore)(distanceMagazzino3) |
	            distanceFromRivenditore@MagazzinoSecondario3(indirizzoRivenditore)(distanceMagazzino4)
	        };

	        idMagazzino = 1;
	        distance = distanceMagazzino1;
	        println@Console("Il magazzino #" + idMagazzino + " dista " + distance + "km dal rivenditore")();
			query = "INSERT INTO temp_distanze_rivenditore_magazzini
					 (idRivenditore, idMagazzino, distanza)
					 VALUES
					 (" + idRivenditore + ", " + idMagazzino + ", " + distance + ")";
			update@Database( query )( responseNewDistance );

	        idMagazzino = 2;
	        distance = distanceMagazzino2;
	        println@Console("Il magazzino #" + idMagazzino + " dista " + distance + "km dal rivenditore")();
			query = "INSERT INTO temp_distanze_rivenditore_magazzini
					 (idRivenditore, idMagazzino, distanza)
					 VALUES
					 (" + idRivenditore + ", " + idMagazzino + ", " + distance + ")";
			update@Database( query )( responseNewDistance );

	        idMagazzino = 3;
	        distance = distanceMagazzino3;
	        println@Console("Il magazzino #" + idMagazzino + " dista " + distance + "km dal rivenditore")();
			query = "INSERT INTO temp_distanze_rivenditore_magazzini
					 (idRivenditore, idMagazzino, distanza)
					 VALUES
					 (" + idRivenditore + ", " + idMagazzino + ", " + distance + ")";
			update@Database( query )( responseNewDistance );

	        idMagazzino = 4;
	        distance = distanceMagazzino4;
	        println@Console("Il magazzino #" + idMagazzino + " dista " + distance + "km dal rivenditore")();
			query = "INSERT INTO temp_distanze_rivenditore_magazzini
					 (idRivenditore, idMagazzino, distanza)
					 VALUES
					 (" + idRivenditore + ", " + idMagazzino + ", " + distance + ")";
			update@Database( query )( responseNewDistance );

			query = "SELECT Ordine.idOrdine,
							Ordine_has_Accessorio.idAccessorio,
							Ordine_has_Accessorio.quantitaAccessorio AS qta_richiesta,
                            magazzino_has_accessorio.idMagazzino,
                            magazzino_has_accessorio.quantita AS qta_disponibile,
                            temp_distanze_rivenditore_magazzini.distanza
					 FROM Ordine_has_Accessorio
					 LEFT JOIN Accessorio ON Ordine_has_Accessorio.idAccessorio = Accessorio.idAccessorio
                     LEFT JOIN magazzino_has_accessorio ON Ordine_has_Accessorio.idAccessorio = magazzino_has_accessorio.idAccessorio
                     LEFT JOIN Ordine ON Ordine_has_Accessorio.idOrdine = Ordine.idOrdine
                     LEFT JOIN temp_distanze_rivenditore_magazzini ON magazzino_has_accessorio.idMagazzino = temp_distanze_rivenditore_magazzini.idMagazzino AND
																	Ordine.idRivenditore = temp_distanze_rivenditore_magazzini.idRivenditore
					 WHERE Ordine_has_Accessorio.idOrdine = " + params.idOrdine + " AND
							tipologia IN ('Non assemblabile', 'Assemblabile facilmente') AND
                            magazzino_has_accessorio.quantita > 0
					ORDER BY temp_distanze_rivenditore_magazzini.distanza ASC";
        	query@Database( query )( accessoriMagazzini );

        	for ( i = 0, i < #accessoriMagazzini.row, i++ ) {
		        idOrdine = accessoriMagazzini.row[i].idOrdine;
		        idAccessorio = accessoriMagazzini.row[i].idAccessorio;
		        idMagazzino = accessoriMagazzini.row[i].idMagazzino;

        		qta_disponibile = accessoriMagazzini.row[i].qta_disponibile;
		        accessori_ordine.(idAccessorio).qta_richiesta = accessoriMagazzini.row[i].qta_richiesta;
		        qta_mancante = accessori_ordine.(idAccessorio).qta_richiesta - accessori_ordine.(idAccessorio).qta_prenotata;

		        /*println@Console("\nqta_disponibile = "+qta_disponibile)();
		        println@Console("accessori_ordine.("+idAccessorio+").qta_richiesta = "+accessori_ordine.(idAccessorio).qta_richiesta)();
		        println@Console("qta_mancante = "+qta_mancante)();*/

		        if(qta_mancante > 0){
			        if(qta_disponibile >= accessori_ordine.(idAccessorio).qta_richiesta){
			           	qta_prenotabile = accessori_ordine.(idAccessorio).qta_richiesta
			        } else { // qta_disponibile < qta_richiesta
			           	qta_prenotabile = qta_disponibile
			        }

			        accessori_ordine.(idAccessorio).qta_prenotata += qta_prenotabile;

			        /*println@Console("\nqta_prenotabile = "+qta_prenotabile)();
			        println@Console("accessori_ordine.("+idAccessorio+").qta_prenotata = "+accessori_ordine.(idAccessorio).qta_prenotata)();*/

			        println@Console("\nIl magazzino #" + idMagazzino + " possiede "+qta_disponibile+" qta su "+qta_mancante+" qta ancora necessarie ("+qta_prenotabile+" prenotabili) dell'accessorio #"+idAccessorio+" per l'ordine #" + idOrdine)();

			        if(qta_prenotabile > 0) {
			            query = "INSERT INTO Magazzino_accessorio_prenotato
					            (idOrdine, idMagazzino, idAccessorio, quantita)
					            VALUES
					            (" + idOrdine + ", " + idMagazzino + ", " + idAccessorio + ", " + qta_prenotabile + ")";
						update@Database( query )( responseNewPrenotazioneAccessorio );
						println@Console("Prenoto " + qta_prenotabile + " qta dell'accessorio #" + idAccessorio + " nel magazzino #" + idMagazzino + " per l'ordine #" + idOrdine)();

						query = "UPDATE magazzino_has_accessorio
								 SET quantita = quantita - " + qta_prenotabile + "
								 WHERE idMagazzino = " + idMagazzino + " AND idAccessorio = " + idAccessorio;
						update@Database( query )( responseScaloQtaMagazzino );
						println@Console("Ho scalato " + qta_prenotabile + " qta dell'accessorio #" + idAccessorio + " dal magazzino #" + idMagazzino + " poiche' prenotate")()
			        }
		    	}
	        }

	        response.message = "Tutti i magazzini sono stati interrogati";
	        println@Console("\n" + response.message)()
	    }
	] {
		println@Console("\n[sceltaMagazzinoPiuVicinoSedeCliente] COMPLETED\n")()
	}

	[
		calcoloPreventivo ( params )( response ) {

			with( response ){
	          .totaleAccessori = 0.0;
	          .spedizioniAccessori = 0.0;
	          .totaleCicli = 0.0;
	          .spedizioniComponenti = 0.0;
	          .totaleCustomizzazioni = 0.0;
	          .totaleCorriere = 0.0;
	          .totalePreventivo = 0.0;
	          .sogliaSconto = 800.00;
	          .ordineContieneMaterialiPrenotatiMP = false;
	          .ordineContieneMaterialiPrenotatiMS = false;
	          .ordineContieneMaterialiDaOrdinareDaFornitore = false;
	          .tuttiAccessoriPresentiNeiMagazzini = true
	        }

	        with( costi_trasporti ){
	          .acme = 0.05;
	          .fornitore_fisso = 10.0;
	          .corriere = 0.10
	        }

	        // Magazzino più vicino al rivenditore

	        query = "SELECT idMagazzino
					FROM temp_distanze_rivenditore_magazzini
					WHERE idRivenditore = " + params.idRivenditore + "
					ORDER BY distanza ASC
					LIMIT 1";
        	query@Database( query )( resultMagazzinoPiuVicinoRivenditore );

        	idMagazzinoPiuVicinoRivenditore = resultMagazzinoPiuVicinoRivenditore.row[0].idMagazzino;

	        // Calcolo prezzo tutti accessori
	        query = "SELECT ROUND(SUM(tot), 2) AS tot
					FROM (
						SELECT  ordine.idOrdine,
								ordine_has_accessorio.idAccessorio,
								ordine_has_accessorio.quantitaAccessorio,
								accessorio.prezzoAccessorio,
                                (ordine_has_accessorio.quantitaAccessorio * accessorio.prezzoAccessorio) AS tot
						FROM ordine
						LEFT JOIN ordine_has_accessorio ON ordine.idOrdine = ordine_has_accessorio.idOrdine
						LEFT JOIN accessorio ON ordine_has_accessorio.idAccessorio = accessorio.idAccessorio
						WHERE ordine.idOrdine = " + params.idOrdine + "
					) AS tot";
        	query@Database( query )( result_tot_prezzo_accessori );

        	response.totaleAccessori += result_tot_prezzo_accessori.row[0].tot;
        	println@Console("\nTotale accessori (senza spedizioni): " + response.totaleAccessori + " EUR")();

        	// Calcolo prezzo tutti cicli
        	query = "SELECT ROUND(SUM(tot), 2) AS tot
					FROM (
					SELECT SUM(tot) AS tot
						FROM (
							SELECT  ordine.idOrdine,
									ordine_has_ciclo.idCiclo,
									ordine_has_ciclo.quantitaCiclo,
									ciclo.prezzoCiclo,
									(ordine_has_ciclo.quantitaCiclo * ciclo.prezzoCiclo) AS tot
							FROM ordine
							LEFT JOIN ordine_has_ciclo ON ordine.idOrdine = ordine_has_ciclo.idOrdine
							LEFT JOIN ciclo ON ordine_has_ciclo.idCiclo = ciclo.idCiclo
							WHERE ordine.idOrdine = " + params.idOrdine + "
						) AS tot
					GROUP BY idOrdine, idCiclo
				) AS tot_complessivo";
        	query@Database( query )( result_tot_prezzo_cicli );

        	response.totaleCicli += result_tot_prezzo_cicli.row[0].tot;
        	println@Console("\nTotale cicli (senza spedizioni): " + response.totaleCicli + " EUR")();

        	// Calcolo prezzo tutte customizzazioni
        	query = "SELECT ROUND(SUM(tot), 2) AS tot
					FROM (
					SELECT SUM(tot) AS tot
						FROM (
							SELECT  ordine.idOrdine,
									ordine_has_ciclo.idCiclo,
									ordine_has_ciclo.quantitaCiclo,
                                    ordine_has_ciclo_has_customizzazione.idCustomizzazione,
                                    customizzazione.prezzoCustomizzazione,
									(ordine_has_ciclo.quantitaCiclo * customizzazione.prezzoCustomizzazione) AS tot
							FROM ordine
							LEFT JOIN ordine_has_ciclo ON ordine.idOrdine = ordine_has_ciclo.idOrdine
							LEFT JOIN ordine_has_ciclo_has_customizzazione ON ordine.idOrdine = ordine_has_ciclo_has_customizzazione.idOrdine AND
																			  ordine_has_ciclo.idCiclo = ordine_has_ciclo_has_customizzazione.idCiclo
							LEFT JOIN customizzazione ON ordine_has_ciclo_has_customizzazione.idCustomizzazione = customizzazione.idCustomizzazione
							WHERE ordine.idOrdine = " + params.idOrdine + "
						) AS tot
					GROUP BY idOrdine, idCiclo
				) AS tot_complessivo";
        	query@Database( query )( result_tot_prezzo_customizzazioni );

        	response.totaleCustomizzazioni += result_tot_prezzo_customizzazioni.row[0].tot;
        	println@Console("\nTotale customizzazioni (senza spedizioni): " + response.totaleCustomizzazioni + " EUR")();

        	// Calcolo spese spedizioni accessori

			println@Console("\n*** Calcolo spese spedizioni accessori [prenotati] ***")();

			query = "SELECT	ordine_has_accessorio.idOrdine,
						ordine_has_accessorio.idAccessorio,
						accessorio.tipologia,
						ordine_has_accessorio.quantitaAccessorio AS qta_richiesta_iniziale,
						CASE WHEN magazzino_accessorio_prenotato.quantita IS NULL
							THEN 0
							ELSE magazzino_accessorio_prenotato.quantita
						END AS qta_prenotata,
						magazzino_accessorio_prenotato.idMagazzino
					FROM ordine_has_accessorio
					LEFT JOIN accessorio ON ordine_has_accessorio.idAccessorio = accessorio.idAccessorio
					LEFT JOIN magazzino_accessorio_prenotato ON ordine_has_accessorio.idOrdine = magazzino_accessorio_prenotato.idOrdine AND
																ordine_has_accessorio.idAccessorio = magazzino_accessorio_prenotato.idAccessorio
					WHERE ordine_has_accessorio.idOrdine = " + params.idOrdine + "
					ORDER BY ordine_has_accessorio.idAccessorio";
        	query@Database( query )( accessoriPrenotati );

	        for ( i = 0, i < #accessoriPrenotati.row, i++ ) {
	            idAccessorio = accessoriPrenotati.row[i].idAccessorio;
	            qta_richiesta_iniziale = accessoriPrenotati.row[i].qta_richiesta_iniziale;
	            qta_prenotata = accessoriPrenotati.row[i].qta_prenotata;
	            idMagazzino = accessoriPrenotati.row[i].idMagazzino;
	            tipologia = accessoriPrenotati.row[i].tipologia;

	            if(idMagazzino == 1){
	            	response.ordineContieneMaterialiPrenotatiMP = true
	            } else if(idMagazzino == 2 || idMagazzino == 3 || idMagazzino == 4){
	            	response.ordineContieneMaterialiPrenotatiMS = true
	            }

	            if(idMagazzino == 0) {
	            	// accessorio non prenotato perchè non presente in magazzino

	            	response.ordineContieneMaterialiDaOrdinareDaFornitore = true;

	            	costo_fornitore = costi_trasporti.fornitore_fisso;
	            	response.spedizioniAccessori += costo_fornitore;
	            	println@Console("\nL'accessorio #" + idAccessorio + " NON e' stato prenotato e quindi deve essere acquistato dal fornitore. Il costo fisso per la spedizione del fornitore e' di " + costo_fornitore + " EUR")()

	            } else if(tipologia == "Assemblabile" && idMagazzino == 1){

	            	println@Console("\nL'accessorio #" + idAccessorio + " si trova gia' nel magazzino #1. Trasferimento non necessario")()

	            } else if(tipologia == "Assemblabile" && idMagazzino != 1) {
	            	// accessorio da assemblare nella Sede Principale
	            	// -> reperimento degli accessori dai magazzini secondari

	            	query = "SELECT ROUND(distanza, 2) AS distanza
							 FROM temp_distanze_magazzino_magazzino
							 WHERE idMagazzinoPartenza = " + idMagazzino + " AND idMagazzinoArrivo = " + 1;
        			query@Database( query )( distance );

        			distanza = distance.row[0].distanza;
        			costo_trasporto = distanza * costi_trasporti.acme;
        			response.spedizioniAccessori += costo_trasporto;

        			roundRequest = costo_trasporto;
			        roundRequest.decimals = 2;
			        round@Math(roundRequest)(roundResponse);
			        costo_trasporto = roundResponse;

        			println@Console("\nL'accessorio #" + idAccessorio + " (" + tipologia + ") deve essere trasferito dal magazzino #"+ idMagazzino + " alla Sede Principale (Assemblaggio). Tale trasporto costera' " + costo_trasporto + " EUR (" + distanza + "km x " + costi_trasporti.acme + " EUR/km)")()

	            } else if((tipologia == "Non assemblabile" || tipologia == "Assemblabile facilmente") && idMagazzino == idMagazzinoPiuVicinoRivenditore){

	            	println@Console("\nL'accessorio #" + idAccessorio + " si trova gia' nel magazzino #" + idMagazzinoPiuVicinoRivenditore + " piu' vicino al rivenditore. Trasferimento non necessario")()

	            } else if((tipologia == "Non assemblabile" || tipologia == "Assemblabile facilmente") && idMagazzino != idMagazzinoPiuVicinoRivenditore){
	            	// accessorio da non assemblare o assemblare facilmente
	            	// -> spedizione da magazzino acme verso il magazzino acme più vicino al rivenditore

	            	query = "SELECT ROUND(distanza, 2) AS distanza
							FROM temp_distanze_magazzino_magazzino
							WHERE idMagazzinoPartenza = " + idMagazzino + " AND idMagazzinoArrivo = " + idMagazzinoPiuVicinoRivenditore;
        			query@Database( query )( distance );

        			distanza = distance.row[0].distanza;
        			costo_trasporto = distanza * costi_trasporti.acme;
        			response.spedizioniAccessori += costo_trasporto;

        			roundRequest = costo_trasporto;
			        roundRequest.decimals = 2;
			        round@Math(roundRequest)(roundResponse);
			        costo_trasporto = roundResponse;

        			println@Console("\nL'accessorio #" + idAccessorio + " (" + tipologia + ") deve essere trasferito dal magazzino #"+ idMagazzino + " al magazzino #" + idMagazzinoPiuVicinoRivenditore + ". Tale trasporto costera' " + costo_trasporto + " EUR (" + distanza + "km x " + costi_trasporti.acme + " EUR/km)")()
	            }
	        }

	        // Alcuni accessori non presenti nei magazzini

	        println@Console("\n*** Calcolo spese spedizioni accessori [NON prenotati] ***")();

	        query = "SELECT	ordine_has_accessorio.idOrdine,
						ordine_has_accessorio.idAccessorio,
						accessorio.tipologia,
						ordine_has_accessorio.quantitaAccessorio AS qta_richiesta_iniziale,
						SUM(magazzino_accessorio_prenotato.quantita) AS qta_prenotata
					FROM ordine_has_accessorio
					LEFT JOIN accessorio ON ordine_has_accessorio.idAccessorio = accessorio.idAccessorio
					LEFT JOIN magazzino_accessorio_prenotato ON ordine_has_accessorio.idOrdine = magazzino_accessorio_prenotato.idOrdine AND
																ordine_has_accessorio.idAccessorio = magazzino_accessorio_prenotato.idAccessorio
					WHERE ordine_has_accessorio.idOrdine = " + params.idOrdine + "
                    GROUP BY ordine_has_accessorio.idOrdine, ordine_has_accessorio.idAccessorio
                    HAVING SUM(magazzino_accessorio_prenotato.quantita) < ordine_has_accessorio.quantitaAccessorio
					ORDER BY ordine_has_accessorio.idAccessorio";
        	query@Database( query )( accessoriFornitore );

	        for ( i = 0, i < #accessoriFornitore.row, i++ ) {
	        	qta_richiesta_iniziale = accessoriFornitore.row[i].qta_richiesta_iniziale;
	        	qta_prenotata = accessoriFornitore.row[i].qta_prenotata;
	        	idAccessorio = accessoriFornitore.row[i].idAccessorio;

	        	if(qta_prenotata < qta_richiesta_iniziale){

					response.ordineContieneMaterialiDaOrdinareDaFornitore = true;
					response.tuttiAccessoriPresentiNeiMagazzini = false;

	        		costo_fornitore = costi_trasporti.fornitore_fisso;
	            	response.spedizioniAccessori += costo_fornitore;
	    			println@Console("\nL'accessorio #" + idAccessorio + " NON e' stato prenotato in tutte le quantita' necessarie, quindi deve essere acquistato dal fornitore. Il costo fisso per la spedizione del fornitore e' di " + costo_fornitore + " EUR")()
	        	}
	        }

	        roundRequest = response.spedizioniAccessori;
			roundRequest.decimals = 2;
			round@Math(roundRequest)(roundResponse);
			response.spedizioniAccessori = roundResponse;

	        println@Console("\nTotale spedizioni accessori: " + response.spedizioniAccessori + " EUR")();

	        println@Console("\nTotale accessori (incluse spedizioni): " + (response.totaleAccessori + response.spedizioniAccessori) + " EUR")();

	        // Calcolo spese spedizioni componenti

			println@Console("\n*** Calcolo spese spedizioni componenti [prenotati] ***")();

			query = "SELECT	Ordine_has_Ciclo.idOrdine,
						Ordine_has_Ciclo.idCiclo,
						Ciclo_has_Componente.idComponente,
						(1 * Ordine_has_Ciclo.quantitaCiclo) qta_richiesta_iniziale,
						CASE WHEN Magazzino_componente_prenotato.quantita IS NULL
							THEN 0
							ELSE Magazzino_componente_prenotato.quantita
						END AS qta_prenotata,
						Magazzino_componente_prenotato.idMagazzino
					FROM Ordine_has_Ciclo
					LEFT JOIN ciclo ON Ordine_has_Ciclo.idCiclo = ciclo.idCiclo
                    LEFT JOIN Ciclo_has_Componente ON ciclo.idCiclo = Ciclo_has_Componente.idCiclo
					LEFT JOIN Magazzino_componente_prenotato ON Ordine_has_Ciclo.idOrdine = Magazzino_componente_prenotato.idOrdine AND
																Ciclo_has_Componente.idComponente = Magazzino_componente_prenotato.idComponente
					WHERE Ordine_has_Ciclo.idOrdine = " + params.idOrdine + "
					ORDER BY Ordine_has_Ciclo.idCiclo, Ciclo_has_Componente.idComponente";
        	query@Database( query )( componentiPrenotati );

	        for ( i = 0, i < #componentiPrenotati.row, i++ ) {
	            idCiclo = componentiPrenotati.row[i].idCiclo;
	            idComponente = componentiPrenotati.row[i].idComponente;
	            qta_richiesta_iniziale = componentiPrenotati.row[i].qta_richiesta_iniziale;
	            qta_prenotata = componentiPrenotati.row[i].qta_prenotata;
	            idMagazzino = componentiPrenotati.row[i].idMagazzino;

	            if(idMagazzino == 1){
	            	response.ordineContieneMaterialiPrenotatiMP = true
	            } else if(idMagazzino == 2 || idMagazzino == 3 || idMagazzino == 4){
	            	response.ordineContieneMaterialiPrenotatiMS = true
	            }

	            if(idMagazzino == 0) {
	            	// componente non prenotato perchè non presente in magazzino

	            	response.ordineContieneMaterialiDaOrdinareDaFornitore = true;

	            	costo_fornitore = costi_trasporti.fornitore_fisso;
	            	response.spedizioniComponenti += costo_fornitore;
	            	println@Console("\nIl componente #" + idComponente + " del ciclo #" + idCiclo + " NON e' stato prenotato e quindi deve essere acquistato dal fornitore. Il costo fisso per la spedizione del fornitore e' di " + costo_fornitore + " EUR")()

	            } else if(idMagazzino == 1){

	            	println@Console("\nIl componente #" + idComponente + " del ciclo #" + idCiclo + " si trova gia' nel magazzino #1. Trasferimento non necessario")()

	            } else if(idMagazzino != 1) {
	            	// componente nella Sede Principale
	            	// -> reperimento componenti dai magazzini secondari

	            	query = "SELECT ROUND(distanza, 2) AS distanza
							 FROM temp_distanze_magazzino_magazzino
							 WHERE idMagazzinoPartenza = " + idMagazzino + " AND idMagazzinoArrivo = " + 1;
        			query@Database( query )( distance );

        			distanza = distance.row[0].distanza;
        			costo_trasporto = distanza * costi_trasporti.acme;
        			response.spedizioniComponenti += costo_trasporto;

        			roundRequest = costo_trasporto;
			        roundRequest.decimals = 2;
			        round@Math(roundRequest)(roundResponse);
			        costo_trasporto = roundResponse;

        			println@Console("\nIl componente #" + idComponente + " del ciclo #" + idCiclo + " deve essere trasferito dal magazzino #"+ idMagazzino + " alla Sede Principale (Assemblaggio). Tale trasporto costera' " + costo_trasporto + " EUR (" + distanza + "km x " + costi_trasporti.acme + " EUR/km)")()
	            }
	        }

	        // Alcuni componenti non presenti nei magazzini

	        println@Console("\n*** Calcolo spese spedizioni componenti [NON prenotati] ***")();

	        query = "SELECT	Ordine_has_Ciclo.idOrdine,
						Ordine_has_Ciclo.idCiclo,
						Ciclo_has_Componente.idComponente,
						(1 * Ordine_has_Ciclo.quantitaCiclo) AS qta_richiesta_iniziale,
						SUM(Magazzino_componente_prenotato.quantita) AS qta_prenotata
					FROM Ordine_has_Ciclo
					LEFT JOIN ciclo ON Ordine_has_Ciclo.idCiclo = ciclo.idCiclo
                    LEFT JOIN Ciclo_has_Componente ON ciclo.idCiclo = Ciclo_has_Componente.idCiclo
					LEFT JOIN Magazzino_componente_prenotato ON Ordine_has_Ciclo.idOrdine = Magazzino_componente_prenotato.idOrdine AND
																Ordine_has_Ciclo.idCiclo = Magazzino_componente_prenotato.idCiclo AND 
																Ciclo_has_Componente.idComponente = Magazzino_componente_prenotato.idComponente
					WHERE Ordine_has_Ciclo.idOrdine = " + params.idOrdine + "
                    GROUP BY Ordine_has_Ciclo.idOrdine, Ordine_has_Ciclo.idCiclo, Ciclo_has_Componente.idComponente
                    HAVING SUM(Magazzino_componente_prenotato.quantita) IS NOT NULL
					ORDER BY Ordine_has_Ciclo.idCiclo, Ciclo_has_Componente.idComponente";
        	query@Database( query )( componentiFornitore );

	        for ( i = 0, i < #componentiFornitore.row, i++ ) {
	        	qta_richiesta_iniziale = componentiFornitore.row[i].qta_richiesta_iniziale;
	        	qta_prenotata = componentiFornitore.row[i].qta_prenotata;
	        	idCiclo = componentiFornitore.row[i].idCiclo;
	        	idComponente = componentiFornitore.row[i].idComponente;

	        	if(qta_prenotata < qta_richiesta_iniziale){

					response.ordineContieneMaterialiDaOrdinareDaFornitore = true;

	        		costo_fornitore = costi_trasporti.fornitore_fisso;
	            	response.spedizioniComponenti += costo_fornitore;
	    			println@Console("\nIl componente #" + idComponente + " del ciclo #" + idCiclo + " NON e' stato prenotato in tutte le quantita' necessarie, quindi deve essere acquistato dal fornitore. Il costo fisso per la spedizione del fornitore e' di " + costo_fornitore + " EUR")()
	        	}
	        }

	        roundRequest = response.spedizioniComponenti;
			roundRequest.decimals = 2;
			round@Math(roundRequest)(roundResponse);
			response.spedizioniComponenti = roundResponse;

	        println@Console("\nTotale spedizioni componenti: " + response.spedizioniComponenti + " EUR")();

	        println@Console("\nTotale cicli (incluse spedizioni): " + (response.totaleCicli + response.spedizioniComponenti) + " EUR")();

	        // Calcolo spedizioni corriere

	        println@Console("\n*** Calcolo spese spedizioni Corriere ***")();

	        // Accessori non assemblabili/assemblabili facilmente

	        query = "SELECT COUNT(Ordine_has_Accessorio.idAccessorio) AS n_accessori_non_assemblabili
					FROM Ordine_has_Accessorio
					LEFT JOIN accessorio ON Ordine_has_Accessorio.idAccessorio = accessorio.idAccessorio
					WHERE Ordine_has_Accessorio.idOrdine = " + params.idOrdine + " AND 
						  accessorio.tipologia IN ('Non assemblabile', 'Assemblabile facilmente')";
        	query@Database( query )( accessoriNonAssemblabili );

        	n_accessori_non_assemblabili = accessoriNonAssemblabili.row[0].n_accessori_non_assemblabili;

        	// spedizione dal magazzino più vicino al rivenditore
        	if(n_accessori_non_assemblabili > 0 && idMagazzinoPiuVicinoRivenditore != 1){
        		query = "SELECT distanza
						FROM temp_distanze_rivenditore_magazzini
						WHERE idMagazzino = " + idMagazzinoPiuVicinoRivenditore + " AND idRivenditore = " + params.idRivenditore;
        		query@Database( query )( resultDistanza );

        		distanza = resultDistanza.row[0].distanza;
        		costo_fornitore = distanza * costi_trasporti.corriere;
	            response.totaleCorriere += costo_fornitore;

	            roundRequest = costo_fornitore;
			    roundRequest.decimals = 2;
			    round@Math(roundRequest)(roundResponse);
			    costo_fornitore = roundResponse;

	        	println@Console("\nLa spedizione del Corriere (per gli accessori da non assemblare/assemblare facilmente) dal magazzino #" + idMagazzinoPiuVicinoRivenditore + " al rivenditore #" + params.idRivenditore + " costa " + costo_fornitore + " EUR (" + distanza + "km x " + costi_trasporti.corriere + " EUR/km)")()

        	} else if(idMagazzinoPiuVicinoRivenditore == 1) {
				println@Console("\nLa spedizione del Corriere (per gli accessori da non assemblare/assemblare facilmente) dal magazzino #" + idMagazzinoPiuVicinoRivenditore + " al rivenditore #" + params.idRivenditore + " verra' effettuata GRATIS assieme alla spedizione per i cicli")()
        	}

        	// Accessori da assemblare e Cicli

        	query = "SELECT COUNT(Ordine_has_Accessorio.idAccessorio) AS n_accessori_assemblabili
					FROM Ordine_has_Accessorio
					LEFT JOIN accessorio ON Ordine_has_Accessorio.idAccessorio = accessorio.idAccessorio
					WHERE Ordine_has_Accessorio.idOrdine = " + params.idOrdine + " AND 
						  accessorio.tipologia = 'Assemblabile'";
        	query@Database( query )( accessoriAssemblabili );

        	n_accessori_assemblabili = accessoriAssemblabili.row[0].n_accessori_assemblabili;

        	query = "SELECT COUNT(idCiclo) AS n_cicli
					FROM Ordine_has_Ciclo
					WHERE idOrdine = " + params.idOrdine;
        	query@Database( query )( cicli );

        	n_cicli = cicli.row[0].n_cicli;

        	// spedizione dall'assemblaggio (magazzino #1)
        	if(n_accessori_assemblabili > 0 || n_cicli > 0){
        		query = "SELECT distanza
						FROM temp_distanze_rivenditore_magazzini
						WHERE idMagazzino = " + 1 + " AND idRivenditore = " + params.idRivenditore;
        		query@Database( query )( resultDistanza );

        		distanza = resultDistanza.row[0].distanza;
        		costo_fornitore = distanza * costi_trasporti.corriere;
	            response.totaleCorriere += costo_fornitore;

	            roundRequest = costo_fornitore;
			    roundRequest.decimals = 2;
			    round@Math(roundRequest)(roundResponse);
			    costo_fornitore = roundResponse;

	        	println@Console("\nLa spedizione del Corriere (per gli accessori da assemblare e i cicli) dal magazzino #" + 1 + " al rivenditore #" + params.idRivenditore + " costa " + costo_fornitore + " EUR (" + distanza + "km x " + costi_trasporti.corriere + " EUR/km)")()
        	}

        	roundRequest = response.totaleCorriere;
			roundRequest.decimals = 2;
			round@Math(roundRequest)(roundResponse);
			response.totaleCorriere = roundResponse;

        	println@Console("\nTotale spedizioni corriere: " + response.totaleCorriere + " EUR")();

	        response.totalePreventivo = response.totaleAccessori + 
	        						response.spedizioniAccessori +
	        						response.totaleCicli + 
	        						response.spedizioniComponenti +
	        						response.totaleCustomizzazioni + 
	        						response.totaleCorriere;

	       	global.ordini.(params.idOrdine).ordineContieneMaterialiPrenotatiMP = response.ordineContieneMaterialiPrenotatiMP;
	       	global.ordini.(params.idOrdine).ordineContieneMaterialiPrenotatiMS = response.ordineContieneMaterialiPrenotatiMS;
	       	global.ordini.(params.idOrdine).ordineContieneMaterialiDaOrdinareDaFornitore = response.ordineContieneMaterialiDaOrdinareDaFornitore;
	       	global.ordini.(params.idOrdine).tuttiAccessoriPresentiNeiMagazzini = response.tuttiAccessoriPresentiNeiMagazzini;

	       	if(DEBUG){
				println@Console("global.ordini.("+params.idOrdine+").ordineContieneMaterialiPrenotatiMP = " + global.ordini.(params.idOrdine).ordineContieneMaterialiPrenotatiMP)();
				println@Console("global.ordini.("+params.idOrdine+").ordineContieneMaterialiPrenotatiMS = " + global.ordini.(params.idOrdine).ordineContieneMaterialiPrenotatiMS)();
				println@Console("global.ordini.("+params.idOrdine+").ordineContieneMaterialiDaOrdinareDaFornitore = " + global.ordini.(params.idOrdine).ordineContieneMaterialiDaOrdinareDaFornitore)();
				println@Console("global.ordini.("+params.idOrdine+").tuttiAccessoriPresentiNeiMagazzini = " + global.ordini.(params.idOrdine).tuttiAccessoriPresentiNeiMagazzini)()
			}

        	// Salvataggio nel db

	        roundRequest = response.totalePreventivo;
	        roundRequest.decimals = 2;
	        round@Math(roundRequest)(roundResponse);
	        response.totalePreventivo = roundResponse;

        	query = "UPDATE Ordine
					SET totalePreventivo = " + response.totalePreventivo + "
					WHERE idOrdine = " + params.idOrdine;
			update@Database( query )( resultUpdatePreventivo );

	        println@Console("\n- - - - - - - - - - - - - - - - - - - - - - ")()

	        println@Console("\nTotale preventivo (incluse spedizioni): " + response.totalePreventivo + " EUR")();
	        println@Console("\nSoglia sconto: " + response.sogliaSconto + " EUR")()

	    }
	] {
		println@Console("\n[calcoloPreventivo] COMPLETED\n")()
	}

	[
		applicazioneSconto ( params )( response ) {

			query = "UPDATE Ordine
					SET totalePreventivo = totalePreventivo - (totalePreventivo / 100 * " + params.percentualeSconto + ")
					WHERE idOrdine = " + params.idOrdine;
			update@Database( query )( resultUpdatePreventivo );

			response.message = "Sconto del " + params.percentualeSconto + "% applicato correttamente all'ordine #" + params.idOrdine;
			println@Console(response.message)()
	    }
	] {
		println@Console("\n[applicazioneSconto] COMPLETED\n")()
	}

	[
		invioPreventivo ( params )( response ) {

	        query = "SELECT totalePreventivo, totaleAnticipo, totaleSaldo
					FROM Ordine
					WHERE idOrdine = " + params.idOrdine;
        	query@Database( query )( preventivo );

        	ricezionePreventivo.idOrdine = params.idOrdine;
        	ricezionePreventivo.totalePreventivo = preventivo.row[0].totalePreventivo;
        	ricezionePreventivo.totaleAnticipo = preventivo.row[0].totaleAnticipo;
        	ricezionePreventivo.totaleSaldo = preventivo.row[0].totaleSaldo;

			if (params.idRivenditore == 1) {
				ricezionePreventivo@Rivenditore1( ricezionePreventivo )
	        } else if(params.idRivenditore == 2){
	            ricezionePreventivo@Rivenditore2( ricezionePreventivo )
	        }

			response.message = "Il preventivo di " + ricezionePreventivo.totalePreventivo + " EUR dell'ordine #" + ricezionePreventivo.idOrdine + " e' stato inviato correttamente al Rivenditore #" + params.idRivenditore;
			println@Console(response.message)()
	    }
	] {
		println@Console("\n[invioPreventivo] COMPLETED\n")()
	}

	[
		accettaPreventivo ( accettaPreventivo )
	] {
		// Message
		message.messageName = "AccettazionePreventivo";
		message.processVariables.accettazionePreventivo.value = accettaPreventivo.idOrdine;
		message.processVariables.accettazionePreventivo.type = "String";
		message@CamundaPort(message)(rit);

		println@Console("Il preventivo per l'ordine #" + accettaPreventivo.idOrdine + " e' stato Accettato")();

		println@Console("\n[accettaPreventivo] COMPLETED\n")()
	}

	[
		rifiutoPreventivo ( rifiutoPreventivo )
	] {
		// Message
		message.messageName = "RifiutoPreventivo";
		message.processVariables.rifiutoPreventivo.value = rifiutoPreventivo.idOrdine;
		message.processVariables.rifiutoPreventivo.type = "String";
		message@CamundaPort(message)(rit);

		println@Console("Il preventivo per l'ordine #" + accettaPreventivo.idOrdine + " e' stato Rifiutato")();

		println@Console("\n[rifiutoPreventivo] COMPLETED\n")()
	}

	[
		sbloccoPrenotazioniComponentiAccessoriMagazzini ( params )( response ) {

			query = "DELETE FROM acme.Magazzino_accessorio_prenotato
					 WHERE idOrdine = " + params.idOrdine;
			update@Database( query )( responseQuery );

			query = "DELETE FROM acme.Magazzino_componente_prenotato
					 WHERE idOrdine = " + params.idOrdine;
			update@Database( query )( responseQuery );

			response.message = "Tutte le prenotazioni dei materiali per l'ordine #" + params.idOrdine + " sono state sbloccate";
			println@Console(response.message)()
	    }
	] {
		println@Console("\n[sbloccoPrenotazioniComponentiAccessoriMagazzini] COMPLETED\n")()
	}

	[
		richiestaTrasferimentoMP ( params )( response ) {

			query = "DELETE FROM acme.Magazzino_accessorio_prenotato
					 WHERE idOrdine = " + params.idOrdine + " AND idMagazzino = 1 ";
			update@Database( query )( responseQuery );

			query = "DELETE FROM acme.Magazzino_componente_prenotato
					 WHERE idOrdine = " + params.idOrdine + " AND idMagazzino = 1 ";
			update@Database( query )( responseQuery );

			response.message = "Tutte le prenotazioni dei materiali per l'ordine #" + params.idOrdine + " nel Magazzino Principale sono state sbloccate";
			println@Console(response.message)()
	    }
	] {
		println@Console("\n[richiestaTrasferimentoMP] COMPLETED\n")()
	}

	[
		richiestaTrasferimentoMS ( params )( response ) {

			query = "DELETE FROM acme.Magazzino_accessorio_prenotato
					 WHERE idOrdine = " + params.idOrdine + " AND idMagazzino IN (2, 3, 4) ";
			update@Database( query )( responseQuery );

			query = "DELETE FROM acme.Magazzino_componente_prenotato
					 WHERE idOrdine = " + params.idOrdine + " AND idMagazzino IN (2, 3, 4) ";
			update@Database( query )( responseQuery );

			response.message = "Tutte le prenotazioni dei materiali per l'ordine #" + params.idOrdine + " nei Magazzini Secondari sono state sbloccate";
			println@Console(response.message)()
	    }
	] {
		println@Console("\n[richiestaTrasferimentoMS] COMPLETED\n")()
	}

	[
		recuperoVariabiliSessione ( params )( response ) {

			response.ordineContieneAccessoriDaNonAssemblare = global.ordini.(params.idOrdine).ordineContieneAccessoriDaNonAssemblare;
			response.ordineContieneMaterialiPrenotatiMP = global.ordini.(params.idOrdine).ordineContieneMaterialiPrenotatiMP;
			response.ordineContieneMaterialiPrenotatiMS = global.ordini.(params.idOrdine).ordineContieneMaterialiPrenotatiMS;
			response.ordineContieneMaterialiDaOrdinareDaFornitore = global.ordini.(params.idOrdine).ordineContieneMaterialiDaOrdinareDaFornitore;
			response.tuttiAccessoriPresentiNeiMagazzini = global.ordini.(params.idOrdine).tuttiAccessoriPresentiNeiMagazzini;

			if(DEBUG){
				println@Console("response.ordineContieneAccessoriDaNonAssemblare = " + response.ordineContieneAccessoriDaNonAssemblare)();
				println@Console("response.ordineContieneMaterialiPrenotatiMP = " + response.ordineContieneMaterialiPrenotatiMP)();
				println@Console("response.ordineContieneMaterialiPrenotatiMS = " + response.ordineContieneMaterialiPrenotatiMS)();
				println@Console("response.ordineContieneMaterialiDaOrdinareDaFornitore = " + response.ordineContieneMaterialiDaOrdinareDaFornitore)();
				println@Console("response.tuttiAccessoriPresentiNeiMagazzini = " + response.tuttiAccessoriPresentiNeiMagazzini)()
			}
	    }
	] {
		println@Console("\n[recuperoVariabiliSessione] COMPLETED\n")()
	}

	[
		verificaAnticipoConSistemaBancario ( params )( response ) {

			response.anticipoVerificato = false;

			// Login

			login.username = "ACME";
			login.password = "5tueh34tw24yrfhswe4";
			println@Console("Accedo alla Banca con dati [username = \"" + login.username + "\", password = \"" + login.password + "\"]...\n")();
	    	login@Banca(login)(loginResponse);

	    	println@Console("Effettuo il check payment con l'authKey fornita dalla Banca (" + loginResponse.authKey + ")...\n")();

	    	if(loginResponse.authenticated) {

		    	// Check payment (Anticipo)

		    	query = "SELECT totaleAnticipo
						FROM Ordine
						WHERE idOrdine = " + params.idOrdine;
	        	query@Database( query )( preventivo );
	        	
	        	amout = preventivo.row[0].totaleAnticipo;

	        	checkPayment.authKey = loginResponse.authKey;
	        	checkPayment.transactionToken = global.ordini.(params.idOrdine).transactionTokenAnticipo;
	        	checkPayment.amount = amout;
	        	checkPayment@Banca(checkPayment)(checkPaymentResponse);

	        	if(checkPaymentResponse.result) {
	        		response.anticipoVerificato = true;
	        		response.message = "VERIFICATO pagamento Anticipo con amount di EUR " + checkPayment.amount + " e transaction token " + checkPayment.transactionToken
	        	} else {
	        		response.message = "NON VERIFICATO pagamento Anticipo con amount di EUR " + checkPayment.amount + " e transaction token " + checkPayment.transactionToken
	        	}

	        	println@Console(response.message)()
	    	}
	    }
	] {
		println@Console("\n[verificaAnticipoConSistemaBancario] COMPLETED\n\n")()
	}

	[
		verificaSaldoConSistemaBancario ( params )( response ) {

			response.saldoVerificato = false;

			// Login

			login.username = "ACME";
			login.password = "5tueh34tw24yrfhswe4";
			println@Console("Accedo alla Banca con dati [username = \"" + login.username + "\", password = \"" + login.password + "\"]...\n")();
	    	login@Banca(login)(loginResponse);

	    	println@Console("Effettuo il check payment con l'authKey fornita dalla Banca (" + loginResponse.authKey + ")...\n")();

	    	if(loginResponse.authenticated) {

		    	// Check payment (Saldo)

		    	query = "SELECT totaleSaldo
						FROM Ordine
						WHERE idOrdine = " + params.idOrdine;
	        	query@Database( query )( preventivo );
	        	
	        	amout = preventivo.row[0].totaleSaldo;

	        	checkPayment.authKey = loginResponse.authKey;
	        	checkPayment.transactionToken = global.ordini.(params.idOrdine).transactionTokenSaldo;
	        	checkPayment.amount = amout;
	        	checkPayment@Banca(checkPayment)(checkPaymentResponse);

	        	if(checkPaymentResponse.result) {
	        		response.saldoVerificato = true;
	        		response.message = "VERIFICATO pagamento Saldo con amount di EUR " + checkPayment.amount + " e transaction token " + checkPayment.transactionToken
	        	} else {
	        		response.message = "NON VERIFICATO pagamento Saldo con amount di EUR " + checkPayment.amount + " e transaction token " + checkPayment.transactionToken
	        	}

	        	println@Console(response.message)()
	    	}
	    }
	] {
		println@Console("\n[verificaSaldoConSistemaBancario] COMPLETED\n\n")()
	}

	[
		ricevutaAnticipo ( params )
	] {
		global.ordini.(params.idOrdine).transactionTokenAnticipo = params.transactionToken;

		// Message
		message.messageName = "RicevutaAnticipo";
		message.processVariables.ricevutaAnticipo.value = params.transactionToken;
		message.processVariables.ricevutaAnticipo.type = "String";
		message@CamundaPort(message)(rit);

		println@Console("Ricevuto il transaction token dell'Anticipo per l'ordine #" + params.idOrdine + " (" + params.transactionToken + ")")();

		println@Console("\n[ricevutaAnticipo] COMPLETED\n")()
	}

	[
		ricevutaSaldo ( params )
	] {
		global.ordini.(params.idOrdine).transactionTokenSaldo = params.transactionToken;

		// Message
		message.messageName = "RicevutaSaldo";
		message.processVariables.ricevutaSaldo.value = params.transactionToken;
		message.processVariables.ricevutaSaldo.type = "String";
		message@CamundaPort(message)(rit);

		println@Console("Ricevuto il transaction token del Saldo per l'ordine #" + params.idOrdine + " (" + params.transactionToken + ")")();

		println@Console("\n[ricevutaSaldo] COMPLETED\n")()
	}

	[
		invioOrdineMaterialiNonPresentiFornitore ( params )( response ) {

			println@Console("Materiali non presenti per l'ordine #" + params.idOrdine + " richiesti al Fornitore\n")();

			richiestaComponentiAccessori.idOrdine = params.idOrdine;

			richiestaComponentiAccessori@Fornitore(richiestaComponentiAccessori)(responseRichiestaComponentiAccessori);

			response.message = responseRichiestaComponentiAccessori.message;

	        println@Console(response.message)()
	    }
	] {
		println@Console("\n[invioOrdineMaterialiNonPresentiFornitore] COMPLETED\n\n")()
	}
}
