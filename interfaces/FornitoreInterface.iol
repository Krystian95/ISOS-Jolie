
// Richiesta Componenti Accessori

type RichiestaComponentiAccessori: void {
	.idOrdine: string
}

type RichiestaComponentiAccessoriResponse: void {
	.result: bool
	.message: string
}

// Richiesta Accessori

type RichiestaAccessori: void {
	.idOrdine: string
}

type RichiestaAccessoriResponse: void {
	.result: bool
	.message: string
}

interface FornitoreInterface {
	RequestResponse:	richiestaComponentiAccessori(RichiestaComponentiAccessori)(RichiestaComponentiAccessoriResponse),
						richiestaAccessori(RichiestaAccessori)(RichiestaAccessoriResponse)
}
