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



interface CamundaInterface {
    RequestResponse: message(StartRequest)(rit)
}