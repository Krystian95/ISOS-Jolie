
type GISRequest: void {
	.key: string
	.from: string
	.to: string
	.unit: string
}

type GISResponse: void {
	.distance: double
	.from: string
	.to: string
	.unit: string
	.key: string
}

interface GISInterface {
	RequestResponse: distanceBetween( GISRequest )( GISResponse )
}