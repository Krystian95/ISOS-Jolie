
type IdOrdine: void {
  .idOrdine: string
}
type IdRivenditore: void {
  .idRivenditore: string
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

type emptyGetIdOrdine: void
type emptyGetIdRivenditore: void

interface ACMEGestioneOrdiniInterface {
  RequestResponse:  getIdOrdine( emptyGetIdOrdine )( IdOrdine ),
  					getIdRivenditore( emptyGetIdRivenditore )( IdRivenditore ),
                    verificaCustomizzazioni( IdOrdine )( EsitoVerificaCustomizzazioni ),
                    notificaCustomizzazioniNonRealizzabili( NotificaCustomizzazioniNonRealizzabili )( Response )
}