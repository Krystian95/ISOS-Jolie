
type IdOrdine: void {
  .idOrdine: string
}

type EsitoVerificaCustomizzazioni: void {
  .customizzazioniPossibili: bool
}

interface ACMEInterface {
  RequestResponse:  verificaCustomizzazioni( IdOrdine )( EsitoVerificaCustomizzazioni )
}