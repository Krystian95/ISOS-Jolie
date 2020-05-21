

// Listino
type Listino: void {
  .cicli*: CicloListino
  .accessori*: AccessorioListino
  .customizzazioni*: CustomizzazioneListino
}

type CicloListino: void{
  .idCiclo: int
  .modello: string
  .colorazione: string
}

type AccessorioListino: void{
  .idAccessorio: int
  .nome: string
}

type CustomizzazioneListino: void{
  .idCustomizzazione: int
  .tipologia: string
  .descrizione: string
}

// Ordine
type Ordine: void{
  .idRivenditore: int
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

interface RivenditoreServerInterface {
  RequestResponse:  requestListino(void)( Listino ),
                    inviaOrdine( Ordine )( void )
}
