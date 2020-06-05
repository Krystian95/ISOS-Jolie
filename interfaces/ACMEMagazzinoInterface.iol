
// Verifica disponibilità componenti accessori

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
