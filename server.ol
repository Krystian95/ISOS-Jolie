
include "console.iol"
include "database.iol"
include "serverRivenditoreService.iol"

inputPort ServerRivenditoreInput {
	Location: "socket://localhost:8001"
	Protocol: soap
	Interfaces: ServerRivenditoreInterface
}

outputPort ServerRivenditoreOutput {
	Location: "socket://localhost:8002"
	Protocol: soap
	Interfaces: ServerRivenditoreInterface
}

execution{ concurrent }

init {
    with(connectionInfo) {
        .host = "127.0.0.1";
        .driver = "mysql";
        .port = 3306;
        //.port = 8889; //Impostazioni per MAMP (MAC)
        .database = "acme?serverTimezone=Europe/Rome";
        .username = "root";
        .password = "rootroot"
        //.password = "root" //Impostazioni per MAMP (MAC)
    };


    connect @Database(connectionInfo)();
    println @Console("Connection to databse: SUCCESS")()

    /* GLOBAL variable init here */

}

main
{
	[
		requestListino( void )( listino ) {
			query = "SELECT idAccessorio, nome FROM accessorio";
        	query@Database( query )( result );

	        i = 0;

	        while (i < #result.row) {
	            listino.lista[i].idAccessorio = result.row[i].idAccessorio[0];
	            listino.lista[i].nome = result.row[i].nome[0];
	            i++
	        }

	        println@Console(listino)()
	    }
	] {
		println@Console("Listino richiesto")()
	}
}





