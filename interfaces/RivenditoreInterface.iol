
type IdOrdineCustomizzazione: string

type RicezionePreventivo: void {
	.idOrdine: string
	.totalePreventivo: double
}

interface RivenditoreInterface {
  OneWay:	notificaCustomizzazioniNonRealizzabili( IdOrdineCustomizzazione ),
  			ricezionePreventivo( RicezionePreventivo )
}
