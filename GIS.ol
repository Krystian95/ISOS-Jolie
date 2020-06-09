include "console.iol"
include "string_utils.iol"

include "interfaces/DistanceMatrixInterface.iol"
include "interfaces/GISInterface.iol"

outputPort DistanceMatrixService {
	Location: "socket://www.mapquestapi.com:80/"
	Protocol: http { 
		.method = "get";
		.osc.default.alias = "directions/v2/route";
		.format = "json"
	}
	Interfaces: DistanceMatrixInterface
}

inputPort InputPort {
	Location: "socket://localhost:8015"
	Protocol: http
	Interfaces: DistanceMatrixInterface
}

inputPort GISService {
	Location: "socket://localhost:8016"
	Protocol: soap
	Interfaces: GISInterface
}

constants
{
	KEY = "6wEJ0kvFptHTcXxlYerm4AtwojJhnUJE"
}

execution { concurrent }

init
{
    println@Console("\nGIS service is running...\n")() // TO CHANGE
}

main
{
	[
		distanceBetween( request )( response ) {

			request.key = KEY;

			default@DistanceMatrixService( request )( responseService );
			response.distance = responseService.route[0].distance[0];

			println@Console("\nDistance between:")();
			println@Console("FROM: " + request.from)();
			println@Console("TO: " + request.to)();
			distance = responseService.route[0].distance[0];
			println@Console(distance + request.unit)()

			response << request;
			response.distance = distance
	    }
	] {
		nullProcess
	}
}
