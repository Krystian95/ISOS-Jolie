
include "console.iol"
include "string_utils.iol"
include "database.iol"

include "interfaces/ACMEMagazzinoInterface.iol"
include "interfaces/GISInterface.iol"

// Porta ACME Gestione Ordini -> ACME Magazzino Principale
inputPort MagazzinoSecondario2 { // TO CHANGE
	Location: "socket://localhost:8008" // TO CHANGE
	Protocol: soap
	Interfaces: ACMEMagazzinoInterface
}

// Porta ACME Magazzino Principale -> GIS
outputPort GISService {
	Location: "socket://localhost:8016"
	Protocol: soap
	Interfaces: GISInterface
}

execution { concurrent }

constants {
	ID_MAGAZZINO = 3 // TO CHANGE
}

init
{
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

    println@Console("\nACME MAGAZZINO SECONDARIO #"+ID_MAGAZZINO+" is running...\n")() // TO CHANGE
}

main
{
	[
		verificaDisponibilitaComponentiAccessori ( params )( response ) {

			idOrdine = params.idOrdine;

			println@Console("Verifico disponibilita' componenti e accessori nel magazzino #"+ID_MAGAZZINO+" per l'ordine #" + idOrdine + ":\n")();

			tuttiAccessoriOrdinePresenti = true;
			tuttiComponentiOrdinePresenti = true;

			// Accessori

			query = "SELECT idAccessorio
					 FROM ordine_has_accessorio
					 WHERE idOrdine = " + idOrdine;
        	query@Database( query )( accessoriOrdine );

	        if ( #accessoriOrdine.row > 0 ) {
	        	// Elenco degli accessori presenti nel magazzino per uno specifico ordine (che non sono ancora stati prenotati)
	        	query = "SELECT
							ordine_has_accessorio.idOrdine,
						    ordine_has_accessorio.idAccessorio,
						    (ordine_has_accessorio.quantitaAccessorio - CASE WHEN SUM(magazzino_accessorio_prenotato.quantita) IS NULL THEN 0 ELSE SUM(magazzino_accessorio_prenotato.quantita) END) AS qta_ancora_necessaria,
						    magazzino_has_accessorio.idMagazzino,
						    magazzino_has_accessorio.quantita AS qta_disponibile,
                            SUM(magazzino_accessorio_prenotato.quantita) AS qta_prenotata
						FROM ordine_has_accessorio
                        LEFT JOIN accessorio ON ordine_has_accessorio.idAccessorio = accessorio.idAccessorio
                        LEFT JOIN magazzino_accessorio_prenotato ON ordine_has_accessorio.idOrdine = magazzino_accessorio_prenotato.idOrdine AND 
                        											ordine_has_accessorio.idAccessorio = magazzino_accessorio_prenotato.idAccessorio
						LEFT JOIN magazzino_has_accessorio ON ordine_has_accessorio.idAccessorio = magazzino_has_accessorio.idAccessorio
						WHERE ordine_has_accessorio.idOrdine = " + idOrdine + " AND 
						magazzino_has_accessorio.idMagazzino = " + ID_MAGAZZINO + " AND 
						accessorio.tipologia = 'Assemblabile' AND 
						(
							magazzino_accessorio_prenotato.quantita < ordine_has_accessorio.quantitaAccessorio OR 
							magazzino_accessorio_prenotato.quantita IS NULL
						)
                        GROUP BY ordine_has_accessorio.idOrdine, ordine_has_accessorio.idAccessorio";
        		query@Database( query )( accessoriOrdineMagazzino );

        		if(#accessoriOrdine.row != #accessoriOrdineMagazzino.row){
        			tuttiAccessoriOrdinePresenti = false // accessori mancanti dal magazzino
        		}

        		// Per ogni accessorio prenoto la qta richiesta oppure quella disponibile
        		for ( i = 0, i < #accessoriOrdineMagazzino.row, i++ ) {
        			qta_ancora_necessaria = accessoriOrdineMagazzino.row[i].qta_ancora_necessaria;
        			qta_disponibile = accessoriOrdineMagazzino.row[i].qta_disponibile;
		            qta_mancante = qta_ancora_necessaria - qta_disponibile;

		            idMagazzino = accessoriOrdineMagazzino.row[i].idMagazzino;
		            idAccessorio = accessoriOrdineMagazzino.row[i].idAccessorio;

		            if(qta_disponibile >= qta_ancora_necessaria){
		           		qta_prenotabile = qta_ancora_necessaria
		           	} else { // qta_disponibile < qta_ancora_necessaria
		           		qta_prenotabile = qta_disponibile;
		            	tuttiAccessoriOrdinePresenti = false // quantità accessori richiesta mancate dal magazzino
		           	}

		           	println@Console("Il magazzino #" + idMagazzino + " possiede "+qta_disponibile+" qta su "+qta_ancora_necessaria+" qta ancora necessarie ("+qta_prenotabile+" prenotabili) dell'accessorio #"+idAccessorio+" per l'ordine #" + idOrdine)();

		            if(qta_prenotabile > 0) {
		            	query = "INSERT INTO Magazzino_accessorio_prenotato
				            	(idOrdine, idMagazzino, idAccessorio, quantita)
				            	VALUES
				            	(" + idOrdine + ", " + idMagazzino + ", " + idAccessorio + ", " + qta_prenotabile + ")";
						update@Database( query )( responseNewPrenotazioneAccessorio );
						println@Console("Prenoto " + qta_prenotabile + " qta dell'accessorio #" + idAccessorio + " nel magazzino #" + idMagazzino + " per l'ordine #" + idOrdine)();

						query = "UPDATE magazzino_has_accessorio
								 SET quantita = quantita - " + qta_prenotabile + "
								 WHERE idMagazzino = " + idMagazzino + " AND idAccessorio = " + idAccessorio;
						update@Database( query )( responseScaloQtaMagazzino );
						println@Console("Ho scalato " + qta_prenotabile + " qta dell'accessorio #" + idAccessorio + " dal magazzino #" + idMagazzino + " poiche' prenotate")()
		            }

		            println@Console("\n")()
		        }
	        }

	        // Componenti

	        query = "SELECT *
					 FROM ordine_has_ciclo
					 LEFT JOIN ciclo_has_componente ON ordine_has_ciclo.idCiclo = ciclo_has_componente.idCiclo
					 WHERE idOrdine = " + idOrdine;
        	query@Database( query )( componentiOrdine );

        	if ( #componentiOrdine.row > 0 ) {
	        	// Elenco dei componenti presenti nel magazzino per uno specifico ordine (che non sono ancora stati prenotati)
	        	query = "SELECT
							ordine_has_ciclo.idOrdine,
							ordine_has_ciclo.idCiclo,
							ordine_has_ciclo.quantitaCiclo AS qta_ciclo,
						    ciclo_has_componente.idComponente,
							magazzino_has_componente.idMagazzino,
							(ordine_has_ciclo.quantitaCiclo - CASE WHEN SUM(magazzino_componente_prenotato.quantita) IS NULL THEN 0 ELSE SUM(magazzino_componente_prenotato.quantita) END) AS qta_ancora_necessaria,
							magazzino_has_componente.idMagazzino,
							magazzino_has_componente.quantita AS qta_disponibile,
							SUM(magazzino_componente_prenotato.quantita) AS qta_prenotata
						FROM ordine_has_ciclo
						LEFT JOIN ciclo_has_componente ON ordine_has_ciclo.idCiclo = ciclo_has_componente.idCiclo
						LEFT JOIN magazzino_componente_prenotato ON ordine_has_ciclo.idOrdine = magazzino_componente_prenotato.idOrdine AND 
																	ciclo_has_componente.idComponente = magazzino_componente_prenotato.idComponente
						LEFT JOIN magazzino_has_componente ON ciclo_has_componente.idComponente = magazzino_has_componente.idComponente
						WHERE ordine_has_ciclo.idOrdine = " + idOrdine + " AND magazzino_has_componente.idMagazzino = " + ID_MAGAZZINO + " AND 
						(
							magazzino_componente_prenotato.quantita < ordine_has_ciclo.quantitaCiclo OR 
							magazzino_componente_prenotato.quantita IS NULL
						)
						GROUP BY ordine_has_ciclo.idOrdine, ordine_has_ciclo.idCiclo,magazzino_has_componente.idComponente";
        		query@Database( query )( componentiOrdineMagazzino );

        		if(#componentiOrdine.row != #componentiOrdineMagazzino.row){
        			tuttiComponentiOrdinePresenti = false // componenti mancanti dal magazzino
        		}

        		// Per ogni componente prenoto la qta necessaria
        		for ( i = 0, i < #componentiOrdineMagazzino.row, i++ ) {
        			qta_ancora_necessaria = componentiOrdineMagazzino.row[i].qta_ancora_necessaria;
		            idCiclo = componentiOrdineMagazzino.row[i].idCiclo;
		            qta_ciclo = componentiOrdineMagazzino.row[i].qta_ciclo;
		            idMagazzino = componentiOrdineMagazzino.row[i].idMagazzino;
		            idComponente = componentiOrdineMagazzino.row[i].idComponente;

		            // Reperisco la disponibilità attuale perchè in caso di ordini con più cicli che hanno
		            // in comune uno stesso componente, questo potrebbe essere già stato prenotato prima
		            // e quindi la sua diponibilità essere variata.
		            query = "SELECT quantita 
							 FROM magazzino_has_componente 
							 WHERE idMagazzino = " + idMagazzino + " AND idComponente = " + idComponente;
					query@Database( query )( responseQtaAttuale );
					qta_disponibile = responseQtaAttuale.row[0].quantita;

		            if(qta_disponibile >= qta_ancora_necessaria){
		           		qta_prenotabile = qta_ancora_necessaria
		           	} else { // qta_disponibile < qta_ancora_necessaria
		           		qta_prenotabile = qta_disponibile
		            	tuttiComponentiOrdinePresenti = false // quantità componenti richiesta mancate dal magazzino
		           	}

		           	println@Console("Il magazzino #" + idMagazzino + " possiede "+qta_disponibile+" qta su "+qta_ancora_necessaria+" qta ancora necessarie ("+qta_prenotabile+" prenotabili) del componente #"+idComponente+" per l'ordine #" + idOrdine)();

		            if(qta_prenotabile > 0) {

		            	query = "INSERT INTO magazzino_componente_prenotato
				            	(idOrdine, idMagazzino, idCiclo, idComponente, quantita)
				            	VALUES
				            	(" + idOrdine + ", " + idMagazzino + ", " + idCiclo + ", " + idComponente + ", " + qta_prenotabile + ")";
						update@Database( query )( responseNewPrenotazioneComponente );
						println@Console("Prenoto " + qta_prenotabile + " qta del componente #" + idComponente + " (ciclo #"+idCiclo+") nel magazzino #" + idMagazzino + " per l'ordine #" + idOrdine)();

						query = "UPDATE magazzino_has_componente
								 SET quantita = quantita - " + qta_prenotabile + "
								 WHERE idMagazzino = " + idMagazzino + " AND idComponente = " + idComponente;
						update@Database( query )( responseScaloQtaMagazzino );
						println@Console("Ho scalato " + qta_prenotabile + " qta del componente #" + idComponente + " dal magazzino #" + idMagazzino + " poiche' prenotate")()
		            }

		            println@Console("\n")()
		        }
	        }

	        // Response

	        if ( tuttiAccessoriOrdinePresenti && tuttiComponentiOrdinePresenti ) {
	        	response.tuttiMaterialiRichiestiPresenti = true;
	        	response.message = "Nel magazzino #"+ID_MAGAZZINO+" sono presenti tutti i componenti/accessori richiesti dall'ordine #" + idOrdine
	        } else {
				response.tuttiMaterialiRichiestiPresenti = false;
				response.message = "Nel magazzino #"+ID_MAGAZZINO+" NON sono presenti tutti i componenti/accessori richiesti dall'ordine #" + idOrdine
	        }

	        println@Console(response.message + "\n")()
	    }
	] {
		println@Console("[verificaDisponibilitaComponentiAccessori] COMPLETED")()
	}

	[
		distanceFromRivenditore ( indirizzoRivenditore )( distance ) {

			query = "SELECT indirizzo
					 FROM Magazzino
					 WHERE idMagazzino = " + ID_MAGAZZINO;
			query@Database( query )( indirizzoMagazzino );
			
			request.from = indirizzoMagazzino.row[0].indirizzo;
			request.to = indirizzoRivenditore;
			request.unit = "k";

			println@Console("request.from: " + request.from)();
			println@Console("request.to: " + request.to)();

			distanceBetween@GISService(request)(response);
			distance = response.distance;
			println@Console("Il magazzino #" + ID_MAGAZZINO + " dista " + distance + "km dal rivenditore " + indirizzoRivenditore)()
	    }
	] {
		println@Console("[distanceFromRivenditore] COMPLETED")()
	}
}
