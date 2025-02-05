
// Listino
type Listino: void {
  .cicli*: CicloListino
  .accessori*: AccessorioListino
  .customizzazioni*: CustomizzazioneListino
}

type CicloListino: void {
  .idCiclo: int
  .modello: string
  .colorazione: string
}

type AccessorioListino: void {
  .idAccessorio: int
  .nome: string
}

type CustomizzazioneListino: void {
  .idCustomizzazione: int
  .tipologia: string
  .descrizione: string
}

// Ordine
type Ordine: void {
  .idOrdine?: int
  .idRivenditore: int
  .cicli*: CicloOrdine
  .accessori*: AccessorioOrdine
  .customizzazioni*: CustomizzazioneOrdine
}

type CustomizzazioneOrdine: void {
  .idCustomizzazione: int
  .idCiclo?: int
  .customizzazioneNomeTiny?: string
}

type AccessorioOrdine: void {
  .idAccessorio: int
  .accessorioNomeTiny: string
  .qta: int
}

type CicloOrdine: void {
  .idCiclo: int
  .qta: int
  .cicloNomeTiny: string
  .customizzazioni*: CustomizzazioneOrdine
}

type AccettaPreventivo: void {
  .idOrdine: string
}

type RifiutoPreventivo: void {
  .idOrdine: string
}

type RicevutaAnticipo: void {
  .idOrdine: string
  .transactionToken: string
}

type RicevutaSaldo: void {
  .idOrdine: string
  .transactionToken: string
}

interface ACMERivenditoreInterface {
  RequestResponse:  richiediListino( void )( Listino )
  OneWay:           inviaOrdine( Ordine ),
                    accettaPreventivo( AccettaPreventivo ),
                    rifiutoPreventivo( RifiutoPreventivo ),
                    ricevutaAnticipo(RicevutaAnticipo),
                    ricevutaSaldo(RicevutaSaldo)
}
