
include "console.iol"
include "database.iol"
include "string_utils.iol"

include "CamundaInterface.iol"

include "ACMERivenditoreInterface.iol"
include "ACMEGestioneOrdiniInterface.iol"

inputPort ACMEGestioneOrdiniRivenditoreInput {
	Location: "socket://localhost:8001"
	Protocol: soap
	Interfaces: ACMERivenditoreInterface
}

outputPort Camunda {
    Location: "socket://localhost:8080/engine-rest/"
    Protocol: http {
        .method = "post";
        .contentType = "application/json";
        .format = "json"
    }
    Interfaces: CamundaInterface
}

inputPort ACMEGestioneOrdini {
	Location: "socket://localhost:8000"
	Protocol: soap {
        .wsdl = "./wsdlACMEGestioneOrdini.wsdl";
        .wsdl.port = "ACMEGestioneOrdini";
        .dropRootValue = true
    }
	Interfaces: ACMEGestioneOrdiniInterface
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
    println@Console("Connection to databse: SUCCESS")();

    global.ordine = null
}

main
{
	[
		richiediListino( void )( listino ) {

			// Cicli
			query = "SELECT idCiclo, modello, colorazione FROM ciclo";
        	query@Database( query )( resultCicli );

	        for ( i = 0, i < #resultCicli.row, i++ ) {
	            listino.cicli[i].idCiclo = resultCicli.row[i].idCiclo;
	            listino.cicli[i].modello = resultCicli.row[i].modello;
	            listino.cicli[i].colorazione = resultCicli.row[i].colorazione
	        }

			// Customizzazioni
			query = "SELECT idCustomizzazione, tipologia, descrizione FROM customizzazione";
        	query@Database( query )( resultCustomizzazioni );

	        for ( i = 0, i < #resultCustomizzazioni.row, i++ ) {
	            listino.customizzazioni[i].idCustomizzazione = resultCustomizzazioni.row[i].idCustomizzazione;
	            listino.customizzazioni[i].tipologia = resultCustomizzazioni.row[i].tipologia;
	            listino.customizzazioni[i].descrizione = resultCustomizzazioni.row[i].descrizione
	        }

			// Accessori
			query = "SELECT idAccessorio, nome FROM accessorio";
        	query@Database( query )( resultAccessori );

	        for ( i = 0, i < #resultAccessori.row, i++ ) {
	            listino.accessori[i].idAccessorio = resultAccessori.row[i].idAccessorio;
	            listino.accessori[i].nome = resultAccessori.row[i].nome
	        }
	    }
	] {
		println@Console("– richiediListino [completed]")()
	}

	[
		inviaOrdine( ordine )( void ) {

			// Inserimento ordine nel db
			if(#ordine.cicli > 0 || #ordine.accessori > 0) {
				scope ( insertOrdine ) {
		        	install ( SQLException => println@Console("\n[!] ERRORE nell'inserimento ordine nel db\n")() );

					query = "INSERT INTO ordine (idRivenditore) VALUES (" + ordine.idRivenditore + ")";
					update@Database( query )( responseNewOrdine );

					query = "SELECT idOrdine FROM ordine WHERE idOrdine = (SELECT MAX(idOrdine) FROM ordine)";
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
	            ordine.messageName = "Ordine";
	            ordine.processVariables.idOrdine.value = string(global.ordine.idOrdine);
	            ordine.processVariables.idOrdine.type = "String";
	            ricezioneOrdine@Camunda(ordine)
        	}
	    }
	] {
		println@Console("– inviaOrdine [completed]")()
	}

	[
		getIdOrdine( void )( idOrdine ) {
			idOrdine.idOrdine = global.ordine.idOrdine
	    }
	] {
		println@Console("– getIdOrdine [completed]")()
	}

	[
		verificaCustomizzazioni( idOrdine )( esitoVerificaCustomizzazioni ) {

			
			 //TODO vertifica customizzazioni per specifico "idOrdine"
			 

			esitoVerificaCustomizzazioni.customizzazioniPossibili = false
	    }
	] {
		println@Console("– verificaCustomizzazioni [completed]")()
	}
}





