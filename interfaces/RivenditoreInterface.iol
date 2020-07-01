
type IdOrdineCustomizzazione: string

type RicezionePreventivo: void {
	.idOrdine: string
	.totalePreventivo: double
	.totaleAnticipo: double
	.totaleSaldo: double
}

interface RivenditoreInterface {
  OneWay:	notificaCustomizzazioniNonRealizzabili( IdOrdineCustomizzazione ),
  			ricezionePreventivo( RicezionePreventivo )
}
