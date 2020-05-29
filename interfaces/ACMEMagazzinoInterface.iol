
// Verifica disponibilità componenti accessori MP

type VerificaDisponibilitaComponentiAccessoriMP: void {
  .idOrdine: string
}

type ResponseVerificaDisponibilitaComponentiAccessoriMP: void {
  .tuttiMaterialiRichiestiPresentiMP: bool
  .response: string
}

interface ACMEMagazzinoInterface {
	RequestResponse:	verificaDisponibilitaComponentiAccessori( VerificaDisponibilitaComponentiAccessoriMP )( ResponseVerificaDisponibilitaComponentiAccessoriMP )
}
