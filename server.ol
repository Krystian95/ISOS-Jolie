
include "console.iol"
include "database.iol"

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


    connect @Database(connectionInfo)();
    println @Console("Connection to databse: SUCCESS")()

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
	            listino.cicli[i].idCiclo = string(resultCicli.row[i].idCiclo);
	            listino.cicli[i].modello = resultCicli.row[i].modello;
	            listino.cicli[i].colorazione = resultCicli.row[i].colorazione
	        }

			// Accessori
			query = "SELECT idAccessorio, nome FROM accessorio";
        	query@Database( query )( resultAccessori );

	        for ( i = 0, i < #resultAccessori.row, i++ ) {
	            listino.accessori[i].idAccessorio = string(resultAccessori.row[i].idAccessorio);
	            listino.accessori[i].nome = resultAccessori.row[i].nome
	        }

			// Customizzazioni
			query = "SELECT idCustomizzazione, tipologia, descrizione FROM customizzazione";
        	query@Database( query )( resultCustomizzazioni );

	        for ( i = 0, i < #resultCustomizzazioni.row, i++ ) {
	            listino.customizzazioni[i].idCustomizzazione = string(resultCustomizzazioni.row[i].idCustomizzazione);
	            listino.customizzazioni[i].tipologia = resultCustomizzazioni.row[i].tipologia;
	            listino.customizzazioni[i].descrizione = resultCustomizzazioni.row[i].descrizione
	        }
	    }
	] {
		println@Console("Listino richiesto")()
	}

	[
		inviaOrdine( ordine )( void ) {

			message.messageName = "Ordine";
            message.processVariables.ordine.value = "999";
            message.processVariables.ordine.type = "String";

            message@CamundaPort(message)(risp)

	    }
	] {
		println@Console("Ordine ricevuto")()
	}
}





