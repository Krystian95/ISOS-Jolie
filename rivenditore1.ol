
include "console.iol"
include "serverRivenditoreService.iol"

outputPort RivenditoreServerOutput {
	Location: "socket://localhost:8001"
	Protocol: soap
	Interfaces: ServerRivenditoreInterface
}

main
{
	requestListino@RivenditoreServerOutput()( listino );

	println@Console( "\nElenco CICLI:" )();
	for ( i = 0, i < #listino.cicli, i++ ) {
		println@Console( listino.cicli[i].idCiclo + " - " + listino.cicli[i].modello + " (" + listino.cicli[i].colorazione + ")" )()
	}

	println@Console( "\nElenco ACCESSORI:" )();
	for ( i = 0, i < #listino.accessori, i++ ) {
		println@Console( listino.accessori[i].idAccessorio + " - " + listino.accessori[i].nome )()
	}

	println@Console( "\nElenco CUSTOMIZZAZIONI:" )();
	for ( i = 0, i < #listino.customizzazioni, i++ ) {
		println@Console( listino.customizzazioni[i].idCustomizzazione + " - " + listino.customizzazioni[i].descrizione + " (" + listino.customizzazioni[i].tipologia + ")" )()
	}
}