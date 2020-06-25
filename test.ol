
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
	
	/*idOrdine.idOrdine = "27";
	verificaCustomizzazioni@ACMEService(idOrdine)(response);
	println@Console("response = " + response.customizzazioniPossibili)();*/

	// Verifica disponibilità accessori e componenti nel MP

	/*prenotazioneMaterialiPresentiMP.idOrdine = "134";
	prenotazioneMaterialiPresentiMP@ACMETest(prenotazioneMaterialiPresentiMP)(response);
	println@Console("tuttiMaterialiRichiestiPresentiMP = " + response.tuttiMaterialiRichiestiPresentiMP)();
	println@Console("response = " + response.message)();*/

	// Verifica disponibilità accessori e componenti nel MS

	/*prenotazioneMaterialiPresentiMS.idOrdine = "134";
	prenotazioneMaterialiPresentiMS@ACMETest(prenotazioneMaterialiPresentiMS)(response);
	println@Console("response = " + response.message)()*/

	// GIS 
	/*request.from = "Via Vittorio Veneto 12, 40131, Bologna (BO), Italia";
	request.to = "Via Siena 27, 41126, Modena (MO), Italia";
	request.unit = "k";
	distanceBetween@GISService(request)(response)*/

	// generazioneListaAccessoriPresentiMagazzini

	/*params.idOrdine = "134";
	generazioneListaAccessoriPresentiMagazzini@ACMETest(params)()*/

	// Notifica customizzazioni non realizzabili
	
	/*notificaCustomizzazioniNonRealizzabili.idOrdine = "104";
	notificaCustomizzazioniNonRealizzabili.idRivenditore = "1";
	notificaCustomizzazioniNonRealizzabili@ACMETest(notificaCustomizzazioniNonRealizzabili)(response);
	println@Console("response = " + response.message)()*/

	// calcolo preventivo

	calcoloPreventivo.idOrdine = "134";
	calcoloPreventivo.idRivenditore = "1";
	calcoloPreventivo@ACMETest(calcoloPreventivo)(response);
	println@Console("response.totalePreventivo = " + response.totalePreventivo)();
	println@Console("response.sogliaSconto = " + response.sogliaSconto)();

	// Applicazione sconto

	applicazioneSconto.idOrdine = "134";
	applicazioneSconto.percentualeSconto = "10";
	applicazioneSconto@ACMETest(applicazioneSconto)(response);
	println@Console("response.message = " + response.message)();

	// Invio preventivo

	invioPreventivo.idOrdine = "134";
	invioPreventivo.idRivenditore = "1";
	invioPreventivo@ACMETest(invioPreventivo)(response);
	println@Console("response.message = " + response.message)();

	// Accetta preventivo

	accettaPreventivo.idOrdine = "134";
	accettaPreventivo@ACMEService( accettaPreventivo );

	// Rifiuto preventivo

	rifiutoPreventivo.idOrdine = "134";
	rifiutoPreventivo@ACMEService( rifiutoPreventivo )

}


