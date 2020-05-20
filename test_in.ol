
include "console.iol"
include "string_utils.iol"

main
{
	registerForInput@Console()();

	println@Console( "\nInserisci gli id dei Cicli da acquistare separati da virgola (es. 1,2,3)" )();
	in(idCicli);

	println@Console( idCicli )();

	request = idCicli;
	request.regex = ",";

	split@StringUtils( request )( idCicliOrdine );

	println@Console( #idCicliOrdine.result )();

	for ( i = 0, i < #idCicliOrdine.result, i++ ) {
		println@Console( "Quanti cicli con id " + idCicliOrdine.result[i] + " vuoi acquistare?" )();
		in(qta);
		ordine.cicli[i].idCiclo = idCicliOrdine.result[i];
		ordine.cicli[i].qta = qta;
		println@Console( "Aggiunte al carrello " + qta + " quantita' del ciclo " + idCicliOrdine.result[i] )()
	}


}