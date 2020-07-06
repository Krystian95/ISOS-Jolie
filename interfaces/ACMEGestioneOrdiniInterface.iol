
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
  .ordineContieneMaterialiPrenotatiMP: bool
  .ordineContieneMaterialiPrenotatiMS: bool
  .ordineContieneMaterialiDaOrdinareDaFornitore: bool
  .tuttiAccessoriPresentiNeiMagazzini: bool
}

// Applicazione sconto

type ApplicazioneSconto: void {
  .idOrdine: string
  .percentualeSconto: string
}

type ApplicazioneScontoResponse: void {
  .message: string
}

// Applicazione sconto

type InvioPreventivo: void {
  .idOrdine: string
  .idRivenditore: string
}

type InvioPreventivoResponse: void {
  .message: string
}

// Sblocco Prenotazioni Componenti Accessori Magazzini

type SbloccoPrenotazioniComponentiAccessoriMagazzini: void {
  .idOrdine: string
}

type SbloccoPrenotazioniComponentiAccessoriMagazziniResponse: void {
  .message: string
}

// Richiesta Trasferimento MP

type RichiestaTrasferimentoMP: void {
  .idOrdine: string
}

type RichiestaTrasferimentoMPResponse: void {
  .message: string
}

// Richiesta Trasferimento MS

type RichiestaTrasferimentoMS: void {
  .idOrdine: string
}

type RichiestaTrasferimentoMSResponse: void {
  .message: string
}

// Get id ordine

type IdOrdineRivenditore: void {
  .idOrdine: string
}

// Recupero Variabili Sessione

type RecuperoVariabiliSessione: void {
  .idOrdine: string
}

type RecuperoVariabiliSessioneResponse: void {
  .ordineContieneAccessoriDaNonAssemblare: bool
  .ordineContieneMaterialiPrenotatiMP: bool
  .ordineContieneMaterialiPrenotatiMS: bool
  .ordineContieneMaterialiDaOrdinareDaFornitore: bool
  .tuttiAccessoriPresentiNeiMagazzini: bool
}

// Verifica Anticipo Con Sistema Bancario

type VerificaAnticipoConSistemaBancario: void {
  .idOrdine: string
}

type VerificaAnticipoConSistemaBancarioResponse: void {
  .anticipoVerificato: bool
  .message: string
}

// Verifica Saldo Con Sistema Bancario

type VerificaSaldoConSistemaBancario: void {
  .idOrdine: string
}

type VerificaSaldoConSistemaBancarioResponse: void {
  .saldoVerificato: bool
  .message: string
}

// Ricevuta Anticipo

type RicevutaAnticipo: void {
  .idOrdine: string
  .transactionToken: string
}

// Ricevuta Saldo

type RicevutaSaldo: void {
  .idOrdine: string
  .transactionToken: string
}

// Invio Ordine Materiali Non Presenti Fornitore

type InvioOrdineMaterialiNonPresentiFornitore: void {
  .idOrdine: string
}

type InvioOrdineMaterialiNonPresentiFornitoreResponse: void {
  .message: string
}

// Invio Ordine Corriere

type InvioOrdineCorriere: void {
  .idOrdine: string
}

type InvioOrdineCorriereResponse: void {
  .message: string
}

// Altro

type emptyGetIdOrdine: void

type AccettaPreventivo: void {
  .idOrdine: string
}

type RifiutoPreventivo: void {
  .idOrdine: string
}

// Risposte generiche

type Response: void {
  .message: string
}

interface ACMEGestioneOrdiniInterface {
  RequestResponse:  getIdOrdine( emptyGetIdOrdine )( IdOrdine ),
                    getIdRivenditore( IdOrdineRivenditore )( IdRivenditore ),
                    verificaCustomizzazioni( IdOrdine )( EsitoVerificaCustomizzazioni ),
                    notificaCustomizzazioniNonRealizzabili( NotificaCustomizzazioniNonRealizzabili )( Response ),
                    prenotazioneMaterialiPresentiMP( PrenotazioneMaterialiPresentiMP )( ResponsePrenotazioneMaterialiPresentiMP ),
                    prenotazioneMaterialiPresentiMS( PrenotazioneMaterialiPresentiMS )( ResponsePrenotazioneMaterialiPresentiMS ),
                    generazioneListaAccessoriPresentiMagazzini( GenerazioneListaAccessoriPresentiMagazzini )( ResponseGenerazioneListaAccessoriPresentiMagazzini ),
                    calcoloPreventivo( CalcoloPreventivo )( CalcoloPreventivoResponse),
                    applicazioneSconto( ApplicazioneSconto )( ApplicazioneScontoResponse),
                    invioPreventivo( InvioPreventivo )( InvioPreventivoResponse),
                    sbloccoPrenotazioniComponentiAccessoriMagazzini(SbloccoPrenotazioniComponentiAccessoriMagazzini)(SbloccoPrenotazioniComponentiAccessoriMagazziniResponse),
                    richiestaTrasferimentoMP(RichiestaTrasferimentoMP)(RichiestaTrasferimentoMPResponse),
                    richiestaTrasferimentoMS(RichiestaTrasferimentoMS)(RichiestaTrasferimentoMSResponse),
                    recuperoVariabiliSessione(RecuperoVariabiliSessione)(RecuperoVariabiliSessioneResponse),
                    verificaAnticipoConSistemaBancario(VerificaAnticipoConSistemaBancario)(VerificaAnticipoConSistemaBancarioResponse),
                    verificaSaldoConSistemaBancario(VerificaSaldoConSistemaBancario)(VerificaSaldoConSistemaBancarioResponse),
                    invioOrdineMaterialiNonPresentiFornitore(InvioOrdineMaterialiNonPresentiFornitore)(InvioOrdineMaterialiNonPresentiFornitoreResponse),
                    invioOrdineCorriere(InvioOrdineCorriere)(InvioOrdineCorriereResponse)
  OneWay:           accettaPreventivo( AccettaPreventivo ),
                    rifiutoPreventivo( RifiutoPreventivo ),
                    ricevutaAnticipo(RicevutaAnticipo),
                    ricevutaSaldo(RicevutaSaldo)
}



