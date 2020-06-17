
include "console.iol"
include "string_utils.iol"

include "interfaces/ACMERivenditoreInterface.iol"
include "interfaces/RivenditoreInterface.iol"
include "interfaces/ACMEGestioneOrdiniInterface.iol"
include "interfaces/ACMEMagazzinoInterface.iol"
include "interfaces/GISInterface.iol"

// Porta [TEST]
outputPort ACMEService {
	Location: "socket://localhost:8000"
	Protocol: soap
	Interfaces: ACMEGestioneOrdiniInterface
}

// Porta [TEST]
outputPort ACMETest {
	Location: "socket://localhost:8003"
	Protocol: soap
	Interfaces: ACMEGestioneOrdiniInterface
}

// Porta [TEST] -> GIS
outputPort GISService {
	Location: "socket://localhost:8016"
	Protocol: soap
	Interfaces: GISInterface
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
	/*prenotazioneMaterialiPresentiMP.idOrdine = "96";
	prenotazioneMaterialiPresentiMP@ACMETest(prenotazioneMaterialiPresentiMP)(response);
	println@Console("tuttiMaterialiRichiestiPresentiMP = " + response.tuttiMaterialiRichiestiPresentiMP)();
	println@Console("response = " + response.message)();*/

	// Verifica disponibilità accessori e componenti nel MS

	// 27 (1 accessorio sì, 1 no - no tutti componenti)
	// 63 (1 accessorio sì - no tutti componenti)
	/*prenotazioneMaterialiPresentiMS.idOrdine = "96";
	prenotazioneMaterialiPresentiMS@ACMETest(prenotazioneMaterialiPresentiMS)(response);
	println@Console("response = " + response.message)()*/

	// GIS 
	/*request.from = "Via Vittorio Veneto 12, 40131, Bologna (BO), Italia";
	request.to = "Via Siena 27, 41126, Modena (MO), Italia";
	request.unit = "k";
	distanceBetween@GISService(request)(response)*/

	// generazioneListaAccessoriPresentiMagazzini

	/*params.idOrdine = "98";
	generazioneListaAccessoriPresentiMagazzini@ACMETest(params)()*/

	// Notifica customizzazioni non realizzabili
	/*notificaCustomizzazioniNonRealizzabili.idOrdine = "104";
	notificaCustomizzazioniNonRealizzabili.idRivenditore = "1";
	notificaCustomizzazioniNonRealizzabili@ACMETest(notificaCustomizzazioniNonRealizzabili)(response);
	println@Console("response = " + response.message)()*/

	// calcolo preventivo

	calcoloPreventivo.idOrdine = "127";
	calcoloPreventivo.idRivenditore = "1";
	calcoloPreventivo@ACMETest(calcoloPreventivo)(response);
	println@Console("response.totaleOrdine = " + response.totaleOrdine)();
	println@Console("response.sogliaSconto = " + response.sogliaSconto)()
}


