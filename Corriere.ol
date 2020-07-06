
include "console.iol"
include "string_utils.iol"
include "time.iol"

include "interfaces/CorriereInterface.iol"

// Porta ACME Gestione Ordini -> Corriere
inputPort Corriere {
	Location: "socket://localhost:8019"
	Protocol: soap
	Interfaces: CorriereInterface
}

execution { sequential }

init {
	println@Console("\nCORRIERE is running...\n")()
}

main
{
	[
		invioOrdine ( params )( response ) {

			response.result = true;
			response.message = "Presa in carico spedizione Corriere per l'ordine #" + params.idOrdine + "!";

	        println@Console(response.message)()
	    }
	] {
		println@Console("\n[invioOrdine] COMPLETED\n\n")()
	}
}
