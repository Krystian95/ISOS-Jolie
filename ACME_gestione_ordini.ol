
include "console.iol"
include "database.iol"
include "string_utils.iol"
include "time.iol"

include "interfaces/CamundaInterface.iol"

include "interfaces/ACMEGestioneOrdiniInterface.iol"

include "interfaces/ACMERivenditoreInterface.iol"
include "interfaces/RivenditoreInterface.iol"

include "interfaces/ACMEMagazzinoInterface.iol"

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

execution { concurrent }

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

    println@Console("\nACME GESTIONE ORDINI running...\n")()
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
					 (idRivenditore, idMagazzino, distance)
					 VALUES
					 (" + idRivenditore + ", " + idMagazzino + ", " + distance + ")";
			update@Database( query )( responseNewDistance );

	        idMagazzino = 2;
	        distance = distanceMagazzino2;
	        println@Console("Il magazzino #" + idMagazzino + " dista " + distance + "km dal rivenditore")();
			query = "INSERT INTO temp_distanze_rivenditore_magazzini
					 (idRivenditore, idMagazzino, distance)
					 VALUES
					 (" + idRivenditore + ", " + idMagazzino + ", " + distance + ")";
			update@Database( query )( responseNewDistance );

	        idMagazzino = 3;
	        distance = distanceMagazzino3;
	        println@Console("Il magazzino #" + idMagazzino + " dista " + distance + "km dal rivenditore")();
			query = "INSERT INTO temp_distanze_rivenditore_magazzini
					 (idRivenditore, idMagazzino, distance)
					 VALUES
					 (" + idRivenditore + ", " + idMagazzino + ", " + distance + ")";
			update@Database( query )( responseNewDistance );

	        idMagazzino = 4;
	        distance = distanceMagazzino4;
	        println@Console("Il magazzino #" + idMagazzino + " dista " + distance + "km dal rivenditore")();
			query = "INSERT INTO temp_distanze_rivenditore_magazzini
					 (idRivenditore, idMagazzino, distance)
					 VALUES
					 (" + idRivenditore + ", " + idMagazzino + ", " + distance + ")";
			update@Database( query )( responseNewDistance );

			query = "SELECT Ordine.idOrdine,
							Ordine_has_Accessorio.idAccessorio,
							Ordine_has_Accessorio.quantitaAccessorio AS qta_richiesta,
                            magazzino_has_accessorio.idMagazzino,
                            magazzino_has_accessorio.quantita AS qta_disponibile,
                            temp_distanze_rivenditore_magazzini.distance
					 FROM Ordine_has_Accessorio
					 LEFT JOIN Accessorio ON Ordine_has_Accessorio.idAccessorio = Accessorio.idAccessorio
                     LEFT JOIN magazzino_has_accessorio ON Ordine_has_Accessorio.idAccessorio = magazzino_has_accessorio.idAccessorio
                     LEFT JOIN Ordine ON Ordine_has_Accessorio.idOrdine = Ordine.idOrdine
                     LEFT JOIN temp_distanze_rivenditore_magazzini ON magazzino_has_accessorio.idMagazzino = temp_distanze_rivenditore_magazzini.idMagazzino AND
																	Ordine.idRivenditore = temp_distanze_rivenditore_magazzini.idRivenditore
					 WHERE Ordine_has_Accessorio.idOrdine = " + params.idOrdine + " AND
							tipologia IN ('Non assemblabile', 'Assemblabile facilmente') AND
                            magazzino_has_accessorio.quantita > 0
					ORDER BY temp_distanze_rivenditore_magazzini.distance ASC";
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
	        println@Console(esponse.message)()
	    }
	] {
		println@Console("\n[sceltaMagazzinoPiuVicinoSedeCliente] COMPLETED\n")()
	}
}
