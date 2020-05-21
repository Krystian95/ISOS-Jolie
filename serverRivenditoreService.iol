

// Listino
type Listino: void {
  .cicli*: Ciclo
  .accessori*: Accessorio
  .customizzazioni*: Customizzazione
}

type Ciclo: void{
  .idCiclo: string
  .modello: string
  .colorazione: string
}

type Accessorio: void{
  .idAccessorio: string
  .nome: string
}

type Customizzazione: void{
  .idCustomizzazione: string
  .tipologia: string
  .descrizione: string
}

// Ordine
type Ordine: void{
  .cicli*: CicloOrdine
  .accessori*: AccessorioOrdine
}

type CicloOrdine: void{
  .idCiclo: string
  .qta: string
  .cicloNomeTiny: string
  .customizzazioni*: CustomizzazioneOrdine
}

type CustomizzazioneOrdine: void{
  .idCustomizzazione: string
  .customizzazioneNomeTiny: string
}

type AccessorioOrdine: void{
  .idAccessorio: string
  .accessorioNomeTiny: string
  .qta: string
}

interface RivenditoreServerInterface {
  RequestResponse:  requestListino(void)( Listino ),
                    inviaOrdine( Ordine )( void )
}
