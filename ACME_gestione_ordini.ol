
include "console.iol"
include "database.iol"
include "string_utils.iol"

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

    println@Console("\nACME GESTIONE ORDINI running...\n")();

    global.ordine = null
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
		println@Console("[richiediListino] COMPLETED")()
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
				idOrdine = responseNewOrdine.row[0].idOrdine;
				ordine.idOrdine = idOrdine;
				println@Console("Ordine #" + idOrdine + " inserito")()
			};

			// Inserimento Cicli Ordine nel db
			if(#ordine.cicli > 0) {
				scope ( insertCicliOrdine ) {
			       	install ( SQLException => println@Console("\n[!] ERRORE nell'inserimento ciclo ordine nel db\n")() );

					query = "INSERT INTO ordine_has_ciclo (idOrdine, idCiclo, quantitaCiclo) VALUES ";

					for ( i = 0, i < #ordine.cicli, i++ ) {
						idCiclo = ordine.cicli[i].idCiclo;
						quantitaCiclo = ordine.cicli[i].qta;
						query += "(" + idOrdine + ", " + idCiclo + ", " + quantitaCiclo + "),"
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
						query += "(" + idOrdine + ", " + idCiclo + ", " + idCustomizzazione + "),"
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
						query += "(" + idOrdine + ", " + idAccessorio + ", " + quantitaAccessorio + "),"
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

	        global.ordine << ordine;
	        undef(ordine);

			// Message
			message.messageName = "Ordine";
			message.processVariables.ordine.value = string( global.ordine.idOrdine );
			message.processVariables.ordine.type = "String";
			message@CamundaPort(message)(rit)
        }

		println@Console("[inviaOrdine] COMPLETED")()
	}

	[
		getIdOrdine( void )( idOrdine ) {

			idOrdine.idOrdine = string( global.ordine.idOrdine )
	    }
	] {
		println@Console("[getIdOrdine] COMPLETED")()
	}

	[
		getIdRivenditore( void )( idRivenditore ) {

			idRivenditore.idRivenditore = string( global.ordine.idRivenditore )
	    }
	] {
		println@Console("[getIdRivenditore] COMPLETED")()
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
		println@Console("[verificaCustomizzazioni] COMPLETED")()
	}

	[
		notificaCustomizzazioniNonRealizzabili ( notificaCustomizzazioniNonRealizzabili )( response ) {

			idRivenditore = notificaCustomizzazioniNonRealizzabili.idRivenditore;
			idOrdine = notificaCustomizzazioniNonRealizzabili.idOrdine;

			idOrdineMessage.idOrdine = idOrdine;

			if (idRivenditore == 1) {
				notificaCustomizzazioniNonRealizzabili@Rivenditore1( idOrdineMessage )
	        } else if(idRivenditore == 2){
	            notificaCustomizzazioniNonRealizzabili@Rivenditore2( idOrdineMessage )
	        }

			response.response = "Notifica customizzazioni NON realizzabili inviata al rivenditore #" + idRivenditore + " per l'ordine #" + idOrdine
	    }
	] {
		println@Console("[notificaCustomizzazioniNonRealizzabili] COMPLETED")()
	}

	[
		prenotazioneMaterialiPresentiMP ( params )( response ) {
			
			verificaDisponibilitaComponentiAccessori@MagazzinoPrincipale( params )( responseMagazzino );
			response.tuttiMaterialiRichiestiPresentiMP = responseMagazzino.tuttiMaterialiRichiestiPresenti;
			response.message = responseMagazzino.message
	    }
	] {
		println@Console("[prenotazioneMaterialiPresentiMP] COMPLETED")()
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

	        response.message = "Tutti i magazzini secondari secondari sono stati interrogati"
	    }
	] {
		println@Console("[prenotazioneMaterialiPresentiMS] COMPLETED")()
	}

	[
		sceltaMagazzinoPiuVicinoSedeCliente ( params )( response ) {

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

        	query = "SELECT idMagazzino
					 FROM Magazzino";
        	query@Database( query )( magazzini );

	        for ( i = 0, i < #magazzini.row, i++ ) {
	            idMagazzino = magazzini.row[i].idMagazzino;

	            if(idMagazzino == 1) {
					distanceFromRivenditore@MagazzinoPrincipale(indirizzoRivenditore)(distance)
	            } else if(idMagazzino == 2) {
					distanceFromRivenditore@MagazzinoSecondario1(indirizzoRivenditore)(distance)
	            } else if(idMagazzino == 3){
	            	distanceFromRivenditore@MagazzinoSecondario2(indirizzoRivenditore)(distance)
	            } else if(idMagazzino == 4){
	            	distanceFromRivenditore@MagazzinoSecondario3(indirizzoRivenditore)(distance)
	            }

	        	println@Console("Il magazzino #" + idMagazzino + " dista " + distance + "km dal rivenditore")();
				query = "INSERT INTO temp_distanze_rivenditore_magazzini
					     (idRivenditore, idMagazzino, distance)
					     VALUES
					     (" + idRivenditore + ", " + idMagazzino + ", " + distance + ")";
				update@Database( query )( responseNewDistance )
	        }



			query = "SELECT Ordine_has_Accessorio.idAccessorio,
					 		Ordine_has_Accessorio.quantitaAccessorio AS qta_richiesta,
					 		magazzino_has_accessorio.idMagazzino,
					 		magazzino_has_accessorio.quantita AS qta_magazzino
					 FROM Ordine_has_Accessorio
					 LEFT JOIN Accessorio ON Ordine_has_Accessorio.idAccessorio = Accessorio.idAccessorio
                     LEFT JOIN magazzino_has_accessorio ON Ordine_has_Accessorio.idAccessorio = magazzino_has_accessorio.idAccessorio
					 WHERE idOrdine = " + params.idOrdine + " AND tipologia IN ('Non assemblabile', 'Assemblabile facilmente') AND magazzino_has_accessorio.quantita > 0";
        	query@Database( query )( accessoriMagazzini );

        	for ( i = 0, i < #accessoriMagazzini.row, i++ ) {
        		with( response.accessoriMagazzini[i] ){
        		  .idAccessorio = accessoriMagazzini.row[i].idAccessorio;
        		  .idMagazzino = accessoriMagazzini.row[i].idMagazzino
        		}
        		println@Console("response.accessoriMagazzini["+i+"].idAccessorio = " + response.accessoriMagazzini[i].idAccessorio)();
        		println@Console("response.accessoriMagazzini["+i+"].idMagazzino = " + response.accessoriMagazzini[i].idMagazzino)()
	        }
	    }
	] {
		println@Console("[sceltaMagazzinoPiuVicinoSedeCliente] COMPLETED")()
	}
}





