
include "console.iol"
include "string_utils.iol"

include "interfaces/ACMERivenditoreInterface.iol"
include "interfaces/RivenditoreInterface.iol"

// Porta Rivenditore -> ACME Gestione Ordini
outputPort ACMEService {
	Location: "socket://localhost:8001"
	Protocol: soap
	Interfaces: ACMERivenditoreInterface
}

// Porta ACME Gestione Ordini -> Rivenditore 1
inputPort Rivenditore1 {
	Location: "socket://localhost:8002"
	Protocol: soap
	Interfaces: RivenditoreInterface
}

execution { sequential }

init {

	// Id rivenditore
	global.idRivenditore = 1;

	// LISTINO
	registerForInput@Console()();

	richiediListino@ACMEService()( listino );

	ordine.idRivenditore = global.idRivenditore;

	// CICLI

	println@Console( "\nListino CICLI:" )();
	for ( i = 0, i < #listino.cicli, i++ ) {
		println@Console( listino.cicli[i].idCiclo + " - " + listino.cicli[i].modello + " (" + listino.cicli[i].colorazione + ")" )()
	}

	println@Console( "\nInserisci gli id dei Cicli da acquistare separati da virgola (es. 1,2,3):" )();
	in(idCicli);

	request = idCicli;
	request.regex = ",";

	split@StringUtils( request )( idCicliOrdine );

	z = 0;

	for ( i = 0, i < #idCicliOrdine.result, i++ ) {
		ordine.cicli[i].idCiclo = int(idCicliOrdine.result[i]);
		cicloTiny = "\"" + listino.cicli[int(idCicliOrdine.result[i])-1].modello + " (" + listino.cicli[int(idCicliOrdine.result[i])-1].colorazione + ")\"";
		println@Console( "\nQuanti cicli #" + ordine.cicli[i].idCiclo + " " + cicloTiny + " vuoi acquistare?" )();
		in(qta);
		ordine.cicli[i].cicloNomeTiny = cicloTiny;
		ordine.cicli[i].qta = int(qta);
		println@Console( "Aggiunte al carrello " + qta + " quantita' del ciclo #" + ordine.cicli[i].idCiclo + " " + cicloTiny )();

		// CUSTOMIZZAZIONI

		println@Console( "\nListino CUSTOMIZZAZIONI:" )();
		for ( k = 0, k < #listino.customizzazioni, k++ ) {
			println@Console( listino.customizzazioni[k].idCustomizzazione + " - " + listino.customizzazioni[k].descrizione + " (" + listino.customizzazioni[k].tipologia + ")" )()
		}
		println@Console( "\nInserisci gli id delle customizzazioni da acquistare separati da virgola (es. 1,2,3) per il ciclo #" + ordine.cicli[i].idCiclo + " " + cicloTiny )();
		in(idCustomizzazioni);

		request = idCustomizzazioni;
		request.regex = ",";

		split@StringUtils( request )( idCustomizzazioniOrdine );

		for ( j = 0, j < #idCustomizzazioniOrdine.result, j++ ) {
			customizzazioneTiny = "\"" + listino.customizzazioni[int(idCustomizzazioniOrdine.result[j])-1].descrizione + " (" + listino.customizzazioni[int(idCustomizzazioniOrdine.result[j])-1].tipologia + ")\"" ;
			ordine.cicli[i].customizzazioni[j].idCustomizzazione = int(idCustomizzazioniOrdine.result[j]);
			ordine.cicli[i].customizzazioni[j].customizzazioneNomeTiny = customizzazioneTiny;

			ordine.customizzazioni[z].idCustomizzazione = int(idCustomizzazioniOrdine.result[j]);
			ordine.customizzazioni[z].idCiclo = ordine.cicli[i].idCiclo;
			
			println@Console( "Aggiunta al carrello la customizzazione #" + ordine.customizzazioni[z].idCustomizzazione + " " + customizzazioneTiny + " per il ciclo #" + ordine.customizzazioni[z].idCiclo + " " + cicloTiny )();
			z++
		}

	}

	// ACCESSORI

	println@Console( "\nListino ACCESSORI:" )();
	for ( i = 0, i < #listino.accessori, i++ ) {
		println@Console( listino.accessori[i].idAccessorio + " - " + listino.accessori[i].nome )()
	}

	println@Console( "\nInserisci gli id degli Accessori da acquistare separati da virgola (es. 1,2,3):" )();
	in(idAccessori);

	request = idAccessori;
	request.regex = ",";

	split@StringUtils( request )( idAccessoriOrdine );

	for ( i = 0, i < #idAccessoriOrdine.result, i++ ) {
		accesorioTiny = "\"" + listino.accessori[int(idAccessoriOrdine.result[i])-1].nome + "\"";
		ordine.accessori[i].idAccessorio = int(idAccessoriOrdine.result[i]);
		println@Console( "Quanti accessori #" + ordine.accessori[i].idAccessorio + " " + accesorioTiny + " vuoi acquistare?" )();
		in(qta);
		ordine.accessori[i].accessorioNomeTiny = accesorioTiny;
		ordine.accessori[i].qta = int(qta);
		println@Console( "Aggiunte al carrello " + qta + " quantita' dell'accessorio #" + ordine.accessori[i].idAccessorio + " " + accesorioTiny )()
	}

	// RIEPILOGO ORDINE

	println@Console( "\n\nRiepilogo ORDINE" )();

	println@Console( "\nCICLI:" )();
	for ( i = 0, i < #ordine.cicli, i++ ) {
		println@Console( "#" + ordine.cicli[i].idCiclo + " " + ordine.cicli[i].cicloNomeTiny + " (" + ordine.cicli[i].qta + " unita')" )();

		println@Console( "\tCUSTOMIZZAZIONI:" )();
		for ( k = 0, k < #ordine.cicli[i].customizzazioni, k++ ) {
			println@Console( "\t" + "#" + ordine.cicli[i].customizzazioni[k].idCustomizzazione + " " + ordine.cicli[i].customizzazioni[k].customizzazioneNomeTiny )()
		}
	}

	println@Console( "ACCESSORI:" )();
	for ( i = 0, i < #ordine.accessori, i++ ) {
		println@Console( "#" + ordine.accessori[i].idAccessorio + " " + ordine.accessori[i].accessorioNomeTiny + " (" + ordine.accessori[i].qta + " unita')" )()
	}

	// Invio ordine
	inviaOrdine@ACMEService( ordine );
	println@Console( "\nORDINE inviato correttamente ad ACME\n" )()
}

main
{
	[
		notificaCustomizzazioniNonRealizzabili ( idOrdine )
	] {
		println@Console("Le customizzazioni richieste per l'ordine #" + idOrdine + " NON sono realizzabili!")();

		println@Console("\n[notificaCustomizzazioniNonRealizzabili] COMPLETED\n")()
	}

	[
		ricezionePreventivo ( params )
	] {
		println@Console("Il totale del preventivo per l'ordine #" + params.idOrdine + " e' di " + params.totalePreventivo + " EUR")();

		println@Console( "Inserire:" )();
		println@Console( "\t1: ACCETTARE" )();
		println@Console( "\t0: RIFIUTARE" )();
		registerForInput@Console()();

		in(scelta);

		if(scelta == "0"){
			println@Console( "Preventivo RIFIUTATO" )()
		}else if(scelta == "1"){
			println@Console( "Preventivo ACCETTATO" )()
		}

		println@Console("\n[ricezionePreventivo] COMPLETED\n")()
	}
}
