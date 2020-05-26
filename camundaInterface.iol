type StartRequest:void {
    .businessKey?:string
    .messageName:string
    .processVariables:varType
    //.resultEnabled:bool
}

type varType:void{
  .conferma?: intStringType
  .ordine?:intStringType
  .menuModificato?: intStringType
  .cancellaOrdine?: intStringType 
  .disponibilitaLocale?: intStringType 
}

type intStringType:void{
  .value:string
  .type:string
}


type rit: void{
  .type?: any
  .message?: any
}

// Ordine

type OrdineMessage: void {
  .businessKey?: string
  .messageName: string
  .processVariables: void {
    .idOrdine: void {
      .value: string
      .type: string
    }
  }
}



interface CamundaInterface {
    RequestResponse: ricezioneOrdine(OrdineMessage)(rit),
                    message(StartRequest)(rit)
}
