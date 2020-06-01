
type IdOrdine: void {
  .idOrdine: string
}

type IdRivenditore: void {
  .idRivenditore: string
}

type EsitoVerificaCustomizzazioni: void {
  .customizzazioniPossibili: bool
  .ordineContieneAccessoriDaNonAssemblare: bool
  .ordineContieneComponentiAccessoriDaAssemblare: bool
}

type NotificaCustomizzazioniNonRealizzabili: void {
  .idRivenditore: string
  .idOrdine: string
}

// Verifica disponibilità componenti accessori MP

type PrenotazioneMaterialiPresentiMPDelegate: void {
  .idOrdine: string
}

type ResponsePrenotazioneMaterialiPresentiMPDelegate: void {
  .tuttiMaterialiRichiestiPresentiMP: bool
  .response: string
}

// Risposte

type Response: void {
  .response: string
}

type emptyGetIdOrdine: void
type emptyGetIdRivenditore: void

interface ACMEGestioneOrdiniInterface {
  RequestResponse:  getIdOrdine( emptyGetIdOrdine )( IdOrdine ),
                    getIdRivenditore( emptyGetIdRivenditore )( IdRivenditore ),
                    verificaCustomizzazioni( IdOrdine )( EsitoVerificaCustomizzazioni ),
                    notificaCustomizzazioniNonRealizzabili( NotificaCustomizzazioniNonRealizzabili )( Response ),
                    prenotazioneMaterialiPresentiMPDelegate( PrenotazioneMaterialiPresentiMPDelegate )( ResponsePrenotazioneMaterialiPresentiMPDelegate )
}