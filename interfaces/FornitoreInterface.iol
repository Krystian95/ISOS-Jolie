
// Richiesta Componenti Accessori

type RichiestaComponentiAccessori: void {
	.idOrdine: string
}

type RichiestaComponentiAccessoriResponse: void {
	.result: bool
	.message: string
}

interface FornitoreInterface {
	RequestResponse:	richiestaComponentiAccessori(RichiestaComponentiAccessori)(RichiestaComponentiAccessoriResponse)
}
