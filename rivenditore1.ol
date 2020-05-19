
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
	println@Console(listino.testo)();

	requestListino@RivenditoreServerOutput()( listino );
	println@Console(listino.testo)()
}