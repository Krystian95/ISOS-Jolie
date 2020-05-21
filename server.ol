
include "console.iol"
include "database.iol"
include "string_utils.iol"

include "serverRivenditoreService.iol"
include "camundaInterface.iol"

inputPort ServerRivenditoreInput {
	Location: "socket://localhost:8001"
	Protocol: soap
	Interfaces: RivenditoreServerInterface
}

outputPort ServerRivenditoreOutput {
	Location: "socket://localhost:8002"
	Protocol: soap
	Interfaces: RivenditoreServerInterface
}

outputPort CamundaPort {

    Location: "socket://localhost:8080/engine-rest/"
    Protocol: http {
        .method = "post";
        .contentType = "application/json";
        .format = "json"
    }
    Interfaces: CamundaInterface
}

execution{ concurrent }

init {
    with(connectionInfo) {
        .host = "127.0.0.1";
        .driver = "mysql";
        .port = 3306;
        .database = "acme?serverTimezone=Europe/Rome";
        .username = "root";
        .password = "rootroot"
    };


    connect@Database(connectionInfo)();
    println@Console("Connection to databse: SUCCESS")()

    /* GLOBAL variable init here */
}

main
{
	[
		requestListino( void )( listino ) {

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
		println@Console("Listino richiesto")()
	}

	[
		inviaOrdine( ordine )( void ) {

			// Inserimento ordine nel db
			scope ( insertOrdine ) {
	        	install ( SQLException => println@Console("[!] ERRORE nell'inserimento ordine nel db")() );
				query = "INSERT INTO ordine (idRivenditore) VALUES (" + ordine.idRivenditore + ")";
				update@Database( query )( responseNewOrdine );

				query = "SELECT idOrdine FROM ordine WHERE idOrdine = (SELECT MAX(idOrdine) FROM ordine)";
				query@Database( query )( responseNewOrdine );
				idOrdine = int(responseNewOrdine.row[0].idOrdine);
				println@Console("Ordine #" + idOrdine + " inserito")()
			};

			// Inserimento Accessori nel db
			scope ( insertAccessorioOrdine ) {
	        	install ( SQLException => println@Console("[!] ERRORE nell'inserimento accessorio ordine nel db")() );
				query = "INSERT INTO ordine_has_accessorio (idOrdine, idAccessorio, quantitaAccessorio)";

				for ( i = 0, i < #ordine.accessori, i++ ) {
					idAccessorio = ordine.accessori[i].idAccessorio
					quantitaAccessorio = ordine.accessori[i].qta
					query += "VALUES (" + idOrdine + ", " + idAccessorio + ", " + quantitaAccessorio + "),"
				}

				query_raw = query;
				query_raw.begin = 1;
				length@StringUtils( query )( queryLength );
				query_raw.end = queryLength - 1;
				println@Console("query end: " + #query)();
				println@Console("string end: " + query_raw.end)();
				substring@StringUtils( query_raw )( substringResponse );
				query = substringResponse;

	            update@Database( query )( responseNewOrdineAccessorio );
	            println@Console("Accessori Ordine inseriti")()
        	}

			// Message
			message.messageName = "Ordine";
            message.processVariables.ordine.value = "999";
            message.processVariables.ordine.type = "String";

            message@CamundaPort(message)(risp)
	    }
	] {
		println@Console("Ordine ricevuto")()
	}
}





