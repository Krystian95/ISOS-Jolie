
include "console.iol"
include "string_utils.iol"

include "ACMEInterface.iol"

outputPort ACMEService {
	Location: "socket://localhost:8001"
	Protocol: soap
	Interfaces: ACMEInterface
}

inputPort RivenditoreServerService {
	Location: "socket://localhost:8004"
	Protocol: soap {
        .wsdl = "./wsdlRivenditore.wsdl";
        .wsdl.port = "RivenditoreServerService";
        .dropRootValue = true
    }
	Interfaces: ACMEInterface
}

init{
	global.idRivenditore = 1
}

main
{
	registerForInput@Console()();

	richiediListino@ACMEService()( listino );

	ordine.idRivenditore = global.idRivenditore

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
		cicloTiny = "\"" + listino.cicli[int(idCicliOrdine.result[i])-1].modello + " (" + listino.cicli[int(idCicliOrdine.result[i])-1].colorazione + ")\"";
		println@Console( "Quanti cicli " + cicloTiny + " vuoi acquistare?" )();
		in(qta);
		ordine.cicli[i].idCiclo = int(idCicliOrdine.result[i]);
		ordine.cicli[i].cicloNomeTiny = cicloTiny;
		ordine.cicli[i].qta = int(qta);
		println@Console( "Aggiunte al carrello " + qta + " quantita' del ciclo " + cicloTiny )();

		// CUSTOMIZZAZIONI

		println@Console( "\nListino CUSTOMIZZAZIONI:" )();
		for ( k = 0, k < #listino.customizzazioni, k++ ) {
			println@Console( listino.customizzazioni[k].idCustomizzazione + " - " + listino.customizzazioni[k].descrizione + " (" + listino.customizzazioni[k].tipologia + ")" )()
		}
		println@Console( "\nInserisci gli id delle customizzazioni da acquistare separati da virgola (es. 1,2,3):" )();
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
			z++;
			
			println@Console( "Aggiunta al carrello la customizzazione " + customizzazioneTiny + " per il ciclo " + cicloTiny )()
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
		println@Console( "Quanti accessori " + accesorioTiny + " vuoi acquistare?" )();
		in(qta);
		ordine.accessori[i].idAccessorio = int(idAccessoriOrdine.result[i]);
		ordine.accessori[i].accessorioNomeTiny = accesorioTiny;
		ordine.accessori[i].qta = int(qta);
		println@Console( "Aggiunte al carrello " + qta + " quantita' dell'accessorio " + accesorioTiny )()
	}

	// RIEPILOGO ORDINE

	println@Console( "\n\nRiepilogo ORDINE" )();

	println@Console( "\nCICLI:" )();
	for ( i = 0, i < #ordine.cicli, i++ ) {
		println@Console( ordine.cicli[i].cicloNomeTiny + " (" + ordine.cicli[i].qta + " unita')" )();

		println@Console( "\tCUSTOMIZZAZIONI:" )();
		for ( k = 0, k < #ordine.cicli[i].customizzazioni, k++ ) {
			println@Console( "\t" + ordine.cicli[i].customizzazioni[k].customizzazioneNomeTiny )()
		}
	}

	println@Console( "ACCESSORI:" )();
	for ( i = 0, i < #ordine.accessori, i++ ) {
		println@Console( ordine.accessori[i].accessorioNomeTiny + " (" + ordine.accessori[i].qta + " unita')" )()
	}

	// Invio ordine
	inviaOrdine@ACMEService( ordine )( void )


}