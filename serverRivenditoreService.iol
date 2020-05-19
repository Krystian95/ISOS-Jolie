
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

interface ServerRivenditoreInterface {
  RequestResponse:  requestListino( void )( Listino )
}
