
// Verifica disponibilità componenti accessori MP

type VerificaDisponibilitaComponentiAccessori: void {
  .idOrdine: string
}

type ResponseVerificaDisponibilitaComponentiAccessori: void {
  .tuttiMaterialiRichiestiPresenti: bool
  .message: string
}

interface ACMEMagazzinoInterface {
	RequestResponse:	verificaDisponibilitaComponentiAccessori( VerificaDisponibilitaComponentiAccessori )( ResponseVerificaDisponibilitaComponentiAccessori )
}
