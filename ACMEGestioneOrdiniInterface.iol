
type IdOrdine: void {
  .idOrdine: string
}

type EsitoVerificaCustomizzazioni: void {
  .customizzazioniPossibili: bool
}

type NotificaCustomizzazioniNonRealizzabili: void {
	.idRivenditore: string
	.idOrdine: string
}

type Response: void {
	.response: string
}

type empty: void

interface ACMEGestioneOrdiniInterface {
  RequestResponse:  getIdOrdine( empty )( IdOrdine ),
                    verificaCustomizzazioni( IdOrdine )( EsitoVerificaCustomizzazioni ),
                    notificaCustomizzazioniNonRealizzabili( NotificaCustomizzazioniNonRealizzabili )( Response )
}