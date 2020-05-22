
type idOrdine: string

type EsitoVerificaCustomizzazioni: void {
  .customizzazioniPossibili: bool
}

interface ACMEInterface {
  RequestResponse:  verificaCustomizzazioni( idOrdine )( EsitoVerificaCustomizzazioni )
}