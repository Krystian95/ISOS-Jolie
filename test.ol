
include "console.iol"
include "string_utils.iol"

include "interfaces/ACMERivenditoreInterface.iol"
include "interfaces/RivenditoreInterface.iol"
include "interfaces/ACMEGestioneOrdiniInterface.iol"
include "interfaces/ACMEMagazzinoInterface.iol"

// Porta [TEST]
outputPort ACMEService {
	Location: "socket://localhost:8000"
	Protocol: soap
	Interfaces: ACMEGestioneOrdiniInterface
}

// Porta [TEST]
outputPort ACMEServiceMP {
	Location: "socket://localhost:8003"
	Protocol: soap
	Interfaces: ACMEGestioneOrdiniInterface
}

main
{
	println@Console("\nTEST...\n")();

	// Customizzazioni realizzabili

	// 27 non realizzabili
	// 62: realizzabili
	
	/*idOrdine.idOrdine = "27";
	verificaCustomizzazioni@ACMEService(idOrdine)(response);
	println@Console("response = " + response.customizzazioniPossibili)();*/

	// Verifica disponibilità accessori e componenti nel MP

	// 27 (1 accessorio sì, 1 no - no tutti componenti)
	// 63 (1 accessorio sì - no tutti componenti)
	prenotazioneMaterialiPresentiMPDelegate.idOrdine = "27";
	prenotazioneMaterialiPresentiMPDelegate@ACMEServiceMP(prenotazioneMaterialiPresentiMPDelegate)(response);
	println@Console("tuttiMaterialiRichiestiPresentiMP = " + response.tuttiMaterialiRichiestiPresentiMP)();
	println@Console("response = " + response.message)()
}
