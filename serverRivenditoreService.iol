
type Listino: void {
  .accessori*: Accessorio
}

type Accessorio: void{
  .idAccessorio: string
  .nome: string
}

interface ServerRivenditoreInterface {
  RequestResponse:  requestListino( void )( Listino )
}
