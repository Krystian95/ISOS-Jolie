
type IdOrdineCustomizzazione: string

type RicezionePreventivo: void {
	.idOrdine: string
	.totalePreventivo: string
}

interface RivenditoreInterface {
  OneWay:	notificaCustomizzazioniNonRealizzabili( IdOrdineCustomizzazione ),
  			ricezionePreventivo( RicezionePreventivo )
}
