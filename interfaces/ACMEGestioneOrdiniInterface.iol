
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

type PrenotazioneMaterialiPresentiMP: void {
  .idOrdine: string
}

type ResponsePrenotazioneMaterialiPresentiMP: void {
  .tuttiMaterialiRichiestiPresentiMP: bool
  .message: string
}

// Verifica disponibilità componenti accessori MS

type PrenotazioneMaterialiPresentiMS: void {
  .idOrdine: string
}

type ResponsePrenotazioneMaterialiPresentiMS: void {
  .message: string
}

// GIS

type GenerazioneListaAccessoriPresentiMagazzini: void {
  .idOrdine: string
}

type ResponseGenerazioneListaAccessoriPresentiMagazzini: void {
  .message: string
}

// Calcolo preventivo

type CalcoloPreventivo: void {
  .idOrdine: string
  .idRivenditore: string
}

type CalcoloPreventivoResponse: void {
  .totaleAccessori: double
  .spedizioniAccessori: double
  .totaleCicli: double
  .spedizioniComponenti: double
  .totaleCustomizzazioni: double
  .totaleCorriere: double
  .totalePreventivo: double
  .sogliaSconto: double
}

// Applicazione sconto

type ApplicazioneSconto: void {
  .idOrdine: string
  .percentualeSconto: string
}

type ApplicazioneScontoResponse: void {
  .message: string
}

// Get id ordine

type IdOrdineRivenditore: void {
  .idOrdine: string
}

// Risposte generiche

type Response: void {
  .message: string
}

type emptyGetIdOrdine: void

interface ACMEGestioneOrdiniInterface {
  RequestResponse:  getIdOrdine( emptyGetIdOrdine )( IdOrdine ),
                    getIdRivenditore( IdOrdineRivenditore )( IdRivenditore ),
                    verificaCustomizzazioni( IdOrdine )( EsitoVerificaCustomizzazioni ),
                    notificaCustomizzazioniNonRealizzabili( NotificaCustomizzazioniNonRealizzabili )( Response ),
                    prenotazioneMaterialiPresentiMP( PrenotazioneMaterialiPresentiMP )( ResponsePrenotazioneMaterialiPresentiMP ),
                    prenotazioneMaterialiPresentiMS( PrenotazioneMaterialiPresentiMS )( ResponsePrenotazioneMaterialiPresentiMS ),
                    generazioneListaAccessoriPresentiMagazzini( GenerazioneListaAccessoriPresentiMagazzini )( ResponseGenerazioneListaAccessoriPresentiMagazzini ),
                    calcoloPreventivo( CalcoloPreventivo )( CalcoloPreventivoResponse),
                    applicazioneSconto( ApplicazioneSconto )( ApplicazioneScontoResponse)
}



