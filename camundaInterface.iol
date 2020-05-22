
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
  .type?: string
  .message?: string
}

// Ordine
type OrdineMessage: void {
  .businessKey?: string
  .messageName: string
  .ordine: Ordine
}

interface CamundaInterface {
  RequestResponse:  ricezioneOrdine(OrdineMessage)(rit),
                    message(StartRequest)(rit)
}