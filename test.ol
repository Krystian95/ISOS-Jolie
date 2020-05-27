
include "console.iol"
include "string_utils.iol"

include "ACMERivenditoreInterface.iol"
include "RivenditoreInterface.iol"
include "ACMEGestioneOrdiniInterface.iol"

// Porta Rivenditore -> ACME Gestione Ordini
outputPort ACMEService {
	Location: "socket://localhost:8000"
	Protocol: soap
	Interfaces: ACMEGestioneOrdiniInterface
}

// Porta ACME Gestione Ordini -> Rivenditore
inputPort Rivenditore {
	Location: "socket://localhost:8002"
	Protocol: soap
	Interfaces: RivenditoreInterface
}

init {
	// 27 non realizzabili - 62: realizzabili
	idOrdine.idOrdine = "63";
	verificaCustomizzazioni@ACMEService(idOrdine)(response);
	println@Console("response = " + response.customizzazioniPossibili)()
}

main
{
	println@Console("TEST")()
}
