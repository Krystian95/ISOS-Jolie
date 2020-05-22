
type IdOrdine: void {
  .idOrdine: string
}

type EsitoVerificaCustomizzazioni: void {
  .customizzazioniPossibili: bool
}

type empty: void

interface ACMEGestioneOrdiniInterface {
  RequestResponse:  getIdOrdine( empty )( IdOrdine ),
                    verificaCustomizzazioni( IdOrdine )( EsitoVerificaCustomizzazioni )
}