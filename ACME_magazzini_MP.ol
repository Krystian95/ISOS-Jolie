
include "console.iol"
include "string_utils.iol"
include "database.iol"

include "interfaces/ACMEMagazzinoInterface.iol"

// Porta ACME Gestione Ordini -> ACME Magazzino Principale
inputPort MagazzinoPrincipale {
	Location: "socket://localhost:8006"
	Protocol: soap
	Interfaces: ACMEMagazzinoInterface
}

execution { concurrent }

init
{
	// Id Magazzino
	global.idMagazzino = 1;

	// Database
	with(connectionInfo) {
        .host = "127.0.0.1";
        .driver = "mysql";
        .port = 3306;
        .database = "acme?serverTimezone=Europe/Rome";
        .username = "root";
        .password = "root"
    };
    
    connect@Database(connectionInfo)();
    println@Console("\nConnection to database: SUCCESS")();

    println@Console("\nACME MAGAZZINO #"+global.idMagazzino+" running...\n")()
}

main
{
	[
		verificaDisponibilitaComponentiAccessori ( params )( response ) {

			idOrdine = params.idOrdine;

			println@Console("Verifico disponibilità componenti e accessori nel Magazzino #"+global.idMagazzino+" per l'ordine #" + idOrdine + "\n")();

			tuttiAccessoriOrdinePresenti = true;
			tuttiComponentiOrdinePresenti = true;

			// Accessori

			query = "SELECT idAccessorio
					 FROM ordine_has_accessorio
					 WHERE idOrdine = " + idOrdine;
        	query@Database( query )( accessoriOrdine );

	        if ( #accessoriOrdine.row > 0 ) {
	        	// Elenco degli accessori presenti nel magazzino per uno specifico ordine
	        	query = "SELECT
							ordine_has_accessorio.idOrdine,
						    ordine_has_accessorio.idAccessorio,
						    ordine_has_accessorio.quantitaAccessorio AS qta_richiesta,
						    magazzino_has_accessorio.idMagazzino,
						    magazzino_has_accessorio.quantita AS qta_disponibile
						FROM ordine_has_accessorio
						LEFT JOIN magazzino_has_accessorio ON ordine_has_accessorio.idAccessorio = magazzino_has_accessorio.idAccessorio
						WHERE ordine_has_accessorio.idOrdine = " + idOrdine +" AND magazzino_has_accessorio.idMagazzino = " + global.idMagazzino;
        		query@Database( query )( accessoriOrdineMagazzino );

        		if(#accessoriOrdine.row != #accessoriOrdineMagazzino.row){
        			tuttiAccessoriOrdinePresenti = false
        		}

        		// Per ogni accessorio prenoto la qta richiesta oppure quella disponibile
        		for ( i = 0, i < #accessoriOrdineMagazzino.row, i++ ) {
        			qta_richiesta = accessoriOrdineMagazzino.row[i].qta_richiesta;
        			qta_disponibile = accessoriOrdineMagazzino.row[i].qta_disponibile;
		            qta_mancante = qta_richiesta - qta_disponibile;

		            idMagazzino = accessoriOrdineMagazzino.row[i].idMagazzino;
		            idAccessorio = accessoriOrdineMagazzino.row[i].idAccessorio;

		            if(qta_disponibile >= qta_richiesta){
		           		qta_prenotabile = qta_richiesta
		           	} else {
		           		qta_prenotabile = qta_disponibile
		           	}

		           	println@Console("Il magazzino #" + idMagazzino + " possiede "+qta_disponibile+" qta su "+qta_richiesta+" qta richieste ("+qta_prenotabile+" prenotabili) dell'accessorio # "+idAccessorio+" per l'ordine #" + idOrdine + "\n")();

		            if(qta_prenotabile > 0) {
		            	tuttiAccessoriOrdinePresenti = false;

		            	query = "INSERT INTO Magazzino_accessorio_prenotato
				            	(idOrdine, idMagazzino, idAccessorio, quantita)
				            	VALUES
				            	(" + idOrdine + ", " + idMagazzino + ", " + idAccessorio + ", " + qta_prenotabile + ")";
						update@Database( query )( responseNewPrenotazioneAccessorio );
						println@Console("Prenoto " + qta_prenotabile + " qta dell'accessorio #" + idAccessorio + " nel magazzino #" + idMagazzino + " per l'ordine #" + idOrdine + "\n")();

						query = "UPDATE magazzino_has_accessorio
								 SET quantita = quantita - " + qta_prenotabile + "
								 WHERE idMagazzino = " + idMagazzino + " AND idAccessorio = " + idAccessorio;
						update@Database( query )( responseScaloQtaMagazzino );
						println@Console("Ho scalato " + qta_prenotabile + " qta dell'accessorio #" + idAccessorio + " dal magazzino #" + idMagazzino + " poiché prenotate" + "\n")()
		            }
		        }
	        }

	        // Componenti

	        query = "SELECT *
					 FROM ordine_has_ciclo
					 LEFT JOIN ciclo_has_componente ON ordine_has_ciclo.idCiclo = ciclo_has_componente.idCiclo
					 WHERE idOrdine = " + idOrdine;
        	query@Database( query )( componentiOrdine );

        	if ( #componentiOrdine.row > 0 ) {
	        	// Elenco dei componenti presenti nel magazzino per uno specifico ordine
	        	query = "SELECT *
						 FROM ordine_has_ciclo
						 LEFT JOIN ciclo_has_componente ON ordine_has_ciclo.idCiclo = ciclo_has_componente.idCiclo
						 WHERE idOrdine = " + idOrdine + " AND idComponente IN (
							SELECT idComponente
    						FROM magazzino_has_componente
    						WHERE idMagazzino = " + global.idMagazzino + " AND quantita > 0
						 )";
        		query@Database( query )( componentiOrdinePresentiMagazzino );

        		if ( #componentiOrdinePresentiMagazzino.row != #componentiOrdine.row ) {
        			tuttiComponentiOrdinePresenti = false
        		}
	        }

	        // Finale (response)

	        if ( tuttiAccessoriOrdinePresenti && tuttiComponentiOrdinePresenti ) {
	        	response.tuttiMaterialiRichiestiPresentiMP = true;
	        	response.message = "Nel MP #"+global.idMagazzino+" sono presenti tutti i Componenti/Accessori richiesti dall'ordine #" + idOrdine
	        } else {
				response.tuttiMaterialiRichiestiPresentiMP = false;
				response.message = "Nel MP #"+global.idMagazzino+" NON sono presenti tutti i Componenti/Accessori richiesti dall'ordine #" + idOrdine
	        }

	        println@Console(response.message + "\n")()
	    }
	] {
		println@Console("[verificaDisponibilitaComponentiAccessori] COMPLETED")()
	}
}
