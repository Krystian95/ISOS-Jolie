
include "console.iol"
include "string_utils.iol"
include "time.iol"

include "interfaces/FornitoreInterface.iol"

// Porta ACME Gestione Ordini -> Fornitore
inputPort Fornitore {
	Location: "socket://localhost:8018"
	Protocol: soap
	Interfaces: FornitoreInterface
}

execution { sequential }

init {
	println@Console("\nFORNITORE is running...\n")()
}

main
{
	[
		richiestaComponentiAccessori ( params )( response ) {

			response.result = true;
			response.message = "Materiali richiesti per l'ordine #" + params.idOrdine + " PRESENTI dal Fornitore e spediti!";

	        println@Console(response.message)()
	    }
	] {
		println@Console("\n[richiestaComponentiAccessori] COMPLETED\n\n")()
	}
}
