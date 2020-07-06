
// Richiesta Componenti Accessori

type InvioOrdine: void {
	.idOrdine: string
}

type InvioOrdineResponse: void {
	.result: bool
	.message: string
}

interface CorriereInterface {
	RequestResponse:	invioOrdine(InvioOrdine)(InvioOrdineResponse)
}
