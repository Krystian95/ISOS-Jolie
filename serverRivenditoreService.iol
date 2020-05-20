

// Listino
type Listino: void {
  .cicli*: Ciclo
  .accessori*: Accessorio
  .customizzazioni*: Customizzazione
}

type Ciclo: void{
  .idCiclo: int
  .modello: string
  .colorazione: string
}

type Accessorio: void{
  .idAccessorio: int
  .nome: string
}

type Customizzazione: void{
  .idCustomizzazione: int
  .tipologia: string
  .descrizione: string
}

// Ordine
type Ordine: void{
  .cicli*: CicloOrdine
  .accessori*: AccessorioOrdine
}

type CicloOrdine: void{
  .idCiclo: int
  .qta: int
  .cicloNomeTiny: string
  .customizzazioni*: CustomizzazioneOrdine
}

type CustomizzazioneOrdine: void{
  .idCustomizzazione: int
  .customizzazioneNomeTiny: string
}

type AccessorioOrdine: void{
  .idAccessorio: int
  .accessorioNomeTiny: string
  .qta: int
}

interface ServerRivenditoreInterface {
  RequestResponse:  requestListino( void )( Listino )
}
