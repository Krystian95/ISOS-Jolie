
// Verifica disponibilità componenti accessori MP

type VerificaDisponibilitaComponentiAccessoriMP: void {
  .idOrdine: string
}

type ResponseVerificaDisponibilitaComponentiAccessoriMP: void {
  .tuttiMaterialiRichiestiPresentiMP: bool
  .message: string
}

interface ACMEMagazzinoInterface {
	RequestResponse:	verificaDisponibilitaComponentiAccessori( VerificaDisponibilitaComponentiAccessoriMP )( ResponseVerificaDisponibilitaComponentiAccessoriMP )
}
