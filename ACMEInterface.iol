
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

interface ACMEInterface {
  RequestResponse:  richiediListino( void )( Listino ),
                    inviaOrdine( Ordine )( void )
}
