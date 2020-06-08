
type RestRequest: void {
	.key: string
	.from: string
	.to: string
	.unit: string
}

interface DistanceMatrixInterface {
	RequestResponse: default( RestRequest )( undefined )
}